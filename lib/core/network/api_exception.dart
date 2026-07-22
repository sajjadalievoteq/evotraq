import 'dart:convert';

import 'package:traqtrace_app/core/network/backend_error_parser.dart';

class ApiException implements Exception {
  final int? statusCode;

  final String? code;

  final String message;

  final List<String> validationMessages;

  final dynamic originalException;

  final String? responseBody;

  ApiException({
    this.statusCode,
    this.code,
    required this.message,
    this.validationMessages = const [],
    this.originalException,
    this.responseBody,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: [$statusCode] $message';
    }
    return 'ApiException: $message';
  }

  
  String getUserFriendlyMessage() {
    if (statusCode == null &&
        (responseBody == null || responseBody!.trim().isEmpty) &&
        validationMessages.isEmpty) {
      return 'Network error. Please check your connection and try again.';
    }

    final details = BackendErrorParser.parse(responseBody);
    if (details.displayMessage != null && details.displayMessage!.isNotEmpty) {
      return details.displayMessage!;
    }

    if (validationMessages.isNotEmpty) {
      return validationMessages.join('\n');
    }

    if (message.isNotEmpty &&
        !BackendErrorParser.isGenericFallbackMessage(message) &&
        !message.startsWith('ApiException:') &&
        statusCode != 500) {
      return message;
    }

    switch (statusCode) {
      case 400:
        return message.isNotEmpty &&
                !BackendErrorParser.isGenericFallbackMessage(message)
            ? message
            : 'The request was invalid. Please check your input and try again.';
      case 401:
        return 'Authentication required. Please log in and try again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return message.isNotEmpty &&
                !BackendErrorParser.isGenericFallbackMessage(message)
            ? message
            : 'The requested resource was not found.';
      case 409:
        return message.isNotEmpty &&
                !BackendErrorParser.isGenericFallbackMessage(message)
            ? message
            : 'There was a conflict with the current state of the resource.';
      case 422:
        return message.isNotEmpty &&
                !BackendErrorParser.isGenericFallbackMessage(message)
            ? message
            : 'The request could not be processed. Check your inputs and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        final parsed500 = _parseResponseBody();
        final errorId = parsed500?['errorId']?.toString();
        if (errorId != null && errorId.isNotEmpty) {
          return 'A server error occurred (ref: $errorId). '
              'Check the backend log for details or try again.';
        }
        return 'A server error occurred. Please try again later.';
      default:
        return message.isNotEmpty
            ? message
            : 'Something went wrong. Please try again.';
    }
  }

  Map<String, dynamic>? _parseResponseBody() {
    if (responseBody == null || responseBody!.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(responseBody!);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
