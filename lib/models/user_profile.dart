class UserProfile {
  const UserProfile({
    required this.name,
    this.profileImagePath,
    this.headline,
    this.careerSummary,
    this.education = const [],
    this.skills = const [],
    this.email,
    this.companyName,
    this.department,
    this.position,
    this.companyNumber,
    this.departmentNumber,
    this.directNumber,
    this.fax,
    this.mobileNumber,
    this.postalCode,
    this.websiteUrl,
    this.usageFrom,
    this.usageUntil,
  });

  final String name;
  final String? profileImagePath;
  final String? headline;
  final String? careerSummary;
  final List<String> education;
  final List<String> skills;

  final String? email;
  final String? companyName;
  final String? department;
  final String? position;

  final String? companyNumber;
  final String? departmentNumber;
  final String? directNumber;
  final String? fax;
  final String? mobileNumber;
  final String? postalCode;
  final String? websiteUrl;

  final String? usageFrom;
  final String? usageUntil;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profileImagePath': profileImagePath,
      'headline': headline,
      'careerSummary': careerSummary,
      'education': education,
      'skills': skills,
      'email': email,
      'companyName': companyName,
      'department': department,
      'position': position,
      'companyNumber': companyNumber,
      'departmentNumber': departmentNumber,
      'directNumber': directNumber,
      'fax': fax,
      'mobileNumber': mobileNumber,
      'postalCode': postalCode,
      'websiteUrl': websiteUrl,
      'usageFrom': usageFrom,
      'usageUntil': usageUntil,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String,
      profileImagePath: map['profileImagePath'] as String?,
      headline: map['headline'] as String?,
      careerSummary: map['careerSummary'] as String?,
      education: List<String>.from(map['education'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      email: map['email'] as String?,
      companyName: map['companyName'] as String?,
      department: map['department'] as String?,
      position: map['position'] as String?,
      companyNumber: map['companyNumber'] as String?,
      departmentNumber: map['departmentNumber'] as String?,
      directNumber: map['directNumber'] as String?,
      fax: map['fax'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      postalCode: map['postalCode'] as String?,
      websiteUrl: map['websiteUrl'] as String?,
      usageFrom: map['usageFrom'] as String?,
      usageUntil: map['usageUntil'] as String?,
    );
  }
}