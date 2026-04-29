import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration.
///
/// Production builds should pass values with --dart-define or
/// --dart-define-from-file. The optional dotenv load in main is only a local
/// development convenience and is not bundled as an app asset.
class AppConfig {
  AppConfig._();

  static const _backendProxyBaseUrl = String.fromEnvironment(
    'BACKEND_PROXY_BASE_URL',
  );
  static const _defaultDepartureAirport = String.fromEnvironment(
    'DEFAULT_DEPARTURE_AIRPORT',
  );
  static const _mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String _value(
    String compileTimeValue,
    String dotenvKey, {
    String fallback = '',
  }) {
    if (compileTimeValue.isNotEmpty) return compileTimeValue;
    try {
      return dotenv.env[dotenvKey] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static String get backendProxyBaseUrl =>
      _value(_backendProxyBaseUrl, 'BACKEND_PROXY_BASE_URL');

  static bool get hasBackendProxy => backendProxyBaseUrl.isNotEmpty;

  static String get defaultDepartureAirport => _value(
    _defaultDepartureAirport,
    'DEFAULT_DEPARTURE_AIRPORT',
    fallback: 'DEL',
  );

  static String get mapboxAccessToken =>
      _value(_mapboxAccessToken, 'MAPBOX_ACCESS_TOKEN');

  static String get supabaseUrl => _value(_supabaseUrl, 'SUPABASE_URL');

  static String get supabaseAnonKey =>
      _value(_supabaseAnonKey, 'SUPABASE_ANON_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasMapboxConfig => mapboxAccessToken.isNotEmpty;

  static List<String> get configurationIssues {
    final issues = <String>[];
    if (!hasBackendProxy) {
      issues.add(
        'Backend proxy is missing, so AI and live travel search are disabled.',
      );
    }
    if (!hasMapboxConfig) {
      issues.add('Mapbox token is missing, so destination maps are disabled.');
    }
    if (!hasSupabaseConfig) {
      issues.add(
        'Supabase config is missing, so auth, cloud sync, and sharing are disabled.',
      );
    }
    return issues;
  }

  static bool get hasRecommendedConfiguration => configurationIssues.isEmpty;
}
