enum NotificationType {
  scanSuccess,
  reminder,
  system,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      type: NotificationType.values.byName(map['type'] as String),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}