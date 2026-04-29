import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/trip_model.dart';

/// Persists trips locally using Hive
class TripStorage {
  static const _boxName = 'trips';
  static String _scope = 'guest';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  static String get _prefix => '$_scope:';

  static void setUserScope(String? userId) {
    _scope = (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  /// Save a trip
  static Future<void> saveTrip(Trip trip) async {
    await _box.put('$_prefix${trip.id}', jsonEncode(trip.toJson()));
  }

  /// Load all trips
  static List<Trip> loadTrips() {
    final trips = <Trip>[];
    for (final key in _box.keys) {
      if (!key.toString().startsWith(_prefix)) continue;
      final json = _box.get(key);
      if (json != null) {
        try {
          trips.add(Trip.fromJson(jsonDecode(json)));
        } catch (_) {}
      }
    }
    // Sort by created date (newest first)
    trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trips;
  }

  /// Delete a trip
  static Future<void> deleteTrip(String id) async {
    await _box.delete('$_prefix$id');
  }

  /// Clear all
  static Future<void> clearTrips() async {
    final scopedKeys = _box.keys
        .where((key) => key.toString().startsWith(_prefix))
        .toList();
    await _box.deleteAll(scopedKeys);
  }

  /// Clear every user's local trip data. Used on explicit sign-out.
  static Future<void> clearAllTrips() async {
    await _box.clear();
  }
}
