import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class HttpService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppConfig _appConfig;
  
  // Singleton pattern
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  
  HttpService._internal() : _appConfig = AppConfig(
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080/api'),
    appName: 'evotraq.io',
    appVersion: '1.0.0',
  ) {
    _dio = Dio(BaseOptions(
      baseUrl: _appConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      contentType: 'application/json',
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to request if available
          final token = await _secureStorage.read(key: AppConfig.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          }
          
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          }
          
          return handler.next(e);
        },
      ),
    );
  }
  
  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // DELETE request
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
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