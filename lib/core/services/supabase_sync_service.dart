import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/services/supabase_service.dart';
import 'package:lookstrip/core/services/trip_storage.dart';

/// Syncs trips between local Hive storage and Supabase cloud
class SupabaseSyncService {
  String? get _userId => SupabaseService.maybeClient?.auth.currentUser?.id;

  List<Map<String, dynamic>> _itineraryPayload(Trip trip) {
    final items = <Map<String, dynamic>>[];
    for (final day in trip.itinerary) {
      for (var i = 0; i < day.activities.length; i++) {
        final act = day.activities[i];
        items.add({
          'trip_id': trip.id,
          'day_number': day.dayNumber,
          'day_title': day.title,
          'time': act.time,
          'title': act.title,
          'description': act.description,
          'emoji': act.emoji,
          'sort_order': i,
        });
      }
    }
    return items;
  }

  /// Upsert a trip + its itinerary items to Supabase
  Future<void> syncTrip(Trip trip) async {
    final client = SupabaseService.maybeClient;
    final userId = _userId;
    if (client == null || userId == null) return;

    try {
      final tripWithUser = trip.copyWith(userId: userId, isSynced: true);
      final items = _itineraryPayload(tripWithUser);

      await client.rpc(
        'sync_trip_with_itinerary',
        params: {
          'trip_payload': tripWithUser.toSupabase(),
          'itinerary_payload': items,
        },
      );

      await TripStorage.saveTrip(tripWithUser);
    } catch (e) {
      // Offline or error — keep local, retry later
      await TripStorage.saveTrip(trip.copyWith(isSynced: false));
    }
  }

  /// Delete a trip from Supabase (cascade deletes itinerary, expenses, etc.)
  Future<void> deleteTrip(String tripId) async {
    final client = SupabaseService.maybeClient;
    if (client == null || _userId == null) return;
    try {
      await client.from('trips').delete().eq('id', tripId);
    } catch (_) {
      // Ignore — local delete already happened
    }
  }

  /// Fetch all trips from Supabase for the current user
  Future<List<Trip>> fetchCloudTrips() async {
    final client = SupabaseService.maybeClient;
    if (client == null || _userId == null) return [];

    try {
      // Get trips (own + collaborated)
      final tripsData = await client
          .from('trips')
          .select()
          .order('created_at', ascending: false);

      // Get all itinerary items for those trips
      final tripIds = (tripsData as List)
          .map((t) => t['id'] as String)
          .toList();
      if (tripIds.isEmpty) return [];

      final itineraryData = await client
          .from('itinerary_items')
          .select()
          .inFilter('trip_id', tripIds)
          .order('day_number')
          .order('sort_order');

      // Group itinerary items by trip
      final itineraryByTrip = <String, List<Map<String, dynamic>>>{};
      for (final item in itineraryData as List) {
        final tripId = item['trip_id'] as String;
        itineraryByTrip.putIfAbsent(tripId, () => []).add(item);
      }

      // Build Trip objects
      return tripsData.map<Trip>((row) {
        final tripId = row['id'] as String;
        final rawItems = itineraryByTrip[tripId] ?? [];

        // Group by day_number
        final dayMap = <int, List<Map<String, dynamic>>>{};
        for (final item in rawItems) {
          final dayNum = item['day_number'] as int;
          dayMap.putIfAbsent(dayNum, () => []).add(item);
        }

        final itinerary = dayMap.entries.map((entry) {
          final activities = entry.value
              .map(
                (a) => TripActivity(
                  time: a['time'] as String? ?? '',
                  title: a['title'] as String,
                  description: a['description'] as String? ?? '',
                  emoji: a['emoji'] as String? ?? '📍',
                ),
              )
              .toList();
          return TripDay(
            dayNumber: entry.key,
            title:
                entry.value.first['day_title'] as String? ?? 'Day ${entry.key}',
            activities: activities,
          );
        }).toList()..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

        return Trip.fromSupabase(row, itinerary: itinerary);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Merge cloud trips with local trips (latest updatedAt wins)
  List<Trip> mergeTrips(List<Trip> cloud, List<Trip> local) {
    final merged = <String, Trip>{};

    // Start with local
    for (final trip in local) {
      merged[trip.id] = trip;
    }

    // Merge cloud — cloud wins if newer
    for (final trip in cloud) {
      final existing = merged[trip.id];
      if (existing != null && !existing.isSynced) {
        // Preserve offline edits until a future push succeeds.
        continue;
      }
      if (existing == null || trip.updatedAt.isAfter(existing.updatedAt)) {
        merged[trip.id] = trip;
      }
    }

    final result = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Sync all unsynced local trips to cloud
  Future<void> syncAllPending() async {
    if (SupabaseService.maybeClient == null || _userId == null) return;

    final local = TripStorage.loadTrips();
    for (final trip in local) {
      if (!trip.isSynced) {
        await syncTrip(trip);
      }
    }
  }

  /// Full sync: push pending + pull cloud + merge
  Future<List<Trip>> fullSync() async {
    await syncAllPending();
    final cloud = await fetchCloudTrips();
    final local = TripStorage.loadTrips();
    final merged = mergeTrips(cloud, local);
    final cloudIds = cloud.map((trip) => trip.id).toSet();

    // Save merged list locally
    for (final trip in merged) {
      await TripStorage.saveTrip(
        cloudIds.contains(trip.id) && trip.isSynced
            ? trip.copyWith(isSynced: true)
            : trip,
      );
    }

    return merged;
  }
}
