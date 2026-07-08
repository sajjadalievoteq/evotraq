import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/epcis/aggregation_event_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_list_utils.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';


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
      selectedEvent:
          clearSelectedEvent ? null : (selectedEvent ?? this.selectedEvent),
      isListLoading: isListLoading ?? this.isListLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: clearError ? null : (error ?? this.error),
      listFetchError: clearListFetchError
          ? null
          : (listFetchError ?? this.listFetchError),
      filterAction:
          clearFilters ? null : (filterAction ?? this.filterAction),
      filterBizStep:
          clearFilters ? null : (filterBizStep ?? this.filterBizStep),
      filterDisposition:
          clearFilters ? null : (filterDisposition ?? this.filterDisposition),
      filterLocationGLN:
          clearFilters ? null : (filterLocationGLN ?? this.filterLocationGLN),
      filterParentEPC:
          clearFilters ? null : (filterParentEPC ?? this.filterParentEPC),
      filterChildEPC:
          clearFilters ? null : (filterChildEPC ?? this.filterChildEPC),
      filterSearchText:
          clearFilters ? null : (filterSearchText ?? this.filterSearchText),
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

class AggregationEventsCubit extends Cubit<AggregationEventsState> {
  final AggregationEventService _service;
  final GLNService _glnService;

  final Map<String, GLN> _glnCache = {};

  AggregationEventsCubit({
    AggregationEventService? service,
    GLNService? glnService,
  })  : _service = service ?? getIt<AggregationEventService>(),
        _glnService = glnService ?? getIt<GLNService>(),
        super(const AggregationEventsState());


  Future<List<AggregationEvent>> _enrichWithGlns(
    List<AggregationEvent> events,
  ) async {
    final codesToFetch = <String>{};
    for (final e in events) {
      if (e.businessLocation != null &&
          isPlaceholderGlnLocation(e.businessLocation!)) {
        codesToFetch.add(e.businessLocation!.glnCode);
      }
      if (e.readPoint != null && isPlaceholderGlnLocation(e.readPoint!)) {
        codesToFetch.add(e.readPoint!.glnCode);
      }
    }

    codesToFetch.removeWhere(_glnCache.containsKey);

    if (codesToFetch.isNotEmpty) {
      final results = await Future.wait(
        codesToFetch.map((code) async {
          try {
            final gln = await _glnService.getGLNByCode(code);
            return MapEntry(code, gln);
          } catch (_) {
            return null;
          }
        }),
      );
      for (final entry in results.whereType<MapEntry<String, GLN>>()) {
        _glnCache[entry.key] = entry.value;
      }
    }

    return events.map((e) {
      final resolvedBizLoc = (e.businessLocation != null &&
              isPlaceholderGlnLocation(e.businessLocation!))
          ? (_glnCache[e.businessLocation!.glnCode] ?? e.businessLocation)
          : e.businessLocation;

      final resolvedReadPt =
          (e.readPoint != null && isPlaceholderGlnLocation(e.readPoint!))
              ? (_glnCache[e.readPoint!.glnCode] ?? e.readPoint)
              : e.readPoint;

      if (resolvedBizLoc == e.businessLocation &&
          resolvedReadPt == e.readPoint) {
        return e;
      }
      return e.copyWith(
        businessLocation: resolvedBizLoc,
        readPoint: resolvedReadPt,
      );
    }).toList();
  }

  Future<AggregationEvent> _enrichOne(AggregationEvent event) async {
    final enriched = await _enrichWithGlns([event]);
    return enriched.first;
  }


