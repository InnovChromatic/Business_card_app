import 'package:business_card_flutter/models/app_notification.dart';
import 'package:business_card_flutter/models/business_card.dart';
import 'package:business_card_flutter/models/parsed_card_data.dart';
import 'package:business_card_flutter/providers/contacts_provider.dart';
import 'package:business_card_flutter/services/notification_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardReviewScreen extends ConsumerStatefulWidget {
  const CardReviewScreen({
    required this.data,
    required this.imagePath,
    super.key,
  });

  final ParsedCardData data;
  final String imagePath;

  @override
  ConsumerState<CardReviewScreen> createState() =>
      _CardReviewScreenState();
}

class _CardReviewScreenState extends ConsumerState<CardReviewScreen> {
  final NotificationStorageService _notificationStorage =
      NotificationStorageService();

  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _designationController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.data.name);
    _companyController = TextEditingController(text: widget.data.company);
    _designationController = TextEditingController(
      text: widget.data.designation,
    );
    _emailController = TextEditingController(text: widget.data.email);
    _phoneController = TextEditingController(text: widget.data.phone);
    _websiteController = TextEditingController(text: widget.data.website);
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _saveCard() async {
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

    final now = DateTime.now();

    final card = BusinessCard(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      company: _optionalValue(_companyController),
      designation: _optionalValue(_designationController),
      email: _optionalValue(_emailController),
      phone: _optionalValue(_phoneController),
      website: _optionalValue(_websiteController),
      imagePath: widget.imagePath,
      createdAt: now,
      source: CardSource.scanned,
    );

    try {
      await ref.read(contactsProvider.notifier).addCard(card);

      await _notificationStorage.addNotification(
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'Business card scanned',
          message: '${card.name} was added to contacts',
          createdAt: DateTime.now(),
          type: NotificationType.scanSuccess,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business card saved')),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save business card')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Card'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ReviewField(
                controller: _nameController,
                label: 'Name',
                textInputAction: TextInputAction.next,
              ),
              _ReviewField(
                controller: _companyController,
                label: 'Company',
                textInputAction: TextInputAction.next,
              ),
              _ReviewField(
                controller: _designationController,
                label: 'Designation',
                textInputAction: TextInputAction.next,
              ),
              _ReviewField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              _ReviewField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              _ReviewField(
                controller: _websiteController,
                label: 'Website',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveCard,
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Card'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.controller,
    required this.label,
    required this.textInputAction,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
      ),
    );
  }
}