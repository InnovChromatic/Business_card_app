import 'package:business_card_flutter/screens/camera/camera_screen.dart';
import 'package:business_card_flutter/screens/messages/messages_screen.dart';
import 'package:business_card_flutter/widgets/bottom_nav_shell.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BottomNavShell(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesScreen(),
      ),
    ],
  );
}