  Future<void> loadAggregationEvents({
    int page = 0,
    int? size,
    String? action,
    String? parentEPC,
    String? childEPC,
    String? businessStep,
    String? disposition,
    String? locationGLN,
    String? searchText,
    DateTime? startTime,
    DateTime? endTime,
    bool isLoadMore = false,
  }) async {
    final effectiveSize = size ?? state.pageSize;

    final effectiveAction = action ?? state.filterAction;
    var effectiveParentEPC = parentEPC ?? state.filterParentEPC;
    var effectiveChildEPC = childEPC ?? state.filterChildEPC;
    final effectiveBizStepRaw = businessStep ?? state.filterBizStep;
    final effectiveDispositionRaw =
        disposition ?? state.filterDisposition;
    final effectiveLocationGLN = locationGLN ?? state.filterLocationGLN;
    final effectiveSearchText = searchText ?? state.filterSearchText;

    final effectiveBizStep = effectiveBizStepRaw != null
        ? AggregationEventListUtils.toBizStepUrn(effectiveBizStepRaw)
        : null;
    final effectiveDisposition = effectiveDispositionRaw != null
        ? AggregationEventListUtils.toDispositionUrn(effectiveDispositionRaw)
        : null;

    final searchEpc =
        AggregationEventListUtils.epcFromSearchQuery(effectiveSearchText);
    if (searchEpc != null) {
      if (effectiveParentEPC == null) {
        effectiveParentEPC = searchEpc;
      } else if (effectiveChildEPC == null &&
          effectiveParentEPC != searchEpc) {
        effectiveChildEPC = searchEpc;
      }
    }

    if (isLoadMore) {
      if (!state.hasMoreData || state.isFetchingMore) return;
      emit(state.copyWith(isFetchingMore: true, clearListFetchError: true));
    } else {
      emit(state.copyWith(
        isListLoading: true,
        isFetchingMore: false,
        aggregationEvents: const [],
        page: 0,
        hasMoreData: false,
        clearListFetchError: true,
      ));
    }

    try {
      List<AggregationEvent> events = [];
      var usedPaginatedEndpoint = false;

      if (effectiveLocationGLN != null &&
          startTime != null &&
          endTime != null) {
        events = await _service.findAggregationEventsByLocationAndTimeWindow(
            effectiveLocationGLN, startTime, endTime);
      } else if (effectiveBizStep != null && effectiveParentEPC != null) {
        events =
            await _service.findAggregationEventsByBusinessStepAndParentEPC(
                effectiveBizStep, effectiveParentEPC);
      } else if (effectiveParentEPC != null && effectiveAction != null) {
        events = await _service.findAggregationEventsByParentEPCAndAction(
            effectiveParentEPC, effectiveAction);
      } else if (effectiveChildEPC != null && effectiveAction != null) {
        events = await _service.findAggregationEventsByChildEPCAndAction(
            effectiveChildEPC, effectiveAction);
      } else if (effectiveParentEPC != null) {
        events = await _service
            .findAggregationEventsByParentEPC(effectiveParentEPC);
      } else if (effectiveChildEPC != null) {
        events =
            await _service.findAggregationEventsByChildEPC(effectiveChildEPC);
      } else if (effectiveDisposition != null) {
        events = await _service.findAggregationEventsByDisposition(
            effectiveDisposition);
      } else if (effectiveBizStep != null) {
        events = await _service.findAggregationEventsByBusinessStep(
            effectiveBizStep);
      } else if (effectiveAction != null) {
        events =
            await _service.findAggregationEventsByAction(effectiveAction);
      } else {
        usedPaginatedEndpoint = true;
        events = await _service.getAllAggregationEvents(
          page,
          effectiveSize,
          direction: state.sortOrder,
        );
      }

      events = AggregationEventListUtils.filterByDisposition(
        events,
        effectiveDisposition,
      );
      events = AggregationEventListUtils.filterByBizStep(
        events,
        effectiveBizStep,
      );
      events = AggregationEventListUtils.applySearchFilter(
        events,
        effectiveSearchText,
      );
      if (!usedPaginatedEndpoint) {
        events = AggregationEventListUtils.sortByEventTime(
          events,
          state.sortOrder,
        );
      }

      events = await _enrichWithGlns(events);

      final nextEvents = isLoadMore
          ? [...state.aggregationEvents, ...events]
          : events;
      final hasMore = usedPaginatedEndpoint && events.length >= effectiveSize;

      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        aggregationEvents: nextEvents,
        isListLoading: false,
        isFetchingMore: false,
        hasMoreData: hasMore,
        page: page,
        pageSize: effectiveSize,
        filterAction: effectiveAction,
        filterBizStep: effectiveBizStepRaw,
        filterDisposition: effectiveDispositionRaw,
        filterLocationGLN: effectiveLocationGLN,
        filterParentEPC: effectiveParentEPC,
        filterChildEPC: effectiveChildEPC,
        filterSearchText: effectiveSearchText,
        clearListFetchError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        isListLoading: false,
        isFetchingMore: false,
        listFetchError: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMoreData || state.isFetchingMore) return;
    await loadAggregationEvents(
      page: state.page + 1,
      size: state.pageSize,
      isLoadMore: true,
    );
  }

