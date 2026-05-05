import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/barcode/screens/barcode_generation_screen.dart';
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
import 'package:traqtrace_app/features/epcis/screens/validation_rule_management_screen.dart'; // Added import
import 'package:traqtrace_app/features/epcis/screens/validation_rules_help_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/rule_editor_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/epc_conversion_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_screen.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_route_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/screens/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/screens/gtin_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/sgtin/sgtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/sgtin/sgtin_list_screen_advanced.dart';
import 'package:traqtrace_app/features/gs1/screens/sscc/sscc_advanced_list_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/sscc/sscc_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/screens/validation/gs1_validation_demo_screen.dart';
import 'package:traqtrace_app/data/services/epc_conversion_service.dart';
import 'package:traqtrace_app/features/user_management/screens/home_screen.dart';
import 'package:traqtrace_app/features/user_management/screens/profile_screen.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings_screen.dart';
// EPCIS imports
import 'package:traqtrace_app/features/epcis/screens/epcis_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/object_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/object_event_batch_import_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/aggregation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/aggregation_event_hierarchy_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_events_help_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_document_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_document_help_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transformation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/transformation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/advanced_query_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/traversal_query_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/epcis_serialization_screen.dart';
// Operations imports
import 'package:traqtrace_app/features/epcis/screens/operations/shipping_operation_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/shipping_operation_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/receiving_operation_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/receiving_operation_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/packing_operation_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/packing_operation_list_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/packing_operation_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/commissioning_operation_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/screens/operations/commissioning_operation_list_screen.dart';
// Notification imports
import 'package:traqtrace_app/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/subscription_management_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/subscription_details_screen.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/webhook_configuration_screen.dart';
// Barcode imports
import 'package:traqtrace_app/features/barcode/screens/api_enabled_barcode_scanner_screen.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/routes/transaction_event_validation_demo_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
// Dashboard imports
import 'package:traqtrace_app/features/dashboards/screens/product_journey_screen.dart';
// API Management imports
import 'package:traqtrace_app/features/api_management/screens/partner_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/partner_detail_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/credential_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/api_analytics_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/service_account_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/api_collection_management_screen.dart';
import 'package:traqtrace_app/features/api_management/screens/partner_access_management_screen.dart';

