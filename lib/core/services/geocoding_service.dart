import 'package:dio/dio.dart';

class GeocodingService {
  GeocodingService._();

  static final GeocodingService instance = GeocodingService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://geocoding-api.open-meteo.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  final Map<String, (double, double)> _memoryCache = {};

  static const _knownCoords = <String, (double, double)>{
    'tokyo': (35.6762, 139.6503),
    'bali': (-8.3405, 115.0920),
    'paris': (48.8566, 2.3522),
    'santorini': (36.3932, 25.4615),
    'new york': (40.7128, -74.0060),
    'maldives': (3.2028, 73.2207),
    'barcelona': (41.3874, 2.1686),
    'swiss alps': (46.8182, 8.2275),
    'cape town': (-33.9249, 18.4241),
    'sydney': (-33.8688, 151.2093),
    'seoul': (37.5665, 126.9780),
    'marrakech': (31.6295, -7.9811),
    'phuket': (7.8804, 98.3923),
    'cancun': (21.1619, -86.8515),
    'rio de janeiro': (-22.9068, -43.1729),
    'banff': (51.1784, -115.5708),
    'queenstown': (-45.0312, 168.6626),
    'dubai': (25.2048, 55.2708),
    'london': (51.5074, -0.1278),
    'rome': (41.9028, 12.4964),
    'bangkok': (13.7563, 100.5018),
    'mumbai': (19.0760, 72.8777),
    'singapore': (1.3521, 103.8198),
    'istanbul': (41.0082, 28.9784),
    'kyoto': (35.0116, 135.7681),
    'lisbon': (38.7223, -9.1393),
    'amsterdam': (52.3676, 4.9041),
    'machu picchu': (-13.1631, -72.5450),
    'petra': (30.3285, 35.4414),
    'reykjavik': (64.1466, -21.9426),
    'cusco': (-13.5320, -71.9675),
    'hanoi': (21.0278, 105.8342),
  };

  Future<(double, double)?> resolve(String destination) async {
    final key = destination.toLowerCase().trim();
    if (key.isEmpty) return null;

    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    final known = _lookupKnown(key);
    if (known != null) {
      _memoryCache[key] = known;
      return known;
    }

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'name': destination,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
      );
      final results = response.data?['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      final coords = (
        (first['latitude'] as num).toDouble(),
        (first['longitude'] as num).toDouble(),
      );
      _memoryCache[key] = coords;
      return coords;
    } catch (_) {
      return null;
    }
  }

  (double, double)? _lookupKnown(String key) {
    if (_knownCoords.containsKey(key)) return _knownCoords[key];
    for (final entry in _knownCoords.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }
}
