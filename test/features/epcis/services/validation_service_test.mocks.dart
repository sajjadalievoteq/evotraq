




import 'dart:async' as _i5;

import 'package:dio/dio.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;
import 'package:traqtrace_app/core/network/dio_service.dart' as _i3;
















class _FakeResponse_0<T> extends _i1.SmartFake implements _i2.Response<T> {
  _FakeResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}




class MockDioService extends _i1.Mock implements _i3.DioService {
  MockDioService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get baseUrl =>
      (super.noSuchMethod(
            Invocation.getter(#baseUrl),
            returnValue: _i4.dummyValue<String>(
              this,
              Invocation.getter(#baseUrl),
            ),
          )
          as String);

  @override
  set onUnauthorized(void Function()? value) => super.noSuchMethod(
    Invocation.setter(#onUnauthorized, value),
    returnValueForMissingStub: null,
  );

  @override
  void setBaseUrl(String? baseUrl) => super.noSuchMethod(
    Invocation.method(#setBaseUrl, [baseUrl]),
    returnValueForMissingStub: null,
  );

  @override
  bool requestHadBearerToken(_i2.RequestOptions? options) =>
      (super.noSuchMethod(
            Invocation.method(#requestHadBearerToken, [options]),
            returnValue: false,
          )
          as bool);

  @override
  bool looksLikePermissionDenied(_i2.Response<dynamic>? response) =>
      (super.noSuchMethod(
            Invocation.method(#looksLikePermissionDenied, [response]),
            returnValue: false,
          )
          as bool);

  @override
  void markAuthSettled() => super.noSuchMethod(
    Invocation.method(#markAuthSettled, []),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<void> handleUnauthorized(_i2.RequestOptions? options) =>
      (super.noSuchMethod(
            Invocation.method(#handleUnauthorized, [options]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> handleAuthFailureStatus({
    required _i2.RequestOptions? options,
    required int? statusCode,
    _i2.Response<dynamic>? response,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#handleAuthFailureStatus, [], {
              #options: options,
              #statusCode: statusCode,
              #response: response,
            }),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  void notifyUnauthorizedDebounced() => super.noSuchMethod(
    Invocation.method(#notifyUnauthorizedDebounced, []),
    returnValueForMissingStub: null,
  );

  @override
  void resetUnauthorizedGuardsForTest({
    bool? clearGrace = true,
    bool? expireGrace = false,
  }) => super.noSuchMethod(
    Invocation.method(#resetUnauthorizedGuardsForTest, [], {
      #clearGrace: clearGrace,
      #expireGrace: expireGrace,
    }),
    returnValueForMissingStub: null,
  );

  @override
  void resetUnauthorizedDebounceForTest() => super.noSuchMethod(
    Invocation.method(#resetUnauthorizedDebounceForTest, []),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<void> warmAuthTokenFromStorage() =>
      (super.noSuchMethod(
            Invocation.method(#warmAuthTokenFromStorage, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  void setCachedAuthTokenForTest(String? token) => super.noSuchMethod(
    Invocation.method(#setCachedAuthTokenForTest, [token]),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<_i2.Response<dynamic>> get(
    String? path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    _i2.ResponseType? responseType,
    bool? acceptAllStatusCodes = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #get,
              [path],
              {
                #queryParameters: queryParameters,
                #headers: headers,
                #responseType: responseType,
                #acceptAllStatusCodes: acceptAllStatusCodes,
              },
            ),
            returnValue: _i5.Future<_i2.Response<dynamic>>.value(
              _FakeResponse_0<dynamic>(
                this,
                Invocation.method(
                  #get,
                  [path],
                  {
                    #queryParameters: queryParameters,
                    #headers: headers,
                    #responseType: responseType,
                    #acceptAllStatusCodes: acceptAllStatusCodes,
                  },
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response<dynamic>>);

  @override
  _i5.Future<_i2.Response<dynamic>> post(
    String? path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    _i2.ResponseType? responseType,
    bool? acceptAllStatusCodes = false,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #post,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #headers: headers,
                #responseType: responseType,
                #acceptAllStatusCodes: acceptAllStatusCodes,
                #connectTimeout: connectTimeout,
                #receiveTimeout: receiveTimeout,
                #sendTimeout: sendTimeout,
              },
            ),
            returnValue: _i5.Future<_i2.Response<dynamic>>.value(
              _FakeResponse_0<dynamic>(
                this,
                Invocation.method(
                  #post,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #headers: headers,
                    #responseType: responseType,
                    #acceptAllStatusCodes: acceptAllStatusCodes,
                    #connectTimeout: connectTimeout,
                    #receiveTimeout: receiveTimeout,
                    #sendTimeout: sendTimeout,
                  },
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response<dynamic>>);

  @override
  _i5.Future<_i2.Response<dynamic>> put(
    String? path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    _i2.ResponseType? responseType,
    bool? acceptAllStatusCodes = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #put,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #headers: headers,
                #responseType: responseType,
                #acceptAllStatusCodes: acceptAllStatusCodes,
              },
            ),
            returnValue: _i5.Future<_i2.Response<dynamic>>.value(
              _FakeResponse_0<dynamic>(
                this,
                Invocation.method(
                  #put,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #headers: headers,
                    #responseType: responseType,
                    #acceptAllStatusCodes: acceptAllStatusCodes,
                  },
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response<dynamic>>);

  @override
  _i5.Future<_i2.Response<dynamic>> patch(
    String? path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    _i2.ResponseType? responseType,
    bool? acceptAllStatusCodes = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patch,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #headers: headers,
                #responseType: responseType,
                #acceptAllStatusCodes: acceptAllStatusCodes,
              },
            ),
            returnValue: _i5.Future<_i2.Response<dynamic>>.value(
              _FakeResponse_0<dynamic>(
                this,
                Invocation.method(
                  #patch,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #headers: headers,
                    #responseType: responseType,
                    #acceptAllStatusCodes: acceptAllStatusCodes,
                  },
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response<dynamic>>);

  @override
  _i5.Future<_i2.Response<dynamic>> delete(
    String? path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    _i2.ResponseType? responseType,
    bool? acceptAllStatusCodes = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [path],
              {
                #data: data,
                #queryParameters: queryParameters,
                #headers: headers,
                #responseType: responseType,
                #acceptAllStatusCodes: acceptAllStatusCodes,
              },
            ),
            returnValue: _i5.Future<_i2.Response<dynamic>>.value(
              _FakeResponse_0<dynamic>(
                this,
                Invocation.method(
                  #delete,
                  [path],
                  {
                    #data: data,
                    #queryParameters: queryParameters,
                    #headers: headers,
                    #responseType: responseType,
                    #acceptAllStatusCodes: acceptAllStatusCodes,
                  },
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response<dynamic>>);

  @override
  _i5.Future<void> saveAuthToken(String? token) =>
      (super.noSuchMethod(
            Invocation.method(#saveAuthToken, [token]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<String?> getAuthToken() =>
      (super.noSuchMethod(
            Invocation.method(#getAuthToken, []),
            returnValue: _i5.Future<String?>.value(),
          )
          as _i5.Future<String?>);

  @override
  _i5.Future<void> removeAuthToken() =>
      (super.noSuchMethod(
            Invocation.method(#removeAuthToken, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}
