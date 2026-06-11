import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_form_validators.dart';

/// List/search helpers for aggregation events.
class AggregationEventListUtils {
  AggregationEventListUtils._();

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static String toBizStepUrn(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('urn:epcglobal:cbv:bizstep:')) return trimmed;
    if (trimmed.startsWith('urn:')) return trimmed;
    final name = trimmed.contains(':') ? trimmed.split(':').last : trimmed;
    return 'urn:epcglobal:cbv:bizstep:$name';
  }

  static String toDispositionUrn(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('urn:epcglobal:cbv:disp:')) return trimmed;
    if (trimmed.startsWith('urn:')) return trimmed;
    final name = trimmed.contains(':') ? trimmed.split(':').last : trimmed;
    return 'urn:epcglobal:cbv:disp:$name';
  }

  static bool looksLikeEpc(String value) =>
      AggregationEventFormValidators.isLikelyEpc(value);

  static bool looksLikeEventId(String value) {
    final trimmed = value.trim();
    return _uuid.hasMatch(trimmed) ||
        trimmed.startsWith('urn:uuid:') ||
        trimmed.startsWith('event') ||
        trimmed.startsWith('pack-') ||
        trimmed.startsWith('unpack-');
  }

  static String? epcFromSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) return null;
    final trimmed = query.trim();
    return looksLikeEpc(trimmed) ? trimmed : null;
  }

  static List<AggregationEvent> applySearchFilter(
    List<AggregationEvent> events,
    String? query,
  ) {
    if (query == null || query.trim().isEmpty) return events;
    final lower = query.trim().toLowerCase();
    return events.where((event) {
      if (event.eventId.toLowerCase().contains(lower)) return true;
      final id = event.id;
      if (id != null && id.toLowerCase().contains(lower)) return true;
      if (event.parentID.toLowerCase().contains(lower)) return true;
      return event.childEPCs.any((c) => c.toLowerCase().contains(lower));
    }).toList();
  }

  static List<AggregationEvent> filterByDisposition(
    List<AggregationEvent> events,
    String? dispositionUrn,
  ) {
    if (dispositionUrn == null || dispositionUrn.isEmpty) return events;
    return events
        .where((event) => event.disposition == dispositionUrn)
        .toList();
  }

  static List<AggregationEvent> filterByBizStep(
    List<AggregationEvent> events,
    String? bizStepUrn,
  ) {
    if (bizStepUrn == null || bizStepUrn.isEmpty) return events;
    return events.where((event) => event.businessStep == bizStepUrn).toList();
  }

  static List<AggregationEvent> sortByEventTime(
    List<AggregationEvent> events,
    String sortOrder,
  ) {
    final sorted = List<AggregationEvent>.from(events);
    sorted.sort((a, b) {
      final cmp = a.eventTime.compareTo(b.eventTime);
      return sortOrder == 'ASC' ? cmp : -cmp;
    });
    return sorted;
  }
}
