import 'package:equatable/equatable.dart';

class OtpVerificationResponse extends Equatable {
  final String message;
  final String email;
  final bool verified;

  const OtpVerificationResponse({
    required this.message,
    required this.email,
    required this.verified,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponse(
      message: json['message'] as String? ?? '',
      email: json['email'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'email': email, 'verified': verified};
  }

  @override
  List<Object?> get props => [message, email, verified];
}
