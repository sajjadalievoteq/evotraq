import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/config/router_not_found_screen.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/core/config/splash_redirect_utils.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/cbv_vocabulary_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data_screen.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/widgets/performance_optimization_dashboard.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning_dashboard.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity_dashboard.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/automation_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_shell.dart';
import 'package:traqtrace_app/features/epcis/widgets/epcis_shell.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools_screen.dart';
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
import 'package:traqtrace_app/features/admin/screens/system_settings_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/object_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/utils/object_event_route_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/object_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_batch_import/object_event_batch_import_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event/object_event_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event/aggregation_event_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/aggregation_event_detail_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_events_help_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_document_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transaction_events/screens/transaction_document_help_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transformation_events/screens/transformation_events_list_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/transformation_events/screens/transformation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/presentation/screens/epcis_generic_event_detail_screen.dart';
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
import 'package:traqtrace_app/features/auth/forgot_password/screens/forgot_password_screen.dart';
import 'package:traqtrace_app/features/auth/verify_email/screens/check_email_screen.dart';
import 'package:traqtrace_app/features/auth/login/screens/login_screen.dart';
import 'package:traqtrace_app/features/auth/signup/screens/signup_screen.dart';
import 'package:traqtrace_app/features/auth/reset_password/screens/reset_password_screen.dart';
import 'package:traqtrace_app/features/splash/screens/Splash/splash_screen.dart';
import 'package:traqtrace_app/features/auth/verify_email/screens/verify_email_screen.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_shell.dart';

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

  AppRouter({required this.authCubit});

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
      GoRoute(
        path: Constants.splashRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          animate: false,
          child: const SplashScreen(),
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => AuthShell(child: child),
        routes: [
          GoRoute(
            path: Constants.loginRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.authShellPage(
                  key: state.pageKey,
                  child: const LoginScreen(),
                ),
          ),
          GoRoute(
            path: Constants.registerRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.authShellPage(
                  key: state.pageKey,
                  child: const RegisterScreen(),
                ),
          ),
          GoRoute(
            path: Constants.checkEmailRoute,
            pageBuilder: (context, state) {
              final email = state.uri.queryParameters['email'];
              return TraqRouterTransitions.authShellPage(
                key: state.pageKey,
                child: CheckEmailScreen(email: email),
              );
            },
          ),
          GoRoute(
            path: Constants.forgotPasswordRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.authShellPage(
                  key: state.pageKey,
                  child: const ForgotPasswordScreen(),
                ),
          ),
          GoRoute(
            path: Constants.resetPasswordRoute,
            pageBuilder: (context, state) {
              final token = state.uri.queryParameters['token'] ?? '';
              return TraqRouterTransitions.authShellPage(
                key: state.pageKey,
                child: ResetPasswordScreen(token: token),
              );
            },
          ),
          GoRoute(
            path: Constants.authResetPasswordRoute,
            pageBuilder: (context, state) {
              final token = state.uri.queryParameters['token'] ?? '';
              return TraqRouterTransitions.authShellPage(
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
              return TraqRouterTransitions.authShellPage(
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
              return TraqRouterTransitions.authShellPage(
                key: state.pageKey,
                child: VerifyEmailScreen(token: token, email: email),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Constants.homeRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: Constants.profileRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: Constants.journeyDashboardRoute,
        pageBuilder: (context, state) {
          final epc = state.uri.queryParameters['epc'];
          return TraqRouterTransitions.fadeThroughPage(
            key: state.pageKey,
            child: JourneyDashboardScreen(initialEpc: epc),
          );
        },
      ),
      GoRoute(
        path: Constants.inboxOutboxRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const InboxOutboxScreen(),
        ),
      ),
      GoRoute(
        path: Constants.productHierarchyRoute,
        pageBuilder: (context, state) {
          final epc = state.uri.queryParameters['epc'];
          return TraqRouterTransitions.fadeThroughPage(
            key: state.pageKey,
            child: ProductHierarchyScreen(initialEpc: epc),
          );
        },
      ),
      GoRoute(
        path: Constants.adminUsersRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const UserManagementScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminApprovalsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ApprovalsScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminSettingsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const SystemSettingsScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminGs1ValidationRoute,
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.loginRoute;
          }
          return '${Constants.gs1ToolsRoute}?tool=batch';
        },
      ),
      GoRoute(
        path: Constants.adminPerformanceTestsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const PerformanceTestScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminPerformanceOptimizationRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const PerformanceOptimizationDashboard(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminMonitoringRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const MonitoringDashboardScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminIntegrationValidationRoute,
        // Integration self-tests write/delete DB rows and are not user-facing.
        // Backend service remains @Profile("!prod") for CI/dev only.
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            return null;
          }
          return Constants.homeRoute;
        },
      ),
      GoRoute(
        path: Constants.adminEventGenerationTestRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const EventGenerationTestScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminIndustryTestDataRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const IndustryTestDataScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminCbvVocabularyRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const CbvVocabularyManagementScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminDatabasePartitioningRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const DatabasePartitioningDashboard(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.adminCacheRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const CacheManagementScreen(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.automationCenterRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: AutomationCenterScreen(
            initialSection: state.uri.queryParameters['section'],
          ),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) return null;
          final section = AutomationCenterSections.normalize(
            state.uri.queryParameters['section'],
          );
          if (AutomationCenterSections.adminOnly.contains(section) &&
              !authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }
          return null;
        },
      ),
      GoRoute(
        path: Constants.adminBackgroundJobsRoute,
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }
          return AutomationCenterSections.location(
            AutomationCenterSections.backgroundJobs,
          );
        },
      ),
      GoRoute(
        path: '/background-jobs',
        redirect: (context, state) => AutomationCenterSections.location(
          AutomationCenterSections.backgroundJobs,
        ),
      ),
      GoRoute(
        path: Constants.adminDataConsistencyIntegrityRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const DataConsistencyIntegrityDashboard(),
        ),
        redirect: (context, state) {
          if (!authCubit.state.isAuthenticated) {
            // Top-level redirect owns login?from= while auth settles.
            return null;
          }
          if (!authCubit.state.isAdmin) {
            return Constants.homeRoute;
          }

          return null;
        },
      ),
      GoRoute(
        path: Constants.gs1GtinsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const GTINScreen(),
        ),
      ),
      GoRoute(
        path: Constants.gs1GtinNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const GTINDetailScreen(isEditing: true),
        ),
      ),
      GoRoute(
        path: Constants.gs1GtinDetailRoute,
        pageBuilder: (context, state) {
          final gtinCode = state.pathParameters['gtinCode'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: GTINDetailScreen(gtinCode: gtinCode, isEditing: false),
          );
        },
      ),
      GoRoute(
        path: Constants.gs1GtinEditRoute,
        pageBuilder: (context, state) {
          final gtinCode = state.pathParameters['gtinCode'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: GTINDetailScreen(gtinCode: gtinCode, isEditing: true),
          );
        },
      ),
      GoRoute(
        path: Constants.gs1GlnsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const GLNScreen(),
        ),
      ),
      GoRoute(
        path: Constants.gs1GlnNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const GLNDetailScreen(isEditing: true),
        ),
      ),
      GoRoute(
        path: Constants.gs1GlnDetailRoute,
        pageBuilder: (context, state) {
          final glnId =
              state.pathParameters[GlnRouteConstants.pathParamGlnId] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: GLNDetailScreen(glnId: glnId, isEditing: false),
          );
        },
      ),
      GoRoute(
        path: Constants.gs1GlnEditRoute,
        pageBuilder: (context, state) {
          final glnId =
              state.pathParameters[GlnRouteConstants.pathParamGlnId] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: GLNDetailScreen(glnId: glnId, isEditing: true),
          );
        },
      ),
      GoRoute(
        path: Constants.gs1SsccsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const SSCCScreen(),
        ),
      ),
      GoRoute(
        path: Constants.gs1SsccNewRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const SSCCDetailScreen(isEditing: true),
        ),
      ),
      GoRoute(
        path: Constants.gs1SsccDetailRoute,
        pageBuilder: (context, state) {
          final ssccCode = state.pathParameters['ssccId'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: SSCCDetailScreen(
              isEditing: false,
              ssccCode: ssccCode.isNotEmpty ? ssccCode : null,
            ),
          );
        },
      ),
      GoRoute(
        path: Constants.gs1SsccEditRoute,
        pageBuilder: (context, state) {
          final ssccCode = state.pathParameters['ssccId'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: SSCCDetailScreen(
              isEditing: true,
              ssccCode: ssccCode.isNotEmpty ? ssccCode : null,
            ),
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) => SgtinShell(child: child),
        routes: [
          GoRoute(
            path: Constants.gs1SgtinsRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.fadeThroughPage(
                  key: state.pageKey,
                  child: const SGTINScreen(),
                ),
          ),
          GoRoute(
            path: Constants.gs1SgtinNewRoute,
            pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
              key: state.pageKey,
              child: const SGTINDetailScreen(isEditing: true),
            ),
          ),
          GoRoute(
            path: Constants.gs1SgtinByEpcRoute,
            pageBuilder: (context, state) {
              final epcUri = state.extra as String? ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: SGTINDetailScreen(
                  epcUri: epcUri.isNotEmpty ? epcUri : null,
                  isEditing: false,
                ),
              );
            },
          ),
          GoRoute(
            path: Constants.gs1SgtinDetailRoute,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: SGTINDetailScreen(sgtinId: id, isEditing: false),
              );
            },
          ),
          GoRoute(
            path: Constants.gs1SgtinEditRoute,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: SGTINDetailScreen(sgtinId: id, isEditing: true),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Constants.gs1ToolsRoute,
        pageBuilder: (context, state) {
          final toolId = state.uri.queryParameters['tool'];
          final modeParam = state.uri.queryParameters['mode'];
          String? resolvedMode = modeParam;
          final tool = Gs1ToolKindX.fromId(
            toolId,
            onMode: (m) => resolvedMode ??= m,
          );
          return TraqRouterTransitions.fadeThroughPage(
            key: state.pageKey,
            child: Gs1ToolsScreen(initialTool: tool, initialMode: resolvedMode),
          );
        },
      ),
      GoRoute(
        path: Constants.validationWorkbenchRoute,
        redirect: (context, state) {
          final sectionId = (state.uri.queryParameters['section'] ?? '')
              .toLowerCase();
          if (sectionId == 'integration') {
            return Constants.homeRoute;
          }
          if (sectionId == 'batch' ||
              sectionId == 'tests' ||
              sectionId == 'gs1-validation') {
            return '${Constants.gs1ToolsRoute}?tool=batch';
          }
          return '${Constants.gs1ToolsRoute}?tool=identifier';
        },
      ),
      GoRoute(
        path: Constants.gs1EpcConversionRoute,
        redirect: (context, state) => '${Constants.gs1ToolsRoute}?tool=epc',
      ),
      GoRoute(
        path: Constants.gs1ValidationDemoRoute,
        redirect: (context, state) =>
            '${Constants.gs1ToolsRoute}?tool=validator',
      ),
      ShellRoute(
        builder: (context, state, child) => EpcisShell(child: child),
        routes: [
          GoRoute(
            path: Constants.epcisObjectEventsRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.fadeThroughPage(
                  key: state.pageKey,
                  child: const ObjectEventScreen(),
                ),
          ),
          GoRoute(
            path: Constants.epcisAggregationEventsRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.fadeThroughPage(
                  key: state.pageKey,
                  child: const AggregationEventScreen(),
                ),
          ),
          GoRoute(
            path: Constants.epcisTransactionEventsRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.fadeThroughPage(
                  key: state.pageKey,
                  child: const TransactionEventsListScreen(),
                ),
          ),
          GoRoute(
            path: Constants.epcisTransformationEventsRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.fadeThroughPage(
                  key: state.pageKey,
                  child: const TransformationEventsListScreen(),
                ),
          ),

          GoRoute(
            path: Constants.epcisObjectEventNewRoute,
            pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
              key: state.pageKey,
              child: const ObjectEventFormScreen(),
            ),
          ),
          GoRoute(
            path: Constants.epcisObjectEventBatchImportRoute,
            pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
              key: state.pageKey,
              child: const ObjectEventBatchImportScreen(),
            ),
          ),
          GoRoute(
            path: Constants.epcisAggregationEventNewRoute,
            pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
              key: state.pageKey,
              child: const AggregationEventFormScreen(),
            ),
          ),
          GoRoute(
            path: Constants.epcisTransactionEventNewRoute,
            pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
              key: state.pageKey,
              child: const TransactionEventFormScreen(),
            ),
          ),
          GoRoute(
            path: Constants.epcisTransactionEventHelpRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.sharedAxisHorizontalPage(
                  key: state.pageKey,
                  child: const TransactionEventsHelpScreen(),
                ),
          ),
          GoRoute(
            path: Constants.epcisTransformationEventNewRoute,
            pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
              key: state.pageKey,
              child: const TransformationEventFormScreen(),
            ),
          ),

          GoRoute(
            path: Constants.epcisEventDetailRoute,
            pageBuilder: (context, state) {
              final eventId = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: EpcisGenericEventDetailScreen(eventId: eventId),
              );
            },
          ),
          GoRoute(
            path: Constants.epcisObjectEventDetailQueryRoute,
            pageBuilder: (context, state) {
              final eventId =
                  state.uri.queryParameters[ObjectEventRouteConstants
                      .queryEventId] ??
                  '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: ObjectEventDetailScreen(eventId: eventId),
              );
            },
          ),
          GoRoute(
            path: Constants.epcisObjectEventDetailRoute,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: ObjectEventDetailScreen(eventId: id),
              );
            },
            redirect: (context, state) {
              if (!authCubit.state.isAuthenticated) {
                // Top-level redirect owns login?from= while auth settles.
                return null;
              }
              final id = state.pathParameters['id'] ?? '';
              if (id.contains(':') || id.contains(';') || id.contains('/')) {
                return ObjectEventRouteConstants.detailLocation(id);
              }
              return null;
            },
          ),
          GoRoute(
            path: Constants.epcisAggregationEventDetailRoute,
            pageBuilder: (context, state) {
              final aggregationEventId = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: AggregationEventDetailScreen(
                  eventId: aggregationEventId,
                ),
              );
            },
          ),
          GoRoute(
            path: Constants.epcisTransactionEventDetailRoute,
            pageBuilder: (context, state) {
              final transactionEventId = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: TransactionEventFormScreen(
                  transactionEventId: transactionEventId,
                ),
              );
            },
          ),
          GoRoute(
            path: Constants.epcisTransactionDocumentsRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.fadeThroughPage(
                  key: state.pageKey,
                  child: const TransactionDocumentScreen(),
                ),
          ),
          GoRoute(
            path: Constants.epcisTransactionDocumentHelpRoute,
            pageBuilder: (context, state) =>
                TraqRouterTransitions.sharedAxisHorizontalPage(
                  key: state.pageKey,
                  child: const TransactionDocumentHelpScreen(),
                ),
          ),
          GoRoute(
            path: Constants.epcisTransformationEventDetailRoute,
            pageBuilder: (context, state) {
              final transformationEventId = state.pathParameters['id'] ?? '';
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: TransformationEventFormScreen(
                  transformationEventId: transformationEventId,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Constants.opShippingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.ship),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ShippingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opShippingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.ship),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const ShippingOperationScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opShippingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.ship),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: ShippingOperationDetailScreen(operationId: operationId),
          );
        },
      ),
      GoRoute(
        path: Constants.opReceivingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.receive),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ReceivingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opReceivingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.receive),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: ReceivingOperationScreen(
            initialPrefill: state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null,
          ),
        ),
      ),
      GoRoute(
        path: Constants.opReceivingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.receive),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: ReceivingOperationDetailScreen(operationId: operationId),
          );
        },
      ),

      GoRoute(
        path: Constants.opReturnShippingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.returnShip),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ReturnShippingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opReturnShippingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.returnShip),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: ReturnShippingOperationScreen(
            pharmaReturnContext: _pharmaReturnContextFromExtra(state.extra),
          ),
        ),
      ),
      GoRoute(
        path: Constants.opReturnShippingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.returnShip),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: ReturnShippingOperationDetailScreen(
              operationId: operationId,
            ),
          );
        },
      ),

      GoRoute(
        path: Constants.opCancelShippingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.cancelShip),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const CancelShippingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opCancelShippingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.cancelShip),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: CancelShippingOperationScreen(
            initialPrefill: state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null,
          ),
        ),
      ),
      GoRoute(
        path: Constants.opCancelShippingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.cancelShip),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: CancelShippingOperationDetailScreen(
              operationId: operationId,
            ),
          );
        },
      ),

      GoRoute(
        path: Constants.opCancelReceivingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.cancelReceive),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const CancelReceivingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opCancelReceivingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.cancelReceive),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const CancelReceivingOperationScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opCancelReceivingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.cancelReceive),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: CancelReceivingOperationDetailScreen(
              operationId: operationId,
            ),
          );
        },
      ),

      GoRoute(
        path: Constants.opReturnReceivingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.returnReceive),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ReturnReceivingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opReturnReceivingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.returnReceive),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: ReturnReceivingOperationScreen(
            pharmaReturnContext: _pharmaReturnContextFromExtra(state.extra),
          ),
        ),
      ),
      GoRoute(
        path: Constants.opReturnReceivingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.returnReceive),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: ReturnReceivingOperationDetailScreen(
              operationId: operationId,
            ),
          );
        },
      ),

      GoRoute(
        path: Constants.opPackingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.pack),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const PackingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opPackingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.pack),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: PackingOperationScreen(),
        ),
      ),
      GoRoute(
        path: Constants.hierarchyRoute,
        pageBuilder: (context, state) {
          final rootEpc = state.uri.queryParameters['rootEpc'] ?? '';
          final title =
              state.uri.queryParameters['title'] ?? 'Container Hierarchy';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: HierarchyScreen(rootEpc: rootEpc, title: title),
          );
        },
      ),
      GoRoute(
        path: Constants.opPackingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.pack),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: PackingOperationDetailScreen(operationId: operationId),
          );
        },
      ),

      GoRoute(
        path: Constants.opUnpackingRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.unpack),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const UnpackingScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opUnpackingCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.unpack),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const UnpackingOperationScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opUnpackingDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.unpack),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: UnpackingOperationDetailScreen(operationId: operationId),
          );
        },
      ),

      GoRoute(
        path: Constants.opUpdateStatusRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.updateStatus),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const UpdateStatusScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opUpdateStatusCreateRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.updateStatus),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const UpdateStatusOperationScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opUpdateStatusDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.updateStatus),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: UpdateStatusOperationDetailScreen(operationId: operationId),
          );
        },
      ),

      GoRoute(
        path: Constants.opCommissioningRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.commission),
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const CommissioningScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opCommissioningNewRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.commission),
        pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
          key: state.pageKey,
          child: const CommissioningOperationScreen(),
        ),
      ),
      GoRoute(
        path: Constants.opCommissioningDetailRoute,
        redirect: (context, state) =>
            _requireOperationStep(OperationSteps.commission),
        pageBuilder: (context, state) {
          final operationId = state.pathParameters['operationId'] ?? '';
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: CommissioningOperationDetailScreen(batchId: operationId),
          );
        },
      ),

      GoRoute(
        path: Constants.notificationsRoute,
        redirect: (context, state) => AutomationCenterSections.location(
          AutomationCenterSections.notificationActivity,
        ),
      ),
      GoRoute(
        path: Constants.notificationSubscriptionsRoute,
        redirect: (context, state) => AutomationCenterSections.location(
          AutomationCenterSections.alertSubscriptions,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => NotificationsShell(child: child),
        routes: [
          GoRoute(
            path: Constants.notificationDetailRoute,
            pageBuilder: (context, state) {
              final subscriptionId = state.pathParameters['subscriptionId']!;
              return TraqRouterTransitions.sharedAxisHorizontalPage(
                key: state.pageKey,
                child: SubscriptionDetailsScreen(
                  subscriptionId: subscriptionId,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Constants.barcodeScanRoute,
        redirect: (context, state) => '${Constants.gs1ToolsRoute}?tool=barcode',
      ),
      GoRoute(
        path: Constants.barcodeGenerateRoute,
        redirect: (context, state) => '${Constants.gs1ToolsRoute}?tool=barcode',
      ),
      GoRoute(
        path: Constants.epcisSerializationRoute,
        redirect: (context, state) =>
            '${Constants.gs1ToolsRoute}?tool=serialize-convert',
      ),
      GoRoute(
        path: Constants.barcodeVerifyRoute,
        redirect: (context, state) =>
            '${Constants.gs1ToolsRoute}?tool=barcode&mode=verify',
      ),
      TransactionEventValidationDemoRoute.getRoute(),
    ],
    errorPageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: RouterNotFoundScreen(uri: state.uri.toString()),
    ),
  );
}
