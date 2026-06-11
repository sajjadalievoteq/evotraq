/// UI constants for the object events list screen.
class ObjectEventListUiConstants {
  ObjectEventListUiConstants._();

  static const String entityPluralEvents = 'events';
  static const List<int> pageSizeOptions = [10, 20, 50, 100];

  static const String searchHint = 'Search by EPC, event ID…';
  static const String dialogQuickFiltersTitle = 'Quick Filters';
  static const String dialogAdvancedFiltersTitle = 'Advanced Filters';
  static const String emptyListTitle = 'No object events found';
  static const String emptyNoMatchSearch =
      'No events match the current search or filters';
  static const String tooltipRefresh = 'Refresh';
  static const String tooltipQuickFilters = 'Quick filters';
  static const String tooltipAdvancedFilters = 'Advanced filters';

  static const String sortLabelEventTime = 'Sort by event time';

  static const String listCardEpcPrefix = 'EPC: ';
  static const String listCardLocationPrefix = 'Location: ';
  static const String listCardBizStepPrefix = 'Biz step: ';

  static const String menuViewDetails = 'View details';
  static const String menuTooltipActions = 'Actions';
}
