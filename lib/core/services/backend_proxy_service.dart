import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lookstrip/core/models/chat_message.dart';
import 'package:lookstrip/core/services/app_config.dart';

class BackendProxyException implements Exception {
  final String message;
  const BackendProxyException(this.message);

  @override
  String toString() => message;
}

/// Calls the privacy-safe backend proxy for AI and travel-search APIs.
///
/// The mobile app never calls OpenRouter or SerpApi directly. Put those secret
/// keys on the proxy server only.
class BackendProxyService {
  BackendProxyService._();

  static final BackendProxyService instance = BackendProxyService._();

  Dio? _dio;

  bool get isConfigured => AppConfig.hasBackendProxy;

  Dio get _client {
    if (!isConfigured) {
      throw const BackendProxyException('Backend proxy is not configured.');
    }

    final baseUrl = _normalizeBaseUrl(AppConfig.backendProxyBaseUrl);
    final existing = _dio;
    if (existing != null && existing.options.baseUrl == baseUrl) {
      return existing;
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    return _dio!;
  }

  String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value : '$value/';
  }

  Stream<String> streamAiCompletion({
    required List<ChatMessage> messages,
    required String systemPrompt,
    CancelToken? cancelToken,
  }) async* {
    if (!isConfigured) {
      throw const BackendProxyException('Backend proxy is not configured.');
    }

    final response = await _client.post<ResponseBody>(
      'ai/chat',
      cancelToken: cancelToken,
      options: Options(responseType: ResponseType.stream),
      data: {
        'system': systemPrompt,
        'messages': messages
            .where((message) => message.role != MessageRole.system)
            .map((message) => message.toApiMessage())
            .toList(),
        'stream': true,
      },
    );

    final responseBody = response.data;
    if (responseBody == null) {
      throw const BackendProxyException('Backend proxy returned no AI stream.');
    }

    final lines = utf8.decoder
        .bind(responseBody.stream)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (cancelToken?.isCancelled == true) return;

      final trimmed = line.trim();
      if (!trimmed.startsWith('data: ')) continue;

      final data = trimmed.substring(6).trim();
      if (data == '[DONE]') return;

      try {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final choices = json['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) continue;
        final delta = choices.first['delta'] as Map<String, dynamic>?;
        final content = delta?['content'] as String?;
        if (content != null) yield content;
      } catch (_) {
        // Ignore malformed SSE keepalive/partial payloads.
      }
    }
  }

  Future<String> completeAiText({
    required String prompt,
    int maxTokens = 2048,
    double temperature = 0.7,
    CancelToken? cancelToken,
  }) async {
    if (!isConfigured) {
      throw const BackendProxyException('Backend proxy is not configured.');
    }

    final response = await _client.post<Map<String, dynamic>>(
      'ai/complete',
      cancelToken: cancelToken,
      data: {
        'prompt': prompt,
        'max_tokens': maxTokens,
        'temperature': temperature,
      },
    );

    final content = response.data?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw const BackendProxyException('Backend proxy returned no AI text.');
    }
    return content;
  }

  Future<Map<String, dynamic>?> serpSearch(
    Map<String, String> params, {
    CancelToken? cancelToken,
  }) async {
    if (!isConfigured) return null;

    final response = await _client.post<Map<String, dynamic>>(
      'serp/search',
      cancelToken: cancelToken,
      data: {'params': params},
    );

    return response.data;
  }
}
