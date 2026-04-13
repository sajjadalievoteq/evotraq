import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/http_service.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';

class AuthService {
  final HttpService _httpService;

  AuthService({required HttpService httpService}) : _httpService = httpService;

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
      final response = await _httpService.post(
        '${_httpService.baseUrl}/auth/login',
        data: jsonEncode(request.toJson()),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final authResponse = AuthResponse.fromJson(data);
        await _httpService.saveAuthToken(authResponse.token);
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
      final response = await _httpService.post(
        '${_httpService.baseUrl}/auth/register',
        data: jsonEncode(request.toJson()),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    try {
      final response = await _httpService.get(
        '${_httpService.baseUrl}/users/profile',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        return User.fromJson(data as Map<String, dynamic>);
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
    await _httpService.removeAuthToken();
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await _httpService.post(
        '${_httpService.baseUrl}/auth/password-reset-request',
        data: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _httpService.get(
        '${_httpService.baseUrl}/auth/validate-reset-token',
        queryParameters: {'token': token},
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _httpService.post(
        '${_httpService.baseUrl}/auth/reset-password',
        data: jsonEncode({
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _httpService.get(
        '${_httpService.baseUrl}/verification/verify-email',
        queryParameters: {'token': token},
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
