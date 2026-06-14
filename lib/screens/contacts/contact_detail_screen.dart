import 'dart:io';

import 'package:business_card_flutter/models/business_card.dart';
import 'package:business_card_flutter/services/business_card_storage_service.dart';
import 'package:flutter/material.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({
    required this.card,
    super.key,
  });

  final BusinessCard card;

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final BusinessCardStorageService _storageService =
      BusinessCardStorageService();

  bool _isDeleting = false;

  BusinessCard get _card => widget.card;

  String get _avatarLetter {
    final name = _card.name.trim();
    return name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Contact?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _storageService.deleteCard(_card.id);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF1D5CFF),
                  child: Text(
                    _avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _card.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_card.company != null) ...[
                const SizedBox(height: 6),
                Text(
                  _card.company!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                  ),
                ),
              ],
              if (_card.designation != null) ...[
                const SizedBox(height: 4),
                Text(
                  _card.designation!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 15,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _ActionButtons(
                hasPhone: _card.phone != null,
                hasEmail: _card.email != null,
                hasWebsite: _card.website != null,
                onCall: () => _showActionMessage('Calling contact...'),
                onEmail: () => _showActionMessage('Opening email...'),
                onWebsite: () => _showActionMessage('Opening website...'),
              ),
              const SizedBox(height: 24),
              if (_card.email != null)
                _DetailCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _card.email!,
                ),
              if (_card.phone != null)
                _DetailCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _card.phone!,
                ),
              if (_card.website != null)
                _DetailCard(
                  icon: Icons.language,
                  label: 'Website',
                  value: _card.website!,
                ),
              if (_card.memo != null)
                _DetailCard(
                  icon: Icons.push_pin_outlined,
                  label: 'Memo',
                  value: _card.memo!,
                ),
              if (_card.imagePath != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Original Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_card.imagePath!),
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return const _ImagePlaceholder();
                    },
                  ),
                ),
              ],
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _isDeleting ? null : _confirmDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isDeleting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : const Icon(Icons.delete_outline),
                label: const Text('Delete Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.hasPhone,
    required this.hasEmail,
    required this.hasWebsite,
    required this.onCall,
    required this.onEmail,
    required this.onWebsite,
  });

  final bool hasPhone;
  final bool hasEmail;
  final bool hasWebsite;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onWebsite;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.phone_outlined,
            label: 'Call',
            onPressed: hasPhone ? onCall : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.email_outlined,
            label: 'Email',
            onPressed: hasEmail ? onEmail : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.language,
            label: 'Website',
            onPressed: hasWebsite ? onWebsite : null,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1D5CFF)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  softWrap: true,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      color: const Color(0xFFF4F5F7),
      alignment: Alignment.center,
      child: const Text(
        'Scanned card preview',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}
