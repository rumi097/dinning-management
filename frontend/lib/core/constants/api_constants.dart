class ApiConstants {
  // Base URL - change this to your backend URL
  // For local testing: http://localhost:8080/api/v1
  // For production: update accordingly
  static const String baseUrl = 'http://localhost:8080/api/v1';

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
