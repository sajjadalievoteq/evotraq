import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';

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
  static const String emptyListTitle = 'No aggregation events yet';
  static const String emptyListSubtitle =
      'Record an aggregation event to get started.';
  static const String emptyAddAction = 'Record Aggregation Event';
  static const String emptyNoMatchSearch =
      'No events match the current search or filters';
  static const String awaitingSelectionTitle = 'Select an aggregation event';
  static const String awaitingSelectionSubtitle =
      'Choose one from the list to view its details.';
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

  static String friendlyBizStep(String? bizStep) {
    return CbvDisplayUtils.displayBizStep(bizStep, fallback: '—');
  }

  static String friendlyDisposition(String? disposition) {
    return CbvDisplayUtils.displayDisposition(disposition, fallback: '—');
  }
}
