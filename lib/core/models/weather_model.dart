/// Weather forecast day from Open-Meteo
class WeatherDay {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final int weatherCode;
  final double precipitationMm;

  const WeatherDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.weatherCode,
    this.precipitationMm = 0,
  });

  /// WMO Weather Code → description + emoji
  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 49) return 'Foggy';
    if (weatherCode <= 59) return 'Drizzle';
    if (weatherCode <= 69) return 'Rain';
    if (weatherCode <= 79) return 'Snow';
    if (weatherCode <= 84) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    if (weatherCode == 95) return 'Thunderstorm';
    if (weatherCode <= 99) return 'Thunderstorm with hail';
    return 'Unknown';
  }

  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 2) return '⛅';
    if (weatherCode == 3) return '☁️';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 59) return '🌦️';
    if (weatherCode <= 69) return '🌧️';
    if (weatherCode <= 79) return '❄️';
    if (weatherCode <= 84) return '🌧️';
    if (weatherCode <= 86) return '🌨️';
    if (weatherCode >= 95) return '⛈️';
    return '🌤️';
  }

  String get tempRange => '${tempMin.round()}° – ${tempMax.round()}°C';

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'temp_min': tempMin,
    'temp_max': tempMax,
    'weather_code': weatherCode,
    'precipitation_mm': precipitationMm,
  };

  factory WeatherDay.fromJson(Map<String, dynamic> json) => WeatherDay(
    date: DateTime.parse(json['date'] as String),
    tempMin: (json['temp_min'] as num).toDouble(),
    tempMax: (json['temp_max'] as num).toDouble(),
    weatherCode: json['weather_code'] as int,
    precipitationMm: (json['precipitation_mm'] as num?)?.toDouble() ?? 0,
  );
}
