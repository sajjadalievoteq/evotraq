import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/cbv_vocabulary_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/cache_management_screen.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/data_consistency_integrity_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/database_partitioning_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_generation_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/industry_test_data/industry_test_data_screen.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard/monitoring_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/performance_optimization_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/performance_test_screen.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/system_settings_screen.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/approvals_screen.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/user_management_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';

List<RouteBase> adminRoutes(RouteAccess access) => [
  GoRoute(
    path: Constants.adminUsersRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const UserManagementScreen(),
    ),
    redirect: (context, state) {
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
        return Constants.homeRoute;
      }

      return null;
    },
  ),
  GoRoute(
    path: Constants.adminGs1ValidationRoute,
    redirect: (context, state) {
      if (!access.authState.isAuthenticated) {
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
        return Constants.homeRoute;
      }

      return null;
    },
  ),
  GoRoute(
    path: Constants.adminBackgroundJobsRoute,
    redirect: (context, state) {
      if (!access.authState.isAuthenticated) {
        return null;
      }
      if (!access.authState.isAdmin) {
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
      if (!access.authState.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!access.authState.isAdmin) {
        return Constants.homeRoute;
      }

      return null;
    },
  ),
];
