import 'dart:convert';

/// Central parser for backend error JSON across all TraqTrace API calls.
///
/// Priority (when multiple fields exist):
/// 1. `messages`
/// 2. `errors` / `fieldErrors`
/// 3. nested `error.messages` / `error.errors`
/// 4. `message`
/// 5. nested `error` string
class BackendErrorParser {
  BackendErrorParser._();

  /// Parsed display text + metadata from a response body string or map.
  static BackendErrorDetails parse(Object? body) {
    final map = _asMap(body);
    if (map == null) {
      return const BackendErrorDetails();
    }
    return parseMap(map);
  }

  static BackendErrorDetails parseMap(Map<String, dynamic> json) {
    final parts = <String>[];

    // 1. messages
    _collectList(parts, json['messages']);

    // 2. errors + fieldErrors (only if messages absent)
    if (parts.isEmpty) {
      _collectList(parts, json['errors']);
      _collectFieldErrors(parts, json['fieldErrors']);
    }

    // 3. nested error.messages / error.errors / error.fieldErrors
    final nested = json['error'];
    if (parts.isEmpty && nested is Map) {
      final nestedMap = Map<String, dynamic>.from(nested);
      _collectList(parts, nestedMap['messages']);
      if (parts.isEmpty) {
        _collectList(parts, nestedMap['errors']);
        _collectFieldErrors(parts, nestedMap['fieldErrors']);
      }
    }

    // 4. top-level message (only when nothing more specific was found)
    if (parts.isEmpty) {
      final headline = cleanLine(json['message']?.toString());
      if (headline != null) {
        parts.addAll(_expandValidationText(headline));
      }
    }

    // 5. nested error as plain string
    if (parts.isEmpty && nested is String) {
      final line = cleanLine(nested);
      if (line != null) parts.add(line);
    }

    final code = cleanLine(json['code']?.toString());
    return BackendErrorDetails(
      displayMessage: parts.isEmpty ? null : parts.join('\n'),
      validationMessages: List.unmodifiable(parts),
      code: code,
    );
  }

  /// True when the body looks like an API error payload (not an operation success DTO).
  static bool isStructuredErrorBody(Map<String, dynamic> json) {
    if (json.containsKey('shippingOperationId') ||
        json.containsKey('receivingOperationId') ||
        json.containsKey('packingOperationId') ||
        json.containsKey('returnShippingOperationId') ||
        json.containsKey('returnReceivingOperationId') ||
        json.containsKey('commissioningOperationId')) {
      return false;
    }

    final messages = json['messages'];
    if (messages is List && messages.isNotEmpty) return true;

    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) return true;
    if (errors is Map && errors.isNotEmpty) return true;

    final fieldErrors = json['fieldErrors'];
    if (fieldErrors is Map && fieldErrors.isNotEmpty) return true;

    final code = json['code'];
    if (code is String && code.isNotEmpty) return true;

    final status = json['status'];
    if (status is String &&
        (status.toUpperCase() == 'VALIDATION_ERROR' ||
            status.toUpperCase() == 'FAILED')) {
      return true;
    }
    if (status is num) return true;

    final nested = json['error'];
    if (nested is Map) return true;
    if (nested is String && nested.trim().isNotEmpty) return true;

    final message = json['message'];
    return message is String && message.trim().isNotEmpty;
  }

  static bool isGenericFallbackMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return true;
    final lower = trimmed.toLowerCase();
    return lower.startsWith('failed to create ') ||
        lower.startsWith('failed to get ') ||
        lower.startsWith('failed to process ') ||
        lower.startsWith('network error while') ||
        lower.startsWith('unexpected error ') ||
        lower == 'something went wrong' ||
        lower == 'request failed' ||
        lower == 'the request was invalid. please check your input and try again.';
  }

  static String? cleanLine(String? raw) {
    if (raw == null) return null;
    var text = raw.trim();
    if (text.isEmpty) return null;

    const prefixes = [
      'Object Event validation failed: ',
      'Object Event entity validation failed: ',
      'Validation failed: ',
      'Packing request validation failed',
      'Packing could not be submitted. Please fix the issues below and try again.',
    ];
    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
      }
    }
    return text.isEmpty ? null : text;
  }

  static List<String> _expandValidationText(String text) {
    if (text.contains('\n• ') || text.contains('\n- ')) {
      final lines = text
          .split('\n')
          .map(cleanLine)
          .whereType<String>()
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isNotEmpty) return lines;
    }
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

  static void _collectList(List<String> parts, Object? value) {
    if (value is List) {
      for (final item in value) {
        final line = cleanLine(item?.toString());
        if (line != null) _appendUnique(parts, line);
      }
      return;
    }
    if (value is Map) {
      for (final entry in value.entries) {
        final line = cleanLine('${entry.key}: ${entry.value}');
        if (line != null) _appendUnique(parts, line);
      }
    }
  }

  static void _collectFieldErrors(List<String> parts, Object? fieldErrors) {
    if (fieldErrors is! Map || fieldErrors.isEmpty) return;
    for (final entry in fieldErrors.entries) {
      final line = cleanLine('${entry.key}: ${entry.value}');
      if (line != null) _appendUnique(parts, line);
    }
  }

  static void _appendUnique(List<String> parts, String line) {
    if (!parts.contains(line)) parts.add(line);
  }

  static Map<String, dynamic>? _asMap(Object? body) {
    if (body == null) return null;
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is String) {
      final trimmed = body.trim();
      if (trimmed.isEmpty) return null;
      try {
        final decoded = json.decode(trimmed);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

class BackendErrorDetails {
  const BackendErrorDetails({
    this.displayMessage,
    this.validationMessages = const [],
    this.code,
  });

  final String? displayMessage;
  final List<String> validationMessages;
  final String? code;

  bool get hasValidationMessages => validationMessages.isNotEmpty;
}
