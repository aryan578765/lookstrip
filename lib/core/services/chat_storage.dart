import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/chat_message.dart';

/// Persists chat messages locally using Hive
class ChatStorage {
  static const _boxName = 'chat_messages';
  static const _maxMessages = 100;
  static String _scope = 'guest';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  static String get _prefix => '$_scope:';

  static void setUserScope(String? userId) {
    _scope = (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  /// Save all messages
  static Future<void> saveMessages(List<ChatMessage> messages) async {
    await clearMessages();
    // Only keep last N messages
    final toSave = messages.length > _maxMessages
        ? messages.sublist(messages.length - _maxMessages)
        : messages;

    for (int i = 0; i < toSave.length; i++) {
      await _box.put('$_prefix$i', jsonEncode(toSave[i].toJson()));
    }
  }

  /// Load all messages
  static List<ChatMessage> loadMessages() {
    final messages = <ChatMessage>[];
    for (int i = 0; i < _box.length; i++) {
      final json = _box.get('$_prefix$i');
      if (json != null) {
        try {
          messages.add(ChatMessage.fromJson(jsonDecode(json)));
        } catch (_) {
          // Skip corrupted entries
        }
      }
    }
    return messages;
  }

  /// Clear all messages
  static Future<void> clearMessages() async {
    final scopedKeys = _box.keys
        .where((key) => key.toString().startsWith(_prefix))
        .toList();
    await _box.deleteAll(scopedKeys);
  }

  static Future<void> clearAllMessages() async {
    await _box.clear();
  }
}
