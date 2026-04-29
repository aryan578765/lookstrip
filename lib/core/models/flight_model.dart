/// Flight search result from SerpApi
class Flight {
  final String airline;
  final String airlineLogo;
  final String departureTime;
  final String arrivalTime;
  final String departureAirport;
  final String arrivalAirport;
  final int stops;
  final String duration;
  final double price;
  final String currency;
  final String bookingUrl;

  const Flight({
    required this.airline,
    this.airlineLogo = '',
    required this.departureTime,
    required this.arrivalTime,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.stops,
    required this.duration,
    required this.price,
    this.currency = 'USD',
    this.bookingUrl = '',
  });

  factory Flight.fromSerpApi(Map<String, dynamic> json) {
    // SerpApi google_flights structure
    final flights = json['flights'] as List<dynamic>? ?? [];
    final firstLeg = flights.isNotEmpty
        ? flights[0] as Map<String, dynamic>
        : <String, dynamic>{};

    return Flight(
      airline: firstLeg['airline'] as String? ?? 'Unknown',
      airlineLogo: firstLeg['airline_logo'] as String? ?? '',
      departureTime: _extractTime(firstLeg['departure_airport']),
      arrivalTime: _extractTime(firstLeg['arrival_airport']),
      departureAirport: _extractAirportName(firstLeg['departure_airport']),
      arrivalAirport: _extractAirportName(firstLeg['arrival_airport']),
      stops: (json['layovers'] as List?)?.length ?? 0,
      duration: '${json['total_duration'] ?? 0} min',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: 'USD',
      bookingUrl: '',
    );
  }

  static String _extractTime(dynamic airport) {
    if (airport is Map<String, dynamic>) {
      return airport['time'] as String? ?? '';
    }
    return '';
  }

  static String _extractAirportName(dynamic airport) {
    if (airport is Map<String, dynamic>) {
      return airport['name'] as String? ?? airport['id'] as String? ?? '';
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
    'airline': airline,
    'airline_logo': airlineLogo,
    'departure_time': departureTime,
    'arrival_time': arrivalTime,
    'departure_airport': departureAirport,
    'arrival_airport': arrivalAirport,
    'stops': stops,
    'duration': duration,
    'price': price,
    'currency': currency,
    'booking_url': bookingUrl,
  };

  factory Flight.fromJson(Map<String, dynamic> json) => Flight(
    airline: json['airline'] as String? ?? '',
    airlineLogo: json['airline_logo'] as String? ?? '',
    departureTime: json['departure_time'] as String? ?? '',
    arrivalTime: json['arrival_time'] as String? ?? '',
    departureAirport: json['departure_airport'] as String? ?? '',
    arrivalAirport: json['arrival_airport'] as String? ?? '',
    stops: json['stops'] as int? ?? 0,
    duration: json['duration'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'USD',
    bookingUrl: json['booking_url'] as String? ?? '',
  );

  String get stopsLabel =>
      stops == 0 ? 'Nonstop' : '$stops stop${stops > 1 ? 's' : ''}';
}
