import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';

abstract final class JourneyTimelineHeaderUtils {
  static String? dateRange(ProductJourney journey) {
    final first = journey.firstEventTime;
    final last = journey.lastEventTime;
    if (first == null || last == null) return null;
    final fmt = DateFormat('MMM d');
    return '${fmt.format(first)} → ${fmt.format(last)}';
  }

  static String durationLabel(ProductJourney journey) {
    final d = journey.journeyDuration;
    if (d == null) return '—';
    if (d.inDays > 0) return '${d.inDays} Days';
    return JourneyFormatters.duration(d);
  }
}
