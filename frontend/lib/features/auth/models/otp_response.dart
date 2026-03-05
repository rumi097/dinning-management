import 'package:equatable/equatable.dart';

class OtpResponse extends Equatable {
  final String message;
  final String email;
  final bool success;
  final String? otpCode;

  const OtpResponse({
    required this.message,
    required this.email,
    required this.success,
    this.otpCode,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] as String? ?? '',
      email: json['email'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      otpCode: json['otpCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'email': email, 'success': success, 'otpCode': otpCode};
  }

  @override
  List<Object?> get props => [message, email, success, otpCode];
}
