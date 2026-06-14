class ScannedCard {
  const ScannedCard({
    required this.id,
    required this.imagePath,
    required this.rawText,
    required this.synced,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String rawText;
  final bool synced;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'rawText': rawText,
      'synced': synced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ScannedCard.fromMap(Map<String, dynamic> map) {
    return ScannedCard(
      id: map['id'] as String,
      imagePath: map['imagePath'] as String,
      rawText: map['rawText'] as String,
      synced: map['synced'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
