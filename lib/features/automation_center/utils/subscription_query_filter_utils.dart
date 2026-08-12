import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';

/// Reads the event-filter fields out of a subscription's raw
/// `queryParameters` map (as sent by [CreateSubscriptionDialog]'s advanced
/// section: `eventTypes`, `operationTypes`, `readPoints`, `epcs`) and renders
/// each as a human-readable value, so the details page can show the actual
/// configured filters instead of a raw key:value dump.
///
/// `businessSteps`/`dispositions` are read too, but only for **display** of
/// subscriptions created before the Operations selector replaced the raw CBV
/// business-step/disposition dropdowns — the create/edit dialog no longer
/// writes these keys, but older subscriptions may still have them stored.
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

  static List<String> operationTypeLabels(
    Map<String, dynamic>? queryParameters,
  ) {
    final raw = _stringList(queryParameters, 'operationTypes');
    return raw.map((value) {
      for (final option in NotificationConstants.operationTypes) {
        if (option['value'] == value) return option['label'] ?? value;
      }
      return value;
    }).toList();
  }

  /// Legacy display-only: business step, if this subscription predates the
  /// Operations selector.
  static String? businessStep(Map<String, dynamic>? queryParameters) =>
      _firstShortName(queryParameters, 'businessSteps');

  /// Legacy display-only: disposition, if this subscription predates the
  /// Operations selector.
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
        operationTypeLabels(queryParameters).isNotEmpty ||
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
