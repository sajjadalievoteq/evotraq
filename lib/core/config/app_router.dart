import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/config/router_not_found_screen.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/barcode/screens/barcode_generation_screen.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/gs1_validation_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data_screen.dart';
import 'package:traqtrace_app/features/admin/screens/integration_validation_screen.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/widgets/performance_optimization_dashboard.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning_dashboard.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/job_queue_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/etl_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/bulk_export_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity_dashboard.dart';
import 'package:traqtrace_app/features/epcis/presentation/validation_rules/screens/validation_rule_management_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/validation_rules/screens/validation_rules_help_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/validation_rules/screens/rule_editor_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/epc_conversion_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln/gln_screen.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin/gtin_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/sgtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin/sgtin_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc/sscc_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/validation/gs1_validation_demo_screen.dart';
import 'package:traqtrace_app/features/home/screens/home/home_screen.dart';
import 'package:traqtrace_app/features/user/screens/profile/profile_screen.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/screens/epcis_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/object_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/utils/object_event_route_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_batch_import/object_event_batch_import_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event/object_event_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event/aggregation_event_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/aggregation_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_hierarchy/aggregation_event_hierarchy_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_events_help_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_document_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_document_help_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transformation_events/screens/transformation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transformation_events/screens/transformation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/query/screens/advanced_query_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/query/screens/traversal_query_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/screens/epcis_generic_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/screens/epcis_serialization_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping/shipping_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/shipping_operation_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving/receiving_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/packing_operation_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing/packing_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/packing_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/unpacking_operation_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking/unpacking_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/unpacking_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning/commissioning_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/subscription_management_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/subscription_details_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/webhook_configuration_screen.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner_screen.dart';
import 'package:traqtrace_app/features/epcis/routes/transaction_event_validation_demo_route.dart';
import 'package:traqtrace_app/features/dashboards/screens/product_journey_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/partner_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/partner_detail_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/credential_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/api_analytics_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/service_account_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/api_collection_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/partner_access_management_screen.dart';

