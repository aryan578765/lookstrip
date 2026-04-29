import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lookstrip/core/models/flight_model.dart';
import 'package:lookstrip/core/models/hotel_model.dart';
import 'package:lookstrip/core/models/place_models.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/models/weather_model.dart';
import 'package:lookstrip/core/services/app_preferences.dart';
import 'package:lookstrip/core/services/app_config.dart';
import 'package:lookstrip/core/services/currency_service.dart';
import 'package:lookstrip/core/services/serpapi_service.dart';
import 'package:lookstrip/core/services/weather_service.dart';

/// State for trip detail screen.
class TripDetailData {
  final List<Flight> flights;
  final List<Hotel> hotels;
  final List<Restaurant> restaurants;
  final List<Attraction> attractions;
  final List<WeatherDay> weather;
  final double? exchangeRate;
  final String localCurrency;
  final bool isLoadingFlights;
  final bool isLoadingHotels;
  final bool isLoadingRestaurants;
  final bool isLoadingAttractions;
  final bool isLoadingWeather;
  final String? error;
  final String? flightError;
  final String? hotelError;
  final String? placesError;
  final String? weatherError;

  const TripDetailData({
    this.flights = const [],
    this.hotels = const [],
    this.restaurants = const [],
    this.attractions = const [],
    this.weather = const [],
    this.exchangeRate,
    this.localCurrency = 'USD',
    this.isLoadingFlights = false,
    this.isLoadingHotels = false,
    this.isLoadingRestaurants = false,
    this.isLoadingAttractions = false,
    this.isLoadingWeather = false,
    this.error,
    this.flightError,
    this.hotelError,
    this.placesError,
    this.weatherError,
  });

  TripDetailData copyWith({
    List<Flight>? flights,
    List<Hotel>? hotels,
    List<Restaurant>? restaurants,
    List<Attraction>? attractions,
    List<WeatherDay>? weather,
    double? exchangeRate,
    String? localCurrency,
    bool? isLoadingFlights,
    bool? isLoadingHotels,
    bool? isLoadingRestaurants,
    bool? isLoadingAttractions,
    bool? isLoadingWeather,
    String? error,
    String? flightError,
    String? hotelError,
    String? placesError,
    String? weatherError,
  }) {
    return TripDetailData(
      flights: flights ?? this.flights,
      hotels: hotels ?? this.hotels,
      restaurants: restaurants ?? this.restaurants,
      attractions: attractions ?? this.attractions,
      weather: weather ?? this.weather,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      localCurrency: localCurrency ?? this.localCurrency,
      isLoadingFlights: isLoadingFlights ?? this.isLoadingFlights,
      isLoadingHotels: isLoadingHotels ?? this.isLoadingHotels,
      isLoadingRestaurants: isLoadingRestaurants ?? this.isLoadingRestaurants,
      isLoadingAttractions: isLoadingAttractions ?? this.isLoadingAttractions,
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      error: error ?? this.error,
      flightError: flightError == null
          ? this.flightError
          : flightError.isEmpty
          ? null
          : flightError,
      hotelError: hotelError == null
          ? this.hotelError
          : hotelError.isEmpty
          ? null
          : hotelError,
      placesError: placesError == null
          ? this.placesError
          : placesError.isEmpty
          ? null
          : placesError,
      weatherError: weatherError == null
          ? this.weatherError
          : weatherError.isEmpty
          ? null
          : weatherError,
    );
  }

  bool get isLoading =>
      isLoadingFlights ||
      isLoadingHotels ||
      isLoadingRestaurants ||
      isLoadingAttractions ||
      isLoadingWeather;

  double get avgFlightPrice {
    if (flights.isEmpty) return 0;
    return flights.map((f) => f.price).reduce((a, b) => a + b) / flights.length;
  }

  double get avgHotelPerNight {
    if (hotels.isEmpty) return 0;
    return hotels.map((h) => h.pricePerNight).reduce((a, b) => a + b) /
        hotels.length;
  }
}

/// Fetches all external data for a trip detail screen.
class TripDetailNotifier extends StateNotifier<TripDetailData> {
  final SerpApiService _serpApi = SerpApiService();
  final WeatherService _weatherService = WeatherService();
  final CurrencyService _currencyService = CurrencyService();
  final Trip trip;

  TripDetailNotifier(this.trip) : super(const TripDetailData());

