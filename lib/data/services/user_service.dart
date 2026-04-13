import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';

class UserService {
  final Dio _dio;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  UserService({
    required Dio dio,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _dio = dio,
       _tokenManager = tokenManager,
       _appConfig = appConfig;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String) {
      final decoded = json.decode(data);
      return Map<String, dynamic>.from(decoded as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(message: 'Unexpected response format');
  }

  String? _stringifyResponseData(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    try {
      return json.encode(data);
    } catch (_) {
      return data.toString();
    }
  }

  Future<User> getCurrentUser() async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dio.get(
        '${_appConfig.apiBaseUrl}/users/profile',
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.data);
        return User.fromJson(data);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to fetch user profile',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to fetch user profile',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dio.put(
        '${_appConfig.apiBaseUrl}/users/profile',
        data: {'firstName': firstName, 'lastName': lastName, 'email': email},
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.data);
        return User.fromJson(data);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update profile',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to update profile',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dio.put(
        '${_appConfig.apiBaseUrl}/users/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to change password',
          responseBody: _stringifyResponseData(response.data),
        );
      }

      return true;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to change password',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<bool> updateNotificationPreferences({
    required bool emailNotifications,
    required bool appNotifications,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dio.put(
        '${_appConfig.apiBaseUrl}/users/preferences/notifications',
        data: {
          'emailNotifications': emailNotifications,
          'appNotifications': appNotifications,
        },
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to update notification preferences',
          responseBody: _stringifyResponseData(response.data),
        );
      }

      return true;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to update notification preferences',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<bool> updateAppPreferences({
    required bool darkMode,
    required String language,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dio.put(
        _appConfig.appPreferencesEndpoint,
        data: {'darkMode': darkMode, 'language': language},
        options: Options(headers: headers, validateStatus: (_) => true),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to update app preferences',
          responseBody: _stringifyResponseData(response.data),
        );
      }

      return true;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to update app preferences',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }
}
