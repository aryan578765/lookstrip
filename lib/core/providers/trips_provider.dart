import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/services/trip_storage.dart';
import 'package:lookstrip/core/services/trip_ai_service.dart';
import 'package:lookstrip/core/services/supabase_sync_service.dart';
import 'package:lookstrip/core/services/supabase_service.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';

/// Trips state
class TripsState {
  final List<Trip> trips;
  final String activeTab; // upcoming, past, all
  final bool isGenerating; // AI is creating itinerary
  final String? generatingMessage;
  final String? generationNotice;
  final bool isSyncing;

  const TripsState({
    this.trips = const [],
    this.activeTab = 'upcoming',
    this.isGenerating = false,
    this.generatingMessage,
    this.generationNotice,
    this.isSyncing = false,
  });

  TripsState copyWith({
    List<Trip>? trips,
    String? activeTab,
    bool? isGenerating,
    String? generatingMessage,
    String? generationNotice,
    bool? isSyncing,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      activeTab: activeTab ?? this.activeTab,
      isGenerating: isGenerating ?? this.isGenerating,
      generatingMessage: generatingMessage == null
          ? this.generatingMessage
          : generatingMessage.isEmpty
          ? null
          : generatingMessage,
      generationNotice: generationNotice == null
          ? this.generationNotice
          : generationNotice.isEmpty
          ? null
          : generationNotice,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  List<Trip> get filteredTrips {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    bool isPast(Trip trip) =>
        trip.status == 'past' || trip.endDate.isBefore(startOfToday);

    switch (activeTab) {
      case 'upcoming':
        return trips.where((t) => !isPast(t)).toList();
      case 'past':
        return trips.where(isPast).toList();
      default:
        return trips;
    }
  }

  bool get isEmpty => trips.isEmpty;
}

/// Trips notifier — dual-writes to Hive + Supabase
class TripsNotifier extends StateNotifier<TripsState> {
  final Ref _ref;
  final TripAiService _aiService = TripAiService();
  final SupabaseSyncService _syncService = SupabaseSyncService();
  CancelToken? _generationCancelToken;

  TripsNotifier(this._ref) : super(const TripsState()) {
    _loadTrips();
    _cloudSync(); // background cloud sync on startup
  }

  void _loadTrips() {
    final trips = TripStorage.loadTrips();
    state = state.copyWith(trips: trips);
  }

  /// Background cloud sync
  Future<void> _cloudSync() async {
    final userId = SupabaseService.maybeClient?.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isSyncing: true);
    try {
      final merged = await _syncService.fullSync();
      state = state.copyWith(trips: merged, isSyncing: false);
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }

  /// Manual sync trigger
  Future<void> syncNow() async => _cloudSync();

  void setTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  /// Add trip — dual write to Hive + Supabase
  Future<void> addTrip(Trip trip) async {
    final userId = SupabaseService.maybeClient?.auth.currentUser?.id;
    final tripWithUser = trip.copyWith(userId: userId);

    // 1. Save locally (instant)
    await TripStorage.saveTrip(tripWithUser);
    _loadTrips();

    // 2. Sync to cloud (async, non-blocking)
    _syncService.syncTrip(tripWithUser);
  }

  /// Update trip — dual write
  Future<void> updateTrip(Trip trip) async {
    final updated = trip.copyWith(updatedAt: DateTime.now());
    await TripStorage.saveTrip(updated);
    _loadTrips();
    _syncService.syncTrip(updated);
  }

  /// Delete trip — dual delete
  Future<void> deleteTrip(String id) async {
    await TripStorage.deleteTrip(id);
    _loadTrips();
    _syncService.deleteTrip(id);
  }

  /// Create a trip with AI-generated itinerary
  Future<bool> createTrip({
    required String destination,
    required String emoji,
    required int days,
  }) async {
    _generationCancelToken?.cancel('Starting a new trip generation');
    _generationCancelToken = CancelToken();
    state = state.copyWith(
      isGenerating: true,
      generatingMessage: 'AI is planning your $destination trip...',
      generationNotice: '',
    );

    try {
      // Get user travel styles for personalization
      final user = _ref.read(currentUserProvider);
      final travelStyle = user?.travelStyles.join(', ');

      // Generate real AI itinerary
      final itinerary = await _aiService.generateItinerary(
        destination: destination,
        days: days,
        travelStyle: travelStyle,
        cancelToken: _generationCancelToken,
      );
      if (_generationCancelToken?.isCancelled == true) return false;

      final now = DateTime.now();
      final userId = SupabaseService.maybeClient?.auth.currentUser?.id;
      final trip = Trip(
        id: 'trip-${now.millisecondsSinceEpoch}',
        userId: userId,
        title: '$days Days in $destination',
        destination: destination,
        emoji: emoji,
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(Duration(days: 13 + days)),
        status: 'upcoming',
        days: days,
        itinerary: itinerary,
        createdAt: now,
      );

      await addTrip(trip);
      if (_aiService.lastUsedFallback) {
        state = state.copyWith(
          generationNotice:
              'The live AI request failed, so LooksTrip created an offline fallback itinerary.',
        );
      }
      return true;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = state.copyWith(generationNotice: 'Trip generation cancelled.');
        return false;
      }
      state = state.copyWith(generationNotice: 'Trip generation failed.');
      return false;
    } catch (_) {
      state = state.copyWith(generationNotice: 'Trip generation failed.');
      return false;
    } finally {
      state = state.copyWith(isGenerating: false, generatingMessage: '');
    }
  }

  void cancelGeneration() {
    _generationCancelToken?.cancel('User cancelled trip generation');
    state = state.copyWith(
      isGenerating: false,
      generatingMessage: '',
      generationNotice: 'Trip generation cancelled.',
    );
  }
}

/// Provider
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  return TripsNotifier(ref);
});
