import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

class DioService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppConfig _appConfig;

  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  DioService._internal()
    : _appConfig = AppConfig(
        apiBaseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080/api',
        ),
        appName: 'traq',
        appVersion: '1.0.0',
      ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _appConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        contentType: 'application/json',
      ),
    );

    _setupInterceptors();
  }

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  String get baseUrl => _dio.options.baseUrl;

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

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.headers.containsKey('Authorization')) {
            final token = await _secureStorage.read(
              key: AppConfig.authTokenKey,
            );
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          _logRequest(options);

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logError(e);

          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool acceptAllStatusCodes = false,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          validateStatus: acceptAllStatusCodes ? (_) => true : null,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool acceptAllStatusCodes = false,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          validateStatus: acceptAllStatusCodes ? (_) => true : null,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool acceptAllStatusCodes = false,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          validateStatus: acceptAllStatusCodes ? (_) => true : null,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool acceptAllStatusCodes = false,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          validateStatus: acceptAllStatusCodes ? (_) => true : null,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool acceptAllStatusCodes = false,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
          validateStatus: acceptAllStatusCodes ? (_) => true : null,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConfig.authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConfig.authTokenKey);
  }

  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: AppConfig.authTokenKey);
  }
}
