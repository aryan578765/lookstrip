import 'dart:async';
import 'dart:io';

/// Monitors network connectivity and exposes a stream
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool _lastKnown = true;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Current status
  bool get isOnline => _lastKnown;

  /// Start periodic connectivity checks
  void startMonitoring() {
    _checkNow();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkNow());
  }

  /// Stop monitoring
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkNow() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (online != _lastKnown) {
        _lastKnown = online;
        _controller.add(online);
      }
    } on SocketException catch (_) {
      if (_lastKnown) {
        _lastKnown = false;
        _controller.add(false);
      }
    } on TimeoutException catch (_) {
      if (_lastKnown) {
        _lastKnown = false;
        _controller.add(false);
      }
    }
  }

  void dispose() {
    stopMonitoring();
    _controller.close();
  }
}
