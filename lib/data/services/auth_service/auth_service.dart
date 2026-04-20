import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';

class AuthService {
  final DioService _dioService;

  AuthService({required DioService dioService}) : _dioService = dioService;

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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/auth/login',
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
        await _dioService.saveAuthToken(authResponse.token);
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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/auth/register',
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

  Future<bool> checkUsernameAvailability(String username) async {
    final trimmedUsername = username.trim();

    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}/auth/check-username',
        queryParameters: {'username': trimmedUsername},
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? Map<String, dynamic>.from(jsonDecode(response.data))
            : Map<String, dynamic>.from(response.data as Map);
        return data['available'] == true;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to verify username availability',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message:
            _parseErrorMessage(e.response?.data) ??
            'Failed to verify username availability',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<User> getCurrentUser() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}/users/profile',
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
    await _dioService.removeAuthToken();
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await _dioService.post(
        '${_dioService.baseUrl}/auth/password-reset-request',
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
      final response = await _dioService.get(
        '${_dioService.baseUrl}/auth/validate-reset-token',
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
      final response = await _dioService.post(
        '${_dioService.baseUrl}/auth/reset-password',
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

  Future<String> verifyEmail(String token) async {
    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}/verification/verify-email',
        queryParameters: {'token': token},
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return _parseErrorMessage(response.data) ??
            'Email verified successfully. Your account is now pending admin approval.';
      }

      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ?? 'Email verification failed',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message:
            _parseErrorMessage(e.response?.data) ?? 'Email verification failed',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }
}
