part of 'app_router.dart';

List<RouteBase> _appRoutes4(AppRouter appRouter) => [
  GoRoute(
    path: Constants.opPackingRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.pack),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const PackingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opPackingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.pack),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: PackingOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.hierarchyRoute,
    pageBuilder: (context, state) {
      final rootEpc = state.uri.queryParameters['rootEpc'] ?? '';
      final title = state.uri.queryParameters['title'] ?? 'Container Hierarchy';
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: HierarchyScreen(rootEpc: rootEpc, title: title),
      );
    },
  ),
  GoRoute(
    path: Constants.opPackingDetailRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.pack),
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
        appRouter._requireOperationStep(OperationSteps.unpack),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const UnpackingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opUnpackingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.unpack),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const UnpackingOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opUnpackingDetailRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.unpack),
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
        appRouter._requireOperationStep(OperationSteps.updateStatus),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const UpdateStatusScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opUpdateStatusCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.updateStatus),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const UpdateStatusOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opUpdateStatusDetailRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.updateStatus),
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
        appRouter._requireOperationStep(OperationSteps.commission),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const CommissioningScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCommissioningNewRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.commission),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const CommissioningOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opCommissioningDetailRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.commission),
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
    pageBuilder: (context, state, child) =>
        TraqRouterTransitions.featureShellPage(
          key: state.pageKey,
          child: NotificationsShell(child: child),
        ),
    routes: [
      GoRoute(
        path: Constants.notificationDetailRoute,
        pageBuilder: (context, state) {
          final subscriptionId = state.pathParameters['subscriptionId']!;
          return TraqRouterTransitions.sharedAxisHorizontalPage(
            key: state.pageKey,
            child: SubscriptionDetailsScreen(subscriptionId: subscriptionId),
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
];
