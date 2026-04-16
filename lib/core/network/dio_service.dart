import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

class DioService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppConfig _appConfig;

  // Singleton pattern
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  DioService._internal()
    : _appConfig = AppConfig(
        apiBaseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080/api',
        ),
        appName: 'evotraq.io',
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

  String _stringify(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _truncate(String value, {int max = 2000}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}...(truncated)';
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to request if available
          if (!options.headers.containsKey('Authorization')) {
            final token = await _secureStorage.read(
              key: AppConfig.authTokenKey,
            );
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            final status = e.response?.statusCode;
            final method = e.requestOptions.method;
            final path = e.requestOptions.path;
            print(
              'ERROR[$status] => $method $path (type: ${e.type}) (message: ${e.message})',
            );
            final error = e.error;
            if (error != null) {
              print('ERROR_OBJECT => $error');
            }
            final responseData = e.response?.data;
            if (responseData != null) {
              print(
                'ERROR_RESPONSE_BODY => ${_truncate(_stringify(responseData))}',
              );
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  // GET request
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

  // POST request
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

  // PUT request
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

  // PATCH request
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

  // DELETE request
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

  // Save auth token
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConfig.authTokenKey, value: token);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConfig.authTokenKey);
  }

  // Remove auth token
  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: AppConfig.authTokenKey);
  }
}
