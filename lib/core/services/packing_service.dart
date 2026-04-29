import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/chat_message.dart';
import 'package:lookstrip/core/models/packing_model.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/services/ai_service.dart';
import 'package:lookstrip/core/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

/// Manages packing lists with local persistence and optional Supabase sync.
class PackingService {
  final _uuid = const Uuid();
  static String _scope = 'guest';

  static Future<void> init() async {
    await Hive.openBox<String>('packing_items');
  }

  static void setUserScope(String? userId) {
    _scope = (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  static Future<void> clearAllItems() async {
    await Hive.box<String>('packing_items').clear();
  }

  Box<String> get _box => Hive.box<String>('packing_items');
  String get _prefix => '$_scope:';

  /// Get packing items for a trip.
  Future<List<PackingItem>> getItems(String tripId) async {
    final client = SupabaseService.maybeClient;
    if (client != null) {
      try {
        final data = await client
            .from('packing_items')
            .select()
            .eq('trip_id', tripId)
            .order('category')
            .order('created_at');

        final remote = (data as List)
            .map((row) => PackingItem.fromJson(row as Map<String, dynamic>))
            .toList();
        if (remote.isNotEmpty) {
          await _saveLocalTrip(tripId, remote);
          return remote;
        }
      } catch (_) {}
    }

    return _loadLocalTrip(tripId);
  }

  /// Toggle packed/unpacked.
  Future<void> toggleItem(String itemId, bool isPacked) async {
    await _updateLocalItem(itemId, (item) => item.copyWith(isPacked: isPacked));

    final client = SupabaseService.maybeClient;
    if (client == null) return;
    try {
      await client
          .from('packing_items')
          .update({'is_packed': isPacked})
          .eq('id', itemId);
    } catch (_) {}
  }

  /// Add a custom item.
  Future<PackingItem> addItem(
    String tripId,
    String name,
    String category,
  ) async {
    final item = PackingItem(
      id: _uuid.v4(),
      tripId: tripId,
      itemName: name,
      category: category,
    );

    final items = [..._loadLocalTrip(tripId), item];
    await _saveLocalTrip(tripId, items);

    final client = SupabaseService.maybeClient;
    if (client != null) {
      try {
        await client.from('packing_items').insert(item.toJson());
      } catch (_) {}
    }

    return item;
  }

  /// Delete an item.
  Future<void> deleteItem(String itemId) async {
    await _deleteLocalItem(itemId);

    final client = SupabaseService.maybeClient;
    if (client == null) return;
    try {
      await client.from('packing_items').delete().eq('id', itemId);
    } catch (_) {}
  }

  /// Generate an AI packing list for a trip.
  Future<List<PackingItem>> generatePackingList(Trip trip) async {
    final aiService = AiService();
    final prompt =
        '''Generate a packing list for a ${trip.days}-day trip to ${trip.destination}.
Categorize items into these exact categories: essentials, clothing, toiletries, tech, documents.
Return ONLY a JSON array, no other text. Each item should have "name" and "category" fields.
Example: [{"name": "Passport", "category": "documents"}, {"name": "Sunscreen", "category": "toiletries"}]
Keep it practical with 15-25 items total.''';

    final messages = [
      ChatMessage(
        id: 'pack-prompt',
        role: MessageRole.user,
        content: prompt,
        timestamp: DateTime.now(),
      ),
    ];

    String fullResponse = '';
    await for (final chunk in aiService.streamCompletion(messages: messages)) {
      fullResponse += chunk;
    }

    final generated = _parsePackingItems(fullResponse, trip.id);
    final packingItems = generated.isEmpty
        ? _defaultPackingList(trip)
        : generated;

    await _replaceTripItems(trip.id, packingItems);
    return packingItems;
  }

  List<PackingItem> _parsePackingItems(String response, String tripId) {
    try {
      final start = response.indexOf('[');
      final end = response.lastIndexOf(']');
      if (start == -1 || end <= start) return [];

      final parsed = jsonDecode(response.substring(start, end + 1));
      if (parsed is! List) return [];

      return parsed
          .whereType<Map>()
          .map((item) {
            final name = item['name']?.toString().trim() ?? '';
            final category = item['category']?.toString().trim() ?? 'general';
            if (name.isEmpty) return null;
            return PackingItem(
              id: _uuid.v4(),
              tripId: tripId,
              itemName: name,
              category: _normalizeCategory(category),
            );
          })
          .whereType<PackingItem>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _normalizeCategory(String category) {
    const valid = {'essentials', 'clothing', 'toiletries', 'tech', 'documents'};
    final normalized = category.toLowerCase();
    return valid.contains(normalized) ? normalized : 'general';
  }

  Future<void> _replaceTripItems(String tripId, List<PackingItem> items) async {
    await _saveLocalTrip(tripId, items);

    final client = SupabaseService.maybeClient;
    if (client == null) return;
    try {
      await client.from('packing_items').delete().eq('trip_id', tripId);
      if (items.isNotEmpty) {
        await client
            .from('packing_items')
            .insert(items.map((p) => p.toJson()).toList());
      }
    } catch (_) {}
  }

  List<PackingItem> _loadLocalTrip(String tripId) {
    final raw = _box.get('$_prefix$tripId');
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => PackingItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalTrip(String tripId, List<PackingItem> items) {
    return _box.put(
      '$_prefix$tripId',
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _updateLocalItem(
    String itemId,
    PackingItem Function(PackingItem item) update,
  ) async {
    for (final key in _box.keys.cast<String>()) {
      if (!key.startsWith(_prefix)) continue;
      final tripId = key.substring(_prefix.length);
      final items = _loadLocalTrip(tripId);
      var changed = false;
      final updated = items.map((item) {
        if (item.id != itemId) return item;
        changed = true;
        return update(item);
      }).toList();
      if (changed) {
        await _saveLocalTrip(tripId, updated);
        return;
      }
    }
  }

  Future<void> _deleteLocalItem(String itemId) async {
    for (final key in _box.keys.cast<String>()) {
      if (!key.startsWith(_prefix)) continue;
      final tripId = key.substring(_prefix.length);
      final items = _loadLocalTrip(tripId);
      final updated = items.where((item) => item.id != itemId).toList();
      if (updated.length != items.length) {
        await _saveLocalTrip(tripId, updated);
        return;
      }
    }
  }

  List<PackingItem> _defaultPackingList(Trip trip) {
    final defaults = [
      ('Passport', 'documents'),
      ('Travel Insurance', 'documents'),
      ('Phone Charger', 'tech'),
      ('Power Bank', 'tech'),
      ('Headphones', 'tech'),
      ('T-shirts (${trip.days}x)', 'clothing'),
      ('Pants/Shorts', 'clothing'),
      ('Underwear (${trip.days}x)', 'clothing'),
      ('Comfortable Shoes', 'clothing'),
      ('Sunglasses', 'essentials'),
      ('Wallet and Cards', 'essentials'),
      ('Water Bottle', 'essentials'),
      ('Day Backpack', 'essentials'),
      ('Toothbrush and Paste', 'toiletries'),
      ('Deodorant', 'toiletries'),
      ('Sunscreen', 'toiletries'),
      ('Medications', 'toiletries'),
    ];

    return defaults
        .map(
          (d) => PackingItem(
            id: _uuid.v4(),
            tripId: trip.id,
            itemName: d.$1,
            category: d.$2,
          ),
        )
        .toList();
  }
}
