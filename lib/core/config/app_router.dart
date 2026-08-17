import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_navigation.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/config/router_not_found_screen.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/cbv_vocabulary_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/performance_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_generation_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/industry_test_data_screen.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard/monitoring_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/performance_optimization_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/database_partitioning_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/cache_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/data_consistency_integrity_dashboard_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/automation_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';
import 'package:traqtrace_app/features/epcis/widgets/epcis_shell.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/gs1_tools_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln/gln_screen.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin/gtin_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/sgtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin/sgtin_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc/sscc_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_screen.dart';
import 'package:traqtrace_app/features/home/screens/home/home_screen.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/user/screens/profile/profile_screen.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/system_settings_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/object_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/utils/object_event_route_constants.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_batch_import/object_event_batch_import_screen.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event/object_event_screen.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event/aggregation_event_screen.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_detail/aggregation_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_events_list/transaction_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_form/transaction_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_events_help/transaction_events_help_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/transaction_document_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document_help/transaction_document_help_screen.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/transformation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/transformation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/epcis_generic_event_detail/epcis_generic_event_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping/shipping_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/shipping_operation_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/inbox_outbox_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving/receiving_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping/return_shipping_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/return_shipping_operation_screen.dart';
import 'package:traqtrace_app/data/models/operations/shared/pharma_return_context.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/return_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping/cancel_shipping_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/cancel_shipping_operation_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/cancel_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving/cancel_receiving_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/cancel_receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/cancel_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving/return_receiving_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation/return_receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/return_receiving_operation_detail_screen.dart';

import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/hierarchy_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing/packing_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/packing_operation_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/packing_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/unpacking_operation_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking/unpacking_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/unpacking_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/update_status_operation_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status/update_status_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/update_status_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning/commissioning_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/subscription_details_screen.dart';
import 'package:traqtrace_app/features/epcis/routes/transaction_event_validation_demo_route.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/journey_dashboard_screen.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/product_hierarchy_screen.dart';

import 'package:traqtrace_app/features/admin/user_management/screens/user_management/user_management_screen.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/approvals_screen.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/screens/forgot_password/forgot_password_screen.dart';
import 'package:traqtrace_app/features/auth/screens/check_email/check_email_screen.dart';
import 'package:traqtrace_app/features/auth/screens/login/login_screen.dart';
import 'package:traqtrace_app/features/auth/screens/signup/signup_screen.dart';
import 'package:traqtrace_app/features/auth/screens/reset_password/reset_password_screen.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/splash_screen.dart';
import 'package:traqtrace_app/features/auth/screens/verify_email/verify_email_screen.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell.dart';

part 'app_routes_1.dart';
part 'app_routes_2.dart';
part 'app_routes_3.dart';
part 'app_routes_4.dart';

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

PharmaReturnContext? _pharmaReturnContextFromExtra(Object? extra) {
  if (extra is! Map<String, dynamic>) return null;
  try {
    return PharmaReturnContext.fromExtra(extra);
  } catch (_) {
    return null;
  }
}

class AppRouter {
  static const bool _enableRouterDiagnostics = bool.fromEnvironment(
    'ENABLE_ROUTER_DEBUG_LOGS',
    defaultValue: false,
  );

  final AuthCubit authCubit;

  AppRouter({required this.authCubit}) {
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

  /// Redirect home when the signed-in user cannot perform [step].
  /// Unauthenticated callers fall through to the top-level auth redirect.
  String? _requireOperationStep(String step) {
    final auth = authCubit.state;
    if (!auth.isAuthenticated) return null;
    if (!auth.canPerform(step)) return Constants.homeRoute;
    return null;
  }

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
    initialLocation: Constants.splashRoute,
    redirect: (context, state) {
      return computeRedirect(
        path: state.uri.path,
        fromQuery: state.uri.queryParameters['from'],
        currentLocation: state.uri.toString(),
      );
    },
    routes: [
      ..._appRoutes1(this),
      ..._appRoutes2(this),
      ..._appRoutes3(this),
      ..._appRoutes4(this),
    ],
    errorPageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: RouterNotFoundScreen(uri: state.uri.toString()),
    ),
  );
}
