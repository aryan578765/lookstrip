/// Packing list item model
class PackingItem {
  final String id;
  final String tripId;
  final String itemName;
  final String category; // essentials, clothing, toiletries, tech, documents
  final bool isPacked;
  final DateTime createdAt;

  PackingItem({
    required this.id,
    required this.tripId,
    required this.itemName,
    this.category = 'general',
    this.isPacked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// All supported packing categories
  static const categories = [
    ('essentials', '🎒', 'Essentials'),
    ('clothing', '👕', 'Clothing'),
    ('toiletries', '🧴', 'Toiletries'),
    ('tech', '📱', 'Tech & Gadgets'),
    ('documents', '📄', 'Documents'),
    ('general', '📦', 'General'),
  ];

  static String emojiFor(String category) {
    return categories
        .firstWhere(
          (c) => c.$1 == category,
          orElse: () => ('general', '📦', 'General'),
        )
        .$2;
  }

  static String labelFor(String category) {
    return categories
        .firstWhere(
          (c) => c.$1 == category,
          orElse: () => ('general', '📦', 'General'),
        )
        .$3;
  }

  PackingItem copyWith({bool? isPacked}) {
    return PackingItem(
      id: id,
      tripId: tripId,
      itemName: itemName,
      category: category,
      isPacked: isPacked ?? this.isPacked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip_id': tripId,
    'item_name': itemName,
    'category': category,
    'is_packed': isPacked,
    'created_at': createdAt.toIso8601String(),
  };

  factory PackingItem.fromJson(Map<String, dynamic> json) => PackingItem(
    id: json['id'] as String,
    tripId: json['trip_id'] as String,
    itemName: json['item_name'] as String,
    category: json['category'] as String? ?? 'general',
    isPacked: json['is_packed'] as bool? ?? false,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );
}
