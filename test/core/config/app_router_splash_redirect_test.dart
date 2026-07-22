import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';
import 'package:traqtrace_app/core/storage/last_route_store.dart';
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

    test('FP-6: pending keeps /splash put and never redirects to login', () {
      for (final status in [AuthStatus.initial, AuthStatus.loading]) {
        when(() => authCubit.state).thenReturn(AuthState(status: status));
        expect(
          appRouter.computeRedirect(path: Constants.splashRoute),
          isNull,
          reason: 'splash must stay for $status',
        );
        final parked = appRouter.computeRedirect(
          path: Constants.homeRoute,
          currentLocation: Constants.homeRoute,
        );
        expect(parked, isNotNull);
        expect(parked!.startsWith(Constants.splashRoute), isTrue);
        final uri = Uri.parse(parked);
        expect(uri.path, Constants.splashRoute);
        expect(uri.queryParameters['from'], Constants.homeRoute);
        expect(parked, isNot(equals(Constants.loginRoute)));
      }
    });

    test('auth-loading bounce preserves deep link as from', () {
      when(() => authCubit.state).thenReturn(
        const AuthState(status: AuthStatus.loading),
      );
      final parked = appRouter.computeRedirect(
        path: '/dashboards/journey',
        currentLocation: '/dashboards/journey?epc=urn:epc:id:sgtin:1',
      );
      expect(parked, isNotNull);
      final uri = Uri.parse(parked!);
      expect(uri.path, Constants.splashRoute);
      expect(
        uri.queryParameters['from'],
        '/dashboards/journey?epc=urn:epc:id:sgtin:1',
      );
    });

    test('on /splash + authenticated restores lastRoute when no from', () {
      final store = LastRouteStore(debounce: Duration.zero);
      store.debugSetLocation('/operations/shipping');
      final router = AppRouter(authCubit: authCubit, lastRouteStore: store);
      when(() => authCubit.state).thenReturn(_authenticated());
      expect(
        router.computeRedirect(path: Constants.splashRoute),
        '/operations/shipping',
      );
      // Once consumed, Back to splash must not re-apply last route.
      expect(
        router.computeRedirect(path: Constants.splashRoute),
        Constants.homeRoute,
      );
      expect(
        router.computeRedirect(
          path: Constants.splashRoute,
          fromQuery: '/home',
        ),
        '/home',
      );
    });

    test('authenticated login without from restores lastRoute only once', () {
      final store = LastRouteStore(debounce: Duration.zero);
      store.debugSetLocation('/operations/shipping');
      final router = AppRouter(authCubit: authCubit, lastRouteStore: store);
      when(() => authCubit.state).thenReturn(_authenticated());

      expect(
        router.computeRedirect(path: Constants.loginRoute),
        '/operations/shipping',
      );
      expect(
        router.computeRedirect(path: Constants.loginRoute),
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
  });
}
