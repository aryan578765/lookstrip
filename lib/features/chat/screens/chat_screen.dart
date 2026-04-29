import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/chat_provider.dart';
import 'package:lookstrip/features/chat/widgets/message_bubble.dart';
import 'package:lookstrip/features/chat/widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  void _sendMessage([String? override]) {
    final text = override ?? _textController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _textController.clear();
    _focusNode.unfocus();

    // Scroll to bottom after a frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Clear chat?'),
        content: const Text('This will delete all messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(ctx);
            },
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Auto-scroll when new messages arrive
    ref.listen(chatProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0) ||
          next.isTyping) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return SafeArea(
      child: Column(
        children: [
          // ─── Header ───
          _buildHeader(context, chatState),
          const Divider(height: 1),

          // ─── Messages or Welcome ───
          Expanded(
            child: chatState.isEmpty
                ? _buildWelcome(context)
                : _buildMessages(chatState),
          ),

          // ─── Input ───
          _buildInput(context, chatState),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatState chatState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppShapes.screenPadding,
        AppShapes.spaceMd,
        AppShapes.screenPadding,
        AppShapes.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.amberGlow,
              borderRadius: BorderRadius.circular(AppShapes.radiusMd),
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppShapes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LooksTrip AI',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  chatState.isTyping ? 'Typing...' : 'Your travel assistant',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: chatState.isTyping
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!chatState.isEmpty)
            GestureDetector(
              onTap: _clearChat,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShapes.screenPadding,
          vertical: AppShapes.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 72)),
            const SizedBox(height: AppShapes.spaceLg),
            Text(
              'Hey! Where would you\nlove to travel?',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 26,
                color: AppColors.onSurface,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppShapes.spaceMd),
            Text(
              'I\'ll help you plan the perfect trip with\nflights, hotels, restaurants & more',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppShapes.spaceLg),
            // Suggestion chips
            Wrap(
              spacing: AppShapes.spaceSm,
              runSpacing: AppShapes.spaceSm,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: '🗺️ Plan a trip',
                  onTap: () => _sendMessage('Plan a trip for me'),
                ),
                _SuggestionChip(
                  label: '🍽️ Find restaurants',
                  onTap: () => _sendMessage(
                    'Find the best restaurants near popular destinations',
                  ),
                ),
                _SuggestionChip(
                  label: '🧳 What to pack',
                  onTap: () => _sendMessage(
                    'What should I pack for a week-long vacation?',
                  ),
                ),
                _SuggestionChip(
                  label: '✈️ Search flights',
                  onTap: () => _sendMessage('Help me find cheap flights'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(ChatState chatState) {
    // Count items: messages + optional typing indicator
    final showTyping =
        chatState.isTyping &&
        chatState.messages.isNotEmpty &&
        chatState.messages.last.isStreaming &&
        chatState.messages.last.content.isEmpty;
    final itemCount = chatState.messages.length + (showTyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppShapes.screenPadding,
        vertical: AppShapes.spaceSm,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && showTyping) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppShapes.spaceSm),
            child: TypingIndicator(),
          );
        }
        return MessageBubble(message: chatState.messages[index]);
      },
    );
  }

  Widget _buildInput(BuildContext context, ChatState chatState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppShapes.spaceMd,
        AppShapes.spaceSm,
        AppShapes.spaceSm,
        AppShapes.spaceLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 120),
              padding: const EdgeInsets.symmetric(
                horizontal: AppShapes.spaceMd,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppShapes.radius2xl),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about travel...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: AppShapes.spaceSm),
          Semantics(
            button: true,
            label: chatState.isTyping ? 'Stop AI response' : 'Send message',
            child: InkWell(
              borderRadius: BorderRadius.circular(AppShapes.radiusFull),
              onTap: chatState.isTyping
                  ? () => ref.read(chatProvider.notifier).cancelGeneration()
                  : () => _sendMessage(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: chatState.isTyping ? null : AppColors.amberGlow,
                  color: chatState.isTyping
                      ? AppColors.surfaceContainerHigh
                      : null,
                  borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                ),
                child: Icon(
                  chatState.isTyping
                      ? Icons.stop_rounded
                      : Icons.arrow_upward_rounded,
                  color: chatState.isTyping
                      ? AppColors.onSurfaceMuted
                      : AppColors.onPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShapes.spaceMd,
          vertical: AppShapes.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.radiusFull),
          border: Border.all(color: AppColors.outline, width: 1),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