import 'package:traqtrace_app/features/admin/user_management/presentation/users/screens/user_management_screen.dart';
import 'package:traqtrace_app/features/admin/user_management/presentation/approvals/screens/approvals_screen.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/forgot_password/screen/forgot_password_screen.dart';
import 'package:traqtrace_app/features/auth/presentation/check_email/screen/check_email_screen.dart';
import 'package:traqtrace_app/features/auth/presentation/login/screen/login_screen.dart';
import 'package:traqtrace_app/features/auth/presentation/register/screen/register_screen.dart';
import 'package:traqtrace_app/features/auth/presentation/reset_password/screen/reset_password_screen.dart';
import 'package:traqtrace_app/features/splash/presentation/splash_screen.dart';
import 'package:traqtrace_app/features/auth/presentation/verify_email/screen/verify_email_screen.dart';

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

      // While auth is being restored, keep users on the splash screen
      // instead of letting protected route guards send them to /login.
      if (_isAuthCheckPending() && !_isPublicPath(path)) {
        return _buildSplashRedirect(state);
      }

      return null;
    },
    // Using modern GoRouter configuration
    routes: [
      GoRoute(
        path: Constants.splashRoute,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: Constants.loginRoute,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: Constants.registerRoute,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: Constants.checkEmailRoute,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return MaterialPage(
            key: state.pageKey,
            child: CheckEmailScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.forgotPasswordRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: Constants.resetPasswordRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      // Same screen as /reset-password — backend/email links often use /auth/...
      GoRoute(
        path: Constants.authResetPasswordRoute,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return MaterialPage(
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
          return MaterialPage(
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
          return MaterialPage(
            key: state.pageKey,
            child: VerifyEmailScreen(token: token, email: email),
          );
        },
      ),
      GoRoute(
        path: Constants.homeRoute,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const HomeScreen()),
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
            MaterialPage(key: state.pageKey, child: const ProfileScreen()),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),
      // Dashboard routes
      GoRoute(
        path: Constants.journeyDashboardRoute,
        pageBuilder: (context, state) {
          final epc = state.uri.queryParameters['epc'];
          return MaterialPage(
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
      // Admin routes
      GoRoute(
        path: Constants.adminUsersRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => getIt<UserManagementCubit>(),
            child: const UserManagementScreen(),
          ),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApprovalsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => getIt<UserManagementCubit>(),
            child: const ApprovalsScreen(),
          ),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminSettingsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SystemSettingsScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminGs1ValidationRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const GS1ValidationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.loginRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminPerformanceTestsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PerformanceTestScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminPerformanceOptimizationRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PerformanceOptimizationDashboard(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminMonitoringRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MonitoringDashboardScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminIntegrationValidationRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const IntegrationValidationScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminEventGenerationTestRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EventGenerationTestScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminIndustryTestDataRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const IndustryTestDataScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminValidationRulesRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ValidationRuleManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminValidationRulesHelpRoute,
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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
          return MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DatabasePartitioningDashboard(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminCacheRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CacheManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      // Phase 3.3 Batch Processing routes
      GoRoute(
        path: Constants.adminJobQueueRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const JobQueueManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminEtlManagementRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ETLManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminBulkExportRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const BulkExportManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminDataConsistencyIntegrityRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DataConsistencyIntegrityDashboard(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      // API Management routes
      GoRoute(
        path: Constants.adminApiPartnersRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PartnerManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
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
          return MaterialPage(
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

          // Check if user has admin role
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
          return MaterialPage(
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

          // Check if user has admin role
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
          return MaterialPage(
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

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApiServiceAccountsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ServiceAccountManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      // API Collections Management route
      GoRoute(
        path: Constants.adminApiCollectionsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ApiCollectionManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      // Partner Access Management route
      GoRoute(
        path: Constants.adminApiPartnerAccessRoute,
        pageBuilder: (context, state) {
          final partnerId = state.pathParameters['partnerId'] ?? '';
          return MaterialPage(
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

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      // Partner Access Management route (without partnerId)
      GoRoute(
        path: Constants.adminApiAccessRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PartnerAccessManagementScreen(),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          final user = authCubit.state.user;

          if (!isAuthenticated) {
            return Constants.loginRoute;
          }

          // Check if user has admin role
          if (user?.role != 'ADMIN') {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      // GTIN routes
      GoRoute(
        path: Constants.gs1GtinsRoute,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const GTINScreen()),
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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
          return MaterialPage(
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
      // GLN routes
      GoRoute(
        path: Constants.gs1GlnsRoute,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const GLNScreen()),
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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
          return MaterialPage(
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
      // SSCC routes
      GoRoute(
        path: Constants.gs1SsccsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SSCCAdvancedListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SSCCDetailScreen(mode: SSCCDetailMode.create),
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
          final ssccId = state.pathParameters['ssccId'] ?? '';
          final ssccCode =
              state.extra as String?; // Pass ssccCode as extra data
          return MaterialPage(
            key: state.pageKey,
            child: SSCCDetailScreen(
              mode: SSCCDetailMode.view,
              ssccId: ssccId.isNotEmpty ? ssccId : null,
              ssccCode: ssccCode,
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
          final ssccId = state.pathParameters['ssccId'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: SSCCDetailScreen(mode: SSCCDetailMode.edit, ssccId: ssccId),
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

      // SGTIN routes
      GoRoute(
        path: Constants.gs1SgtinsRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SGTINAdvancedListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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
          return MaterialPage(
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

      // EPC Conversion route
      GoRoute(
        path: Constants.gs1EpcConversionRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: EPCConversionScreen(
            epcConversionService: getIt<EPCConversionService>(),
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
      // GS1 Validation Demo route
      GoRoute(
        path: Constants.gs1ValidationDemoRoute,
        pageBuilder: (context, state) => MaterialPage(
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
      // EPCIS Event Routes with placeholder screens
      GoRoute(
        path: Constants.epcisEventsRoute,
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ObjectEventsListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AggregationEventsListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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

      // Advanced Query Interface Routes
      GoRoute(
        path: Constants.epcisAdvancedQueryRoute,
        pageBuilder: (context, state) => MaterialPage(
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

      // Supply Chain Traversal Query Routes
      GoRoute(
        path: Constants.epcisTraversalQueryRoute,
        pageBuilder: (context, state) => MaterialPage(
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

      // EPCIS Serialization & Format Conversion Routes
      GoRoute(
        path: Constants.epcisSerializationRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: EPCISSerializationScreen(appConfig: getIt<AppConfig>()),
        ),
        redirect: (context, state) {
          final isAuthenticated = authCubit.state.isAuthenticated;
          if (!isAuthenticated) {
            return Constants.loginRoute;
          }
          return null;
        },
      ),

      // Routes for creating new EPCIS events
      GoRoute(
        path: Constants.epcisObjectEventNewRoute,
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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

      // Routes for viewing and editing existing EPCIS events
      GoRoute(
        path: Constants.epcisEventDetailRoute,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            // Generic event detail view
            child: Scaffold(
              appBar: AppBar(title: const Text('Event Details')),
              body: Center(child: Text('Viewing event ID: $eventId')),
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
        path: Constants.epcisObjectEventDetailRoute,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra;

          // If we received the event object directly via the extra parameter
          if (extra is ObjectEvent) {
            return MaterialPage(
              key: state.pageKey,
              child: ObjectEventFormScreen(
                event: extra,
                isViewOnly: true, // Set to view mode
              ),
            );
          } else {
            // Otherwise we need to fetch it - the provider would handle this
            return MaterialPage(
              key: state.pageKey,
              child: Builder(
                builder: (context) {
                  // Trigger loading of the event data
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final cubit = context.read<ObjectEventsCubit>();
                    cubit.getObjectEvent(id);
                  });

                  // Return the form screen that will display the event once loaded
                  return const ObjectEventFormScreen(
                    isViewOnly: true, // Set to view mode
                  );
                },
              ),
            );
          }
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
        path: Constants.epcisAggregationEventDetailRoute,
        pageBuilder: (context, state) {
          final aggregationEventId = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: AggregationEventFormScreen(
              aggregationEventId: aggregationEventId,
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
          return MaterialPage(
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
      // Add route for Transaction Document operations
      GoRoute(
        path: Constants.epcisTransactionDocumentsRoute,
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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
      // Aggregation Event Hierarchy Screen
      GoRoute(
        path: Constants.epcisAggregationEventHierarchyRoute,
        pageBuilder: (context, state) {
          final epc = state.pathParameters['epc'] ?? '';
          final Map<String, dynamic> extra =
              (state.extra as Map<String, dynamic>?) ?? {};
          final isParent = extra['isParent'] as bool? ?? true;

          return MaterialPage(
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

      // Operations routes
      GoRoute(
        path: Constants.opShippingRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ShippingOperationListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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

      // Receiving Operations routes
      GoRoute(
        path: Constants.opReceivingRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ReceivingOperationListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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

      // Packing Operations routes
      GoRoute(
        path: Constants.opPackingRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PackingOperationListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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

      // Commissioning Operations routes
      GoRoute(
        path: Constants.opCommissioningRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CommissioningOperationListScreen(),
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => getIt<GTINCubit>(),
            child: const CommissioningOperationScreen(),
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
        path: Constants.opCommissioningDetailRoute,
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: CommissioningOperationDetailScreen(operationId: operationId),
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

      // Notification routes
      GoRoute(
        path: Constants.notificationsRoute,
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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
          return MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
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

      // Barcode Routes - Using the new GS1 Barcode Scanner
      GoRoute(
        path: Constants.barcodeScanRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ApiEnabledBarcodeScannerScreen(
            title: 'GS1 Barcode Scanner',
            locationGLN: '',
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
      // Barcode generation route
      GoRoute(
        path: Constants.barcodeGenerateRoute,
        pageBuilder: (context, state) => MaterialPage(
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
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: ApiEnabledBarcodeScannerScreen(
            title: 'Verify GS1 Barcode',
            businessStep: 'urn:epcglobal:cbv:bizstep:verifying',
            disposition: 'urn:epcglobal:cbv:disp:in_progress',
            locationGLN: '',
            isVerificationMode: true,
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
      // Demo routes for showcasing validation
      TransactionEventValidationDemoRoute.getRoute(),
      GoRoute(
        path: Constants.demoValidationRulesRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ValidationRuleManagementScreen(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Text('No route defined for ${state.uri.toString()}'),
        ),
      ),
    ),
  );
}
