part of 'auth_service.dart';

extension AuthServiceAccountActions on AuthService {
  Future<List<UserSession>> listSessions() async {
    try {
      final response = await _dioService.get(
        '${_dioService.baseUrl}${Constants.authSessionsEndpoint}',
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final decoded = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        if (decoded is! List) {
          throw ApiException(message: 'Unexpected sessions response format');
        }
        return decoded
            .map(
              (item) =>
                  UserSession.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.data) ?? 'Failed to load sessions',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message:
            _parseErrorMessage(e.response?.data) ?? 'Failed to load sessions',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> revokeSession(String sessionId) async {
    try {
      final response = await _dioService.delete(
        '${_dioService.baseUrl}${Constants.authSessionsEndpoint}/$sessionId',
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ?? 'Failed to sign out session',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message:
            _parseErrorMessage(e.response?.data) ??
            'Failed to sign out session',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
  }

  Future<void> revokeOtherSessions() async {
    try {
      final response = await _dioService.post(
        '${_dioService.baseUrl}${Constants.authSessionsRevokeOthersEndpoint}',
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to sign out other sessions',
        responseBody: _stringifyResponseData(response.data),
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message:
            _parseErrorMessage(e.response?.data) ??
            'Failed to sign out other sessions',
        responseBody: _stringifyResponseData(e.response?.data),
        originalException: e,
      );
    }
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
