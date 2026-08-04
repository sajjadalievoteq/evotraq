import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';

class ObjectEventSharedUiConstants {
  ObjectEventSharedUiConstants._();

  static const String appBarManagement = 'Object Events';
  static const String splitCreateHeader = 'New Object Event';
  static const String tooltipClose = 'Close';

  static const String actionAdd = 'ADD';
  static const String actionObserve = 'OBSERVE';
  static const String actionDelete = 'DELETE';

  static const String fabHeroTag = 'object_event_add_fab';
  static const String fabAddTooltip = 'Record Object Event';
  static const String fabCloseTooltip = 'Cancel';

  static const String emDash = '—';

  static String friendlyBizStep(String? bizStep) {
    return CbvDisplayUtils.displayBizStep(bizStep, fallback: emDash);
  }

  static String friendlyDisposition(String? disposition) {
    return CbvDisplayUtils.displayDisposition(disposition, fallback: emDash);
  }
}
