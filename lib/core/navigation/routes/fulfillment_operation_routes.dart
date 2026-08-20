import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/traq_router_transitions.dart';
import 'package:traqtrace_app/core/navigation/routes/route_extra_parser.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/cancel_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/cancel_receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving/cancel_receiving_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/cancel_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/cancel_shipping_operation_screen.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping/cancel_shipping_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving/receiving_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/return_receiving_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation/return_receiving_operation_screen.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving/return_receiving_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/return_shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/return_shipping_operation_screen.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping/return_shipping_screen.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/shipping_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/shipping_operation_screen.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping/shipping_screen.dart';
import 'package:traqtrace_app/core/navigation/routes/route_access.dart';

List<RouteBase> fulfillmentOperationRoutes(RouteAccess access) => [
  GoRoute(
    path: Constants.opShippingRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.ship),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ShippingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opShippingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.ship),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const ShippingOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opShippingDetailRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.ship),
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
        access.requireOperationStep(OperationSteps.receive),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ReceivingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opReceivingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.receive),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
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
        access.requireOperationStep(OperationSteps.receive),
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
        access.requireOperationStep(OperationSteps.returnShip),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ReturnShippingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opReturnShippingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.returnShip),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: ReturnShippingOperationScreen(
            pharmaReturnContext: pharmaReturnContextFromExtra(state.extra),
          ),
        ),
  ),
  GoRoute(
    path: Constants.opReturnShippingDetailRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.returnShip),
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
        access.requireOperationStep(OperationSteps.cancelShip),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const CancelShippingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCancelShippingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.cancelShip),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
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
        access.requireOperationStep(OperationSteps.cancelShip),
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
        access.requireOperationStep(OperationSteps.cancelReceive),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const CancelReceivingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opCancelReceivingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.cancelReceive),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: const CancelReceivingOperationScreen(),
        ),
  ),
  GoRoute(
    path: Constants.opCancelReceivingDetailRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.cancelReceive),
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
        access.requireOperationStep(OperationSteps.returnReceive),
    pageBuilder: (context, state) => TraqRouterTransitions.fadeThroughPage(
      key: state.pageKey,
      child: const ReturnReceivingScreen(),
    ),
  ),
  GoRoute(
    path: Constants.opReturnReceivingCreateRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.returnReceive),
    pageBuilder: (context, state) =>
        TraqRouterTransitions.sharedAxisHorizontalPage(
          key: state.pageKey,
          child: ReturnReceivingOperationScreen(
            pharmaReturnContext: pharmaReturnContextFromExtra(state.extra),
          ),
        ),
  ),
  GoRoute(
    path: Constants.opReturnReceivingDetailRoute,
    redirect: (context, state) =>
        access.requireOperationStep(OperationSteps.returnReceive),
    pageBuilder: (context, state) {
      final operationId = state.pathParameters['operationId']!;
      return TraqRouterTransitions.sharedAxisHorizontalPage(
        key: state.pageKey,
        child: ReturnReceivingOperationDetailScreen(operationId: operationId),
      );
    },
  ),
];
