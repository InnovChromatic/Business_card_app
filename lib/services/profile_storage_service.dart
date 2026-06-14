import 'package:business_card_flutter/models/user_profile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileStorageService {
  static const String _boxName = 'user_profile';
  static const String _profileKey = 'profile';

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = _getBox();
    await box.put(_profileKey, profile.toMap());
  }

  Future<void> updateProfile(UserProfile profile) async {
    final box = _getBox();
    await box.put(_profileKey, profile.toMap());
  }

  UserProfile? getProfile() {
    final box = _getBox();
    final data = box.get(_profileKey);

    if (data == null) {
      return null;
    }

    if (data is! Map) {
      throw const ProfileStorageException(
        'Stored profile data has invalid format.',
      );
    }

    return UserProfile.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  Box<dynamic> _getBox() {
    if (!Hive.isBoxOpen(_boxName)) {
      throw const ProfileStorageException(
        'Profile storage is unavailable.',
      );
    }

    return Hive.box<dynamic>(_boxName);
  }
}

class ProfileStorageException implements Exception {
  const ProfileStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}