import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';

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

void main() {
  group('resolvePendingLocationFrom', () {
    test('rejects null, empty, splash, and auth-flow paths', () {
      expect(resolvePendingLocationFrom(null), isNull);
      expect(resolvePendingLocationFrom(''), isNull);
      expect(resolvePendingLocationFrom(Constants.splashRoute), isNull);
      expect(resolvePendingLocationFrom(Constants.loginRoute), isNull);
      expect(resolvePendingLocationFrom(Constants.registerRoute), isNull);
      expect(resolvePendingLocationFrom(Constants.forgotPasswordRoute), isNull);
      expect(resolvePendingLocationFrom(Constants.checkEmailRoute), isNull);
      expect(resolvePendingLocationFrom('${Constants.loginRoute}?x=1'), isNull);
    });

    test('preserves path and query parameters', () {
      expect(
        resolvePendingLocationFrom(Constants.homeRoute),
        Constants.homeRoute,
      );
      expect(
        resolvePendingLocationFrom('/gtins/00629200080027'),
        '/gtins/00629200080027',
      );
      expect(
        resolvePendingLocationFrom('/events?page=3&type=shipping'),
        '/events?page=3&type=shipping',
      );
      expect(
        resolvePendingLocationFrom(
          '/epcis/aggregation-events/hierarchy/urn:epc:id:sscc:123?tab=children',
        ),
        '/epcis/aggregation-events/hierarchy/urn:epc:id:sscc:123?tab=children',
      );
    });
  });

  group('loginLocationWithFrom', () {
    test('omits from for invalid/auth targets', () {
      expect(loginLocationWithFrom(null), Constants.loginRoute);
      expect(loginLocationWithFrom(Constants.loginRoute), Constants.loginRoute);
    });

    test('encodes valid deep link as from query', () {
      final result = loginLocationWithFrom('/gtins/00629200080027');
      expect(result.startsWith(Constants.loginRoute), isTrue);
      final uri = Uri.parse(result);
      expect(uri.path, Constants.loginRoute);
      expect(uri.queryParameters['from'], '/gtins/00629200080027');
    });
  });

  group('computeRedirect deep-link restoration', () {
    late _MockAuthCubit authCubit;
    late AppRouter appRouter;

    setUp(() {
      authCubit = _MockAuthCubit();
      appRouter = AppRouter(authCubit: authCubit);
    });

    test('unauthenticated protected path → login?from=original', () {
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.unauthenticated),
      );

      final deep = '/gtins/00629200080027';
      final result = appRouter.computeRedirect(
        path: deep,
        currentLocation: deep,
      );
      expect(result, isNotNull);
      final uri = Uri.parse(result!);
      expect(uri.path, Constants.loginRoute);
      expect(uri.queryParameters['from'], deep);
    });

    test('unauthenticated path with query → login preserves query in from', () {
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.unauthenticated),
      );

      const deep = '/events?page=3&type=shipping';
      final result = appRouter.computeRedirect(
        path: '/events',
        currentLocation: deep,
      );
      final uri = Uri.parse(result!);
      expect(uri.path, Constants.loginRoute);
      expect(uri.queryParameters['from'], deep);
    });

    test('authenticated on login?from=deep → restores deep link', () {
      when(() => authCubit.state).thenReturn(_authenticated());

      const deep = '/gtins/00629200080027';
      expect(
        appRouter.computeRedirect(
          path: Constants.loginRoute,
          fromQuery: deep,
        ),
        deep,
      );
    });

    test('authenticated on login without from → home', () {
      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        appRouter.computeRedirect(path: Constants.loginRoute),
        Constants.homeRoute,
      );
    });

    test('authenticated on login?from=/login → home (invalid from)', () {
      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        appRouter.computeRedirect(
          path: Constants.loginRoute,
          fromQuery: Constants.loginRoute,
        ),
        Constants.homeRoute,
      );
    });

    test('splash?from=deep + unauthenticated → login?from=deep', () {
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.unauthenticated),
      );

      const deep =
          '/epcis/aggregation-events/hierarchy/urn:epc:id:sscc:123?tab=children';
      final result = appRouter.computeRedirect(
        path: Constants.splashRoute,
        fromQuery: deep,
      );
      final uri = Uri.parse(result!);
      expect(uri.path, Constants.loginRoute);
      expect(uri.queryParameters['from'], deep);
    });

    test(
      'full flow: protected → login?from → authenticated → restored once',
      () {
        when(() => authCubit.state).thenReturn(
          const AuthState(status: AuthStatus.unauthenticated),
        );

        const deep = '/gtins/00629200080027';
        final toLogin = appRouter.computeRedirect(
          path: deep,
          currentLocation: deep,
        )!;
        final loginUri = Uri.parse(toLogin);
        expect(loginUri.path, Constants.loginRoute);
        expect(loginUri.queryParameters['from'], deep);

        when(() => authCubit.state).thenReturn(_authenticated());
        final restored = appRouter.computeRedirect(
          path: loginUri.path,
          fromQuery: loginUri.queryParameters['from'],
        );
        expect(restored, deep);

        
        expect(
          appRouter.computeRedirect(path: deep, currentLocation: deep),
          isNull,
        );
      },
    );
  });
}
