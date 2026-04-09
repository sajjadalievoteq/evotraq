import 'dart:convert';

/// Exception thrown when an API request fails
class ApiException implements Exception {
  /// HTTP status code of the error response
  final int? statusCode;
  
  /// Error message from the API
  final String message;
  
  /// Original exception that caused the error, if any
  final dynamic originalException;
  
  /// Original response body if available
  final String? responseBody;

  /// Creates a new API exception
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
    /// Returns a user-friendly error message based on status code
  String getUserFriendlyMessage() {
    if (statusCode == null) {
      return 'Network error. Please check your connection and try again.';
    }
    
    // Try to extract error message from response body for any error status
    if (responseBody != null) {
      try {
        final jsonBody = json.decode(responseBody!);
        if (jsonBody['message'] != null) {
          return jsonBody['message'];
        }
        if (jsonBody['error'] != null) {
          return jsonBody['error'];
        }
      } catch (e) {
        // Failed to parse response body, fall back to default message
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