import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/services/ai_service.dart';

/// Generates AI itineraries using OpenRouter.
class TripAiService {
  static final TripAiService _instance = TripAiService._();
  factory TripAiService() => _instance;
  TripAiService._();

  final AiService _aiService = AiService();
  bool lastUsedFallback = false;

  /// Generate a full itinerary for a trip.
  Future<List<TripDay>> generateItinerary({
    required String destination,
    required int days,
    String? travelStyle,
    CancelToken? cancelToken,
  }) async {
    lastUsedFallback = false;
    final prompt =
        '''Generate a detailed $days-day travel itinerary for $destination.
${travelStyle != null && travelStyle.isNotEmpty ? 'Travel style preference: $travelStyle.' : ''}

IMPORTANT: Respond ONLY with valid JSON. No markdown, no explanation, no code blocks.
The JSON must be an array of day objects with this exact structure:
[
  {
    "dayNumber": 1,
    "title": "Arrival and Old Town",
    "activities": [
      {
        "time": "09:00",
        "title": "Activity name",
        "description": "Brief description of the activity",
        "emoji": "emoji character"
      }
    ]
  }
]

Each day should have 4-5 activities spread throughout the day.
Use specific real places, restaurants, and attractions in $destination.''';

    try {
      final content = await _aiService.completeText(
        prompt: prompt,
        maxTokens: 2048,
        temperature: 0.7,
        cancelToken: cancelToken,
      );
      final jsonStr = _extractJsonArray(content);
      if (jsonStr == null) {
        lastUsedFallback = true;
        return _fallbackItinerary(destination, days);
      }

      final parsed = jsonDecode(jsonStr) as List<dynamic>;
      final itinerary = parsed
          .map((d) => TripDay.fromJson(d as Map<String, dynamic>))
          .toList();

      if (itinerary.isEmpty) {
        lastUsedFallback = true;
        return _fallbackItinerary(destination, days);
      }
      return itinerary;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      lastUsedFallback = true;
      return _fallbackItinerary(destination, days);
    } catch (_) {
      lastUsedFallback = true;
      return _fallbackItinerary(destination, days);
    }
  }

  String? _extractJsonArray(String content) {
    var jsonStr = content.trim();
    if (jsonStr.contains('```')) {
      final match = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
      if (match != null) jsonStr = match.group(1)!.trim();
    }

    final start = jsonStr.indexOf('[');
    final end = jsonStr.lastIndexOf(']');
    if (start == -1 || end <= start) return null;
    return jsonStr.substring(start, end + 1);
  }

  /// Fallback when API is unavailable.
  List<TripDay> _fallbackItinerary(String destination, int days) {
    return List.generate(
      days,
      (i) => TripDay(
        dayNumber: i + 1,
        title: i == 0
            ? 'Arrival and Exploration'
            : i == days - 1
            ? 'Last Day and Departure'
            : 'Day ${i + 1} in $destination',
        activities: [
          TripActivity(
            time: '08:00',
            title: i == 0 ? 'Check-in and freshen up' : 'Breakfast at hotel',
            description: i == 0
                ? 'Arrive and settle into your accommodation'
                : 'Start the day with a local breakfast',
            emoji: i == 0 ? '\u{1F3E8}' : '\u{2615}',
          ),
          TripActivity(
            time: '10:00',
            title: 'Morning sightseeing',
            description: 'Explore popular landmarks in $destination',
            emoji: '\u{1F4F8}',
          ),
          const TripActivity(
            time: '13:00',
            title: 'Lunch at local restaurant',
            description: 'Try authentic local cuisine',
            emoji: '\u{1F37D}\u{FE0F}',
          ),
          const TripActivity(
            time: '15:00',
            title: 'Afternoon activity',
            description: 'Visit museums, markets, or natural attractions',
            emoji: '\u{1F3DB}\u{FE0F}',
          ),
          TripActivity(
            time: '19:00',
            title: i == days - 1 ? 'Farewell dinner' : 'Evening exploration',
            description: i == days - 1
                ? 'Enjoy a memorable last dinner in $destination'
                : 'Dinner and evening entertainment',
            emoji: '\u{1F319}',
          ),
        ],
      ),
    );
  }
}
