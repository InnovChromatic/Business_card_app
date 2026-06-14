enum CardSource {
  scanned,
  manual,
  imported,
}

class BusinessCard {
  const BusinessCard({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.source,
    this.company,
    this.designation,
    this.email,
    this.phone,
    this.website,
    this.imagePath,
  });

  final String id;
  final String name;
  final String? company;
  final String? designation;
  final String? email;
  final String? phone;
  final String? website;
  final String? imagePath;
  final DateTime createdAt;
  final CardSource source;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'designation': designation,
      'email': email,
      'phone': phone,
      'website': website,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'source': source.name,
    };
  }

  factory BusinessCard.fromMap(Map<String, dynamic> map) {
    return BusinessCard(
      id: map['id'] as String,
      name: map['name'] as String,
      company: map['company'] as String?,
      designation: map['designation'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      website: map['website'] as String?,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      source: CardSource.values.byName(map['source'] as String),
    );
  }
}
