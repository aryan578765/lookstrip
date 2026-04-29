import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/services/collaboration_service.dart';

/// Collaboration state
class CollabState {
  final List<Collaborator> collaborators;
  final bool isLoading;
  final String? error;

  const CollabState({
    this.collaborators = const [],
    this.isLoading = false,
    this.error,
  });

  CollabState copyWith({
    List<Collaborator>? collaborators,
    bool? isLoading,
    String? error,
  }) {
    return CollabState(
      collaborators: collaborators ?? this.collaborators,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Collaboration notifier for a specific trip
class CollabNotifier extends StateNotifier<CollabState> {
  final String tripId;
  final CollaborationService _service = CollaborationService();

  CollabNotifier(this.tripId) : super(const CollabState()) {
    loadCollaborators();
  }

  Future<void> loadCollaborators() async {
    state = state.copyWith(isLoading: true);
    try {
      final collabs = await _service.getCollaborators(tripId);
      state = state.copyWith(collaborators: collabs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> addByUserId(String userId, {String role = 'editor'}) async {
    final success = await _service.addCollaborator(tripId, userId, role: role);
    if (success) await loadCollaborators();
    return success;
  }

  Future<bool> shareByPhone(String phone, {String role = 'editor'}) async {
    final success = await _service.shareTrip(tripId, phone, role: role);
    if (success) await loadCollaborators();
    return success;
  }

  Future<void> remove(String collabId) async {
    await _service.removeCollaborator(tripId, collabId);
    await loadCollaborators();
  }

  /// Start listening for real-time changes
  void startRealtime(void Function() onTripChanged) {
    _service.subscribeItineraryChanges(tripId, onTripChanged);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Riverpod family provider — one per trip
final collabProvider =
    StateNotifierProvider.family<CollabNotifier, CollabState, String>(
      (ref, tripId) => CollabNotifier(tripId),
    );
