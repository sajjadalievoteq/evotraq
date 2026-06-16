import 'dart:convert';

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
      final fromStructured = _messageFromStructuredBody(parsed);
      if (fromStructured != null && fromStructured.isNotEmpty) {
        return fromStructured;
      }
    }

    if (message.isNotEmpty &&
        !message.startsWith('ApiException:') &&
        message != 'Failed to create object event') {
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
      case 500:
      case 502:
      case 503:
      case 504:
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

    final message = jsonBody['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    final error = jsonBody['error'];
    if (error != null && error.toString().isNotEmpty) {
      return error.toString();
    }

    return null;
  }
}
