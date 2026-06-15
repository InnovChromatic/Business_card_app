import 'package:business_card_flutter/models/app_notification.dart';
import 'package:business_card_flutter/models/business_card.dart';
import 'package:business_card_flutter/models/parsed_card_data.dart';
import 'package:business_card_flutter/providers/contacts_provider.dart';
import 'package:business_card_flutter/services/notification_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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
  ConsumerState<CardReviewScreen> createState() => _CardReviewScreenState();
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

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  bool _containsPhone(Contact contact, String normalizedPhone) {
    for (final phone in contact.phones) {
      final existing = _normalizePhone(phone.number);
      if (existing == normalizedPhone) {
        return true;
      }
    }
    return false;
  }

  bool _containsEmail(Contact contact, String email) {
    for (final e in contact.emails) {
      if (e.address.toLowerCase() == email.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  Future<Contact?> _findExistingContact(BusinessCard card) async {
    final contacts = await FlutterContacts.getContacts(withProperties: true);

    final normalizedPhone = card.phone != null
        ? _normalizePhone(card.phone!)
        : null;

    for (final contact in contacts) {
      if (normalizedPhone != null && _containsPhone(contact, normalizedPhone)) {
        return contact;
      }

      if (card.email != null && _containsEmail(contact, card.email!)) {
        return contact;
      }
    }

    return null;
  }

  Future<void> _mergeContact(Contact existing, BusinessCard card) async {
    if (card.phone != null) {
      final normalized = _normalizePhone(card.phone!);

      if (!_containsPhone(existing, normalized)) {
        existing.phones.add(Phone(card.phone!));
      }
    }

    if (card.email != null) {
      if (!_containsEmail(existing, card.email!)) {
        existing.emails.add(Email(card.email!));
      }
    }

    if (card.company != null || card.designation != null) {
      if (existing.organizations.isEmpty) {
        existing.organizations.add(
          Organization(
            company: card.company ?? '',
            title: card.designation ?? '',
          ),
        );
      } else {
        final org = existing.organizations.first;

        if (org.company.isEmpty && card.company != null) {
          org.company = card.company!;
        }

        if (org.title.isEmpty && card.designation != null) {
          org.title = card.designation!;
        }
      }
    }

    await existing.update();
  }

  Future<void> _insertNewContact(BusinessCard card) async {
    final contact = Contact();

    contact.name.first = card.name;

    if (card.phone != null) {
      contact.phones = [Phone(card.phone!)];
    }

    if (card.email != null) {
      contact.emails = [Email(card.email!)];
    }

    if (card.company != null || card.designation != null) {
      contact.organizations = [
        Organization(
          company: card.company ?? '',
          title: card.designation ?? '',
        ),
      ];
    }

    await contact.insert();
  }

  Future<void> _saveToPhoneContacts(BusinessCard card) async {
    final permission = await FlutterContacts.requestPermission();

    if (!permission) {
      debugPrint('Contacts permission denied');
      return;
    }

    try {
      final existing = await _findExistingContact(card);

      if (existing != null) {
        await _mergeContact(existing, card);
        debugPrint('Merged with existing contact');
      } else {
        await _insertNewContact(card);
        debugPrint('Inserted new contact');
      }
    } catch (e) {
      debugPrint('Phone contact sync failed: $e');
    }
  }

  Future<void> _saveCard() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
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
      final wasAdded = await ref.read(contactsProvider.notifier).addCard(card);

      await _saveToPhoneContacts(card);

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
        SnackBar(
          content: Text(
            wasAdded
                ? 'Business card saved successfully'
                : 'Contact already exists',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Save error: $e');

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
      appBar: AppBar(title: const Text('Review Card')),
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
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
