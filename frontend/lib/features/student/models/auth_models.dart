/// Auth request/response models matching the backend auth endpoints.

/// Login request payload.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  @override
  String toString() => 'LoginRequest(email: $email)';
}

/// Signup request payload (matches backend SignupRequest DTO).
class SignupRequest {
  final String email;
  final String password;
  final String name;
  final String roll;
  final String phoneNo;
  final String? roomNo;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.roll,
    required this.phoneNo,
    this.roomNo,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'roll': roll,
        'phoneNo': phoneNo,
        if (roomNo != null) 'roomNo': roomNo,
      };

  @override
  String toString() => 'SignupRequest(email: $email, name: $name)';
}

/// Auth response from login/signup/me (matches backend AuthResponse DTO).
class AuthResponse {
  final String token;
  final String email;
  final String role;
  final String name;
  final int userId;
  final int? hallId;
  // Student-only fields
  final String? roll;
  final String? phoneNo;
  final String? roomNo;

  const AuthResponse({
    required this.token,
    required this.email,
    required this.role,
    required this.name,
    required this.userId,
    this.hallId,
    this.roll,
    this.phoneNo,
    this.roomNo,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        name: json['name'] as String,
        userId: json['userId'] as int,
        hallId: json['hallId'] as int?,
        roll: json['roll'] as String?,
        phoneNo: json['phoneNo'] as String?,
        roomNo: json['roomNo'] as String?,
      );

  Map<String, dynamic> toJson() => {
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

  /// Whether this user is a student.
  bool get isStudent => role == 'STUDENT';

  /// Whether this user is a meal manager.
  bool get isMealManager => role == 'MEAL_MANAGER';

  /// Whether this user is a dining manager.
  bool get isDiningManager => role == 'DINING_MANAGER';

  @override
  String toString() =>
      'AuthResponse(userId: $userId, email: $email, role: $role)';
}

/// OTP verification request.
class OtpVerifyRequest {
  final String email;
  final String otp;

  const OtpVerifyRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };

  @override
  String toString() => 'OtpVerifyRequest(email: $email)';
}

/// Password reset request.
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};

  @override
  String toString() => 'ForgotPasswordRequest(email: $email)';
}

/// Reset password with new password.
class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      };

  @override
  String toString() => 'ResetPasswordRequest(email: $email)';
}
