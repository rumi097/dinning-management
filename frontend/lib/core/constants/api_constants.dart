import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL — can be overridden at build time via:
  //   --dart-define=BASE_URL=https://your-server.com/api/v1
  //
  // If not overridden:
  // - Debug/Profile: localhost (for local development)
  // - Release: Render production backend
  static const String _buildTimeBaseUrl = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    if (_buildTimeBaseUrl.isNotEmpty) {
      return _buildTimeBaseUrl;
    }

    return kReleaseMode
        ? 'https://dsi-backend-gy8s.onrender.com/api/v1'
        : 'http://localhost:8080/api/v1';
  }

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String sendOtpEndpoint = '/auth/send-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String getCurrentUserEndpoint = '/auth/me';

  // TODO: These endpoints need to be implemented in the backend
  static const String sendResetOtpEndpoint =
      '/auth/send-otp'; // Same endpoint, different flow
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // API timeout in milliseconds
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Headers
  static const String contentTypeHeader = 'content-type';
  static const String authorizationHeader = 'authorization';
  static const String applicationJsonContentType = 'application/json';
}
