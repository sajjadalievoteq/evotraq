import 'dart:convert';

import 'package:traqtrace_app/core/network/api_exception.dart';

abstract final class OperationApiErrorMessage {
  static bool isStructuredErrorBody(Map<String, dynamic> json) {
    final code = json['code'];
    final status = json['status'];
    return code is String &&
        code.isNotEmpty &&
        status is num &&
        !json.containsKey('shippingOperationId') &&
        !json.containsKey('receivingOperationId') &&
        !json.containsKey('packingOperationId');
  }

  static String? fromJsonMap(Map<String, dynamic> json) {
    final parts = <String>[];

    final headline = cleanLine(json['message']?.toString());
    if (headline != null) {
      parts.addAll(_expandValidationText(headline));
    }

    final errors = json['errors'];
    if (errors is List) {
      for (final item in errors) {
        final line = cleanLine(item?.toString());
        if (line != null) {
          _appendUnique(parts, line);
        }
      }
    }

    final fieldErrors = json['fieldErrors'];
    if (fieldErrors is Map) {
      for (final entry in fieldErrors.entries) {
        final line = cleanLine('${entry.key}: ${entry.value}');
        if (line != null) {
          _appendUnique(parts, line);
        }
      }
    }

    if (parts.isEmpty) {
      final error = cleanLine(json['error']?.toString());
      if (error != null) return error;
      return null;
    }

    return parts.join('\n');
  }

  static String fromApiException(ApiException exception) {
    final parsed = _parseResponseBody(exception.responseBody);
    if (parsed != null) {
      final fromBody = fromJsonMap(parsed);
      if (fromBody != null && fromBody.isNotEmpty) {
        return fromBody;
      }
    }

    final fallback = cleanLine(exception.message);
    if (fallback != null &&
        !_isGenericServiceFallback(fallback) &&
        exception.statusCode != 500) {
      return fallback;
    }

    return exception.getUserFriendlyMessage();
  }

  static String epcConversionFailures(List<String> failedBarcodes) {
    if (failedBarcodes.isEmpty) {
      return 'One or more scanned values could not be converted to EPC URIs.';
    }
    final preview = failedBarcodes.take(5).join('\n• ');
    final suffix = failedBarcodes.length > 5
        ? '\n… and ${failedBarcodes.length - 5} more'
        : '';
    return 'Could not convert ${failedBarcodes.length} scan(s) to EPC URIs. '
        'Use a registered SGTIN (GTIN + serial), SSCC, or lot-based GTIN barcode.\n'
        '• $preview$suffix';
  }

  static String unexpected(String operationName, Object error) =>
      'An unexpected error occurred while submitting $operationName: $error';

  static String? cleanLine(String? raw) {
    if (raw == null) return null;
    var text = raw.trim();
    if (text.isEmpty) return null;

    const prefixes = [
      'Object Event validation failed: ',
      'Object Event entity validation failed: ',
      'Validation failed: ',
    ];
    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
      }
    }
    return text.isEmpty ? null : text;
  }

  static List<String> _expandValidationText(String text) {
    if (!text.contains(', ') || text.length <= 120) {
      final cleaned = cleanLine(text);
      return cleaned == null ? const [] : [cleaned];
    }
    return text
        .split(', ')
        .map(cleanLine)
        .whereType<String>()
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static void _appendUnique(List<String> parts, String line) {
    if (!parts.contains(line)) {
      parts.add(line);
    }
  }

  static Map<String, dynamic>? _parseResponseBody(String? responseBody) {
    if (responseBody == null || responseBody.trim().isEmpty) return null;
    try {
      final decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  static bool _isGenericServiceFallback(String message) {
    return message == 'Failed to create shipping operation' ||
        message == 'Failed to create receiving operation' ||
        message.startsWith('Network error while');
  }
}
