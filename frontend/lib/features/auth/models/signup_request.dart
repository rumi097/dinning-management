import 'package:equatable/equatable.dart';

class SignupRequest extends Equatable {
  final String email;
  final String password;
  final String name;
  final String? roll;
  final String? phoneNo;
  final String? roomNo;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.name,
    this.roll,
    this.phoneNo,
    this.roomNo,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) {
    return SignupRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      roll: json['roll'] as String?,
      phoneNo: json['phoneNo'] as String?,
      roomNo: json['roomNo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'roll': roll,
      'phoneNo': phoneNo,
      'roomNo': roomNo,
    };
  }

  @override
  List<Object?> get props => [email, password, name, roll, phoneNo, roomNo];
}
