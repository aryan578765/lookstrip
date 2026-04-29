import 'package:dio/dio.dart';
import 'package:lookstrip/core/models/chat_message.dart';
import 'package:lookstrip/core/services/backend_proxy_service.dart';

/// AI service backed by the privacy-safe backend proxy.
class AiService {
  static final AiService _instance = AiService._();
  factory AiService() => _instance;
  AiService._();

  final BackendProxyService _proxy = BackendProxyService.instance;

  /// Build system prompt personalized with user data.
  String buildSystemPrompt({String? userName, List<String>? travelStyles}) {
    final name = (userName?.isNotEmpty == true) ? userName! : 'Traveler';
    final styles = (travelStyles?.isNotEmpty == true)
        ? travelStyles!.join(', ')
        : 'exploring new places';

    return '''You are LooksTrip AI, a friendly and knowledgeable travel planning assistant.
You help users plan trips, find destinations, suggest day-by-day itineraries, recommend hotels, restaurants, and answer travel-related questions.
Keep responses concise, well-structured, and helpful.
When suggesting itineraries, use a clear day-by-day format.
The user's name is $name and they enjoy: $styles.
Always be encouraging and practical.''';
  }

  /// Send chat messages and stream the proxy response.
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    String? userName,
    List<String>? travelStyles,
    CancelToken? cancelToken,
  }) async* {
    if (!_proxy.isConfigured) {
      yield 'AI is not configured yet. Add BACKEND_PROXY_BASE_URL so LooksTrip can call the private API proxy without exposing secrets in the app.';
      return;
    }

    yield* _proxy.streamAiCompletion(
      messages: messages,
      systemPrompt: buildSystemPrompt(
        userName: userName,
        travelStyles: travelStyles,
      ),
      cancelToken: cancelToken,
    );
  }

  Future<String> completeText({
    required String prompt,
    int maxTokens = 2048,
    double temperature = 0.7,
    CancelToken? cancelToken,
  }) {
    return _proxy.completeAiText(
      prompt: prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      cancelToken: cancelToken,
    );
  }
}
