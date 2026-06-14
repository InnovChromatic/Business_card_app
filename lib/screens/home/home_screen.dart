import 'package:business_card_flutter/models/user_profile.dart';
import 'package:business_card_flutter/providers/profile_provider.dart';
import 'package:business_card_flutter/screens/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _backgroundColor = Color(0xFFCFDBF5);
const _accentColor = Color(0xFF1D5CFF);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  children: [
                    _QrSection(profile: profile),
                    const SizedBox(height: 24),
                    const _ActionsRow(),
                    const SizedBox(height: 28),
                    _BusinessCard(profile: profile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'eight',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            'Virtual Card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showPlaceholder(
                    context,
                    'Messages screen coming soon',
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  const _QrSection({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final qrData = profile.email ?? profile.mobileNumber ?? profile.name;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: QrImageView(
            data: qrData,
            size: 190,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Send anyone your card via QR code',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.phone,
          label: '1 Touch',
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.send,
          label: 'Send',
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          onTap: () {
            context.push('/camera');
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: _accentColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            const SizedBox(height: 6),
            Text(profile.position!),
          ],
          if (profile.companyName != null) ...[
            const SizedBox(height: 4),
            Text(
              profile.companyName!,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          if (profile.email != null)
            Text(
              "Email: ${profile.email!}",
              style: const TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (profile.mobileNumber != null) ...[
            const SizedBox(height: 8),
            Text("Mobile: ${profile.mobileNumber!}"),
          ],
          if (profile.websiteUrl != null) ...[
            const SizedBox(height: 8),
            Text("Website: ${profile.websiteUrl!}"),
          ],
        ],
      ),
    );
  }
}