import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lookstrip/core/services/app_config.dart';

/// Centralized Supabase access so missing configuration does not crash startup.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured => AppConfig.hasSupabaseConfig;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (!isConfigured || _initialized) return;

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient? get maybeClient {
    if (!_initialized) return null;
    return Supabase.instance.client;
  }
}
