import 'package:business_card_flutter/screens/contacts/contacts_screen.dart';
import 'package:business_card_flutter/screens/feed/feed_screen.dart';
import 'package:business_card_flutter/screens/home/home_screen.dart';
import 'package:business_card_flutter/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    FeedScreen(),
    ContactsScreen(),
    ProfileScreen(),
  ];

  int get _selectedNavigationIndex {
    return _currentIndex < 2 ? _currentIndex : _currentIndex + 1;
  }

  void _onNavigationTap(int index) {
    if (index == 2) {
      context.push('/camera');
      return;
    }

    setState(() {
      _currentIndex = index > 2 ? index - 1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavigationIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.import_export),
            label: 'Exchange',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: _CameraNavigationIcon(),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
        ],
      ),
    );
  }
}

class _CameraNavigationIcon extends StatelessWidget {
  const _CameraNavigationIcon();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1D5CFF),
      elevation: 5,
      shape: const CircleBorder(),
      child: const SizedBox.square(
        dimension: 46,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
