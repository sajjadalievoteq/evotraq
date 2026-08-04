import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
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
  group('resolveSplashPendingLocationFrom', () {
    test('rejects null, empty, and splash itself', () {
      expect(resolveSplashPendingLocationFrom(null), isNull);
      expect(resolveSplashPendingLocationFrom(''), isNull);
      expect(resolveSplashPendingLocationFrom(Constants.splashRoute), isNull);
    });

    test('returns valid deep-link from value', () {
      expect(
        resolveSplashPendingLocationFrom(Constants.homeRoute),
        Constants.homeRoute,
      );
    });
  });

  group('AppRouter.computeRedirect splash-exit', () {
    late _MockAuthCubit authCubit;
    late AppRouter appRouter;

    setUp(() {
      authCubit = _MockAuthCubit();
      appRouter = AppRouter(authCubit: authCubit);
    });

    test('on /splash + authenticated → home (or from)', () {
      when(() => authCubit.state).thenReturn(_authenticated());

      expect(
        appRouter.computeRedirect(path: Constants.splashRoute),
        Constants.homeRoute,
      );
      expect(
        appRouter.computeRedirect(
          path: Constants.splashRoute,
          fromQuery: '/dashboards/journey',
        ),
        '/dashboards/journey',
      );
    });

    test('on /splash + unauthenticated → login (preserves from when present)',
        () {
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.unauthenticated),
      );
      expect(
        appRouter.computeRedirect(path: Constants.splashRoute),
        Constants.loginRoute,
      );
      final withFrom = appRouter.computeRedirect(
        path: Constants.splashRoute,
        fromQuery: Constants.homeRoute,
      );
      expect(withFrom, isNotNull);
      final uri = Uri.parse(withFrom!);
      expect(uri.path, Constants.loginRoute);
      expect(uri.queryParameters['from'], Constants.homeRoute);
    });

    test('FP-6: pending keeps URL put — no splash park on protected routes', () {
      for (final status in [AuthStatus.initial, AuthStatus.loading]) {
        when(() => authCubit.state).thenReturn(AuthState(status: status));
        expect(
          appRouter.computeRedirect(path: Constants.splashRoute),
          isNull,
          reason: 'splash must stay for $status',
        );
        expect(
          appRouter.computeRedirect(
            path: Constants.homeRoute,
            currentLocation: Constants.homeRoute,
          ),
          isNull,
          reason: 'protected URL must not redirect to splash for $status',
        );
        expect(
          appRouter.computeRedirect(path: '/'),
          Constants.splashRoute,
          reason: 'bare / cold-starts on splash for $status',
        );
      }
    });

    test('auth-loading keeps deep link URL (no splash?from=)', () {
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.loading),
      );
      expect(
        appRouter.computeRedirect(
          path: '/dashboards/journey',
          currentLocation: '/dashboards/journey?epc=urn:epc:id:sgtin:1',
        ),
        isNull,
      );
    });

    test('authenticated splash without from → home (no Hive restore)', () {
      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        appRouter.computeRedirect(path: Constants.splashRoute),
        Constants.homeRoute,
      );
    });

    test('authenticated login without from → home', () {
      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        appRouter.computeRedirect(path: Constants.loginRoute),
        Constants.homeRoute,
      );
    });

    test(
      'FP-5: initial→loading→authenticated at /splash?from=/home → /home, no re-entry',
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

        expect(trail, isNotEmpty);
        expect(trail.last, Constants.homeRoute);

        final firstHome = trail.indexOf(Constants.homeRoute);
        expect(firstHome, isNonNegative);
        expect(
          trail.skip(firstHome).where((l) => l.startsWith(Constants.splashRoute)),
          isEmpty,
        );

        expect(
          trail.where((l) => l == Constants.homeRoute).length,
          lessThanOrEqualTo(1),
        );
      },
    );

    test(
      'FP-5: initial→loading→unauthenticated at /splash → /login, no re-entry',
      () {
        final trail = _collectRedirectTrail(
          router: appRouter,
          authCubit: authCubit,
          startPath: Constants.splashRoute,
          fromQuery: null,
          emissions: const [
            AuthState(status: AuthStatus.initial),
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.unauthenticated),
          ],
        );

        expect(trail, isNotEmpty);
        expect(trail.last, Constants.loginRoute);
        final firstLogin = trail.indexOf(Constants.loginRoute);
        expect(firstLogin, isNonNegative);
        expect(
          trail.skip(firstLogin).where((l) => l.startsWith(Constants.splashRoute)),
          isEmpty,
        );
      },
    );

    test('FP-5: authenticated splash→home does not oscillate', () {
      when(() => authCubit.state).thenReturn(_authenticated());

      final locations = <String?>[];
      var path = Constants.splashRoute;
      String? from = Constants.homeRoute;

      for (var i = 0; i < 6; i++) {
        final next = appRouter.computeRedirect(path: path, fromQuery: from);
        locations.add(next);
        if (next == null) break;
        path = Uri.parse(next).path;
        from = Uri.parse(next).queryParameters['from'];
      }

      expect(locations.first, Constants.homeRoute);
      expect(locations.where((e) => e == Constants.splashRoute), isEmpty);
      expect(locations.skip(1).every((e) => e == null), isTrue);
    });

    test('refresh of deep link: pending→authenticated stays put', () {
      const deep = '/gs1/gtins/00629200080027';
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.loading),
      );
      expect(
        appRouter.computeRedirect(path: deep, currentLocation: deep),
        isNull,
      );

      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        appRouter.computeRedirect(path: deep, currentLocation: deep),
        isNull,
      );
    });
  });
}
