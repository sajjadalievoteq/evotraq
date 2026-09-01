import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/commissioning_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_commissioning_prefill.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_commissioning_prefill.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning/commissioning_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/packing_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/packing_operation_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing/packing_screen.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/unpacking_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/unpacking_operation_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking/unpacking_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/update_status_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/update_status_operation_screen.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status/update_status_screen.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/hierarchy_screen.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_route.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_route.dart';

List<RouteBase> handlingOperationRoutes(RouteAccess access) => [
  GoRoute(
    path: Constants.opPackingRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.pack),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const PackingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opPackingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.pack),
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
    redirect: (context, state) {
      final operationId = state.pathParameters['operationId'] ?? '';
      return MasterDetailRoute.redirectDetailRouteIfDesktop(
        context,
        authRedirect: access.requireOperationStep(OperationSteps.pack),
        listRoute: Constants.opPackingRoute,
        selectedId: operationId,
      );
    },
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
        access.requireOperationStep(OperationSteps.unpack),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const UnpackingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opUnpackingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.unpack),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const UnpackingOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opUnpackingDetailRoute,
    redirect: (context, state) {
      final operationId = state.pathParameters['operationId'] ?? '';
      return MasterDetailRoute.redirectDetailRouteIfDesktop(
        context,
        authRedirect: access.requireOperationStep(OperationSteps.unpack),
        listRoute: Constants.opUnpackingRoute,
        selectedId: operationId,
      );
    },
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
        access.requireOperationStep(OperationSteps.updateStatus),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const UpdateStatusScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opUpdateStatusCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.updateStatus),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const UpdateStatusOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opUpdateStatusDetailRoute,
    redirect: (context, state) {
      final operationId = state.pathParameters['operationId'] ?? '';
      return MasterDetailRoute.redirectDetailRouteIfDesktop(
        context,
        authRedirect: access.requireOperationStep(OperationSteps.updateStatus),
        listRoute: Constants.opUpdateStatusRoute,
        selectedId: operationId,
      );
    },
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
        access.requireOperationStep(OperationSteps.commission),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const CommissioningScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCommissioningNewRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.commission),
    pageBuilder: (context, state) {
      final typeParam =
          state.uri.queryParameters['identifierType']?.toLowerCase();
      final initialType = switch (typeParam) {
        'sscc' => EPCType.sscc,
        'sgtin' => EPCType.sgtin,
        _ => null,
      };
      final prefill = SsccCommissioningPrefill.fromQueryParameters(
        state.uri.queryParameters,
      );
      final initialEpc = state.uri.queryParameters['epc'] ?? prefill?.ssccCode;

      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: CommissioningOperationScreen(
          initialIdentifierType: initialType,
          initialEpc: initialEpc,
          ssccPrefill: prefill,
        ),
      );
    },
  ),
  GoRoute(
    path: Constants.opCommissioningDetailRoute,
    redirect: (context, state) {
      final operationId = state.pathParameters['operationId'] ?? '';
      return MasterDetailRoute.redirectDetailRouteIfDesktop(
        context,
        authRedirect: access.requireOperationStep(OperationSteps.commission),
        listRoute: Constants.opCommissioningRoute,
        selectedId: operationId,
      );
    },
    pageBuilder: (context, state) {
      final operationId = state.pathParameters['operationId'] ?? '';
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: CommissioningOperationDetailScreen(batchId: operationId),
      );
    },
  ),
];
