import 'dart:ui';

/// Represents a user in the system (matches backend User + StudentInfo entities).
class UserModel {
  final int id;
  final String email;
  final String name;
  final String role; // 'STUDENT' | 'MEAL_MANAGER' | 'DINING_MANAGER'
  final int? hallId;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.hallId,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        hallId: json['hallId'] as int?,
        isVerified: json['isVerified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'hallId': hallId,
        'isVerified': isVerified,
      };

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    int? hallId,
    bool? isVerified,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        hallId: hallId ?? this.hallId,
        isVerified: isVerified ?? this.isVerified,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, role: $role)';
}

/// Extended student profile (matches backend StudentInfo entity).
class StudentProfile {
  final int id;
  final String email;
  final String name;
  final String roll;
  final String phoneNo;
  final String? roomNo;
  final int? hallId;
  final String? hallName;
  final Color? avatarColor;

  const StudentProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.roll,
    required this.phoneNo,
    this.roomNo,
    this.hallId,
    this.hallName,
    this.avatarColor,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
        roll: json['roll'] as String,
        phoneNo: json['phoneNo'] as String,
        roomNo: json['roomNo'] as String?,
        hallId: json['hallId'] as int?,
        hallName: json['hallName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'roll': roll,
        'phoneNo': phoneNo,
        'roomNo': roomNo,
        'hallId': hallId,
        'hallName': hallName,
      };

  /// Get display initials (first letter of name).
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  StudentProfile copyWith({
    int? id,
    String? email,
    String? name,
    String? roll,
    String? phoneNo,
    String? roomNo,
    int? hallId,
    String? hallName,
    Color? avatarColor,
  }) =>
      StudentProfile(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        roll: roll ?? this.roll,
        phoneNo: phoneNo ?? this.phoneNo,
        roomNo: roomNo ?? this.roomNo,
        hallId: hallId ?? this.hallId,
        hallName: hallName ?? this.hallName,
        avatarColor: avatarColor ?? this.avatarColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'StudentProfile(id: $id, name: $name, roll: $roll, hallName: $hallName)';
}
