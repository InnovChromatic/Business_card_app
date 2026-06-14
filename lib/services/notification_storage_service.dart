import 'package:business_card_flutter/models/app_notification.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationStorageService {
  static const String _boxName = 'notifications';

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    final box = _getBox();
    await box.put(notification.id, notification.toMap());
  }

  Future<void> deleteNotification(String id) async {
    final box = _getBox();
    await box.delete(id);
  }

  Future<void> markAsRead(String id) async {
    final box = _getBox();
    final raw = box.get(id);

    if (raw == null || raw is! Map) return;

    final notification = AppNotification.fromMap(
      Map<String, dynamic>.from(raw),
    );

    final updated = notification.copyWith(isRead: true);
    await box.put(id, updated.toMap());
  }

  List<AppNotification> getAllNotifications() {
    final box = _getBox();

    final notifications = box.values.map((value) {
      if (value is! Map) {
        throw const NotificationStorageException(
          'Stored notification data has invalid format.',
        );
      }

      return AppNotification.fromMap(
        Map<String, dynamic>.from(value),
      );
    }).toList();

    notifications.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notifications;
  }

  Box<dynamic> _getBox() {
    if (!Hive.isBoxOpen(_boxName)) {
      throw const NotificationStorageException(
        'Notification storage unavailable.',
      );
    }

    return Hive.box<dynamic>(_boxName);
  }
}

class NotificationStorageException implements Exception {
  const NotificationStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}