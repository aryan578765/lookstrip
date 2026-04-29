import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/models/chat_message.dart';
import 'package:lookstrip/core/services/ai_service.dart';
import 'package:lookstrip/core/services/chat_storage.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';

/// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }

  /// Whether to show the welcome state (no messages yet)
  bool get isEmpty => messages.isEmpty;
}

/// Chat notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final AiService _aiService = AiService();
  StreamSubscription<String>? _streamSub;
  CancelToken? _cancelToken;

  ChatNotifier(this._ref) : super(const ChatState()) {
    _loadHistory();
  }

  /// Load persisted messages from Hive
  void _loadHistory() {
    final messages = ChatStorage.loadMessages();
    if (messages.isNotEmpty) {
      state = state.copyWith(messages: messages);
    }
  }

  /// Send a user message and get AI response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Cancel any in-progress stream
    await _streamSub?.cancel();
    _cancelToken?.cancel('New chat message started');
    _cancelToken = CancelToken();

    // Add user message
    final userMessage = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isTyping: true,
      error: null,
    );

    // Create placeholder AI message
    final aiMessage = ChatMessage(
      id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    final messagesWithAi = [...updatedMessages, aiMessage];
    state = state.copyWith(messages: messagesWithAi);

    // Get user info for personalization
    final user = _ref.read(currentUserProvider);

    // Stream AI response
    String fullContent = '';

    _streamSub = _aiService
        .streamCompletion(
          messages: updatedMessages,
          userName: user?.name,
          travelStyles: user?.travelStyles,
          cancelToken: _cancelToken,
        )
        .listen(
          (chunk) {
            fullContent += chunk;
            // Update the AI message in place
            final updated = state.messages.map((m) {
              if (m.id == aiMessage.id) {
                return m.copyWith(content: fullContent);
              }
              return m;
            }).toList();
            state = state.copyWith(messages: updated);
          },
          onDone: () {
            // Mark streaming as done
            final updated = state.messages.map((m) {
              if (m.id == aiMessage.id) {
                return m.copyWith(isStreaming: false);
              }
              return m;
            }).toList();
            state = state.copyWith(messages: updated, isTyping: false);
            // Persist to Hive
            ChatStorage.saveMessages(updated);
          },
          onError: (e) {
            if (e is DioException && CancelToken.isCancel(e)) {
              state = state.copyWith(isTyping: false);
              return;
            }
            final updated = state.messages.map((m) {
              if (m.id == aiMessage.id) {
                return m.copyWith(
                  content: '❌ Failed to get response. Please try again.',
                  isStreaming: false,
                );
              }
              return m;
            }).toList();
            state = state.copyWith(messages: updated, isTyping: false);
          },
        );
  }

  Future<void> cancelGeneration() async {
    _cancelToken?.cancel('User cancelled chat generation');
    await _streamSub?.cancel();
    final updated = state.messages
        .map(
          (message) => message.isStreaming
              ? message.copyWith(isStreaming: false)
              : message,
        )
        .toList();
    state = state.copyWith(messages: updated, isTyping: false);
    await ChatStorage.saveMessages(updated);
  }

  /// Clear all messages
  Future<void> clearChat() async {
    _streamSub?.cancel();
    _cancelToken?.cancel('Chat cleared');
    await ChatStorage.clearMessages();
    state = const ChatState();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

/// Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
