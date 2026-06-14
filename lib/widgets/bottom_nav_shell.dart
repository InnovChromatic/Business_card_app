import 'package:business_card_flutter/screens/feed/feed_screen.dart';
import 'package:business_card_flutter/screens/home/home_screen.dart';
import 'package:business_card_flutter/screens/messages/messages_screen.dart';
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
    MessagesScreen(),
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
