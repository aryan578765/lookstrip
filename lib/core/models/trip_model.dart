/// Trip model for storing user trips — syncs to Supabase + Hive
class Trip {
  final String id;
  final String? userId;
  final String title;
  final String destination;
  final String emoji;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // upcoming, ongoing, past
  final int days;
  final String? budget;
  final List<TripDay> itinerary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Trip({
    required this.id,
    this.userId,
    required this.title,
    required this.destination,
    required this.emoji,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.days,
    this.budget,
    this.itinerary = const [],
    required this.createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  }) : updatedAt = updatedAt ?? createdAt;

  Trip copyWith({
    String? userId,
    String? title,
    String? status,
    String? budget,
    List<TripDay>? itinerary,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Trip(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      destination: destination,
      emoji: emoji,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      days: days,
      budget: budget ?? this.budget,
      itinerary: itinerary ?? this.itinerary,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'destination': destination,
    'emoji': emoji,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status,
    'days': days,
    'budget': budget,
    'itinerary': itinerary.map((d) => d.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isSynced': isSynced,
  };

  /// For Supabase upsert (snake_case, no itinerary — stored separately)
  Map<String, dynamic> toSupabase() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'destination': destination,
    'emoji': emoji,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'status': status,
    'days': days,
    'budget': budget,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    userId: json['user_id'] as String?,
    title: json['title'] as String,
    destination: json['destination'] as String,
    emoji: json['emoji'] as String? ?? '🌍',
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    status: json['status'] as String,
    days: json['days'] as int,
    budget: json['budget'] as String?,
    itinerary:
        (json['itinerary'] as List<dynamic>?)
            ?.map((d) => TripDay.fromJson(d))
            .toList() ??
        [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    isSynced: json['isSynced'] as bool? ?? false,
  );

  /// Parse from Supabase row (snake_case)
  factory Trip.fromSupabase(
    Map<String, dynamic> json, {
    List<TripDay> itinerary = const [],
  }) {
    return Trip(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      destination: json['destination'] as String,
      emoji: json['emoji'] as String? ?? '🌍',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'upcoming',
      days: json['days'] as int? ?? 3,
      budget: json['budget'] as String?,
      itinerary: itinerary,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isSynced: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Trip && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TripDay {
  final int dayNumber;
  final String title;
  final List<TripActivity> activities;

  const TripDay({
    required this.dayNumber,
    required this.title,
    this.activities = const [],
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'title': title,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
    dayNumber: json['dayNumber'] as int,
    title: json['title'] as String,
    activities:
        (json['activities'] as List<dynamic>?)
            ?.map((a) => TripActivity.fromJson(a))
            .toList() ??
        [],
  );
}

class TripActivity {
  final String time;
  final String title;
  final String description;
  final String emoji;

  const TripActivity({
    required this.time,
    required this.title,
    required this.description,
    this.emoji = '📍',
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'title': title,
    'description': description,
    'emoji': emoji,
  };

  factory TripActivity.fromJson(Map<String, dynamic> json) => TripActivity(
    time: json['time'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    emoji: json['emoji'] as String? ?? '📍',
  );
}
