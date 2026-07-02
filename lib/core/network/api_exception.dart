import 'dart:convert';

import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class ApiException implements Exception {
  final int? statusCode;
  
  final String message;
  
  final dynamic originalException;
  
  final String? responseBody;

  ApiException({
    this.statusCode,
    required this.message,
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
    if (statusCode == null) {
      return 'Network error. Please check your connection and try again.';
    }

    final parsed = _parseResponseBody();
    if (parsed != null) {
      if (OperationApiErrorMessage.isStructuredErrorBody(parsed)) {
        final fromStructured = OperationApiErrorMessage.fromJsonMap(parsed);
        if (fromStructured != null && fromStructured.isNotEmpty) {
          return fromStructured;
        }
      }
      final fromStructured = _messageFromStructuredBody(parsed);
      if (fromStructured != null && fromStructured.isNotEmpty) {
        return fromStructured;
      }
    }

    if (message.isNotEmpty &&
        !message.startsWith('ApiException:') &&
        message != 'Failed to create object event' &&
        statusCode != 500) {
      return message;
    }

    switch (statusCode) {
      case 400:
        return 'The request was invalid. Please check your input and try again.';
      case 401:
        return 'Authentication required. Please log in and try again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'There was a conflict with the current state of the resource. The GTIN code may already exist.';
      case 422:
        return message.isNotEmpty
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
        return message;
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

  String? _messageFromStructuredBody(Map<String, dynamic> jsonBody) {
    final message = jsonBody['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    final fieldErrors = jsonBody['fieldErrors'];
    if (fieldErrors is Map && fieldErrors.isNotEmpty) {
      return fieldErrors.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    }

    final errors = jsonBody['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join('\n');
    }

    if (errors is Map && errors.isNotEmpty) {
      return errors.values.map((e) => e.toString()).join('\n');
    }

    final error = jsonBody['error'];
    if (error != null && error.toString().isNotEmpty) {
      return error.toString();
    }

    return null;
  }
}
