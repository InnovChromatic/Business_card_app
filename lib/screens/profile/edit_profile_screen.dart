import 'package:business_card_flutter/models/user_profile.dart';
import 'package:business_card_flutter/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    required this.profile,
    super.key,
  });

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _summaryController;
  late final TextEditingController _educationController;
  late final TextEditingController _skillsController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.profile.name,
    );

    _headlineController = TextEditingController(
      text: widget.profile.headline ?? '',
    );

    _summaryController = TextEditingController(
      text: widget.profile.careerSummary ?? '',
    );

    _educationController = TextEditingController(
      text: widget.profile.education.join('\n'),
    );

    _skillsController = TextEditingController(
      text: widget.profile.skills.join(', '),
    );
  }

  List<String> _parseEducation() {
    return _educationController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> _parseSkills() {
    return _skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedProfile = UserProfile(
      name: name,
      profileImagePath: widget.profile.profileImagePath,
      headline: _headlineController.text.trim(),
      careerSummary: _summaryController.text.trim(),
      education: _parseEducation(),
      skills: _parseSkills(),
      email: widget.profile.email,
      companyName: widget.profile.companyName,
      department: widget.profile.department,
      position: widget.profile.position,
      companyNumber: widget.profile.companyNumber,
      departmentNumber: widget.profile.departmentNumber,
      directNumber: widget.profile.directNumber,
      fax: widget.profile.fax,
      mobileNumber: widget.profile.mobileNumber,
      postalCode: widget.profile.postalCode,
      websiteUrl: widget.profile.websiteUrl,
      usageFrom: widget.profile.usageFrom,
      usageUntil: widget.profile.usageUntil,
    );

    await ref
        .read(profileProvider.notifier)
        .updateProfile(updatedProfile);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _field(
                label: 'Name',
                controller: _nameController,
              ),
              _field(
                label: 'Headline',
                controller: _headlineController,
                maxLines: 2,
              ),
              _field(
                label: 'Career Summary',
                controller: _summaryController,
                maxLines: 5,
              ),
              _field(
                label: 'Education (one per line)',
                controller: _educationController,
                maxLines: 5,
              ),
              _field(
                label: 'Skills (comma separated)',
                controller: _skillsController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}