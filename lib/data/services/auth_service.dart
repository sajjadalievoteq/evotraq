import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';

class AuthService {
  final Dio _dio;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  AuthService({
    required Dio dio,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _dio = dio,
       _tokenManager = tokenManager,
       _appConfig = appConfig;

  String? _parseErrorMessage(dynamic data) {
    try {
      if (data is String) {
        final Map<String, dynamic> json = jsonDecode(data);
        return json['message'] ?? json['error'];
      }
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'];
      }
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        return map['message'] ?? map['error'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _stringifyResponseData(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '${_appConfig.apiBaseUrl}/auth/login',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(
          response.data is String ? jsonDecode(response.data) : response.data,
        );
        await _tokenManager.saveToken(authResponse.token);
        return authResponse;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.data) ?? 'Login failed',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _parseErrorMessage(e.response?.data) ?? 'Login failed',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '${_appConfig.apiBaseUrl}/auth/register',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response.data) ?? 'Registration failed',
          responseBody: _stringifyResponseData(response.data),
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _parseErrorMessage(e.response?.data) ?? 'Registration failed',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<User> getCurrentUser() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    try {
      final response = await _dio.get(
        '${_appConfig.apiBaseUrl}/users/profile',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        return User.fromJson(data);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ?? 'Failed to get user details',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message:
            _parseErrorMessage(e.response?.data) ??
            'Failed to get user details',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> logout() async {
    await _tokenManager.deleteToken();
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await _dio.post(
        '${_appConfig.apiBaseUrl}/auth/password-reset-request',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      // Always return true to prevent email enumeration
      // The backend will always return 200 OK too
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validatePasswordResetToken(String token) async {
    try {
      final response = await _dio.get(
        '${_appConfig.apiBaseUrl}/auth/validate-reset-token',
        queryParameters: {'token': token},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = (response.data is String)
            ? Map<String, dynamic>.from(jsonDecode(response.data))
            : Map<String, dynamic>.from(response.data as Map);
        return data['valid'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        '${_appConfig.apiBaseUrl}/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _dio.get(
        '${_appConfig.apiBaseUrl}/api/verification/verify-email',
        queryParameters: {'token': token},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
