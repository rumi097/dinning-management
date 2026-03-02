import 'package:equatable/equatable.dart';

class SignupResponse extends Equatable {
  final String message;
  final String email;
  final int userId;

  const SignupResponse({
    required this.message,
    required this.email,
    required this.userId,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'] as String? ?? '',
      email: json['email'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'email': email, 'userId': userId};
  }

  @override
  List<Object?> get props => [message, email, userId];
}
