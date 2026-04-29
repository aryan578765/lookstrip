/// LooksTrip User Profile
class UserModel {
  final String id;
  final String phone;
  final String name;
  final String? avatarUrl;
  final List<String> travelStyles;
  final bool isProfileComplete;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.name = '',
    this.avatarUrl,
    this.travelStyles = const [],
    this.isProfileComplete = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    List<String>? travelStyles,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id,
      phone: phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      travelStyles: travelStyles ?? this.travelStyles,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      travelStyles:
          (json['travel_styles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'avatar_url': avatarUrl,
      'travel_styles': travelStyles,
      'is_profile_complete': isProfileComplete,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Dev-mode placeholder user
  factory UserModel.guest() {
    return UserModel(
      id: 'guest',
      phone: '+910000000000',
      name: 'Traveler',
      createdAt: DateTime.now(),
    );
  }
}
