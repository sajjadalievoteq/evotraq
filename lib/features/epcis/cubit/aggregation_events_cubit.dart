import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/epcis/aggregation_event_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/data/services/operations/unpacking/unpacking_operation_service.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/utils/aggregation_event_list_utils.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';

import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_state.dart';


class AggregationEventsCubit extends Cubit<AggregationEventsState> {
  final AggregationEventService service;
  final PackingOperationService packingService;
  final UnpackingOperationService unpackingService;
  final GLNService _glnService;

  final Map<String, GLN> _glnCache = {};

  AggregationEventsCubit({
    AggregationEventService? service,
    PackingOperationService? packingService,
    UnpackingOperationService? unpackingService,
    GLNService? glnService,
  }) : service = service ?? getIt<AggregationEventService>(),
       packingService = packingService ?? getIt<PackingOperationService>(),
       unpackingService =
           unpackingService ?? getIt<UnpackingOperationService>(),
       _glnService = glnService ?? getIt<GLNService>(),
       super(const AggregationEventsState());

  Future<List<AggregationEvent>> enrichWithGlns(
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
    _seedGlnCacheFromCatalog(codesToFetch);
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
      final resolvedBizLoc =
          (e.businessLocation != null &&
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

  void _seedGlnCacheFromCatalog(Iterable<String> codes) {
    if (!getIt.isRegistered<GlnPickerCatalog>()) return;
    final catalog = getIt<GlnPickerCatalog>();
    if (!catalog.isLoaded) return;
    for (final code in codes) {
      if (_glnCache.containsKey(code)) continue;
      final hit = resolveGlnInCatalog(code, catalog.items);
      if (hit != null) _glnCache[code] = hit;
    }
  }

  Future<AggregationEvent> _enrichOne(AggregationEvent event) async {
    final enriched = await enrichWithGlns([event]);
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
    final effectiveDispositionRaw = disposition ?? state.filterDisposition;
    final effectiveLocationGLN = locationGLN ?? state.filterLocationGLN;
    final effectiveSearchText = searchText ?? state.filterSearchText;

    final effectiveBizStep = effectiveBizStepRaw != null
        ? AggregationEventListUtils.toBizStepUrn(effectiveBizStepRaw)
        : null;
    final effectiveDisposition = effectiveDispositionRaw != null
        ? AggregationEventListUtils.toDispositionUrn(effectiveDispositionRaw)
        : null;

    final searchEpc = AggregationEventListUtils.epcFromSearchQuery(
      effectiveSearchText,
    );
    if (searchEpc != null) {
      if (effectiveParentEPC == null) {
        effectiveParentEPC = searchEpc;
      } else if (effectiveChildEPC == null && effectiveParentEPC != searchEpc) {
        effectiveChildEPC = searchEpc;
      }
    }

    if (isLoadMore) {
      if (!state.hasMoreData || state.isFetchingMore) return;
      emit(state.copyWith(isFetchingMore: true, clearListFetchError: true));
    } else {
      emit(
        state.copyWith(
          isListLoading: true,
          isFetchingMore: false,
          aggregationEvents: const [],
          page: 0,
          hasMoreData: false,
          clearListFetchError: true,
        ),
      );
    }

    try {
      List<AggregationEvent> events = [];

      if (effectiveLocationGLN != null &&
          startTime != null &&
          endTime != null) {
        events = await service.findAggregationEventsByLocationAndTimeWindow(
          effectiveLocationGLN,
          startTime,
          endTime,
        );
      } else if (effectiveBizStep != null && effectiveParentEPC != null) {
        events = await service.findAggregationEventsByBusinessStepAndParentEPC(
          effectiveBizStep,
          effectiveParentEPC,
        );
      } else if (effectiveParentEPC != null && effectiveAction != null) {
        events = await service.findAggregationEventsByParentEPCAndAction(
          effectiveParentEPC,
          effectiveAction,
        );
      } else if (effectiveChildEPC != null && effectiveAction != null) {
        events = await service.findAggregationEventsByChildEPCAndAction(
          effectiveChildEPC,
          effectiveAction,
        );
      } else if (effectiveParentEPC != null) {
        events = await service.findAggregationEventsByParentEPC(
          effectiveParentEPC,
        );
      } else if (effectiveChildEPC != null) {
        events = await service.findAggregationEventsByChildEPC(
          effectiveChildEPC,
        );
      } else if (effectiveDisposition != null) {
        events = await service.findAggregationEventsByDisposition(
          effectiveDisposition,
        );
      } else if (effectiveBizStep != null) {
        events = await service.findAggregationEventsByBusinessStep(
          effectiveBizStep,
        );
      } else if (effectiveAction != null) {
        events = await service.findAggregationEventsByAction(effectiveAction);
      } else {
        final result = await service.getAllAggregationEvents(
          page,
          effectiveSize,
          direction: state.sortOrder,
        );
        events = result['content'] as List<AggregationEvent>;
        events = await enrichWithGlns(events);

        final nextEvents = isLoadMore
            ? [...state.aggregationEvents, ...events]
            : events;
        final isLast = result['last'] as bool? ?? true;

        emit(
          state.copyWith(
            status: AggregationEventsStatus.success,
            aggregationEvents: nextEvents,
            isListLoading: false,
            isFetchingMore: false,
            hasMoreData: !isLast,
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
          ),
        );
        return;
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
      events = AggregationEventListUtils.sortByEventTime(
        events,
        state.sortOrder,
      );

      events = await enrichWithGlns(events);

      final nextEvents = isLoadMore
          ? [...state.aggregationEvents, ...events]
          : events;

      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          aggregationEvents: nextEvents,
          isListLoading: false,
          isFetchingMore: false,
          hasMoreData: false,
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
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          isListLoading: false,
          isFetchingMore: false,
          listFetchError: e.toString(),
        ),
      );
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
    emit(
      state.copyWith(status: AggregationEventsStatus.loading, clearError: true),
    );
    try {
      final raw = await service.getAggregationEventByIdentifier(id);
      final event = await _enrichOne(raw);
      emit(
        state.copyWith(
          status: AggregationEventsStatus.success,
          selectedEvent: event,
        ),
      );
      return event;
    } catch (e) {
      emit(
        state.copyWith(
          status: AggregationEventsStatus.error,
          error: e.toString(),
        ),
      );
      return null;
    }
  }
}
