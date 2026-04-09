import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/services/aggregation_event_service.dart';
import 'package:traqtrace_app/features/epcis/services/aggregation_event_service_impl.dart';

class AggregationEventsState extends Equatable {
  final List<AggregationEvent> aggregationEvents;
  final bool loading;
  final String? error;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final AggregationEvent? selectedEvent;
  final String? filterAction;
  final String? filterBizStep;
  final String? filterDisposition;
  final String? filterLocationGLN;
  final String? filterParentEPC;
  final String? filterChildEPC;

  const AggregationEventsState({
    this.aggregationEvents = const [],
    this.loading = false,
    this.error,
    this.totalPages = 0,
    this.totalElements = 0,
    this.currentPage = 0,
    this.selectedEvent,
    this.filterAction,
    this.filterBizStep,
    this.filterDisposition,
    this.filterLocationGLN,
    this.filterParentEPC,
    this.filterChildEPC,
  });

  AggregationEventsState copyWith({
    List<AggregationEvent>? aggregationEvents,
    bool? loading,
    String? error,
    int? totalPages,
    int? totalElements,
    int? currentPage,
    AggregationEvent? selectedEvent,
    String? filterAction,
    String? filterBizStep,
    String? filterDisposition,
    String? filterLocationGLN,
    String? filterParentEPC,
    String? filterChildEPC,
  }) {
    return AggregationEventsState(
      aggregationEvents: aggregationEvents ?? this.aggregationEvents,
      loading: loading ?? this.loading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      filterAction: filterAction ?? this.filterAction,
      filterBizStep: filterBizStep ?? this.filterBizStep,
      filterDisposition: filterDisposition ?? this.filterDisposition,
      filterLocationGLN: filterLocationGLN ?? this.filterLocationGLN,
      filterParentEPC: filterParentEPC ?? this.filterParentEPC,
      filterChildEPC: filterChildEPC ?? this.filterChildEPC,
    );
  }

  @override
  List<Object?> get props => [
        aggregationEvents,
        loading,
        error,
        totalPages,
        totalElements,
        currentPage,
        selectedEvent,
        filterAction,
        filterBizStep,
        filterDisposition,
        filterLocationGLN,
        filterParentEPC,
        filterChildEPC,
      ];
}

class AggregationEventsCubit extends Cubit<AggregationEventsState> {
  final AggregationEventService _service;

  AggregationEventsCubit({AggregationEventService? service, required AppConfig appConfig})
      : _service = service ??
            AggregationEventServiceImpl(
              httpClient: http.Client(),
              tokenManager: TokenManager(),
              appConfig: appConfig,
            ),
        super(const AggregationEventsState());

