import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';

abstract final class AggregationEventDetailFormatters {
  static const dateFormat = 'MMM dd, yyyy HH:mm:ss';

  static String formatDateTime(DateTime? dt) =>
      dt == null ? '—' : DateFormat(dateFormat).format(dt.toLocal());

  static String epcisVersionLabel(EPCISVersion? version) {
    switch (version) {
      case EPCISVersion.v1_3:
        return '1.3';
      case EPCISVersion.v2_0:
        return '2.0';
      case null:
        return '2.0';
    }
  }
}
