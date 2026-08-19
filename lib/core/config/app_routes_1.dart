part of 'app_router.dart';

List<RouteBase> _appRoutes1(AppRouter appRouter) => [
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
        pageBuilder: (context, state) => TraqRouterTransitions.authShellPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Constants.registerRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.authShellPage(
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
        pageBuilder: (context, state) => TraqRouterTransitions.authShellPage(
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
        return Constants.homeRoute;
      }

      return null;
    },
  ),
  GoRoute(
    path: Constants.adminGs1ValidationRoute,
    redirect: (context, state) {
      if (!appRouter.authCubit.state.isAuthenticated) {
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) {
        // Top-level redirect owns login?from= while auth settles.
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
      if (!appRouter.authCubit.state.isAuthenticated) return null;
      final tab = AutomationCenterSections.normalizeTab(
        state.uri.queryParameters['section'],
        isAdmin: appRouter.authCubit.state.isAdmin,
      );
      final requested = state.uri.queryParameters['section'];
      // Non-admins deep-linked to Job Operations land on Subscriptions.
      if (requested != null &&
          AutomationCenterSections.adminOnlyTabs.contains(
            AutomationCenterSections.normalizeTab(requested),
          ) &&
          !appRouter.authCubit.state.isAdmin) {
        return AutomationCenterSections.location(
          AutomationCenterSections.alertSubscriptions,
        );
      }
      // Normalize unknown / legacy aliases onto a canonical tab query.
      if (requested != tab &&
          requested != AutomationCenterSections.notifications) {
        return AutomationCenterSections.location(tab);
      }
      return null;
    },
  ),
  GoRoute(
    path: Constants.tatmeenIntegrationRoute,
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const TatmeenIntegrationScreen(),
    ),
    redirect: (context, state) {
      if (!appRouter.authCubit.state.isAuthenticated) return null;
      if (!appRouter.authCubit.state.canAccessTatmeenIntegration) {
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
      if (!appRouter.authCubit.state.isAuthenticated) return null;
      if (!appRouter.authCubit.state.canAccessTatmeenIntegration) {
        return Constants.homeRoute;
      }
      return null;
    },
  ),
];
