import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String token;
  final String email;
  final String role;
  final String name;
  final int userId;
  final int hallId;
  final String? roll;
  final String? phoneNo;
  final String? roomNo;

  const AuthResponse({
    required this.token,
    required this.email,
    required this.role,
    required this.name,
    required this.userId,
    required this.hallId,
    this.roll,
    this.phoneNo,
    this.roomNo,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      userId: json['userId'] as int,
      hallId: json['hallId'] as int,
      roll: json['roll'] as String?,
      phoneNo: json['phoneNo'] as String?,
      roomNo: json['roomNo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'role': role,
      'name': name,
      'userId': userId,
      'hallId': hallId,
      'roll': roll,
      'phoneNo': phoneNo,
      'roomNo': roomNo,
    };
  }

  @override
  List<Object?> get props => [
    token,
    email,
    role,
    name,
    userId,
    hallId,
    roll,
    phoneNo,
    roomNo,
  ];
}
