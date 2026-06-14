import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _backgroundColor = Color(0xFFCFDBF5);
const _accentColor = Color(0xFF1D5CFF);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  children: [
                    _QrSection(),
                    SizedBox(height: 24),
                    _ActionsRow(),
                    SizedBox(height: 28),
                    _BusinessCard(),
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
                  tooltip: 'Chat',
                ),
                IconButton(
                  onPressed: () => _showPlaceholder(
                    context,
                    'Notifications screen coming soon',
                  ),
                  icon: const Icon(Icons.notifications_none),
                  tooltip: 'Notifications',
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
  const _QrSection();

  @override
  Widget build(BuildContext context) {
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
            data: 'manas-tiwari-business-card',
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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.phone,
          label: '1 Touch',
        ),
        _ActionButton(
          icon: Icons.send,
          label: 'Send',
        ),
        _ActionButton(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: _accentColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
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
  const _BusinessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manas Tiwari',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 18),
          Divider(),
          SizedBox(height: 14),
          Text(
            'Email',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'official.manastiwari2101@gmail.com',
            style: TextStyle(
              color: _accentColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
