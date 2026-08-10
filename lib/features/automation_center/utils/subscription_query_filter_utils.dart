import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';

/// Reads the event-filter fields out of a subscription's raw
/// `queryParameters` map (as sent by [CreateSubscriptionDialog]'s advanced
/// section: `eventTypes`, `businessSteps`, `dispositions`, `readPoints`,
/// `epcs`) and renders each as a human-readable value, so the details page
/// can show the actual configured filters instead of a raw key:value dump.
abstract final class SubscriptionQueryFilterUtils {
  static List<String> eventTypeLabels(Map<String, dynamic>? queryParameters) {
    final raw = _stringList(queryParameters, 'eventTypes');
    return raw.map((value) {
      for (final option in NotificationConstants.eventTypes) {
        if (option['value'] == value) return option['label'] ?? value;
      }
      return value;
    }).toList();
  }

  static String? businessStep(Map<String, dynamic>? queryParameters) =>
      _firstShortName(queryParameters, 'businessSteps');

  static String? disposition(Map<String, dynamic>? queryParameters) =>
      _firstShortName(queryParameters, 'dispositions');

  static String? readPoint(Map<String, dynamic>? queryParameters) =>
      _first(queryParameters, 'readPoints');

  static String? epcPattern(Map<String, dynamic>? queryParameters) =>
      _first(queryParameters, 'epcs');

  /// True if at least one advanced filter is configured. When false, the
  /// subscription matches every EPCIS event of the delivery method's scope.
  static bool hasAnyFilter(Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return false;
    return eventTypeLabels(queryParameters).isNotEmpty ||
        businessStep(queryParameters) != null ||
        disposition(queryParameters) != null ||
        readPoint(queryParameters) != null ||
        epcPattern(queryParameters) != null;
  }

  static List<String> _stringList(Map<String, dynamic>? params, String key) {
    final value = params?[key];
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String? _first(Map<String, dynamic>? params, String key) {
    final list = _stringList(params, key);
    return list.isEmpty ? null : list.first;
  }

  static String? _firstShortName(Map<String, dynamic>? params, String key) {
    final value = _first(params, key);
    if (value == null) return null;
    return CbvVocabularyFormatter.shortName(value);
  }
}
