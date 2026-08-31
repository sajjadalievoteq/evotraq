import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/utils/app_time.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/object_events/utils/object_event_shared_ui_constants.dart';

class ObjectEventDetailFormatters {
  ObjectEventDetailFormatters._();

  static const dateFormat = 'MMM dd, yyyy HH:mm:ss';

  static String formatDate(DateTime? dt) => dt == null
      ? ObjectEventSharedUiConstants.emDash
      : AppTime.formatUae(dt, DateFormat(dateFormat));

  static String epcisVersionLabel(EPCISVersion? version) {
    switch (version) {
      case EPCISVersion.v1_3:
        return '1.3';
      case EPCISVersion.v2_0:
      case null:
        return '2.0';
    }
  }
}
