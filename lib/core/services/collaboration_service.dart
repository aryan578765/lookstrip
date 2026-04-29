import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lookstrip/core/services/supabase_service.dart';

/// Collaborator info
class Collaborator {
  final String id;
  final String tripId;
  final String userId;
  final String role; // owner, editor, viewer
  final DateTime joinedAt;
  final String? phone;

  const Collaborator({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.phone,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    id: json['id'] as String,
    tripId: json['trip_id'] as String,
    userId: json['user_id'] as String,
    role: json['role'] as String? ?? 'editor',
    joinedAt: DateTime.parse(json['joined_at'] as String),
    phone: json['phone'] as String?,
  );
}

/// Manages trip sharing and real-time collaboration
class CollaborationService {
  SupabaseClient? get _client => SupabaseService.maybeClient;

  String? get _userId => _client?.auth.currentUser?.id;

  RealtimeChannel? _tripChannel;
  RealtimeChannel? _itineraryChannel;

  /// Share a trip with another user by phone number
  Future<bool> shareTrip(
    String tripId,
    String phone, {
    String role = 'editor',
  }) async {
    final client = _client;
    if (client == null || _userId == null) return false;

    try {
      final inviteeId = await _findProfileIdByPhone(phone.trim());
      if (inviteeId == null || inviteeId == _userId) {
        return false;
      }

      await client.from('trip_collaborators').upsert({
        'trip_id': tripId,
        'user_id': inviteeId,
        'role': role,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _findProfileIdByPhone(String phone) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client.rpc(
        'find_profile_by_phone',
        params: {'target_phone': phone},
      );
      if (response is String && response.isNotEmpty) return response;
    } catch (_) {
      // Fall back for databases that have not installed the helper RPC yet.
    }

    try {
      final profile = await client
          .from('profiles')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      return profile?['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Add a collaborator directly by user ID
  Future<bool> addCollaborator(
    String tripId,
    String userId, {
    String role = 'editor',
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('trip_collaborators').upsert({
        'trip_id': tripId,
        'user_id': userId,
        'role': role,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get all collaborators for a trip
  Future<List<Collaborator>> getCollaborators(String tripId) async {
    final client = _client;
    if (client == null) return [];
    try {
      final data = await client
          .from('trip_collaborators')
          .select()
          .eq('trip_id', tripId);

      return (data as List).map((row) => Collaborator.fromJson(row)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Remove a collaborator
  Future<void> removeCollaborator(String tripId, String collabId) async {
    final client = _client;
    if (client == null) return;
    await client.from('trip_collaborators').delete().eq('id', collabId);
  }

  /// Subscribe to real-time trip changes
  StreamSubscription<List<Map<String, dynamic>>>? subscribeTripChanges(
    String tripId,
    void Function(Map<String, dynamic> payload) onTripUpdate,
  ) {
    final client = _client;
    if (client == null) return null;
    _tripChannel?.unsubscribe();
    _tripChannel = client
        .channel('trip-$tripId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'trips',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: tripId,
          ),
          callback: (payload) {
            onTripUpdate(payload.newRecord);
          },
        )
        .subscribe();
    return null;
  }

  /// Subscribe to real-time itinerary changes for a trip
  void subscribeItineraryChanges(
    String tripId,
    void Function() onItineraryChange,
  ) {
    final client = _client;
    if (client == null) return;
    _itineraryChannel?.unsubscribe();
    _itineraryChannel = client
        .channel('itinerary-$tripId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'itinerary_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'trip_id',
            value: tripId,
          ),
          callback: (_) {
            onItineraryChange();
          },
        )
        .subscribe();
  }

  /// Unsubscribe from all realtime channels
  void dispose() {
    _tripChannel?.unsubscribe();
    _itineraryChannel?.unsubscribe();
  }
}