  Future<void> loadAggregationEvents({
    int? page,
    int size = 20,
    String? action,
    String? parentEPC,
    String? childEPC,
    String? businessStep,
    String? locationGLN,
    DateTime? startTime,
    DateTime? endTime,
    bool loadMore = false,
  }) async {
    page = page ?? state.currentPage;
    action = action ?? state.filterAction;
    parentEPC = parentEPC ?? state.filterParentEPC;
    childEPC = childEPC ?? state.filterChildEPC;
    businessStep = businessStep ?? state.filterBizStep;
    locationGLN = locationGLN ?? state.filterLocationGLN;

    if (!loadMore) {
      emit(state.copyWith(
        loading: true,
        error: null,
        aggregationEvents: const [],
        currentPage: page,
      ));
    } else {
      emit(state.copyWith(loading: true, error: null));
    }

    try {
      List<AggregationEvent> events = [];

      if (locationGLN != null && startTime != null && endTime != null) {
        events = await _service.findAggregationEventsByLocationAndTimeWindow(locationGLN, startTime, endTime);
      } else if (businessStep != null && parentEPC != null) {
        events = await _service.findAggregationEventsByBusinessStepAndParentEPC(businessStep, parentEPC);
      } else if (parentEPC != null && action != null) {
        events = await _service.findAggregationEventsByParentEPCAndAction(parentEPC, action);
      } else if (childEPC != null && action != null) {
        events = await _service.findAggregationEventsByChildEPCAndAction(childEPC, action);
      } else if (parentEPC != null) {
        events = await _service.findAggregationEventsByParentEPC(parentEPC);
      } else if (childEPC != null) {
        events = await _service.findAggregationEventsByChildEPC(childEPC);
      } else if (action != null) {
        events = await _service.findAggregationEventsByAction(action);
      } else {
        events = await _service.getAllAggregationEvents(page, size);
      }

      final nextEvents = loadMore ? [...state.aggregationEvents, ...events] : events;
      final totalElements = events.length;
      final totalPages = events.isEmpty ? 0 : math.max(1, (totalElements / size).ceil());

      emit(state.copyWith(
        aggregationEvents: nextEvents,
        totalElements: totalElements,
        totalPages: totalPages,
        loading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<AggregationEvent?> getAggregationEventById(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(id);

      final event = isUuid ? await _service.getAggregationEventById(id) : await _service.getAggregationEventByEventId(id);
      emit(state.copyWith(loading: false, selectedEvent: event));
      return event;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<AggregationEvent?> getAggregationEventByEventId(String eventId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final event = await _service.getAggregationEventByEventId(eventId);
      emit(state.copyWith(loading: false, selectedEvent: event));
      return event;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<AggregationEvent> createAggregationEvent(AggregationEvent event) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final newEvent = await _service.createAggregationEvent(event);
      emit(state.copyWith(aggregationEvents: [newEvent, ...state.aggregationEvents], loading: false));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
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
    emit(state.copyWith(loading: true, error: null));
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
      emit(state.copyWith(aggregationEvents: [newEvent, ...state.aggregationEvents], loading: false));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
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
    emit(state.copyWith(loading: true, error: null));
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
      emit(state.copyWith(aggregationEvents: [newEvent, ...state.aggregationEvents], loading: false));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateAggregationEvent(AggregationEvent event) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final updatedEvent = await _service.updateAggregationEvent(event.id!, event);
      final nextEvents = [...state.aggregationEvents];
      final index = nextEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        nextEvents[index] = updatedEvent;
      }

      final nextSelected = (state.selectedEvent != null && state.selectedEvent!.id == event.id) ? updatedEvent : state.selectedEvent;

      emit(state.copyWith(
        aggregationEvents: nextEvents,
        selectedEvent: nextSelected,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteAggregationEvent(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _service.deleteAggregationEvent(id);
      final nextEvents = state.aggregationEvents.where((event) => event.id != id).toList();
      final nextSelected = (state.selectedEvent != null && state.selectedEvent!.id == id) ? null : state.selectedEvent;
      emit(state.copyWith(aggregationEvents: nextEvents, selectedEvent: nextSelected, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> findCurrentChildrenOfParent(String parentEPC) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findCurrentChildrenOfParent(parentEPC);
      emit(state.copyWith(
        aggregationEvents: events,
        totalElements: events.length,
        totalPages: 1,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<AggregationEvent?> findCurrentParentOfChild(String childEPC) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final event = await _service.findCurrentParentOfChild(childEPC);
      emit(state.copyWith(loading: false));
      return event;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<void> trackParentHistory(String parentEPC) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.trackParentHistory(parentEPC);
      emit(state.copyWith(
        aggregationEvents: events,
        totalElements: events.length,
        totalPages: 1,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> trackChildHistory(String childEPC) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.trackChildHistory(childEPC);
      emit(state.copyWith(
        aggregationEvents: events,
        totalElements: events.length,
        totalPages: 1,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<List<String>> loadContainerContents(String parentEPC) async {
    try {
      emit(state.copyWith(loading: true));
      final contents = await _service.findContainerContents(parentEPC);
      emit(state.copyWith(loading: false));
      return contents;
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Error loading container contents: $e"));
      return [];
    }
  }

  Future<void> applyChildEPCFilter(String childEPC) async {
    emit(state.copyWith(
      filterAction: null,
      filterBizStep: null,
      filterDisposition: null,
      filterLocationGLN: null,
      filterParentEPC: null,
      filterChildEPC: childEPC,
      currentPage: 0,
      aggregationEvents: const [],
    ));

    await loadAggregationEvents(childEPC: childEPC);
  }

  Future<List<AggregationEvent>> loadAggregationEventsByParentEPC(String parentEPC) async {
    try {
      emit(state.copyWith(loading: true));
      final events = await _service.findAggregationEventsByParentEPC(parentEPC);
      emit(state.copyWith(loading: false));
      return events;
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Error loading events by parent EPC: $e"));
      return [];
    }
  }

  Future<bool> verifyHierarchy(String epc) async {
    try {
      emit(state.copyWith(loading: true));
      final result = await _service.verifyHierarchy(epc);
      emit(state.copyWith(loading: false));
      return result;
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Error verifying hierarchy: $e"));
      return false;
    }
  }
}

