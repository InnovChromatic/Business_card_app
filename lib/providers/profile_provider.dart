import 'package:business_card_flutter/models/user_profile.dart';
import 'package:business_card_flutter/services/profile_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile?>(
  (ref) => ProfileNotifier(),
);

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null) {
    loadProfile();
  }

  final ProfileStorageService _storage = ProfileStorageService();

  Future<void> loadProfile() async {
    await _storage.initialize();

    final storedProfile = _storage.getProfile();

    if (storedProfile != null) {
      state = storedProfile;
      return;
    }

    final defaultProfile = UserProfile(
      name: 'Manas Tiwari',
      headline: 'Flutter developer building OCR networking products',
      careerSummary:
          'Building scalable mobile applications with focus on OCR, systems design and modern UI architecture.',
      education: const [
        'B.Tech Computer Science',
        'XYZ University (2022 - 2026)',
      ],
      skills: const ['Flutter', 'OCR', 'C++', 'React', 'Backend'],
      email: 'official.manastiwari2101@gmail.com',
    );

    await _storage.saveProfile(defaultProfile);
    state = defaultProfile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _storage.updateProfile(profile);
    state = profile;
  }
}