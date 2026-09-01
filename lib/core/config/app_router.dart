import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_navigation.dart';
import 'package:traqtrace_app/core/config/router_not_found_screen.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/core/config/platform_startup_route.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';

import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

import 'package:traqtrace_app/core/navigation/routes/core_routes.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';

typedef FeatureRoutesBuilder = List<RouteBase> Function(RouteAccess access);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => _refresh());
  }

  late final StreamSubscription<dynamic> _subscription;
  bool _refreshScheduled = false;
  bool _disposed = false;

  void _refresh() {
    if (_disposed || _refreshScheduled) return;

    // Authentication can change while a protected route is building (for
    // example, when an initState API request returns 401). Mutating the
    // Navigator synchronously at that point can unmount a route-scoped
    // BlocProvider before Flutter has detached all of its dependents, which
    // triggers framework.dart's `_dependents.isEmpty` assertion. Always apply
    // stream-driven redirects at the next frame boundary and coalesce parallel
    // 401s into one router refresh.
    _refreshScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!_disposed) notifyListeners();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static const bool _enableRouterDiagnostics = bool.fromEnvironment(
    'ENABLE_ROUTER_DEBUG_LOGS',
    defaultValue: false,
  );

  final AuthCubit authCubit;
  final FeatureRoutesBuilder featureRoutes;

  final String _initialLocation;

  late final RouteAccess routeAccess = RouteAccess(authCubit);

  AppRouter({
    required this.authCubit,
    required this.featureRoutes,
    String? initialLocation,
  }) : _initialLocation = initialLocation ?? resolvePlatformStartupRoute() {
    // `push` keeps reverse animations; by default go_router does not put those
    // pages in the browser URL. Enable this so drill-downs stay shareable/deeplinkable.
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  bool _isAuthCheckPending() {
    return authCubit.state.status == AuthStatus.initial ||
        authCubit.state.status == AuthStatus.loading;
  }

  bool _isPublicPath(String path) {
    return path == '/' ||
        path.isEmpty ||
        path == Constants.splashRoute ||
        path == Constants.loginRoute ||
        path == Constants.registerRoute ||
        path == Constants.checkEmailRoute ||
        path == Constants.forgotPasswordRoute ||
        path == Constants.resetPasswordRoute ||
        path == Constants.authResetPasswordRoute ||
        path == Constants.verifyEmailRoute ||
        path == Constants.verifyEmailAliasRoute;
  }

  bool _isAuthOnlyPath(String path) {
    return path == Constants.loginRoute ||
        path == Constants.registerRoute ||
        path == Constants.checkEmailRoute ||
        path == Constants.forgotPasswordRoute;
  }

  bool _isRootPath(String path) => path == '/' || path.isEmpty;

  /// Pure auth/location state machine. Browser URL is the source of truth —
  /// no Hive restore and no parking protected URLs on `/splash`.
  String? computeRedirect({
    required String path,
    String? fromQuery,
    String? currentLocation,
  }) {
    final authState = authCubit.state;
    final isAuthenticated = authState.isAuthenticated;

    // Auth still resolving: keep the current URL (including deep links).
    // Only send bare `/` to splash for cold-start branding.
    if (_isAuthCheckPending() && !isAuthenticated) {
      if (_isRootPath(path)) return Constants.splashRoute;
      return null;
    }

    // Cold-start / explicit splash exit.
    if (path == Constants.splashRoute) {
      if (isAuthenticated) {
        return resolveSplashPendingLocationFrom(fromQuery) ??
            Constants.homeRoute;
      }
      return loginLocationWithFrom(fromQuery);
    }

    if (_isRootPath(path)) {
      return isAuthenticated ? Constants.homeRoute : Constants.loginRoute;
    }

    // Authenticated users leave auth-only screens (honor login `from=`).
    if (isAuthenticated && _isAuthOnlyPath(path)) {
      return resolvePendingLocationFrom(fromQuery) ?? Constants.homeRoute;
    }

    // Settled unauthenticated → login, preserving the requested deep link.
    if (!isAuthenticated && !_isPublicPath(path)) {
      return loginLocationWithFrom(currentLocation ?? path);
    }

    return null;
  }

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    debugLogDiagnostics: _enableRouterDiagnostics,
    initialLocation: _initialLocation,
    redirect: (context, state) {
      return computeRedirect(
        path: state.uri.path,
        fromQuery: state.uri.queryParameters['from'],
        currentLocation: state.uri.toString(),
      );
    },
    routes: [
      ...coreRoutes(),
      ...featureRoutes(routeAccess),
    ],
    errorPageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: RouterNotFoundScreen(uri: state.uri.toString()),
    ),
  );
}
