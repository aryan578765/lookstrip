import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/services/connectivity_service.dart';
import 'package:lookstrip/core/services/supabase_sync_service.dart';

/// Streams connectivity status — true = online, false = offline
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ConnectivityService();
  service.startMonitoring();
  ref.onDispose(() => service.stopMonitoring());
  return service.onConnectivityChanged;
});

/// Simple bool check for current connectivity
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (online) => online,
    loading: () => true, // assume online while checking
    error: (_, _) => true,
  );
});

/// Auto-sync when coming back online
final autoSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
    final wasOffline = prev?.valueOrNull == false;
    final isNowOnline = next.valueOrNull == true;
    if (wasOffline && isNowOnline) {
      // Back online — sync pending trips
      SupabaseSyncService().syncAllPending();
    }
  });
});
