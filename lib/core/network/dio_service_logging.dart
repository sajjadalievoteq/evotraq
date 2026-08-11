part of 'dio_service.dart';

extension DioServiceLogging on DioService {
  String _formatBody(dynamic data) {
    if (data == null) return '(none)';
    if (data is FormData) {
      return 'FormData('
          'fields: ${data.fields}, '
          'files: ${data.files.map((f) => f.key).toList()})';
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return '(empty)';
      try {
        final decoded = jsonDecode(trimmed);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return data;
      }
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _requestUrl(RequestOptions options) => options.uri.toString();

  Map<String, dynamic> _redactedHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }

  void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('──────── API REQUEST ────────')
      ..writeln('${options.method} ${_requestUrl(options)}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('Query: ${options.queryParameters}');
    }

    if (options.headers.isNotEmpty) {
      buffer.writeln('Headers: ${_redactedHeaders(options.headers)}');
    }

    buffer
      ..writeln('Body:')
      ..writeln(_formatBody(options.data))
      ..writeln('──────────────────────────────');

    debugPrint(buffer.toString());
  }

  void _logResponse(Response<dynamic> response) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('──────── API RESPONSE ────────')
      ..writeln(
        '${response.requestOptions.method} '
        '${_requestUrl(response.requestOptions)}',
      )
      ..writeln('Status: ${response.statusCode}')
      ..writeln('Body:')
      ..writeln(_formatBody(response.data))
      ..writeln('──────────────────────────────');

    debugPrint(buffer.toString());
  }

  void _logError(DioException error) {
    if (!kDebugMode) return;

    final options = error.requestOptions;
    final buffer = StringBuffer()
      ..writeln('──────── API ERROR ────────')
      ..writeln('${options.method} ${_requestUrl(options)}')
      ..writeln('Type: ${error.type}')
      ..writeln('Message: ${error.message}');

    if (options.data != null) {
      buffer
        ..writeln('Request body:')
        ..writeln(_formatBody(options.data));
    }

    if (error.response != null) {
      buffer
        ..writeln('Status: ${error.response?.statusCode}')
        ..writeln('Response body:')
        ..writeln(_formatBody(error.response?.data));
    } else if (error.error != null) {
      buffer.writeln('Error object: ${error.error}');
    }

    buffer.writeln('──────────────────────────────');
    debugPrint(buffer.toString());
  }
}