import 'package:traqtrace_app/features/admin/user_management/screens/user_management/user_management_screen.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/approvals_screen.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/forgot_password/screens/forgot_password_screen.dart';
import 'package:traqtrace_app/features/auth/verify_email/screens/check_email_screen.dart';
import 'package:traqtrace_app/features/auth/login/screens/login_screen.dart';
import 'package:traqtrace_app/features/auth/signup/screens/signup_screen.dart';
import 'package:traqtrace_app/features/auth/reset_password/screens/reset_password_screen.dart';
import 'package:traqtrace_app/features/splash/presentation/splash_screen.dart';
import 'package:traqtrace_app/features/auth/verify_email/screens/verify_email_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
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

  AppRouter({required this.authCubit});

  bool _isAuthCheckPending() {
    return authCubit.state.status == AuthStatus.initial ||
        authCubit.state.status == AuthStatus.loading;
  }

  bool _isPublicPath(String path) {
    return path == Constants.splashRoute ||
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

  String? _buildSplashRedirect(GoRouterState state) {
    final currentLocation = state.uri.toString();
    if (state.uri.path == Constants.splashRoute) {
      return null;
    }

    return Uri(
      path: Constants.splashRoute,
      queryParameters: {'from': currentLocation},
    ).toString();
  }

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    debugLogDiagnostics: _enableRouterDiagnostics,
    initialLocation: Constants.splashRoute,
    redirect: (context, state) {
      final path = state.uri.path;

      if (_isAuthCheckPending() && !_isPublicPath(path)) {
        return _buildSplashRedirect(state);
      }

      if (authCubit.state.isAuthenticated && _isAuthOnlyPath(path)) {
        return Constants.homeRoute;
      }

      if (!authCubit.state.isAuthenticated &&
          !_isPublicPath(path) &&
          !_isAuthCheckPending()) {
        return Constants.loginRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Constants.splashRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: Constants.loginRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: Constants.registerRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: Constants.checkEmailRoute,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: CheckEmailScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.forgotPasswordRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: Constants.resetPasswordRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: Constants.authResetPasswordRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: Constants.verifyEmailRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'];
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: VerifyEmailScreen(token: token, email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.verifyEmailAliasRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'];
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: VerifyEmailScreen(token: token, email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.homeRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const HomeScreen()),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.profileRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const ProfileScreen()),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.journeyDashboardRoute,
        pageBuilder: (context, state) {
          final epc = state.uri.queryParameters['epc'];
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ProductJourneyScreen(initialEpc: epc),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.adminUsersRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const UserManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApprovalsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ApprovalsScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminSettingsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const SystemSettingsScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminGs1ValidationRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const GS1ValidationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.loginRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminPerformanceTestsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const PerformanceTestScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminPerformanceOptimizationRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const PerformanceOptimizationDashboard(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminMonitoringRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const MonitoringDashboardScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminIntegrationValidationRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const IntegrationValidationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminEventGenerationTestRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const EventGenerationTestScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminIndustryTestDataRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const IndustryTestDataScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminCbvVocabularyRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const CbvVocabularyManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminValidationRulesRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ValidationRuleManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminValidationRulesHelpRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ValidationRulesHelpScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminValidationRulesNewRoute,
        pageBuilder: (context, state) {
          final ruleId = state.pathParameters['ruleId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: RuleEditorRouteScreen(
              ruleId: ruleId,
              isPredefined: false,
              isNew: true,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminValidationRulesEditRoute,
        pageBuilder: (context, state) {
          final ruleId = state.pathParameters['ruleId'] ?? '';
          final isPredefined =
              state.uri.queryParameters['predefined'] == 'true';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: RuleEditorRouteScreen(
              ruleId: ruleId,
              isPredefined: isPredefined,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminDatabasePartitioningRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const DatabasePartitioningDashboard(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminCacheRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const CacheManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminJobQueueRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const JobQueueManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminEtlManagementRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ETLManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminBulkExportRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const BulkExportManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminDataConsistencyIntegrityRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const DataConsistencyIntegrityDashboard(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiPartnersRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const PartnerManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiPartnerDetailRoute,
        pageBuilder: (context, state) {
          final partnerId = state.pathParameters['partnerId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: PartnerDetailScreen(partnerId: partnerId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiPartnerCredentialsRoute,
        pageBuilder: (context, state) {
          final partnerId = state.pathParameters['partnerId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: CredentialManagementScreen(partnerId: partnerId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiPartnerAnalyticsRoute,
        pageBuilder: (context, state) {
          final partnerId = state.pathParameters['partnerId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ApiAnalyticsScreen(partnerId: partnerId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiServiceAccountsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ServiceAccountManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiCollectionsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ApiCollectionManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiPartnerAccessRoute,
        pageBuilder: (context, state) {
          final partnerId = state.pathParameters['partnerId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: PartnerAccessManagementScreen(initialPartnerId: partnerId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiAccessRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const PartnerAccessManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GtinsRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const GTINScreen()),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GtinNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const GTINDetailScreen(isEditing: true),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GtinDetailRoute,
        pageBuilder: (context, state) {
          final gtinCode = state.pathParameters['gtinCode'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: GTINDetailScreen(gtinCode: gtinCode, isEditing: false),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GtinEditRoute,
        pageBuilder: (context, state) {
          final gtinCode = state.pathParameters['gtinCode'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: GTINDetailScreen(gtinCode: gtinCode, isEditing: true),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GlnsRoute,
        pageBuilder: (context, state) =>
            TraqRouterTransitions.page(key: state.pageKey, child: const GLNScreen()),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GlnNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const GLNDetailScreen(isEditing: true),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GlnDetailRoute,
        pageBuilder: (context, state) {
          final glnId =
              state.pathParameters[GlnRouteConstants.pathParamGlnId] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: GLNDetailScreen(glnId: glnId, isEditing: false),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GlnEditRoute,
        pageBuilder: (context, state) {
          final glnId =
              state.pathParameters[GlnRouteConstants.pathParamGlnId] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: GLNDetailScreen(glnId: glnId, isEditing: true),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SsccsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const SSCCScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SsccNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const SSCCDetailScreen(isEditing: true),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SsccDetailRoute,
        pageBuilder: (context, state) {
          final ssccCode = state.pathParameters['ssccId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: SSCCDetailScreen(
              isEditing: false,
              ssccCode: ssccCode.isNotEmpty ? ssccCode : null,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SsccEditRoute,
        pageBuilder: (context, state) {
          final ssccCode = state.pathParameters['ssccId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: SSCCDetailScreen(
              isEditing: true,
              ssccCode: ssccCode.isNotEmpty ? ssccCode : null,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.gs1SgtinsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const SGTINScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SgtinNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const SGTINDetailScreen(isEditing: true),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SgtinDetailRoute,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: SGTINDetailScreen(sgtinId: id, isEditing: false),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1SgtinEditRoute,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: SGTINDetailScreen(sgtinId: id, isEditing: true),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.gs1EpcConversionRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const EPCConversionScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1ValidationDemoRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const GS1ValidationDemoScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const EPCISEventsListScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisObjectEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ObjectEventScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisAggregationEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const AggregationEventScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransactionEventsListScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransformationEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransformationEventsListScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.epcisAdvancedQueryRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const AdvancedQueryScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.epcisTraversalQueryRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TraversalQueryScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.epcisSerializationRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const EPCISSerializationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.epcisObjectEventNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ObjectEventFormScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisObjectEventBatchImportRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ObjectEventBatchImportScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisAggregationEventNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const AggregationEventFormScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionEventNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransactionEventFormScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionEventHelpRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransactionEventsHelpScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransformationEventNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransformationEventFormScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.epcisEventDetailRoute,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: EpcisGenericEventDetailScreen(eventId: eventId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisObjectEventDetailQueryRoute,
        pageBuilder: (context, state) {
          final eventId = state.uri.queryParameters[
                  ObjectEventRouteConstants.queryEventId] ??
              '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ObjectEventDetailScreen(eventId: eventId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisObjectEventDetailRoute,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ObjectEventDetailScreen(eventId: id),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          final id = state.pathParameters['id'] ?? '';
          if (id.contains(':') ||
              id.contains(';') ||
              id.contains('/')) {
            return ObjectEventRouteConstants.detailLocation(id);
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisAggregationEventDetailRoute,
        pageBuilder: (context, state) {
          final aggregationEventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: AggregationEventDetailScreen(
              eventId: aggregationEventId,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionEventDetailRoute,
        pageBuilder: (context, state) {
          final transactionEventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: TransactionEventFormScreen(
              transactionEventId: transactionEventId,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionDocumentsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransactionDocumentScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransactionDocumentHelpRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const TransactionDocumentHelpScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisTransformationEventDetailRoute,
        pageBuilder: (context, state) {
          final transformationEventId = state.pathParameters['id'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: TransformationEventFormScreen(
              transformationEventId: transformationEventId,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.epcisAggregationEventHierarchyRoute,
        pageBuilder: (context, state) {
          final epc = state.pathParameters['epc'] ?? '';
          final Map<String, dynamic> extra =
              (state.extra as Map<String, dynamic>?) ?? {};
          final isParent = extra['isParent'] as bool? ?? true;

          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: AggregationEventHierarchyScreen(
              epc: epc,
              isParent: isParent,
            ),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.opShippingRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ShippingScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opShippingCreateRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ShippingOperationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opShippingDetailRoute,
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ShippingOperationDetailScreen(operationId: operationId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.opReceivingRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ReceivingScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opReceivingCreateRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ReceivingOperationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opReceivingDetailRoute,
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: ReceivingOperationDetailScreen(operationId: operationId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.opPackingRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const PackingScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opPackingCreateRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const PackingOperationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opPackingDetailRoute,
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: PackingOperationDetailScreen(operationId: operationId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.opUnpackingRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const UnpackingScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opUnpackingCreateRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const UnpackingOperationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opUnpackingDetailRoute,
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: UnpackingOperationDetailScreen(operationId: operationId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.opCommissioningRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const CommissioningScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opCommissioningNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const CommissioningOperationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.opCommissioningDetailRoute,
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId'] ?? '';
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: CommissioningOperationDetailScreen(batchId: operationId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.notificationsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const NotificationCenterScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.notificationSubscriptionsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const SubscriptionManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.notificationDetailRoute,
        pageBuilder: (context, state) {
          final subscriptionId = state.pathParameters['subscriptionId']!;
          return TraqRouterTransitions.page(
            key: state.pageKey,
            child: SubscriptionDetailsScreen(subscriptionId: subscriptionId),
          );
        },
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.notificationWebhooksRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const WebhookConfigurationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      GoRoute(
        path: Constants.barcodeScanRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const GS1BarcodeScannerScreen(
            title: 'GS1 Barcode Scanner',
          ),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.barcodeGenerateRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const BarcodeGenerationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.barcodeVerifyRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const GS1BarcodeScannerScreen(
            title: 'Verify GS1 Barcode',
            verifyWithBackend: true,
          ),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      TransactionEventValidationDemoRoute.getRoute(),
      GoRoute(
        path: Constants.demoValidationRulesRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.page(
          key: state.pageKey,
          child: const ValidationRuleManagementScreen(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => TraqRouterTransitions.page(
      key: state.pageKey,
      child: RouterNotFoundScreen(uri: state.uri.toString()),
    ),
  );
}
