import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/tatmeen_dashboard_screen.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/tatmeen_records_route_screen.dart';

List<RouteBase> tatmeenRoutes(RouteAccess access) => [
  GoRoute(
    path: Constants.tatmeenIntegrationRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const TatmeenDashboardScreen(),
    ),
    redirect: (context, state) {
      if (!access.authState.isAuthenticated) return null;
      if (!access.authState.canAccessTatmeenIntegration) {
        return Constants.homeRoute;
      }
      return null;
    },
  ),
  GoRoute(
    path: Constants.tatmeenIntegrationRecordsRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const TatmeenRecordsRouteScreen(),
    ),
    redirect: (context, state) {
      if (!access.authState.isAuthenticated) return null;
      if (!access.authState.canAccessTatmeenIntegration) {
        return Constants.homeRoute;
      }
      return null;
    },
  ),
];
