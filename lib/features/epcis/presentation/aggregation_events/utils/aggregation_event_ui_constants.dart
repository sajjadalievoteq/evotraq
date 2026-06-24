class AggregationEventUiConstants {
  AggregationEventUiConstants._();

  static const String appBarManagement = 'Aggregation Events';
  static const String splitCreateHeader = 'New Aggregation Event';
  static const String tooltipClose = 'Close';

  static const String entityPluralEvents = 'events';
  static const List<int> pageSizeOptions = [10, 20, 50, 100];

  static const String searchHint = 'Search by parent EPC, event ID…';
  static const String dialogQuickFiltersTitle = 'Quick Filters';
  static const String dialogAdvancedFiltersTitle = 'Advanced Filters';
  static const String emptyListTitle = 'No aggregation events found';
  static const String emptyNoMatchSearch =
      'No events match the current search or filters';
  static const String tooltipRefresh = 'Refresh';
  static const String tooltipQuickFilters = 'Quick filters';
  static const String tooltipAdvancedFilters = 'Advanced filters';

  static const String sortLabelEventTime = 'Sort by event time';

  static const String listCardParentPrefix = 'Parent: ';
  static const String listCardItemCountPrefix = 'Items: ';
  static const String listCardLocationPrefix = 'Location: ';
  static const String listCardBizStepPrefix = 'Biz step: ';
  static const String listCardDispositionPrefix = 'Disposition: ';

  static const String sectionIdentification = 'Event Identification';
  static const String sectionHierarchy = 'Aggregation Hierarchy';
  static const String sectionLocation = 'Location & Timing';
  static const String sectionBizStep = 'Business Context';
  static const String sectionExtensions = 'Extensions / ILMD';

  static const String menuViewDetails = 'View details';
  static const String menuTooltipActions = 'Actions';

  static const String actionAdd = 'ADD';
  static const String actionObserve = 'OBSERVE';
  static const String actionDelete = 'DELETE';

  static const String fabHeroTag = 'aggregation_event_add_fab';
  static const String fabAddTooltip = 'Record Aggregation Event';
  static const String fabCloseTooltip = 'Cancel';

  static const String _cbvHttpsPrefix =
      'https://ref.gs1.org/cbv/BizStep-';
  static const String _cbvUrnPrefix =
      'urn:epcglobal:cbv:bizstep:';

  static String friendlyBizStep(String? bizStep) {
    if (bizStep == null) return '—';
    var s = bizStep
        .replaceFirst(_cbvHttpsPrefix, '')
        .replaceFirst(_cbvUrnPrefix, '')
        .replaceAll('_', ' ');
    if (s.isEmpty) return bizStep;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String friendlyDisposition(String? disposition) {
    if (disposition == null) return '—';
    final s = disposition
        .split('/')
        .last
        .split(':')
        .last
        .replaceAll('_', ' ');
    if (s.isEmpty) return disposition;
    return s[0].toUpperCase() + s.substring(1);
  }
}