  final _fmt = DateFormat('yyyy-MM-dd');

  Future<void> loadAll() async {
    await Future.wait([
      loadWeather(),
      loadFlights(),
      loadHotels(),
      loadRestaurants(),
      loadAttractions(),
      loadCurrency(),
    ]);
  }

  Future<void> loadFlights() async {
    state = state.copyWith(isLoadingFlights: true, flightError: '');
    try {
      if (!AppConfig.hasBackendProxy) {
        state = state.copyWith(
          flights: const [],
          isLoadingFlights: false,
          flightError: 'Backend proxy is not configured.',
        );
        return;
      }
      final flights = await _serpApi.searchFlights(
        from: await AppPreferences.getDepartureAirport(),
        to: trip.destination,
        date: _fmt.format(trip.startDate),
        returnDate: _fmt.format(trip.endDate),
      );
      state = state.copyWith(
        flights: flights,
        isLoadingFlights: false,
        flightError: flights.isEmpty ? 'No flight results returned.' : null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingFlights: false,
        flightError: 'Flight search failed. Check the proxy and try again.',
      );
    }
  }

  Future<void> loadHotels() async {
    state = state.copyWith(isLoadingHotels: true, hotelError: '');
    try {
      if (!AppConfig.hasBackendProxy) {
        state = state.copyWith(
          hotels: const [],
          isLoadingHotels: false,
          hotelError: 'Backend proxy is not configured.',
        );
        return;
      }
      final hotels = await _serpApi.searchHotels(
        destination: trip.destination,
        checkIn: _fmt.format(trip.startDate),
        checkOut: _fmt.format(trip.endDate),
      );
      state = state.copyWith(
        hotels: hotels,
        isLoadingHotels: false,
        hotelError: hotels.isEmpty ? 'No hotel results returned.' : null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingHotels: false,
        hotelError: 'Hotel search failed. Check the proxy and try again.',
      );
    }
  }

  Future<void> loadRestaurants() async {
    state = state.copyWith(isLoadingRestaurants: true, placesError: '');
    try {
      if (!AppConfig.hasBackendProxy) {
        state = state.copyWith(
          restaurants: const [],
          isLoadingRestaurants: false,
          placesError: 'Backend proxy is not configured.',
        );
        return;
      }
      final restaurants = await _serpApi.searchRestaurants(
        destination: trip.destination,
      );
      state = state.copyWith(
        restaurants: restaurants,
        isLoadingRestaurants: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingRestaurants: false,
        placesError: 'Restaurant search failed. Check the proxy and try again.',
      );
    }
  }

  Future<void> loadAttractions() async {
    state = state.copyWith(isLoadingAttractions: true, placesError: '');
    try {
      if (!AppConfig.hasBackendProxy) {
        state = state.copyWith(
          attractions: const [],
          isLoadingAttractions: false,
          placesError: 'Backend proxy is not configured.',
        );
        return;
      }
      final attractions = await _serpApi.searchAttractions(
        destination: trip.destination,
      );
      state = state.copyWith(
        attractions: attractions,
        isLoadingAttractions: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingAttractions: false,
        placesError: 'Attraction search failed. Check the proxy and try again.',
      );
    }
  }

  Future<void> loadWeather() async {
    state = state.copyWith(isLoadingWeather: true, weatherError: '');
    try {
      final weather = await _weatherService.getForecast(trip.destination);
      state = state.copyWith(
        weather: weather,
        isLoadingWeather: false,
        weatherError: weather.isEmpty
            ? 'Weather/geocoding returned no data.'
            : null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingWeather: false,
        weatherError: 'Weather lookup failed. Try again.',
      );
    }
  }

  Future<void> loadCurrency() async {
    final preferredCurrency = await AppPreferences.getPreferredCurrency();
    final currency = preferredCurrency.isNotEmpty
        ? preferredCurrency
        : CurrencyService.getCurrencyFor(trip.destination);
    state = state.copyWith(localCurrency: currency);
    try {
      final rate = await _currencyService.getRate('USD', currency);
      state = state.copyWith(exchangeRate: rate);
    } catch (_) {}
  }
}

final tripDetailProvider =
    StateNotifierProvider.family<TripDetailNotifier, TripDetailData, Trip>(
      (ref, trip) => TripDetailNotifier(trip),
    );
