import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/backend_error_parser.dart';


abstract final class ApiExceptionMapper {
  static ApiException fromHttpResponse(
    Response<dynamic> response, {
    required String fallbackMessage,
  }) {
    final details = BackendErrorParser.parse(response.data);
    final body = _stringify(response.data);
    final exception = ApiException(
      statusCode: response.statusCode,
      code: details.code,
      message: details.displayMessage ?? fallbackMessage,
      validationMessages: details.validationMessages,
      responseBody: body,
    );
    _log(exception);
    return exception;
  }

  static ApiException fromDio(
    DioException exception, {
    required String fallbackMessage,
    StackTrace? stackTrace,
  }) {
    final raw = exception.response?.data;
    final details = BackendErrorParser.parse(raw);
    final body = _stringify(raw);
    final apiException = ApiException(
      statusCode: exception.response?.statusCode,
      code: details.code,
      message: details.displayMessage ?? fallbackMessage,
      validationMessages: details.validationMessages,
      responseBody: body,
      originalException: exception,
    );
    _log(apiException, stackTrace: stackTrace);
    return apiException;
  }

  static String? _stringify(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map || data is List) {
      try {
        return jsonEncode(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  static const int _logBodyPreviewChars = 2048;

  static void _log(ApiException exception, {StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint(
      '[ApiExceptionMapper] ApiException '
      'status=${exception.statusCode} code=${exception.code} '
      'message=${exception.message}',
    );
    final body = exception.responseBody;
    if (body != null && body.isNotEmpty) {
      final preview = body.length <= _logBodyPreviewChars
          ? body
          : '${body.substring(0, _logBodyPreviewChars)}… '
              '[truncated ${body.length - _logBodyPreviewChars} chars]';
      debugPrint('[ApiExceptionMapper] responseBody: $preview');
    }
    if (stackTrace != null) {
      debugPrint('[ApiExceptionMapper] $stackTrace');
    }
  }
}
