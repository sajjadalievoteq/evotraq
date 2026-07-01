import 'dart:convert';

/// Captured request/response details for troubleshooting operation API calls.
class OperationApiDebugTrace {
  OperationApiDebugTrace({
    required this.operation,
    required this.method,
    required this.url,
    required this.timestamp,
    this.requestHeaders = const {},
    this.requestBody,
    this.statusCode,
    this.responseBody,
    this.errorMessage,
    this.durationMs,
    this.stackTrace,
    this.validationNotes = const [],
    this.extra = const {},
  });

  final String operation;
  final String method;
  final String url;
  final DateTime timestamp;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final int? statusCode;
  final String? responseBody;
  final String? errorMessage;
  final int? durationMs;
  final String? stackTrace;
  final List<String> validationNotes;
  final Map<String, String> extra;

  static OperationApiDebugTrace? _last;

  /// Most recent trace (e.g. after a failed decommissioning create).
  static OperationApiDebugTrace? get last => _last;

  static void remember(OperationApiDebugTrace trace) => _last = trace;

  Map<String, dynamic>? get parsedResponseBody {
    final raw = responseBody;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  String? get errorId => parsedResponseBody?['errorId']?.toString();

  String? get errorCode => parsedResponseBody?['code']?.toString();

  String? get serverMessage => parsedResponseBody?['message']?.toString();

  String prettyRequestBody() => _prettyJson(requestBody);

  String prettyResponseBody() => _prettyJson(responseBody);

  String fullReport() {
    final buffer = StringBuffer()
      ..writeln('=== $operation API Debug ===')
      ..writeln('Time: ${timestamp.toIso8601String()}')
      ..writeln('Duration: ${durationMs ?? '?'} ms')
      ..writeln('$method $url')
      ..writeln('Status: ${statusCode ?? '—'}')
      ..writeln('Error: ${errorMessage ?? '—'}');

    if (errorId != null) buffer.writeln('Error ID: $errorId');
    if (errorCode != null) buffer.writeln('Code: $errorCode');
    if (serverMessage != null) buffer.writeln('Server message: $serverMessage');

    if (validationNotes.isNotEmpty) {
      buffer.writeln('\n--- Client validation ---');
      for (final note in validationNotes) {
        buffer.writeln('• $note');
      }
    }

    if (extra.isNotEmpty) {
      buffer.writeln('\n--- Extra ---');
      extra.forEach((k, v) => buffer.writeln('$k: $v'));
    }

    buffer
      ..writeln('\n--- Request headers ---')
      ..writeln(_prettyMap(requestHeaders))
      ..writeln('\n--- Request body ---')
      ..writeln(prettyRequestBody())
      ..writeln('\n--- Response body ---')
      ..writeln(prettyResponseBody());

    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer
        ..writeln('\n--- Stack trace ---')
        ..writeln(stackTrace);
    }

    return buffer.toString();
  }

  static Map<String, String> redactHeaders(Map<String, String> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: entry.key.toLowerCase() == 'authorization'
            ? _redactAuth(entry.value)
            : entry.value,
    };
  }

  static String _redactAuth(String value) {
    if (value.isEmpty) return '[empty]';
    if (value.length <= 24) return '[redacted]';
    return '${value.substring(0, 12)}…${value.substring(value.length - 6)}';
  }

  static String _prettyJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '(empty)';
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw;
    }
  }

  static String _prettyMap(Map<String, String> map) {
    if (map.isEmpty) return '(none)';
    return map.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
