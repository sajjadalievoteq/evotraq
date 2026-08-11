part of 'app_router.dart';

List<RouteBase> _appRoutes2(AppRouter appRouter) => [
  GoRoute(
    path: Constants.adminBackgroundJobsRoute,
    redirect: (context, state) {
      if (!appRouter.authCubit.state.isAuthenticated) {
        return null;
      }
      if (!appRouter.authCubit.state.isAdmin) {
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
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
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
    redirect: (context, state) => '${Constants.gs1ToolsRoute}?tool=validator',
  ),
];
