import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';

import '../../../data/services/transformation_event_service.dart';

class TransformationEventsState extends Equatable {
  final List<TransformationEvent> transformationEvents;
  final bool isLoading;
  final String? errorMessage;
  final TransformationEvent? selectedEvent;

  const TransformationEventsState({
    required this.transformationEvents,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedEvent,
  });

  factory TransformationEventsState.initial() => const TransformationEventsState(
        transformationEvents: [],
        isLoading: false,
        errorMessage: null,
        selectedEvent: null,
      );

  TransformationEventsState copyWith({
    List<TransformationEvent>? transformationEvents,
    bool? isLoading,
    String? errorMessage,
    TransformationEvent? selectedEvent,
    bool clearError = false,
    bool clearSelectedEvent = false,
  }) {
    return TransformationEventsState(
      transformationEvents: transformationEvents ?? this.transformationEvents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedEvent:
          clearSelectedEvent ? null : (selectedEvent ?? this.selectedEvent),
    );
  }

  @override
  List<Object?> get props => [
        transformationEvents,
        isLoading,
        errorMessage,
        selectedEvent,
      ];
}

class TransformationEventsCubit extends Cubit<TransformationEventsState> {
  final TransformationEventService _service;
  final DioService _dioService;

  TransformationEventsCubit({
    TransformationEventService? service,
    DioService? dioService,
  })  : _service = service ?? getIt<TransformationEventService>(),
        _dioService = dioService ?? getIt<DioService>(),
        super(TransformationEventsState.initial());

  Future<void> loadTransformationEvents() async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      final token = await _dioService.getAuthToken();
      final response = await _dioService.get(
        '${_dioService.baseUrl}/transformation-events',
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        if (data['content'] != null && data['content'] is List) {
          final events = (data['content'] as List)
              .map((json) => TransformationEvent.fromJson(json))
              .toList(growable: false);

          emit(
            state.copyWith(
              transformationEvents: events,
              isLoading: false,
            ),
          );
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load transformation events: ${response.statusCode}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load transformation events: ${e.toString()}',
        ),
      );
    }
  }
    /// Create a transformation process
  Future<TransformationEvent> createTransformationProcess(
      {required String transformationId,
      required Set<String> inputEPCs,
      required Set<String> outputEPCs,
      required String locationGLN,
      required String businessStep,
      required String disposition,
      required Map<String, String> parameters,
      required Map<String, String> bizData}) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final newEvent = await _service.createTransformationProcess(
        transformationId,
        inputEPCs,
        outputEPCs,
        locationGLN,
        businessStep,
        disposition,
        parameters,
        bizData,
      );
      
      emit(
        state.copyWith(
          transformationEvents: [newEvent, ...state.transformationEvents],
          isLoading: false,
        ),
      );
      return newEvent;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create transformation process: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Create a transformation event
  Future<TransformationEvent> createTransformationEvent(TransformationEvent event) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final newEvent = await _service.createTransformationEvent(event);
      
      emit(
        state.copyWith(
          transformationEvents: [newEvent, ...state.transformationEvents],
          isLoading: false,
        ),
      );
      return newEvent;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create transformation event: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Find transformation events by transformation ID
  Future<List<TransformationEvent>> findByTransformationId(String transformationId) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final events = await _service.findTransformationEventsByTransformationId(transformationId);
      emit(state.copyWith(transformationEvents: events, isLoading: false));
      return events;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find transformation events: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Find transformation events by input EPC
  Future<List<TransformationEvent>> findByInputEPC(String inputEPC) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final events = await _service.findTransformationEventsByInputEPC(inputEPC);
      emit(state.copyWith(transformationEvents: events, isLoading: false));
      return events;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find transformation events: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Find transformation events by output EPC
  Future<List<TransformationEvent>> findByOutputEPC(String outputEPC) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final events = await _service.findTransformationEventsByOutputEPC(outputEPC);
      emit(state.copyWith(transformationEvents: events, isLoading: false));
      return events;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find transformation events: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Find transformation events by input EPC class
  Future<List<TransformationEvent>> findByInputEPCClass(String inputEPCClass) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final events = await _service.findTransformationEventsByInputEPCClass(inputEPCClass);
      emit(state.copyWith(transformationEvents: events, isLoading: false));
      return events;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find transformation events: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Find transformation events by output EPC class
  Future<List<TransformationEvent>> findByOutputEPCClass(String outputEPCClass) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final events = await _service.findTransformationEventsByOutputEPCClass(outputEPCClass);
      emit(state.copyWith(transformationEvents: events, isLoading: false));
      return events;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find transformation events: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Find transformation history for an output EPC
  Future<List<TransformationEvent>> findTransformationHistory(String outputEPC) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final events = await _service.findTransformationHistoryForOutput(outputEPC);
      emit(state.copyWith(transformationEvents: events, isLoading: false));
      return events;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find transformation history: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Get a transformation event by ID
  Future<TransformationEvent> getTransformationEventById(String eventId) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final event = await _service.getTransformationEventByEventId(eventId);
      emit(state.copyWith(selectedEvent: event, isLoading: false));
      return event;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to get transformation event: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
    /// Update a transformation event
  Future<void> updateTransformationEvent(TransformationEvent event) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      if (event.id == null) {
        throw Exception('Cannot update transformation event without an ID');
      }
      
      final updatedEvent = await _service.updateTransformationEvent(event.id!, event);
      
      final updatedEvents = state.transformationEvents
          .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
          .toList(growable: false);

      final selectedEvent = state.selectedEvent?.id == updatedEvent.id
          ? updatedEvent
          : state.selectedEvent;
      
      emit(
        state.copyWith(
          transformationEvents: updatedEvents,
          selectedEvent: selectedEvent,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update transformation event: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Delete a transformation event
  Future<void> deleteTransformationEvent(String id) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      await _service.deleteTransformationEvent(id);
      
      final updatedEvents = state.transformationEvents
          .where((e) => e.id != id)
          .toList(growable: false);

      emit(
        state.copyWith(
          transformationEvents: updatedEvents,
          clearSelectedEvent: state.selectedEvent?.id == id,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to delete transformation event: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }
  
  /// Track transformations for a specific EPC
  Future<List<TransformationEvent>> trackTransformationsByEPC(String epc) async {
    try {
      final events = await _service.findTransformationsByEPC(epc);
      return events;
    } catch (e) {
      return [];
    }
  }
  
  /// Find transformations by input and output relationship
  Future<List<TransformationEvent>> findTransformationsByInputOutput(
      String inputEPC, String outputEPC) async {
    try {
      final events = await _service.findTransformationsByInputAndOutputEPC(inputEPC, outputEPC);
      return events;
    } catch (e) {
      return [];
    }
  }
  
  /// Get transformation events by transformation ID
  Future<List<TransformationEvent>> getTransformationsByTransformationId(String transformationId) async {
    try {
      final events = await _service.findTransformationEventsByTransformationId(transformationId);
      return events;
    } catch (e) {
      return [];
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
