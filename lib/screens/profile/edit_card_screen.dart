import 'package:business_card_flutter/models/user_profile.dart';
import 'package:business_card_flutter/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditCardScreen extends ConsumerStatefulWidget {
  const EditCardScreen({
    required this.profile,
    super.key,
  });

  final UserProfile profile;

  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  late final TextEditingController _companyController;
  late final TextEditingController _departmentController;
  late final TextEditingController _positionController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyNumberController;
  late final TextEditingController _departmentNumberController;
  late final TextEditingController _directNumberController;
  late final TextEditingController _faxController;
  late final TextEditingController _mobileController;
  late final TextEditingController _postalController;
  late final TextEditingController _websiteController;
  late final TextEditingController _usageFromController;
  late final TextEditingController _usageUntilController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final p = widget.profile;

    _companyController = TextEditingController(text: p.companyName ?? '');
    _departmentController = TextEditingController(text: p.department ?? '');
    _positionController = TextEditingController(text: p.position ?? '');
    _emailController = TextEditingController(text: p.email ?? '');
    _companyNumberController =
        TextEditingController(text: p.companyNumber ?? '');
    _departmentNumberController =
        TextEditingController(text: p.departmentNumber ?? '');
    _directNumberController =
        TextEditingController(text: p.directNumber ?? '');
    _faxController = TextEditingController(text: p.fax ?? '');
    _mobileController = TextEditingController(text: p.mobileNumber ?? '');
    _postalController = TextEditingController(text: p.postalCode ?? '');
    _websiteController = TextEditingController(text: p.websiteUrl ?? '');
    _usageFromController = TextEditingController(text: p.usageFrom ?? '');
    _usageUntilController = TextEditingController(text: p.usageUntil ?? '');
  }

  String? _value(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final old = widget.profile;

    final updated = UserProfile(
      name: old.name,
      profileImagePath: old.profileImagePath,
      headline: old.headline,
      careerSummary: old.careerSummary,
      education: old.education,
      skills: old.skills,
      email: _value(_emailController),
      companyName: _value(_companyController),
      department: _value(_departmentController),
      position: _value(_positionController),
      companyNumber: _value(_companyNumberController),
      departmentNumber: _value(_departmentNumberController),
      directNumber: _value(_directNumberController),
      fax: _value(_faxController),
      mobileNumber: _value(_mobileController),
      postalCode: _value(_postalController),
      websiteUrl: _value(_websiteController),
      usageFrom: _value(_usageFromController),
      usageUntil: _value(_usageUntilController),
    );

    await ref.read(profileProvider.notifier).updateProfile(updated);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _companyNumberController.dispose();
    _departmentNumberController.dispose();
    _directNumberController.dispose();
    _faxController.dispose();
    _mobileController.dispose();
    _postalController.dispose();
    _websiteController.dispose();
    _usageFromController.dispose();
    _usageUntilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Card'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _sectionTitle('Company Info'),
              _field('Company Name', _companyController),
              _field('Department', _departmentController),
              _field('Position', _positionController),

              _sectionTitle('Contact Info'),
              _field('Email', _emailController),
              _field('Company Number', _companyNumberController),
              _field('Department Number', _departmentNumberController),
              _field('Direct Number', _directNumberController),
              _field('FAX', _faxController),
              _field('Mobile Number', _mobileController),
              _field('Postal Code', _postalController),
              _field('Website URL', _websiteController),

              _sectionTitle('Usage Period'),
              _field('From', _usageFromController),
              _field('Until', _usageUntilController),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: const Text('Save Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}