/// Expense model for tracking real trip spending
class Expense {
  final String id;
  final String tripId;
  final String? userId;
  final String category; // food, transport, hotel, activity, shopping, other
  final double amount;
  final String currency;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.tripId,
    this.userId,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    this.note,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? date;

  /// All supported expense categories
  static const categories = [
    ('food', '🍽️', 'Food & Drink'),
    ('transport', '🚕', 'Transport'),
    ('hotel', '🏨', 'Accommodation'),
    ('activity', '🎡', 'Activities'),
    ('shopping', '🛍️', 'Shopping'),
    ('other', '📦', 'Other'),
  ];

  static String emojiFor(String category) {
    return categories
        .firstWhere(
          (c) => c.$1 == category,
          orElse: () => ('other', '📦', 'Other'),
        )
        .$2;
  }

  static String labelFor(String category) {
    return categories
        .firstWhere(
          (c) => c.$1 == category,
          orElse: () => ('other', '📦', 'Other'),
        )
        .$3;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip_id': tripId,
    'user_id': userId,
    'category': category,
    'amount': amount,
    'currency': currency,
    'note': note,
    'date': date.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    tripId: json['trip_id'] as String,
    userId: json['user_id'] as String?,
    category: json['category'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USD',
    note: json['note'] as String?,
    date: DateTime.parse(json['date'] as String),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );
}
