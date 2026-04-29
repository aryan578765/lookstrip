import 'package:dio/dio.dart';
import 'package:lookstrip/core/models/weather_model.dart';
import 'package:lookstrip/core/services/geocoding_service.dart';

/// Open-Meteo weather service. No API key required.
class WeatherService {
  static final WeatherService _instance = WeatherService._();
  factory WeatherService() => _instance;
  WeatherService._();

  final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.open-meteo.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<WeatherDay>> getForecast(String destination) async {
    final coords = await GeocodingService.instance.resolve(destination);
    if (coords == null) return [];

    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': coords.$1,
          'longitude': coords.$2,
          'daily':
              'temperature_2m_max,temperature_2m_min,weathercode,precipitation_sum',
          'timezone': 'auto',
          'forecast_days': 7,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final daily = data['daily'] as Map<String, dynamic>;
        final dates = daily['time'] as List<dynamic>;
        final maxTemps = daily['temperature_2m_max'] as List<dynamic>;
        final minTemps = daily['temperature_2m_min'] as List<dynamic>;
        final codes = daily['weathercode'] as List<dynamic>;
        final precip = daily['precipitation_sum'] as List<dynamic>;

        return List.generate(
          dates.length,
          (i) => WeatherDay(
            date: DateTime.parse(dates[i] as String),
            tempMax: (maxTemps[i] as num).toDouble(),
            tempMin: (minTemps[i] as num).toDouble(),
            weatherCode: codes[i] as int,
            precipitationMm: (precip[i] as num).toDouble(),
          ),
        );
      }
    } catch (_) {}
    return [];
  }
}
