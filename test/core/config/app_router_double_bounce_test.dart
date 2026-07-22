import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

AuthState _authenticated() => AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 1,
        username: 'u',
        email: 'u@t.com',
        firstName: 'U',
        lastName: 'T',
        role: 'USER',
        enabled: true,
      ),
      token: 'tok',
    );

AuthState _loadingWithUser() => AuthState(
      status: AuthStatus.loading,
      user: _authenticated().user,
      token: 'tok',
    );

List<String> _collectRedirectTrail({
  required AppRouter router,
  required _MockAuthCubit authCubit,
  required String startPath,
  required String? fromQuery,
  required List<AuthState> emissions,
}) {
  final trail = <String>[];
  var path = startPath;
  var from = fromQuery;

  for (final emission in emissions) {
    when(() => authCubit.state).thenReturn(emission);
    for (var step = 0; step < 4; step++) {
      final next = router.computeRedirect(
        path: path,
        fromQuery: from,
        currentLocation: path == Constants.splashRoute && from != null
            ? Uri(path: path, queryParameters: {'from': from}).toString()
            : path,
      );
      if (next == null) break;
      trail.add(next);
      if (trail.length >= 2 &&
          trail[trail.length - 1] == trail[trail.length - 2]) {
        fail('Redirect loop (repeated location): $trail');
      }
      final uri = Uri.parse(next);
      path = uri.path;
      from = uri.queryParameters['from'];
    }
  }
  return trail;
}

void main() {
  group('FP-5: redirect single authority', () {
    late _MockAuthCubit authCubit;
    late AppRouter appRouter;

    setUp(() {
      authCubit = _MockAuthCubit();
      appRouter = AppRouter(authCubit: authCubit);
    });

    test(
      'initial→loading→authenticated lands on /home; splash once, never re-entered',
      () {
        final trail = _collectRedirectTrail(
          router: appRouter,
          authCubit: authCubit,
          startPath: Constants.splashRoute,
          fromQuery: Constants.homeRoute,
          emissions: [
            const AuthState(status: AuthStatus.initial),
            const AuthState(status: AuthStatus.loading),
            _authenticated(),
          ],
        );

        expect(trail.last, Constants.homeRoute);
        expect(
          trail.where((l) => l.startsWith(Constants.splashRoute)).length,
          lessThanOrEqualTo(1),
        );
        expect(
          trail
              .skip(trail.indexOf(Constants.homeRoute))
              .where((l) => l.startsWith(Constants.splashRoute)),
          isEmpty,
        );
      },
    );

    test(
      'authenticated→unauthenticated on protected route redirects to login',
      () {
        when(() => authCubit.state).thenReturn(_authenticated());
        expect(
          appRouter.computeRedirect(path: Constants.homeRoute),
          isNull,
        );

        when(() => authCubit.state).thenReturn(
          const AuthState(status: AuthStatus.unauthenticated),
        );
        final result = appRouter.computeRedirect(path: Constants.homeRoute);
        expect(result, isNotNull);
        final uri = Uri.parse(result!);
        expect(uri.path, Constants.loginRoute);
        expect(uri.queryParameters['from'], Constants.homeRoute);
      },
    );

    test(
      'transient loading with established user on /home does not redirect to splash',
      () {
        when(() => authCubit.state).thenReturn(_loadingWithUser());
        expect(
          appRouter.computeRedirect(
            path: Constants.homeRoute,
            currentLocation: Constants.homeRoute,
          ),
          isNull,
        );
      },
    );

    test('login while authenticated redirects to home (router-owned)', () {
      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        appRouter.computeRedirect(path: Constants.loginRoute),
        Constants.homeRoute,
      );
    });
  });

  group('FP-4: interceptor 401/403 session handling', () {
    late DioService dio;
    late int unauthorizedCalls;

    setUp(() {
      dio = DioService();
      unauthorizedCalls = 0;
      dio.resetUnauthorizedGuardsForTest(clearGrace: true);
      dio.onUnauthorized = () => unauthorizedCalls++;
    });

    tearDown(() {
      dio.onUnauthorized = null;
      dio.resetUnauthorizedGuardsForTest(clearGrace: true);
    });

    RequestOptions opts({String? authorization}) {
      final headers = <String, dynamic>{};
      if (authorization != null) {
        headers['Authorization'] = authorization;
      }
      return RequestOptions(
        path: '/api/home/overview',
        headers: headers,
      );
    }

    Response resp(RequestOptions options, {Object? data, int status = 403}) {
      return Response(
        requestOptions: options,
        data: data,
        statusCode: status,
      );
    }

    test('401 with Bearer after grace → teardown', () async {
      dio.resetUnauthorizedGuardsForTest(expireGrace: true);
      await dio.handleAuthFailureStatus(
        options: opts(authorization: 'Bearer real-token'),
        statusCode: 401,
      );
      expect(unauthorizedCalls, 1);
    });

    test('403 with Bearer after grace → teardown', () async {
      dio.resetUnauthorizedGuardsForTest(expireGrace: true);
      await dio.handleAuthFailureStatus(
        options: opts(authorization: 'Bearer real-token'),
        statusCode: 403,
        response: resp(opts(authorization: 'Bearer real-token')),
      );
      expect(unauthorizedCalls, 1);
    });

    test('403 without Bearer → no teardown', () async {
      dio.resetUnauthorizedGuardsForTest(expireGrace: true);
      await dio.handleAuthFailureStatus(
        options: opts(),
        statusCode: 403,
      );
      expect(unauthorizedCalls, 0);
    });

    test('403 during startup grace → no teardown', () async {
      dio.markAuthSettled();
      await dio.handleAuthFailureStatus(
        options: opts(authorization: 'Bearer real-token'),
        statusCode: 403,
      );
      expect(unauthorizedCalls, 0);
    });

    test('permission-denied 403 → no teardown', () async {
      dio.resetUnauthorizedGuardsForTest(expireGrace: true);
      final options = opts(authorization: 'Bearer real-token');
      await dio.handleAuthFailureStatus(
        options: options,
        statusCode: 403,
        response: resp(
          options,
          data: {'message': 'Access Denied: insufficient permission'},
        ),
      );
      expect(unauthorizedCalls, 0);
    });

    test('JWT-invalid 403 with Bearer → teardown', () async {
      dio.resetUnauthorizedGuardsForTest(expireGrace: true);
      final options = opts(authorization: 'Bearer real-token');
      await dio.handleAuthFailureStatus(
        options: options,
        statusCode: 403,
        response: resp(options, data: {'message': 'Invalid JWT token'}),
      );
      expect(unauthorizedCalls, 1);
    });

    test('401 with no token → no teardown', () async {
      dio.resetUnauthorizedGuardsForTest(expireGrace: true);
      await dio.handleAuthFailureStatus(options: opts(), statusCode: 401);
      expect(unauthorizedCalls, 0);
    });

    test('memory token cache is preferred over storage read', () async {
      dio.setCachedAuthTokenForTest('cached-token');
      expect(await dio.getAuthToken(), 'cached-token');
      dio.setCachedAuthTokenForTest(null);
      expect(dio.requestHadBearerToken(opts(authorization: 'Bearer x')), isTrue);
      expect(dio.requestHadBearerToken(opts()), isFalse);
    });
  });
}
