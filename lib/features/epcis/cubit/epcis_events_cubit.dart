import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/features/epcis/services/epcis_event_service.dart';
import 'package:traqtrace_app/features/epcis/utils/epcis_query_factory.dart';

class EPCISEventsState extends Equatable {
  final List<EPCISEvent> events;
  final bool loading;
  final String? error;
  final int totalPages;
  final int totalElements;

  const EPCISEventsState({
    this.events = const [],
    this.loading = false,
    this.error,
    this.totalPages = 0,
    this.totalElements = 0,
  });

  EPCISEventsState copyWith({
    List<EPCISEvent>? events,
    bool? loading,
    String? error,
    int? totalPages,
    int? totalElements,
  }) {
    return EPCISEventsState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
    );
  }

  @override
  List<Object?> get props => [
    events,
    loading,
    error,
    totalPages,
    totalElements,
  ];
}

class EPCISEventsCubit extends Cubit<EPCISEventsState> {
  final EPCISEventService _eventService;

  EPCISEventsCubit(this._eventService) : super(const EPCISEventsState());

  Future<void> loadEvents({int page = 0, int pageSize = 20}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getAllEventsPaginated(page, pageSize);
      emit(
        state.copyWith(
          events: result['content'] as List<EPCISEvent>,
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

  Future<void> loadEventsByTimeWindow(
    DateTime startTime,
    DateTime endTime, {
    int page = 0,
    int pageSize = 20,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.findEventsByTimeWindow(
        startTime,
        endTime,
      );
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> deleteEvent(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _eventService.deleteEvent(id);
      final updated = List<EPCISEvent>.from(state.events)
        ..removeWhere((event) => event.id == id);
      emit(state.copyWith(events: updated, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadEventsByBusinessStep(String businessStep) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getEventsByBusinessStep(businessStep);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadEventsByDisposition(String disposition) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getEventsByDisposition(disposition);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadEventsByLocation(String locationGLN) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getEventsByLocation(locationGLN);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadEventsByEPC(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getEventsByEPC(epc);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadItemHistory(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getItemHistory(epc);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<Map<String, dynamic>> getItemStatus(String epc) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.getItemStatus(epc);
      emit(state.copyWith(loading: false, error: null));
      return result;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return {'error': e.toString()};
    }
  }

  Future<void> executeQuery(EPCISQueryParametersDTO queryParams) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await _eventService.queryEvents(queryParams);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> complexSearch({
    List<String>? epcs,
    List<String>? businessSteps,
    List<String>? dispositions,
    List<String>? locations,
    bool? locationsAreReadPoints,
    List<String>? eventTypes,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 50,
    int offset = 0,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final queryParams = EPCISQueryFactory.createComplexQuery(
        epcs: epcs,
        businessSteps: businessSteps,
        dispositions: dispositions,
        readPoints: locationsAreReadPoints == true ? locations : null,
        businessLocations: locationsAreReadPoints == false ? locations : null,
        eventTypes: eventTypes,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
        offset: offset,
      );

      final result = await _eventService.queryEvents(queryParams);
      emit(
        state.copyWith(
          events: result,
          totalPages: 1,
          totalElements: result.length,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
