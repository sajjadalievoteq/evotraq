import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_service.dart';


enum ObjectEventsStatus { initial, loading, success, error }

class ObjectEventsState extends Equatable {
  final ObjectEventsStatus status;
  final List<ObjectEvent> objectEvents;
  final ObjectEvent? selectedEvent;

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
  final String? filterEPC;
  final String? filterSearchText;

  final String sortOrder;

  const ObjectEventsState({
    this.status = ObjectEventsStatus.initial,
    this.objectEvents = const [],
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
    this.filterEPC,
    this.filterSearchText,
    this.sortOrder = 'DESC',
  });

  ObjectEventsState copyWith({
    ObjectEventsStatus? status,
    List<ObjectEvent>? objectEvents,
    ObjectEvent? selectedEvent,
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
    String? filterEPC,
    String? filterSearchText,
    String? sortOrder,
    bool clearSelectedEvent = false,
    bool clearError = false,
    bool clearListFetchError = false,
    bool clearFilters = false,
  }) {
    return ObjectEventsState(
      status: status ?? this.status,
      objectEvents: objectEvents ?? this.objectEvents,
      selectedEvent:
          clearSelectedEvent ? null : (selectedEvent ?? this.selectedEvent),
      isListLoading: isListLoading ?? this.isListLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: clearError ? null : (error ?? this.error),
      listFetchError:
          clearListFetchError ? null : (listFetchError ?? this.listFetchError),
      filterAction: clearFilters ? null : (filterAction ?? this.filterAction),
      filterBizStep:
          clearFilters ? null : (filterBizStep ?? this.filterBizStep),
      filterDisposition:
          clearFilters ? null : (filterDisposition ?? this.filterDisposition),
      filterLocationGLN:
          clearFilters ? null : (filterLocationGLN ?? this.filterLocationGLN),
      filterEPC: clearFilters ? null : (filterEPC ?? this.filterEPC),
      filterSearchText:
          clearFilters ? null : (filterSearchText ?? this.filterSearchText),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        status,
        objectEvents,
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
        filterEPC,
        filterSearchText,
        sortOrder,
      ];
}

class ObjectEventsCubit extends Cubit<ObjectEventsState> {
  final ObjectEventService _service;

  ObjectEventsCubit({ObjectEventService? service})
      : _service = service ?? getIt<ObjectEventService>(),
        super(const ObjectEventsState());


