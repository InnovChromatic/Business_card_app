import 'package:business_card_flutter/models/user_profile.dart';
import 'package:business_card_flutter/providers/profile_provider.dart';
import 'package:business_card_flutter/screens/profile/edit_card_screen.dart';
import 'package:business_card_flutter/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _accentColor = Color(0xFF1D5CFF);
const _backgroundColor = Color(0xFFF5F7FB);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _openEditProfile() async {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }

  Future<void> _openEditCard() async {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditCardScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _TopBar(profile: profile),
              const SizedBox(height: 20),
              const _ProfileAvatar(),
              const SizedBox(height: 20),
              _HeadlineCard(profile: profile),
              const SizedBox(height: 24),
              _CardsSection(
                profile: profile,
                onEditCard: _openEditCard,
              ),
              const SizedBox(height: 24),
              _CareerSummarySection(profile: profile),
              const SizedBox(height: 20),
              _EducationSection(profile: profile),
              const SizedBox(height: 20),
              _SkillsSection(profile: profile),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _openEditProfile,
                    child: const Text('Edit Profile'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              profile.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.diamond_outlined,
              color: _accentColor,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(
            Icons.person,
            size: 70,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.camera_alt,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              profile.headline ?? 'What do you do?',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const Icon(Icons.edit_outlined, color: _accentColor),
        ],
      ),
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection({
    required this.profile,
    required this.onEditCard,
  });

  final UserProfile profile;
  final VoidCallback onEditCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Using 1 card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onEditCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add your card'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (profile.position != null) ...[
                const SizedBox(height: 8),
                Text(profile.position!),
              ],
              if (profile.companyName != null) ...[
                const SizedBox(height: 8),
                Text(profile.companyName!),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                profile.email ?? 'No email',
                style: const TextStyle(
                  color: _accentColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CareerSummarySection extends StatelessWidget {
  const _CareerSummarySection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Career Summary',
      child: Text(profile.careerSummary ?? 'No career summary yet.'),
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Education',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: profile.education
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(entry),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Skills',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            profile.skills.map((skill) => Chip(label: Text(skill))).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}