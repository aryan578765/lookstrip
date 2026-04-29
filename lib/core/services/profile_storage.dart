import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/user_model.dart';

/// Persists user profile locally using Hive
class ProfileStorage {
  static const _boxName = 'user_profile';
  static const _currentUserKey = 'current_user_id';
  static const _legacyKey = 'current_user';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  /// Save user profile
  static Future<void> saveUser(UserModel user) async {
    await _box.put(_currentUserKey, user.id);
    await _box.put(_profileKey(user.id), jsonEncode(user.toJson()));
  }

  /// Load user profile
  static UserModel? loadUser() {
    final currentUserId = _box.get(_currentUserKey);
    final json = currentUserId == null
        ? _box.get(_legacyKey)
        : _box.get(_profileKey(currentUserId));
    if (json != null) {
      try {
        return UserModel.fromJson(jsonDecode(json));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Clear profile
  static Future<void> clearProfile() async {
    await _box.delete(_currentUserKey);
    await _box.delete(_legacyKey);
  }

  static Future<void> clearAllProfiles() async {
    await _box.clear();
  }

  static String _profileKey(String userId) => 'profile:$userId';
}
