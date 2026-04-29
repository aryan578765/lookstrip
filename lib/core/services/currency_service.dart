import 'package:dio/dio.dart';

/// Free currency exchange rates (no API key needed)
class CurrencyService {
  static final CurrencyService _instance = CurrencyService._();
  factory CurrencyService() => _instance;
  CurrencyService._();

  final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://open.er-api.com/v6',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // In-memory cache
  final Map<String, _CachedRate> _rateCache = {};

  /// Get exchange rate from → to
  Future<double?> getRate(String from, String to) async {
    if (from == to) return 1.0;

    final key = '${from}_$to';
    final cached = _rateCache[key];
    if (cached != null && !cached.isExpired) return cached.rate;

    try {
      final response = await _dio.get('/latest/${from.toUpperCase()}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>?;
        if (rates != null) {
          final rate = (rates[to.toUpperCase()] as num?)?.toDouble();
          if (rate != null) {
            _rateCache[key] = _CachedRate(rate: rate);
            return rate;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Convert amount from one currency to another
  Future<double?> convert(double amount, String from, String to) async {
    final rate = await getRate(from, to);
    if (rate == null) return null;
    return amount * rate;
  }

  // Country → currency code mapping
  static const destinationCurrency = {
    'japan': 'JPY',
    'tokyo': 'JPY',
    'kyoto': 'JPY',
    'indonesia': 'IDR',
    'bali': 'IDR',
    'france': 'EUR',
    'paris': 'EUR',
    'greece': 'EUR',
    'santorini': 'EUR',
    'usa': 'USD',
    'new york': 'USD',
    'maldives': 'MVR',
    'spain': 'EUR',
    'barcelona': 'EUR',
    'switzerland': 'CHF',
    'swiss alps': 'CHF',
    'south africa': 'ZAR',
    'cape town': 'ZAR',
    'australia': 'AUD',
    'sydney': 'AUD',
    'south korea': 'KRW',
    'seoul': 'KRW',
    'morocco': 'MAD',
    'marrakech': 'MAD',
    'uae': 'AED',
    'dubai': 'AED',
    'uk': 'GBP',
    'london': 'GBP',
    'italy': 'EUR',
    'rome': 'EUR',
    'thailand': 'THB',
    'bangkok': 'THB',
    'india': 'INR',
    'mumbai': 'INR',
    'singapore': 'SGD',
    'turkey': 'TRY',
    'istanbul': 'TRY',
  };

  /// Get currency code for a destination
  static String getCurrencyFor(String destination) {
    final key = destination.toLowerCase().trim();
    if (destinationCurrency.containsKey(key)) return destinationCurrency[key]!;
    for (final entry in destinationCurrency.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return 'USD';
  }
}

class _CachedRate {
  final double rate;
  final DateTime cachedAt;

  _CachedRate({required this.rate}) : cachedAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(cachedAt).inHours >= 24;
}
