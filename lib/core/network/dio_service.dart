import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

part 'dio_service_logging.dart';

class DioService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppConfig _appConfig;

  void Function()? onUnauthorized;

  DateTime? _lastUnauthorizedNotifyAt;
  static const Duration _unauthorizedDebounce = Duration(seconds: 2);

  String? _cachedAuthToken;

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

  static const Set<String> _publicAuthPathSuffixes = {
    '/auth/login',
    '/auth/register',
    '/auth/check-username',
    '/auth/resend-verification-email',
    '/auth/password-reset-request',
    '/auth/validate-reset-token',
    '/auth/reset-password',
    '/verification/verify-email',
  };

  bool _isPublicAuthRequest(RequestOptions options) {
    final path = options.uri.path;
    return _publicAuthPathSuffixes.any(path.endsWith);
  }

  bool requestHadBearerToken(RequestOptions options) {
    final raw =
        options.headers['Authorization'] ?? options.headers['authorization'];
    if (raw == null) return false;
    final value = raw.toString().trim();
    if (value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (lower == 'bearer') return false;
    if (lower.startsWith('bearer ')) {
      return lower.substring(7).trim().isNotEmpty;
    }
    return true;
  }

  bool looksLikePermissionDenied(Response? response) {
    if (response == null) return false;
    final raw = response.data;
    final text = raw is String ? raw : (raw == null ? '' : raw.toString());
    final lower = text.toLowerCase();
    if (lower.isEmpty) return false;

    const sessionMarkers = [
      'expiredjwt',
      'jwt expired',
      'invalid jwt',
      'invalid token',
      'token expired',
      'full authentication is required',
      'authentication credentials were not provided',
    ];
    if (sessionMarkers.any(lower.contains)) return false;

    const permissionMarkers = [
      'access is denied',
      'access denied',
      'insufficient permission',
      'insufficient_scope',
      'not authorized to',
      'permission denied',
      'forbidden for this role',
      'requires role',
      'requires authority',
      'accessdeniedexception',
    ];
    return permissionMarkers.any(lower.contains);
  }

  /// Retained as a bootstrap hook for callers. Bearer-token detection now
  /// provides the startup-race guard, so a real authenticated 401 is never
  /// ignored for an arbitrary grace period.
  void markAuthSettled() {}

  Future<void> handleUnauthorized(RequestOptions options) async {
    if (_isPublicAuthRequest(options)) return;

    if (!requestHadBearerToken(options)) return;
    try {
      await removeAuthToken();
    } catch (_) {}
    notifyUnauthorizedDebounced();
  }

  Future<void> handleAuthFailureStatus({
    required RequestOptions options,
    required int? statusCode,
    Response? response,
  }) async {
    _authDebugLog(options, statusCode);

    if (statusCode == 401) {
      await handleUnauthorized(options);
      return;
    }

    if (statusCode == 403) {
      // 403 = authenticated but NOT authorized (e.g. a role-restricted
      // endpoint like dashboard/GLNs for a USER). This must never log the user
      // out. Invalid/expired sessions come back as 401 (handled above), so on a
      // 403 we simply surface the error and keep the session.
      return;
    }
  }

  void _authDebugLog(RequestOptions options, int? statusCode) {
    if (!kDebugMode) return;
    final path = options.uri.path;
    final isProfile = path.contains('/users/profile');
    final isAuthFailure = statusCode == 401 || statusCode == 403;
    if (!isProfile && !isAuthFailure) return;
    debugPrint(
      '[AUTH DEBUG] ${options.method} $path '
      'hadBearer=${requestHadBearerToken(options)} status=$statusCode',
    );
  }

  void notifyUnauthorizedDebounced() {
    final now = DateTime.now();
    if (_lastUnauthorizedNotifyAt != null &&
        now.difference(_lastUnauthorizedNotifyAt!) < _unauthorizedDebounce) {
      return;
    }
    _lastUnauthorizedNotifyAt = now;
    onUnauthorized?.call();
  }

  @visibleForTesting
  void resetUnauthorizedGuardsForTest({
    bool clearGrace = true,
    bool expireGrace = false,
  }) {
    _lastUnauthorizedNotifyAt = null;
  }

  @visibleForTesting
  void resetUnauthorizedDebounceForTest() {
    resetUnauthorizedGuardsForTest();
  }

  Future<void> warmAuthTokenFromStorage() async {
    try {
      final token = await _secureStorage.read(key: AppConfig.authTokenKey);
      if (token != null && token.isNotEmpty) {
        _cachedAuthToken = token;
      }
    } catch (_) {}
  }

  @visibleForTesting
  void setCachedAuthTokenForTest(String? token) {
    _cachedAuthToken = token;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_isPublicAuthRequest(options)) {
            options.headers.remove('Authorization');
          } else if (!options.headers.containsKey('Authorization')) {
            final token = await getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          _logRequest(options);
          if (kDebugMode && options.uri.path.contains('/users/profile')) {
            _authDebugLog(options, null);
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          _logResponse(response);
          final code = response.statusCode;
          if (code == 401 || code == 403) {
            await handleAuthFailureStatus(
              options: response.requestOptions,
              statusCode: code,
              response: response,
            );
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logError(e);
          final code = e.response?.statusCode;
          if (code == 401 || code == 403) {
            await handleAuthFailureStatus(
              options: e.requestOptions,
              statusCode: code,
              response: e.response,
            );
          }

          return handler.next(e);
        },
      ),
    );
  }

  Duration? _sendTimeoutForBody(dynamic data) {
    if (data == null) return null;
    return Duration(milliseconds: AppConfig.sendTimeout);
  }

  Options _requestOptions({
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool acceptAllStatusCodes = false,
    dynamic data,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    return Options(
      headers: headers,
      responseType: responseType,
      validateStatus: acceptAllStatusCodes ? (_) => true : null,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout ?? _sendTimeoutForBody(data),
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
        options: _requestOptions(
          headers: headers,
          responseType: responseType,
          acceptAllStatusCodes: acceptAllStatusCodes,
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
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _requestOptions(
          headers: headers,
          responseType: responseType,
          acceptAllStatusCodes: acceptAllStatusCodes,
          data: data,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
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
        options: _requestOptions(
          headers: headers,
          responseType: responseType,
          acceptAllStatusCodes: acceptAllStatusCodes,
          data: data,
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
        options: _requestOptions(
          headers: headers,
          responseType: responseType,
          acceptAllStatusCodes: acceptAllStatusCodes,
          data: data,
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
        options: _requestOptions(
          headers: headers,
          responseType: responseType,
          acceptAllStatusCodes: acceptAllStatusCodes,
          data: data,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveAuthToken(String token) async {
    _cachedAuthToken = token;
    await _secureStorage.write(key: AppConfig.authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    final cached = _cachedAuthToken;
    if (cached != null && cached.isNotEmpty) return cached;
    final token = await _secureStorage.read(key: AppConfig.authTokenKey);
    if (token != null && token.isNotEmpty) {
      _cachedAuthToken = token;
    }
    return token;
  }

  Future<void> removeAuthToken() async {
    _cachedAuthToken = null;
    await _secureStorage.delete(key: AppConfig.authTokenKey);
  }
}
