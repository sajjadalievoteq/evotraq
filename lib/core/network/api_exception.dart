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
    
    if (responseBody != null) {
      try {
        final jsonBody = json.decode(responseBody!);
        final errors = jsonBody['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return errors.values.join(', ');
        }
        if (jsonBody['message'] != null) {
          return jsonBody['message'] as String;
        }
        if (jsonBody['error'] != null) {
          return jsonBody['error'] as String;
        }
      } catch (_) {
      }
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
}