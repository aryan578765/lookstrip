import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.content));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Copied to clipboard'),
              backgroundColor: AppColors.surfaceContainer,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
              ),
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: EdgeInsets.only(
            left: _isUser ? 48 : 0,
            right: _isUser ? 0 : 48,
            bottom: AppShapes.spaceSm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppShapes.spaceMd,
            vertical: AppShapes.spaceSm + 4,
          ),
          decoration: BoxDecoration(
            color: _isUser ? null : AppColors.surfaceContainer,
            gradient: _isUser ? AppColors.amberGlow : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppShapes.radiusLg),
              topRight: const Radius.circular(AppShapes.radiusLg),
              bottomLeft: Radius.circular(
                _isUser ? AppShapes.radiusLg : AppShapes.radiusXs,
              ),
              bottomRight: Radius.circular(
                _isUser ? AppShapes.radiusXs : AppShapes.radiusLg,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message content
              Text(
                message.content.isEmpty ? '...' : message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isUser ? AppColors.onPrimary : AppColors.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              // Timestamp
              Text(
                _formatTime(message.timestamp),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _isUser
                      ? AppColors.onPrimary.withValues(alpha: 0.7)
                      : AppColors.onSurfaceMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
