import 'package:traqtrace_app/core/consts/app_consts.dart';

abstract final class HomeNavigation {
  static const String home = Constants.homeRoute;

  static const String notifications = Constants.notificationsRoute;
  static const String epcisEvents = Constants.epcisEventsRoute;
  static const String epcisObjectEventNew = Constants.epcisObjectEventNewRoute;

  static const String gs1Gtins = Constants.gs1GtinsRoute;
  static const String gs1Glns = Constants.gs1GlnsRoute;
  static const String gs1Sgtins = Constants.gs1SgtinsRoute;
  static const String gs1Ssccs = Constants.gs1SsccsRoute;

  static const String epcisObjectEvents = Constants.epcisObjectEventsRoute;
  static const String epcisAggregationEvents =
      Constants.epcisAggregationEventsRoute;
  static const String epcisTransactionEvents =
      Constants.epcisTransactionEventsRoute;
  static const String epcisTransformationEvents =
      Constants.epcisTransformationEventsRoute;

  static const String opShippingCreate = Constants.opShippingCreateRoute;
  static const String opReceiving = Constants.opReceivingRoute;
  static const String opReceivingCreate = Constants.opReceivingCreateRoute;
  static const String opReturnShipping = Constants.opReturnShippingRoute;
  static const String opReturnShippingCreate =
      Constants.opReturnShippingCreateRoute;
  static const String opReturnReceiving = Constants.opReturnReceivingRoute;
  static const String opReturnReceivingCreate =
      Constants.opReturnReceivingCreateRoute;
  static const String opPacking = Constants.opPackingRoute;
  static const String opPackingCreate = Constants.opPackingCreateRoute;
  static const String opUnpacking = Constants.opUnpackingRoute;
  static const String opUnpackingCreate = Constants.opUnpackingCreateRoute;
  static const String opCommissioning = Constants.opCommissioningRoute;
  static const String opCommissioningNew = Constants.opCommissioningNewRoute;
  static const String opUpdateStatus = Constants.opUpdateStatusRoute;
  static const String opUpdateStatusCreate =
      Constants.opUpdateStatusCreateRoute;
  static const String opCancelShippingCreate =
      Constants.opCancelShippingCreateRoute;
  static const String opCancelReceivingCreate =
      Constants.opCancelReceivingCreateRoute;
}
