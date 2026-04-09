import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';
import 'package:traqtrace_app/features/user_management/services/user_service.dart';

class UserServiceImpl implements UserService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  UserServiceImpl({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = client,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

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
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to fetch user profile: ${response.body}',
      );
    }
  }

  @override
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update profile: ${response.body}',
      );
    }
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/users/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to change password: ${response.body}',
      );
    }
    
    return true;
  }

  @override
  Future<bool> updateNotificationPreferences({
    required bool emailNotifications,
    required bool appNotifications,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/users/preferences/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'emailNotifications': emailNotifications,
        'appNotifications': appNotifications,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update notification preferences: ${response.body}',
      );
    }
    
    return true;
  }

  @override
  Future<bool> updateAppPreferences({
    required bool darkMode,
    required String language,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.put(
      Uri.parse(_appConfig.appPreferencesEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'darkMode': darkMode,
        'language': language,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update app preferences: ${response.body}',
      );
    }
    
    return true;
  }
}