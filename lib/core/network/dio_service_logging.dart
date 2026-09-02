import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const bool kDioLogFullBodies =
    bool.fromEnvironment('DIO_LOG_FULL_BODIES', defaultValue: false);

const int kDioBodyPreviewLimitChars = 4096;

const List<String> kDioLargePayloadPathHints = [
  '/master-data/',
  '/glns',
  '/gtins',
  '/sgtins',
  '/ssccs',
  '/notifications/',
  '/job-queue/',
  '/dashboard/',
];

abstract final class DioServiceLogger {
  static final RegExp _sensitiveKey = RegExp(
    r'(authorization|password|passwd|secret|token|api[_-]?key|access[_-]?token|'
    r'refresh[_-]?token|bearer|cookie|set-cookie|webhook.?secret|credential)',
    caseSensitive: false,
  );

  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('──────── API REQUEST ────────')
      ..writeln('${options.method} ${_sanitizedUrl(options.uri)}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('Query: ${_redactMap(options.queryParameters)}');
    }

    if (options.headers.isNotEmpty) {
      buffer.writeln('Headers: ${_redactedHeaders(options.headers)}');
    }

    final contentType = options.contentType ??
        options.headers['content-type'] ??
        options.headers['Content-Type'];
    if (contentType != null) {
      buffer.writeln('Content-Type: $contentType');
    }

