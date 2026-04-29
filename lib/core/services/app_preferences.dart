import 'package:lookstrip/core/services/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static const _departureAirportKey = 'departure_airport';
  static const _currencyKey = 'preferred_currency';

  static Future<String> getDepartureAirport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_departureAirportKey) ??
        AppConfig.defaultDepartureAirport;
  }

  static Future<void> setDepartureAirport(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_departureAirportKey, value.trim().toUpperCase());
  }

  static Future<String> getPreferredCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'USD';
  }

  static Future<void> setPreferredCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, value.trim().toUpperCase());
  }
}
