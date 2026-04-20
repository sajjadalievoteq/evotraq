import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';

class UserService {
  final DioService _dioService;

  UserService({required DioService dioService}) : _dioService = dioService;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeJsonMap(dynamic data) {
    if (data is String) {
      final decoded = json.decode(data);
      return Map<String, dynamic>.from(decoded as Map);
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
      final response = await _dioService.get(
        '${_dioService.baseUrl}/users/profile',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _dioService.put(
        '${_dioService.baseUrl}/users/profile',
        data: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        }),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _dioService.put(
        '${_dioService.baseUrl}/users/password',
        data: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _dioService.put(
        '${_dioService.baseUrl}/users/preferences/notifications',
        data: jsonEncode({
          'emailNotifications': emailNotifications,
          'appNotifications': appNotifications,
        }),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
      final response = await _dioService.put(
        '${_dioService.baseUrl}/users/preferences/app',
        data: jsonEncode({'darkMode': darkMode, 'language': language}),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
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
