part of 'app_router.dart';

List<RouteBase> _appRoutes3(AppRouter appRouter) => [
  ShellRoute(
    builder: (context, state, child) => EpcisShell(child: child),
    routes: [
      GoRoute(
        path: Constants.epcisObjectEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const ObjectEventScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisAggregationEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const AggregationEventScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisTransactionEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
          key: state.pageKey,
          child: const TransactionEventsListScreen(),
        ),
      ),
      GoRoute(
        path: Constants.epcisTransformationEventsRoute,
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
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
          if (!appRouter.authCubit.state.isAuthenticated) {
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
            child: AggregationEventDetailScreen(eventId: aggregationEventId),
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
        pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
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
        appRouter._requireOperationStep(OperationSteps.ship),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ShippingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opShippingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.ship),
    pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
      key: state.pageKey,
      child: const ShippingOperationScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opShippingDetailRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.ship),
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
        appRouter._requireOperationStep(OperationSteps.receive),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ReceivingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opReceivingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.receive),
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
        appRouter._requireOperationStep(OperationSteps.receive),
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
        appRouter._requireOperationStep(OperationSteps.returnShip),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ReturnShippingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opReturnShippingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.returnShip),
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
        appRouter._requireOperationStep(OperationSteps.returnShip),
    pageBuilder: (context, state) {
      final operationId = state.pathParameters['operationId']!;
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: ReturnShippingOperationDetailScreen(operationId: operationId),
      );
    },
  ),

  GoRoute(
    path: Constants.opCancelShippingRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.cancelShip),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const CancelShippingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCancelShippingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.cancelShip),
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
        appRouter._requireOperationStep(OperationSteps.cancelShip),
    pageBuilder: (context, state) {
      final operationId = state.pathParameters['operationId']!;
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: CancelShippingOperationDetailScreen(operationId: operationId),
      );
    },
  ),

  GoRoute(
    path: Constants.opCancelReceivingRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.cancelReceive),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const CancelReceivingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCancelReceivingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.cancelReceive),
    pageBuilder: (context, state) => TraqRouterTransitions.modalPage(
      key: state.pageKey,
      child: const CancelReceivingOperationScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCancelReceivingDetailRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.cancelReceive),
    pageBuilder: (context, state) {
      final operationId = state.pathParameters['operationId']!;
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: CancelReceivingOperationDetailScreen(operationId: operationId),
      );
    },
  ),

  GoRoute(
    path: Constants.opReturnReceivingRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.returnReceive),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ReturnReceivingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opReturnReceivingCreateRoute,
    redirect: (context, state) =>
        appRouter._requireOperationStep(OperationSteps.returnReceive),
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
        appRouter._requireOperationStep(OperationSteps.returnReceive),
    pageBuilder: (context, state) {
      final operationId = state.pathParameters['operationId']!;
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: ReturnReceivingOperationDetailScreen(operationId: operationId),
      );
    },
  ),
];
