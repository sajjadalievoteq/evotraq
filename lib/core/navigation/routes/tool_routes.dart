import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/epcis/routes/transaction_event_validation_demo_route.dart';

List<RouteBase> toolRoutes() => [
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
