import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';

enum AggregationEventsStatus { initial, loading, success, error }

class AggregationEventsState extends Equatable {
  final AggregationEventsStatus status;
  final List<AggregationEvent> aggregationEvents;
  final AggregationEvent? selectedEvent;

  final bool isListLoading;
  final bool isFetchingMore;
  final bool hasMoreData;
  final int page;
  final int pageSize;

  final String? error;
  final String? listFetchError;

  final String? filterAction;
  final String? filterBizStep;
  final String? filterDisposition;
  final String? filterLocationGLN;
  final String? filterParentEPC;
  final String? filterChildEPC;
  final String? filterSearchText;

  final String sortOrder;

  const AggregationEventsState({
    this.status = AggregationEventsStatus.initial,
    this.aggregationEvents = const [],
    this.selectedEvent,
    this.isListLoading = false,
    this.isFetchingMore = false,
    this.hasMoreData = false,
    this.page = 0,
    this.pageSize = 20,
    this.error,
    this.listFetchError,
    this.filterAction,
    this.filterBizStep,
    this.filterDisposition,
    this.filterLocationGLN,
    this.filterParentEPC,
    this.filterChildEPC,
    this.filterSearchText,
    this.sortOrder = 'DESC',
  });

  AggregationEventsState copyWith({
    AggregationEventsStatus? status,
    List<AggregationEvent>? aggregationEvents,
    AggregationEvent? selectedEvent,
    bool? isListLoading,
    bool? isFetchingMore,
    bool? hasMoreData,
    int? page,
    int? pageSize,
    String? error,
    String? listFetchError,
    String? filterAction,
    String? filterBizStep,
    String? filterDisposition,
    String? filterLocationGLN,
    String? filterParentEPC,
    String? filterChildEPC,
    String? filterSearchText,
    String? sortOrder,
    bool clearSelectedEvent = false,
    bool clearError = false,
    bool clearListFetchError = false,
    bool clearFilters = false,
  }) {
    return AggregationEventsState(
      status: status ?? this.status,
      aggregationEvents: aggregationEvents ?? this.aggregationEvents,
      selectedEvent: clearSelectedEvent
          ? null
          : (selectedEvent ?? this.selectedEvent),
      isListLoading: isListLoading ?? this.isListLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: clearError ? null : (error ?? this.error),
      listFetchError: clearListFetchError
          ? null
          : (listFetchError ?? this.listFetchError),
      filterAction: clearFilters ? null : (filterAction ?? this.filterAction),
      filterBizStep: clearFilters
          ? null
          : (filterBizStep ?? this.filterBizStep),
      filterDisposition: clearFilters
          ? null
          : (filterDisposition ?? this.filterDisposition),
      filterLocationGLN: clearFilters
          ? null
          : (filterLocationGLN ?? this.filterLocationGLN),
      filterParentEPC: clearFilters
          ? null
          : (filterParentEPC ?? this.filterParentEPC),
      filterChildEPC: clearFilters
          ? null
          : (filterChildEPC ?? this.filterChildEPC),
      filterSearchText: clearFilters
          ? null
          : (filterSearchText ?? this.filterSearchText),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get hasActiveFilters =>
      filterAction != null ||
      filterBizStep != null ||
      filterDisposition != null ||
      filterLocationGLN != null ||
      filterParentEPC != null ||
      filterChildEPC != null ||
      (filterSearchText != null && filterSearchText!.isNotEmpty);

  @override
  List<Object?> get props => [
    status,
    aggregationEvents,
    selectedEvent,
    isListLoading,
    isFetchingMore,
    hasMoreData,
    page,
    pageSize,
    error,
    listFetchError,
    filterAction,
    filterBizStep,
    filterDisposition,
    filterLocationGLN,
    filterParentEPC,
    filterChildEPC,
    filterSearchText,
    sortOrder,
  ];
}
