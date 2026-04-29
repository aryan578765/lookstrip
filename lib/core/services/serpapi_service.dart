import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/flight_model.dart';
import 'package:lookstrip/core/models/hotel_model.dart';
import 'package:lookstrip/core/models/place_models.dart';
import 'package:lookstrip/core/services/backend_proxy_service.dart';

/// Unified SerpApi service with TTL caching.
class SerpApiService {
  static final SerpApiService _instance = SerpApiService._();
  factory SerpApiService() => _instance;
  SerpApiService._();

  final BackendProxyService _proxy = BackendProxyService.instance;
  static String _scope = 'guest';

  static const _flightCodes = <String, String>{
    'delhi': 'DEL',
    'new delhi': 'DEL',
    'tokyo': 'TYO',
    'bali': 'DPS',
    'paris': 'PAR',
    'santorini': 'JTR',
    'new york': 'NYC',
    'maldives': 'MLE',
    'barcelona': 'BCN',
    'swiss alps': 'ZRH',
    'cape town': 'CPT',
    'sydney': 'SYD',
    'seoul': 'SEL',
    'marrakech': 'RAK',
    'phuket': 'HKT',
    'cancun': 'CUN',
    'rio de janeiro': 'GIG',
    'rio': 'GIG',
    'banff': 'YYC',
    'queenstown': 'ZQN',
    'dubai': 'DXB',
    'london': 'LON',
    'rome': 'ROM',
    'bangkok': 'BKK',
    'mumbai': 'BOM',
    'singapore': 'SIN',
    'istanbul': 'IST',
    'kyoto': 'OSA',
    'lisbon': 'LIS',
    'amsterdam': 'AMS',
    'machu picchu': 'CUZ',
    'cusco': 'CUZ',
    'petra': 'AMM',
    'reykjavik': 'KEF',
    'hanoi': 'HAN',
  };

  static const _flightCacheTtl = 120;
  static const _hotelCacheTtl = 240;
  static const _restaurantCacheTtl = 1440;
  static const _attractionCacheTtl = 10080;

  static Future<void> init() async {
    await Hive.openBox<String>('serp_cache');
  }

  static void setUserScope(String? userId) {
    _scope = (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  static Future<void> clearAllCache() async {
    await Hive.box<String>('serp_cache').clear();
  }

  Box<String> get _cache => Hive.box<String>('serp_cache');

  Map<String, dynamic>? _getFromCache(String key, int ttlMinutes) {
    final raw = _cache.get(key);
    if (raw == null) return null;

    try {
      final cached = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = cached['_timestamp'] as int? ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > ttlMinutes * 60 * 1000) return null;
      return cached;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    final cached = Map<String, dynamic>.from(data)
      ..['_timestamp'] = DateTime.now().millisecondsSinceEpoch;
    await _cache.put(key, jsonEncode(cached));
  }

  Future<Map<String, dynamic>?> _request(
    Map<String, String> params,
    String cacheKey,
    int cacheTtl,
  ) async {
    final scopedCacheKey = '$_scope:$cacheKey';
    final cached = _getFromCache(scopedCacheKey, cacheTtl);
    if (cached != null) return cached;

    if (!_proxy.isConfigured) return null;

    try {
      final data = await _proxy.serpSearch(params);
      if (data != null) {
        await _saveToCache(scopedCacheKey, data);
        return data;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        final raw = _cache.get(scopedCacheKey);
        if (raw != null) {
          try {
            return jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
    }
    return null;
  }

  Future<List<Flight>> searchFlights({
    required String from,
    required String to,
    required String date,
    String? returnDate,
    int adults = 1,
    int children = 0,
  }) async {
    final fromCode = _flightCodeFor(from);
    final toCode = _flightCodeFor(to);
    final cacheKey =
        'flights_${fromCode}_${toCode}_${date}_${returnDate ?? 'oneway'}_${adults}_$children';
    final params = {
      'engine': 'google_flights',
      'departure_id': fromCode,
      'arrival_id': toCode,
      'outbound_date': date,
      'currency': 'USD',
      'hl': 'en',
      'type': returnDate != null ? '1' : '2',
      'adults': adults.toString(),
    };
    if (returnDate != null) params['return_date'] = returnDate;
    if (children > 0) params['children'] = children.toString();

    final data = await _request(params, cacheKey, _flightCacheTtl);
    if (data == null) return [];

    final bestFlights = data['best_flights'] as List<dynamic>? ?? [];
    final otherFlights = data['other_flights'] as List<dynamic>? ?? [];
    final allFlights = [...bestFlights, ...otherFlights];

    return allFlights
        .take(10)
        .map((f) => Flight.fromSerpApi(f as Map<String, dynamic>))
        .where((f) => f.price > 0)
        .toList();
  }

  Future<List<Hotel>> searchHotels({
    required String destination,
    required String checkIn,
    required String checkOut,
  }) async {
    final cacheKey = 'hotels_${_cacheToken(destination)}_${checkIn}_$checkOut';
    final params = {
      'engine': 'google_hotels',
      'q': '$destination hotels',
      'check_in_date': checkIn,
      'check_out_date': checkOut,
      'currency': 'USD',
      'hl': 'en',
    };

    final data = await _request(params, cacheKey, _hotelCacheTtl);
    if (data == null) return [];

    final properties = data['properties'] as List<dynamic>? ?? [];
    return properties
        .take(10)
        .map((h) => Hotel.fromSerpApi(h as Map<String, dynamic>))
        .toList();
  }

  Future<List<Restaurant>> searchRestaurants({
    required String destination,
  }) async {
    final cacheKey = 'restaurants_${_cacheToken(destination)}';
    final params = {
      'engine': 'google_maps',
      'q': 'restaurants in $destination',
      'hl': 'en',
      'type': 'search',
    };

    final data = await _request(params, cacheKey, _restaurantCacheTtl);
    if (data == null) return [];

    final places = data['local_results'] as List<dynamic>? ?? [];
    return places
        .take(10)
        .map((r) => Restaurant.fromSerpApi(r as Map<String, dynamic>))
        .where((r) => r.rating > 0)
        .toList();
  }

  Future<List<Attraction>> searchAttractions({
    required String destination,
  }) async {
    final cacheKey = 'attractions_${_cacheToken(destination)}';
    final params = {
      'engine': 'google_maps',
      'q': 'things to do in $destination',
      'hl': 'en',
      'type': 'search',
    };

    final data = await _request(params, cacheKey, _attractionCacheTtl);
    if (data == null) return [];

    final places = data['local_results'] as List<dynamic>? ?? [];
    return places
        .take(10)
        .map((a) => Attraction.fromSerpApi(a as Map<String, dynamic>))
        .where((a) => a.rating > 0)
        .toList();
  }

  String _flightCodeFor(String value) {
    final trimmed = value.trim();
    if (RegExp(r'^[A-Za-z]{3}$').hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }

    final key = trimmed.toLowerCase();
    if (_flightCodes.containsKey(key)) return _flightCodes[key]!;

    for (final entry in _flightCodes.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    return trimmed.toUpperCase();
  }

  String _cacheToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }
}
