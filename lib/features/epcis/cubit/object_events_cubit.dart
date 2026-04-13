import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_types.dart';
import 'package:traqtrace_app/data/services/object_event_service.dart';

class ObjectEventsState extends Equatable {
  final List<ObjectEvent> events;
  final bool loading;
  final String? error;
  final int totalPages;
  final int totalElements;
  final ObjectEvent? selectedEvent;

  const ObjectEventsState({
    this.events = const [],
    this.loading = false,
    this.error,
    this.totalPages = 0,
    this.totalElements = 0,
    this.selectedEvent,
  });

  ObjectEventsState copyWith({
    List<ObjectEvent>? events,
    bool? loading,
    String? error,
    int? totalPages,
    int? totalElements,
    ObjectEvent? selectedEvent,
  }) {
    return ObjectEventsState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      selectedEvent: selectedEvent ?? this.selectedEvent,
    );
  }

  @override
  List<Object?> get props => [
    events,
    loading,
    error,
    totalPages,
    totalElements,
    selectedEvent,
  ];
}

class ObjectEventsCubit extends Cubit<ObjectEventsState> {
  final ObjectEventService _service;

  ObjectEventsCubit({
    ObjectEventService? service,
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _service =
           service ??
           ObjectEventService(
             httpClient: httpClient,
             tokenManager: tokenManager,
             appConfig: appConfig,
           ),
       super(const ObjectEventsState());

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> loadObjectEvents({
    int page = 0,
    int size = 20,
    bool append = false,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _service.getAllEventsPaginated(page, size);
      final newEvents = result['content'] as List<ObjectEvent>;
      final events = append && page > 0
          ? (List<ObjectEvent>.from(state.events)..addAll(newEvents))
          : newEvents;
      emit(
        state.copyWith(
          events: events,
          totalPages: result['totalPages'] as int,
          totalElements: result['totalElements'] as int,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> getObjectEvent(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(id);
      final selected = isUuid
          ? await _service.getObjectEventById(id)
          : await _service.getObjectEventByEventId(id);
      emit(
        state.copyWith(selectedEvent: selected, loading: false, error: null),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
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
  }) async {
    emit(state.copyWith(loading: true, error: null));
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
      );
      final updatedEvents = [newEvent, ...state.events];
      emit(state.copyWith(events: updatedEvents, loading: false, error: null));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<ObjectEvent> createAddEvent({
    required List<String> epcList,
    required String locationGLN,
    required String bizStep,
    required String disposition,
    String? readPointGLN,
    Map<String, dynamic>? ilmd,
    Map<String, String>? bizData,
    List<SourceDestination>? sourceList,
    List<SourceDestination>? destinationList,
    String? persistentDisposition,
    List<Map<String, dynamic>>? sensorElementList,
    List<Map<String, dynamic>>? certificationInfoList,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final newEvent = await _service.createObjectEvent(
        action: 'ADD',
        businessStep: bizStep,
        disposition: disposition,
        readPointGLN: readPointGLN,
        businessLocationGLN: locationGLN,
        epcs: epcList,
        ilmd: ilmd,
        bizData: bizData,
        sources: sourceList,
        destinations: destinationList,
        persistentDisposition: persistentDisposition,
        sensorElements: sensorElementList,
        certificationInfo: certificationInfoList,
      );
      final updatedEvents = [newEvent, ...state.events];
      emit(state.copyWith(events: updatedEvents, loading: false, error: null));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<ObjectEvent> createObserveEvent({
    required List<String> epcList,
    required String locationGLN,
    required String bizStep,
    required String disposition,
    String? readPointGLN,
    Map<String, String>? bizData,
    List<SourceDestination>? sourceList,
    List<SourceDestination>? destinationList,
    String? persistentDisposition,
    List<Map<String, dynamic>>? sensorElementList,
    List<Map<String, dynamic>>? certificationInfo,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final newEvent = await _service.createObjectEvent(
        action: 'OBSERVE',
        businessStep: bizStep,
        disposition: disposition,
        readPointGLN: readPointGLN,
        businessLocationGLN: locationGLN,
        epcs: epcList,
        bizData: bizData,
        sources: sourceList,
        destinations: destinationList,
        persistentDisposition: persistentDisposition,
        sensorElements: sensorElementList,
        certificationInfo: certificationInfo,
      );
      final updatedEvents = [newEvent, ...state.events];
      emit(state.copyWith(events: updatedEvents, loading: false, error: null));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<ObjectEvent> createDeleteEvent({
    required List<String> epcList,
    required String locationGLN,
    required String bizStep,
    required String disposition,
    String? readPointGLN,
    Map<String, String>? bizData,
    List<SourceDestination>? sourceList,
    List<SourceDestination>? destinationList,
    String? persistentDisposition,
    List<Map<String, dynamic>>? sensorElementList,
    List<Map<String, dynamic>>? certificationInfo,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final newEvent = await _service.createObjectEvent(
        action: 'DELETE',
        businessStep: bizStep,
        disposition: disposition,
        readPointGLN: readPointGLN,
        businessLocationGLN: locationGLN,
        epcs: epcList,
        bizData: bizData,
        sources: sourceList,
        destinations: destinationList,
        persistentDisposition: persistentDisposition,
        sensorElements: sensorElementList,
        certificationInfo: certificationInfo,
      );
      final updatedEvents = [newEvent, ...state.events];
      emit(state.copyWith(events: updatedEvents, loading: false, error: null));
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateObjectEvent(ObjectEvent event) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final updatedEvent = await _service.updateObjectEvent(event.id!, event);
      final updatedList = List<ObjectEvent>.from(state.events);
      final index = updatedList.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        updatedList[index] = updatedEvent;
      }
      final newSelected =
          state.selectedEvent != null && state.selectedEvent!.id == event.id
          ? updatedEvent
          : state.selectedEvent;
      emit(
        state.copyWith(
          events: updatedList,
          selectedEvent: newSelected,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteObjectEvent(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _service.deleteObjectEvent(id);
      final updatedList = List<ObjectEvent>.from(state.events)
        ..removeWhere((e) => e.id == id);
      final sel = state.selectedEvent != null && state.selectedEvent!.id == id
          ? null
          : state.selectedEvent;
      emit(
        state.copyWith(
          events: updatedList,
          selectedEvent: sel,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> findEventsByEPC(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      bool isValidEPC = await _service.validateEPC(epc);
      if (!isValidEPC) {
        try {
          epc = await _service.convertGS1ElementStringToEPC(epc);
        } catch (_) {}
      }
      final events = await _service.findObjectEventsByEPC(epc);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByEPCClass(String epcClass) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByEPCClass(epcClass);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByBusinessStepAndEPC(
    String businessStep,
    String epc,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByBusinessStepAndEPC(
        businessStep,
        epc,
      );
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByILMD(String key, String value) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByILMD(key, value);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> getEPCHistory(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findEPCHistory(epc);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<ObjectEvent?> getCurrentStatusOfEPC(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final status = await _service.getCurrentStatusOfEPC(epc);
      emit(state.copyWith(selectedEvent: status, loading: false, error: null));
      return status;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<Map<String, dynamic>> getEventStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final stats = await _service.getEventStatistics(
        startTime: startTime,
        endTime: endTime,
      );
      emit(state.copyWith(loading: false, error: null));
      return stats;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> findEventsByMultipleEPCs(List<String> epcs) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByEPCs(epcs);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByQuantity(
    String epcClass,
    double minQuantity,
    double maxQuantity,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByQuantity(
        epcClass,
        minQuantity,
        maxQuantity,
      );
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsWithSensorData(Map<String, dynamic> criteria) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsWithSensorData(criteria);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByBusinessStep(String businessStep) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByBusinessStep(
        businessStep,
      );
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByDisposition(String disposition) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByDisposition(disposition);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByLocation(String locationGLN) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByLocation(locationGLN);
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByTimeWindow(
    DateTime startTime,
    DateTime endTime,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByTimeWindow(
        startTime,
        endTime,
      );
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final events = await _service.findObjectEventsByLocationAndTimeWindow(
        locationGLN,
        startTime,
        endTime,
      );
      emit(
        state.copyWith(
          events: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<List<ObjectEvent>> createEventsBatch(List<ObjectEvent> events) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final createdEvents = await _service.createObjectEventsBatch(events);
      emit(state.copyWith(loading: false, error: null));
      return createdEvents;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> validateAllEvents() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      for (final event in state.events) {
        await _service.validateObjectEvent(event);
      }
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateEvent(ObjectEvent event) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _service.validateObjectEvent(event);
      emit(state.copyWith(loading: false, error: null));
      return result;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateObjectEvent(ObjectEvent event) {
    return validateEvent(event);
  }
}