    _appendBodySection(
      buffer,
      label: 'Body',
      data: options.data,
      path: options.uri.path,
      forceFull: kDioLogFullBodies,
    );
    buffer.writeln('──────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logResponse(Response<dynamic> response) {
    if (!kDebugMode) return;

    final options = response.requestOptions;
    final started = options.extra['dio_log_started_ms'];
    final durationMs = started is int
        ? DateTime.now().millisecondsSinceEpoch - started
        : null;

    final buffer = StringBuffer()
      ..writeln('──────── API RESPONSE ────────')
      ..writeln('${options.method} ${_sanitizedUrl(options.uri)}')
      ..writeln('Status: ${response.statusCode}');

    if (durationMs != null) {
      buffer.writeln('Duration: ${durationMs}ms');
    }

    final contentType = response.headers.value('content-type');
    if (contentType != null) {
      buffer.writeln('Content-Type: $contentType');
    }

    _appendBodySection(
      buffer,
      label: 'Body',
      data: response.data,
      path: options.uri.path,
      forceFull: kDioLogFullBodies,
      responseHeaders: response.headers,
    );
    buffer.writeln('──────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logError(DioException error) {
    if (!kDebugMode) return;

    final options = error.requestOptions;
    final buffer = StringBuffer()
      ..writeln('──────── API ERROR ────────')
      ..writeln('${options.method} ${_sanitizedUrl(options.uri)}')
      ..writeln('Type: ${error.type}')
      ..writeln('Message: ${error.message}');

    if (options.data != null) {
      _appendBodySection(
        buffer,
        label: 'Request body',
        data: options.data,
        path: options.uri.path,
        forceFull: kDioLogFullBodies,
      );
    }

    if (error.response != null) {
      buffer.writeln('Status: ${error.response?.statusCode}');
      _appendBodySection(
        buffer,
        label: 'Response body',
        data: error.response?.data,
        path: options.uri.path,
        forceFull: kDioLogFullBodies,
        responseHeaders: error.response?.headers,
      );
    } else if (error.error != null) {
      buffer.writeln('Error object: ${error.error}');
    }

    buffer.writeln('──────────────────────────────');
    debugPrint(buffer.toString());
  }

  @visibleForTesting
  static String formatBodyForTest(
    dynamic data, {
    String path = '/',
    bool forceFull = false,
    int previewLimit = kDioBodyPreviewLimitChars,
  }) {
    return _describeBody(
      data,
      forceFull: forceFull,
      previewLimit: previewLimit,
      preferMetadata: _isLargePayloadPath(path) && !forceFull,
    );
  }

  @visibleForTesting
  static Map<String, dynamic> redactHeadersForTest(Map<String, dynamic> headers) {
    return _redactedHeaders(headers);
  }

  @visibleForTesting
  static dynamic redactValueForTest(dynamic value) => _redactValue(value);

  static void _appendBodySection(
    StringBuffer buffer, {
    required String label,
    required dynamic data,
    required String path,
    required bool forceFull,
    Headers? responseHeaders,
  }) {
    final contentType = responseHeaders?.value('content-type');
    if (_looksBinary(data, contentType)) {
      buffer
        ..writeln('$label: (binary)')
        ..writeln('Approx size: ${_approxSizeLabel(data)}');
      return;
    }

    final largeHint = _isLargePayloadPath(path);
    final description = _describeBody(
      data,
      forceFull: forceFull,
      previewLimit: kDioBodyPreviewLimitChars,
      preferMetadata: largeHint && !forceFull,
    );
    buffer
      ..writeln('$label:')
      ..writeln(description)
      ..writeln('Approx size: ${_approxSizeLabel(data)}');
    if (largeHint && !forceFull) {
      buffer.writeln('(large/master-data path — preview only)');
    }
  }

  static String _describeBody(
    dynamic data, {
    required bool forceFull,
    required int previewLimit,
    bool preferMetadata = false,
  }) {
    if (data == null) return '(none)';

    if (data is FormData) {
      final fieldKeys = data.fields.map((e) => e.key).toList();
      final fileKeys = data.files.map((f) => f.key).toList();
      final redactedFields = data.fields
          .map((e) => MapEntry(e.key, _isSensitiveKey(e.key) ? '***' : _truncateScalar(e.value, 64)))
          .toList();
      final summary =
          'FormData(fields: $redactedFields, files: $fileKeys, fieldKeys: $fieldKeys)';
      return forceFull ? summary : _truncate(summary, previewLimit);
    }

    if (data is List<int> || data is Uint8List) {
      return '(binary bytes, length=${(data as List).length})';
    }

    if (data is ResponseBody) {
      return '(streamed ResponseBody)';
    }

    if (data is List) {
      final meta =
          'List(length=${data.length}${data.isEmpty ? '' : ', firstType=${data.first.runtimeType}'})';
      if (!forceFull || preferMetadata) {
        final preview = data.isEmpty
            ? meta
            : '$meta preview=${_truncate(_compactJson(_redactValue(data.take(2).toList())), previewLimit ~/ 2)}';
        return preview;
      }
      return _truncate(_prettyOrCompact(_redactValue(data)), previewLimit * 4);
    }

    if (data is Map) {
      final keys = data.keys.map((k) => k.toString()).take(20).toList();
      final meta = 'Map(keys=${keys.length > 20 ? '${keys.length}+' : keys})';
      final redacted = _redactValue(data);
      if (!forceFull || preferMetadata) {
        return '$meta\n${_truncate(_compactJson(redacted), previewLimit)}';
      }
      return _truncate(_prettyOrCompact(redacted), previewLimit * 4);
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return '(empty)';
      
      if (!forceFull) {
        return _truncate(trimmed, previewLimit);
      }
      try {
        final decoded = jsonDecode(trimmed);
        return _truncate(_prettyOrCompact(_redactValue(decoded)), previewLimit * 4);
      } catch (_) {
        return _truncate(data, previewLimit * 4);
      }
    }

    try {
      final redacted = _redactValue(data);
      if (!forceFull) {
        return _truncate(_compactJson(redacted), previewLimit);
      }
      return _truncate(_prettyOrCompact(redacted), previewLimit * 4);
    } catch (_) {
      return _truncate(data.toString(), previewLimit);
    }
  }

  static String _prettyOrCompact(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String _compactJson(dynamic value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String _truncate(String value, int limit) {
    if (value.length <= limit) return value;
    return '${value.substring(0, limit)}… [truncated ${value.length - limit} chars]';
  }

  static String _truncateScalar(String value, int limit) {
    if (value.length <= limit) return value;
    return '${value.substring(0, limit)}…';
  }

  static String _approxSizeLabel(dynamic data) {
    final bytes = _approxByteSize(data);
    if (bytes == null) return 'unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static int? _approxByteSize(dynamic data) {
    if (data == null) return 0;
    if (data is List<int>) return data.length;
    if (data is Uint8List) return data.length;
    if (data is String) return data.length;
    if (data is FormData) {
      var n = 0;
      for (final f in data.fields) {
        n += f.key.length + f.value.length;
      }
      n += data.files.length * 64;
      return n;
    }
    if (data is ResponseBody) return null;
    try {
      return utf8.encode(jsonEncode(data)).length;
    } catch (_) {
      return data.toString().length;
    }
  }

  static bool _looksBinary(dynamic data, String? contentType) {
    if (data is List<int> || data is Uint8List || data is ResponseBody) {
      return true;
    }
    if (contentType == null) return false;
    final ct = contentType.toLowerCase();
    if (ct.contains('application/json') ||
        ct.contains('text/') ||
        ct.contains('application/xml') ||
        ct.contains('application/x-www-form-urlencoded')) {
      return false;
    }
    return ct.contains('octet-stream') ||
        ct.contains('multipart/') ||
        ct.contains('image/') ||
        ct.contains('pdf') ||
        ct.contains('zip');
  }

  static bool _isLargePayloadPath(String path) {
    final lower = path.toLowerCase();
    return kDioLargePayloadPathHints.any(lower.contains);
  }

  static String _sanitizedUrl(Uri uri) {
    final cleaned = Map<String, dynamic>.from(
      uri.queryParameters.map((k, v) => MapEntry(k, v)),
    );
    final redacted = _redactMap(cleaned);
    return uri.replace(
      queryParameters: redacted.map((k, v) => MapEntry(k, '$v')),
    ).toString();
  }

  static Map<String, dynamic> _redactedHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (_isSensitiveKey(key)) {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }

  static Map<String, dynamic> _redactMap(Map<dynamic, dynamic> input) {
    return input.map((key, value) {
      final k = key.toString();
      if (_isSensitiveKey(k)) {
        return MapEntry(k, '***');
      }
      return MapEntry(k, _redactValue(value));
    });
  }

  static dynamic _redactValue(dynamic value) {
    if (value is Map) {
      return _redactMap(value);
    }
    if (value is List) {
      return value.map(_redactValue).toList();
    }
    return value;
  }

  static bool _isSensitiveKey(String key) => _sensitiveKey.hasMatch(key);
}
