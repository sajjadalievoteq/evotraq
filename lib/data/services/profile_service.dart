import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/data/services/profile_service_consts.dart';

class ProfileService {
  final DioService _dioService;

  ProfileService({required DioService dioService}) : _dioService = dioService;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: ProfileServiceConsts.noAuthTokenFound);
    }
    return {
      ProfileServiceConsts.contentTypeHeaderKey:
          ProfileServiceConsts.contentTypeHeaderValueJson,
      ProfileServiceConsts.authHeaderKey:
          '${ProfileServiceConsts.authHeaderValuePrefix}$token',
    };
  }

  Map<String, dynamic> _decodeJsonMap(dynamic data) {
    if (data is String) {
      final decoded = json.decode(data);
      return Map<String, dynamic>.from(decoded as Map);
    }
    throw ApiException(message: ProfileServiceConsts.unexpectedResponseFormat);
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
        '${_dioService.baseUrl}${ProfileServiceConsts.userProfilePath}',
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
        message: ProfileServiceConsts.failedToFetchUserProfile,
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: ProfileServiceConsts.failedToFetchUserProfile,
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dioService.put(
        '${_dioService.baseUrl}${ProfileServiceConsts.userProfilePath}',
        data: jsonEncode({
          ProfileServiceConsts.firstNameKey: firstName,
          ProfileServiceConsts.lastNameKey: lastName,
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
        message: ProfileServiceConsts.failedToUpdateProfile,
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: ProfileServiceConsts.failedToUpdateProfile,
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<Uint8List?> getProfilePictureBytes() async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}${ProfileServiceConsts.profilePicturePath}',
        headers: headers,
        responseType: ResponseType.bytes,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List<int>) {
          return Uint8List.fromList(data);
        }
        if (data is Uint8List) {
          return data;
        }
        throw ApiException(message: ProfileServiceConsts.unexpectedResponseFormat);
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to fetch profile picture',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to fetch profile picture',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<User> uploadProfilePicture({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: MediaType.parse(contentType),
        ),
      });

      final response = await _dioService.put(
        '${_dioService.baseUrl}${ProfileServiceConsts.profilePicturePath}',
        data: formData,
        headers: {
          ProfileServiceConsts.authHeaderKey: headers[ProfileServiceConsts.authHeaderKey]!,
        },
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.data);
        return User.fromJson(data);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to upload profile picture',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to upload profile picture',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<User> deleteProfilePicture() async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dioService.delete(
        '${_dioService.baseUrl}${ProfileServiceConsts.profilePicturePath}',
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
        message: 'Failed to delete profile picture',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Failed to delete profile picture',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dioService.put(
        '${_dioService.baseUrl}${ProfileServiceConsts.changePasswordPath}',
        data: jsonEncode({
          ProfileServiceConsts.currentPasswordKey: currentPassword,
          ProfileServiceConsts.newPasswordKey: newPassword,
        }),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: ProfileServiceConsts.failedToChangePassword,
          responseBody: _stringifyResponseData(response.data),
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: ProfileServiceConsts.failedToChangePassword,
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> updateNotificationPreferences({
    required bool emailNotifications,
    required bool appNotifications,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dioService.put(
        '${_dioService.baseUrl}${ProfileServiceConsts.notificationPreferencesPath}',
        data: jsonEncode({
          ProfileServiceConsts.emailNotificationsKey: emailNotifications,
          ProfileServiceConsts.appNotificationsKey: appNotifications,
        }),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: ProfileServiceConsts.failedToUpdateNotificationPreferences,
          responseBody: _stringifyResponseData(response.data),
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: ProfileServiceConsts.failedToUpdateNotificationPreferences,
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> updateAppPreferences({
    required bool darkMode,
    required String language,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await _dioService.put(
        '${_dioService.baseUrl}${ProfileServiceConsts.appPreferencesPath}',
        data: jsonEncode({
          ProfileServiceConsts.darkModeKey: darkMode,
          ProfileServiceConsts.languageKey: language,
        }),
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: ProfileServiceConsts.failedToUpdateAppPreferences,
          responseBody: _stringifyResponseData(response.data),
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: ProfileServiceConsts.failedToUpdateAppPreferences,
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }
}
