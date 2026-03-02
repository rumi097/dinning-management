import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/features/auth/models/auth_response.dart';
import 'package:frontend/features/auth/models/login_request.dart';
import 'package:frontend/features/auth/models/signup_request.dart';
import 'package:frontend/features/auth/models/otp_response.dart';
import 'package:frontend/features/auth/models/otp_verification_response.dart';
import 'package:frontend/features/auth/models/signup_response.dart';

class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Backend returns AuthResponse directly (not wrapped in ApiResponse)
        final authResponse = AuthResponse.fromJson(response.data!);

        // Save token and user info
        await _tokenStorage.saveToken(authResponse.token);
        await _tokenStorage.saveEmail(authResponse.email);
        await _tokenStorage.saveUserId(authResponse.userId);
        await _tokenStorage.saveRole(authResponse.role);

        return authResponse;
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Send OTP for signup (step 1)
  Future<OtpResponse> sendSignupOtp(String email) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.sendOtpEndpoint,
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200 && response.data != null) {
        return OtpResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to send OTP');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Verify signup OTP (step 2)
  Future<OtpVerificationResponse> verifySignupOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyOtpEndpoint,
        queryParameters: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200 && response.data != null) {
        return OtpVerificationResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to verify OTP');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Complete signup with credentials (step 3)
  /// After OTP is verified, send signup data to backend
  /// Returns SignupResponse (no token - user must login after signup)
  Future<SignupResponse> completeSignup(SignupRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.signupEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        // Backend returns SignupResponse (not AuthResponse)
        return SignupResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to complete signup');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Send OTP for password reset
  Future<OtpResponse> sendResetOtp(String email) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.sendResetOtpEndpoint,
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200 && response.data != null) {
        return OtpResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to send reset OTP');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Verify reset OTP
  Future<OtpVerificationResponse> verifyResetOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyOtpEndpoint,
        queryParameters: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200 && response.data != null) {
        return OtpVerificationResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to verify reset OTP');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Reset password
  Future<void> resetPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      // TODO: Backend needs to implement this endpoint
      await _apiClient.post(
        ApiConstants.resetPasswordEndpoint,
        data: {
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get current logged-in user
  Future<AuthResponse> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getCurrentUserEndpoint,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Backend returns AuthResponse directly with Bearer token in Authorization header
        return AuthResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to get current user');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _tokenStorage.clearAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _tokenStorage.isLoggedIn();
  }

  /// Get stored token
  Future<String?> getToken() async {
    return _tokenStorage.getToken();
  }

  /// Get stored role
  Future<String?> getRole() async {
    return _tokenStorage.getRole();
  }

  /// Handle DioException and return user-friendly error
  String _handleDioException(DioException error) {
    return ApiClient.getErrorMessage(error);
  }
}