  void updatePageSize(int newSize) {
    emit(state.copyWith(pageSize: newSize));
    loadAggregationEvents(page: 0, size: newSize);
  }

  void toggleSortOrder() {
    final next = state.sortOrder == 'ASC' ? 'DESC' : 'ASC';
    emit(state.copyWith(sortOrder: next));
    loadAggregationEvents(page: 0);
  }

  void clearFiltersAndReload() {
    emit(state.copyWith(clearFilters: true));
    loadAggregationEvents(page: 0);
  }


  Future<AggregationEvent?> getAggregationEventById(String id) async {
    emit(state.copyWith(
      status: AggregationEventsStatus.loading,
      clearError: true,
    ));
    try {
      final raw = await _service.getAggregationEventByIdentifier(id);
      final event = await _enrichOne(raw);
      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        selectedEvent: event,
      ));
      return event;
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        error: e.toString(),
      ));
      return null;
    }
  }


  Future<AggregationEvent> createAggregationEvent(
      AggregationEvent event) async {
    emit(state.copyWith(
      status: AggregationEventsStatus.loading,
      clearError: true,
    ));
    try {
      final newEvent = await _service.createAggregationEvent(event);
      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        selectedEvent: newEvent,
        aggregationEvents: [newEvent, ...state.aggregationEvents],
      ));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  Future<AggregationEvent> createPackEvent({
    required String parentEPC,
    required List<String> childEPCs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    emit(state.copyWith(
      status: AggregationEventsStatus.loading,
      clearError: true,
    ));
    try {
      final newEvent = await _service.createPackEvent(
        parentEPC,
        childEPCs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        sourceList: sourceList,
        destinationList: destinationList,
      );
      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        selectedEvent: newEvent,
        aggregationEvents: [newEvent, ...state.aggregationEvents],
      ));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  Future<AggregationEvent> createUnpackEvent({
    required String parentEPC,
    List<String>? childEPCs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    emit(state.copyWith(
      status: AggregationEventsStatus.loading,
      clearError: true,
    ));
    try {
      final newEvent = await _service.createUnpackEvent(
        parentEPC,
        childEPCs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        sourceList: sourceList,
        destinationList: destinationList,
      );
      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        selectedEvent: newEvent,
        aggregationEvents: [newEvent, ...state.aggregationEvents],
      ));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        error: e.toString(),
      ));
      rethrow;
    }
  }


  Future<AggregationEvent?> findCurrentParentOfChild(String childEPC) async {
    try {
      return await _service.findCurrentParentOfChild(childEPC);
    } catch (_) {
      return null;
    }
  }

  Future<void> trackParentHistory(String parentEPC) async {
    emit(state.copyWith(isListLoading: true, clearListFetchError: true));
    try {
      final raw = await _service.findAggregationEventsByParentEPC(parentEPC);
      final events = await _enrichWithGlns(raw);
      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        aggregationEvents: events,
        isListLoading: false,
        hasMoreData: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        isListLoading: false,
        listFetchError: e.toString(),
      ));
    }
  }

  Future<void> trackChildHistory(String childEPC) async {
    emit(state.copyWith(isListLoading: true, clearListFetchError: true));
    try {
      final raw = await _service.findAggregationEventsByChildEPC(childEPC);
      final events = await _enrichWithGlns(raw);
      emit(state.copyWith(
        status: AggregationEventsStatus.success,
        aggregationEvents: events,
        isListLoading: false,
        hasMoreData: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AggregationEventsStatus.error,
        isListLoading: false,
        listFetchError: e.toString(),
      ));
    }
  }

  Future<List<String>> loadContainerContents(String parentEPC) async {
    try {
      return await _service.findContainerContents(parentEPC);
    } catch (_) {
      return [];
    }
  }

  Future<bool> verifyHierarchy(String epc) async {
    try {
      return await _service.verifyHierarchy(epc);
    } catch (_) {
      return false;
    }
  }

}
