import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';
import 'package:traqtrace_app/features/auth/services/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  AuthServiceImpl({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = client,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      // Store only the token part, not the "Bearer " prefix
      await _tokenManager.saveToken(authResponse.token);
      return authResponse;
    } else {
      throw ApiException(
        statusCode: response.statusCode, 
        message: _parseErrorMessage(response.body) ?? 'Login failed',
      );
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Registration failed',
      );
    }
  }

  @override
  Future<User> getCurrentUser() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to get user details',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _tokenManager.deleteToken();
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/auth/password-reset-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      // Always return true to prevent email enumeration
      // The backend will always return 200 OK too
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> validatePasswordResetToken(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/auth/validate-reset-token?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['valid'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    try {
      final response = await _client.post(
        Uri.parse('${_appConfig.apiBaseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${_appConfig.apiBaseUrl}/api/verification/verify-email?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String? _parseErrorMessage(String body) {
    try {
      final Map<String, dynamic> json = jsonDecode(body);
      return json['message'] ?? json['error'];
    } catch (_) {
      return null;
    }
  }
}