  Future<void> loadObjectEvents({
    int page = 0,
    int size = 20,
    String? action,
    String? businessStep,
    String? disposition,
    String? locationGLN,
    String? epc,
    String? searchText,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    emit(state.copyWith(
      isListLoading: true,
      clearListFetchError: true,
      page: page,
      pageSize: size,
      filterAction: action,
      filterBizStep: businessStep,
      filterDisposition: disposition,
      filterLocationGLN: locationGLN,
      filterEPC: epc,
      filterSearchText: searchText,
    ));
    try {
      final Map<String, dynamic> result;
      final hasFilters = action != null ||
          businessStep != null ||
          disposition != null ||
          locationGLN != null ||
          searchText != null ||
          startTime != null ||
          endTime != null;

      if (epc != null) {
        final events = await _service.findObjectEventsByEPC(epc);
        result = {
          'content': events,
          'totalElements': events.length,
          'totalPages': 1,
          'currentPage': 0,
          'size': events.length,
          'first': true,
          'last': true,
        };
      } else if (hasFilters) {
        result = await _service.searchObjectEvents(
          action: action,
          bizStep: businessStep,
          disposition: disposition,
          locationGLN: locationGLN,
          searchText: searchText,
          startTime: startTime,
          endTime: endTime,
          page: page,
          size: size,
          direction: state.sortOrder,
        );
      } else {
        result = await _service.getAllEventsPaginated(page, size);
      }

      final newEvents = result['content'] as List<ObjectEvent>;
      final totalPages = result['totalPages'] as int? ?? 1;
      emit(state.copyWith(
        status: ObjectEventsStatus.success,
        objectEvents: newEvents,
        isListLoading: false,
        hasMoreData: page < totalPages - 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ObjectEventsStatus.error,
        isListLoading: false,
        listFetchError: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.isFetchingMore || !state.hasMoreData) return;
    final nextPage = state.page + 1;
    emit(state.copyWith(isFetchingMore: true));
    try {
      final Map<String, dynamic> result;
      final hasFilters = state.filterAction != null ||
          state.filterBizStep != null ||
          state.filterDisposition != null ||
          state.filterLocationGLN != null ||
          state.filterSearchText != null;

      if (state.filterEPC != null) {
        emit(state.copyWith(isFetchingMore: false, hasMoreData: false));
        return;
      } else if (hasFilters) {
        result = await _service.searchObjectEvents(
          action: state.filterAction,
          bizStep: state.filterBizStep,
          disposition: state.filterDisposition,
          locationGLN: state.filterLocationGLN,
          searchText: state.filterSearchText,
          page: nextPage,
          size: state.pageSize,
          direction: state.sortOrder,
        );
      } else {
        result = await _service.getAllEventsPaginated(nextPage, state.pageSize);
      }

      final newEvents = result['content'] as List<ObjectEvent>;
      final totalPages = result['totalPages'] as int? ?? 1;
      emit(state.copyWith(
        objectEvents: [...state.objectEvents, ...newEvents],
        isFetchingMore: false,
        page: nextPage,
        hasMoreData: nextPage < totalPages - 1,
      ));
    } catch (e) {
      emit(state.copyWith(isFetchingMore: false));
    }
  }

  void updatePageSize(int size) {
    loadObjectEvents(page: 0, size: size);
  }

  void toggleSortOrder() {
    final next = state.sortOrder == 'DESC' ? 'ASC' : 'DESC';
    emit(state.copyWith(sortOrder: next));
    loadObjectEvents(page: 0, size: state.pageSize);
  }

  Future<void> clearFiltersAndReload() async {
    emit(state.copyWith(clearFilters: true));
    await loadObjectEvents(page: 0, size: state.pageSize);
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }


  Future<ObjectEvent?> getObjectEventById(String id) async {
    emit(state.copyWith(isListLoading: true, clearError: true));
    try {
      final event = RegExp(r'^\d+$').hasMatch(id)
          ? await _service.getObjectEventById(id)
          : await _service.getObjectEventByEventId(id);
      emit(state.copyWith(selectedEvent: event, isListLoading: false));
      return event;
    } catch (e) {
      emit(state.copyWith(isListLoading: false, error: e.toString()));
      return null;
    }
  }

  Future<void> getObjectEvent(String id) async {
    await getObjectEventById(id);
  }


  Future<ObjectEvent> createObjectEvent({
    required String action,
    required String bizStep,
    required String disposition,
    String? readPoint,
    String? bizLocation,
    List<String>? epcList,
    List<String>? epcClassList,
    List<QuantityElement>? quantityList,
    Map<String, dynamic>? ilmd,
    Map<String, String>? bizData,
    List<SourceDestination>? sourceList,
    List<SourceDestination>? destinationList,
    String? persistentDisposition,
    List<Map<String, dynamic>>? sensorElementList,
    List<Map<String, dynamic>>? certificationInfo,
    EPCISVersion epcisVersion = EPCISVersion.v2_0,
  }) async {
    emit(state.copyWith(isListLoading: true, clearError: true));
    try {
      final newEvent = await _service.createObjectEvent(
        action: action,
        businessStep: bizStep,
        disposition: disposition,
        readPointGLN: readPoint,
        businessLocationGLN: bizLocation,
        epcs: epcList,
        epcClasses: epcClassList,
        quantities: quantityList,
        ilmd: ilmd,
        bizData: bizData,
        sources: sourceList,
        destinations: destinationList,
        persistentDisposition: persistentDisposition,
        sensorElements: sensorElementList,
        certificationInfo: certificationInfo,
        epcisVersion: epcisVersion,
      );
      emit(state.copyWith(
        objectEvents: [newEvent, ...state.objectEvents],
        selectedEvent: newEvent,
        isListLoading: false,
      ));
      return newEvent;
    } catch (e, st) {
      if (e is ApiException) {
        debugPrint(
          '[ObjectEventsCubit.createObjectEvent] ApiException '
          'status=${e.statusCode} message=${e.message}',
        );
        if (e.responseBody != null && e.responseBody!.isNotEmpty) {
          debugPrint(
            '[ObjectEventsCubit.createObjectEvent] responseBody: ${e.responseBody}',
          );
        }
      } else {
        debugPrint('[ObjectEventsCubit.createObjectEvent] error: $e');
        debugPrint('[ObjectEventsCubit.createObjectEvent] $st');
      }
      emit(state.copyWith(isListLoading: false, error: e.toString()));
      rethrow;
    }
  }


  Future<void> updateObjectEvent(ObjectEvent event) async {
    emit(state.copyWith(isListLoading: true, clearError: true));
    try {
      final updated = await _service.updateObjectEvent(event.id!, event);
      final list = List<ObjectEvent>.from(state.objectEvents);
      final idx = list.indexWhere((e) => e.id == event.id);
      if (idx != -1) list[idx] = updated;
      emit(state.copyWith(
        objectEvents: list,
        selectedEvent: updated,
        isListLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isListLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteObjectEvent(String id) async {
    emit(state.copyWith(isListLoading: true, clearError: true));
    try {
      await _service.deleteObjectEvent(id);
      final list = List<ObjectEvent>.from(state.objectEvents)
        ..removeWhere((e) => e.id == id);
      final hasSel = state.selectedEvent?.id == id;
      emit(state.copyWith(
        objectEvents: list,
        isListLoading: false,
        clearSelectedEvent: hasSel,
        selectedEvent: hasSel ? null : state.selectedEvent,
      ));
    } catch (e) {
      emit(state.copyWith(isListLoading: false, error: e.toString()));
      rethrow;
    }
  }


  Future<List<ObjectEvent>> createEventsBatch(List<ObjectEvent> events) async {
    emit(state.copyWith(isListLoading: true, clearError: true));
    try {
      final created = await _service.createObjectEventsBatch(events);
      emit(state.copyWith(isListLoading: false));
      return created;
    } catch (e) {
      emit(state.copyWith(isListLoading: false, error: e.toString()));
      rethrow;
    }
  }
}