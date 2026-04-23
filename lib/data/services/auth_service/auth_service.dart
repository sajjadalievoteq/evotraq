import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';

class AuthService {
  final DioService _dioService;

  AuthService({required DioService dioService}) : _dioService = dioService;

  String? _extractMessageFromDecodedBody(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      final fieldErrors = decoded.entries
          .where((entry) => entry.value is String)
          .map((entry) => '${entry.key}: ${entry.value}')
          .toList();
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.join('\n');
      }
    }

    if (decoded is Map) {
      return _extractMessageFromDecodedBody(Map<String, dynamic>.from(decoded));
    }

    if (decoded is List) {
      final messages = decoded
          .map(_extractMessageFromDecodedBody)
          .whereType<String>()
          .map((message) => message.trim())
          .where((message) => message.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }

    return null;
  }

  String? _parseErrorMessage(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        return _extractMessageFromDecodedBody(decoded) ?? data.trim();
      }
      if (data is Map<String, dynamic>) {
        return _extractMessageFromDecodedBody(data);
      }
      if (data is Map) {
        return _extractMessageFromDecodedBody(data);
      }
      return null;
    } catch (_) {
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      return null;
    }
  }

  String _userFriendlyAuthMessage(
    String? rawMessage, {
    int? statusCode,
    required String fallback,
  }) {
    final message = rawMessage?.trim();
    if (message == null || message.isEmpty) {
      return fallback;
    }

    final normalized = message.toLowerCase();

    if (normalized.contains('email is already in use') ||
        normalized.contains('email already exists') ||
        normalized.contains('email already in use')) {
      return 'An account with this email already exists. Try logging in or use a different email address.';
    }

    if (normalized.contains('username is already taken') ||
        normalized.contains('username already exists') ||
        normalized.contains('username is taken')) {
      return 'That username is already taken. Please choose a different one.';
    }

    if (normalized.contains('invalid username or password')) {
      return 'Incorrect username/email or password.';
    }

    if (normalized.contains('password') &&
        normalized.contains('confirm') &&
        normalized.contains('match')) {
      return 'Passwords do not match.';
    }

    if (normalized.contains('password must')) {
      return message;
    }

    if (normalized.contains('email:')) {
      return message.replaceFirst(RegExp(r'^email:\s*', caseSensitive: false), '');
    }

    if (normalized.contains('username:')) {
      return message.replaceFirst(
        RegExp(r'^username:\s*', caseSensitive: false),
        '',
      );
    }

    if (statusCode == 409 && normalized.contains('already')) {
      return message;
    }

    if (statusCode == 400 && message.contains('\n')) {
      return message.split('\n').first.trim();
    }

    return message;
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

  Map<String, dynamic>? parseResponseMap(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioService.post(
        '${_dioService.baseUrl}${Constants.authLoginEndpoint}',
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
        message: _userFriendlyAuthMessage(
          _parseErrorMessage(response.data),
          statusCode: response.statusCode,
          fallback: 'Login failed',
        ),
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _userFriendlyAuthMessage(
          _parseErrorMessage(e.response?.data),
          statusCode: e.response?.statusCode,
          fallback: 'Login failed',
        ),
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _dioService.post(
        '${_dioService.baseUrl}${Constants.authRegisterEndpoint}',
        data: jsonEncode(request.toJson()),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _userFriendlyAuthMessage(
            _parseErrorMessage(response.data),
            statusCode: response.statusCode,
            fallback: 'Registration failed',
          ),
          responseBody: _stringifyResponseData(response.data),
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _userFriendlyAuthMessage(
          _parseErrorMessage(e.response?.data),
          statusCode: e.response?.statusCode,
          fallback: 'Registration failed',
        ),
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<String> resendVerificationEmail(String email) async {
    try {
      final response = await _dioService.post(
        '${_dioService.baseUrl}${Constants.authResendVerificationEmailEndpoint}',
        data: jsonEncode({'email': email.trim()}),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return _parseErrorMessage(response.data) ??
            'If an unverified account exists for that email, a new verification email has been sent.';
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _userFriendlyAuthMessage(
          _parseErrorMessage(response.data),
          statusCode: response.statusCode,
          fallback: 'Failed to resend verification email',
        ),
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _userFriendlyAuthMessage(
          _parseErrorMessage(e.response?.data),
          statusCode: e.response?.statusCode,
          fallback: 'Failed to resend verification email',
        ),
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final trimmedUsername = username.trim();

    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}${Constants.authCheckUsernameEndpoint}',
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
        '${_dioService.baseUrl}${Constants.usersProfileEndpoint}',
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
        '${_dioService.baseUrl}${Constants.authPasswordResetRequestEndpoint}',
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
        '${_dioService.baseUrl}${Constants.authValidateResetTokenEndpoint}',
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
        '${_dioService.baseUrl}${Constants.authResetPasswordEndpoint}',
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
        '${_dioService.baseUrl}${Constants.verificationVerifyEmailEndpoint}',
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
