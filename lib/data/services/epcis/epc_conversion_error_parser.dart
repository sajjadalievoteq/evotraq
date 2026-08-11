import 'dart:convert';

abstract final class EpcConversionErrorParser {
  static String? parse(dynamic responseData) {
    try {
      if (responseData is String) {
        final jsonBody = jsonDecode(responseData);
        if (jsonBody['message'] != null) return jsonBody['message'] as String?;
        if (jsonBody['error'] != null) return jsonBody['error'] as String?;
      } else if (responseData is Map) {
        if (responseData['message'] != null) {
          return responseData['message'] as String?;
        }
        if (responseData['error'] != null) {
          return responseData['error'] as String?;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
