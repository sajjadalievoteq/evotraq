import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_event_service.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_event_service_impl.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

class TransactionEventsState extends Equatable {
  final List<TransactionEvent> transactionEvents;
  final bool loading;
  final String? error;
  final int totalPages;
  final int totalElements;
  final TransactionEvent? selectedEvent;

  const TransactionEventsState({
    required this.transactionEvents,
    required this.loading,
    required this.error,
    required this.totalPages,
    required this.totalElements,
    required this.selectedEvent,
  });

  factory TransactionEventsState.initial() => const TransactionEventsState(
        transactionEvents: [],
        loading: false,
        error: null,
        totalPages: 0,
        totalElements: 0,
        selectedEvent: null,
      );

  TransactionEventsState copyWith({
    List<TransactionEvent>? transactionEvents,
    bool? loading,
    String? error,
    int? totalPages,
    int? totalElements,
    TransactionEvent? selectedEvent,
    bool clearError = false,
    bool clearSelectedEvent = false,
  }) {
    return TransactionEventsState(
      transactionEvents: transactionEvents ?? this.transactionEvents,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      selectedEvent:
          clearSelectedEvent ? null : (selectedEvent ?? this.selectedEvent),
    );
  }

  @override
  List<Object?> get props => [
        transactionEvents,
        loading,
        error,
        totalPages,
        totalElements,
        selectedEvent,
      ];
}

class TransactionEventsCubit extends Cubit<TransactionEventsState> {
  final TransactionEventService _service;

  TransactionEventsCubit({
    TransactionEventService? service,
    required AppConfig appConfig,
  })  : _service = service ??
            TransactionEventServiceImpl(
              httpClient: getIt<http.Client>(),
              tokenManager: getIt<TokenManager>(),
              appConfig: appConfig,
            ),
        super(TransactionEventsState.initial());

  Future<void> loadTransactionEvents({
    int page = 0,
    int size = 20,
    String? bizStep,
    String? disposition,
    String? locationGLN,
    DateTime? startTime,
    DateTime? endTime,
    bool loadMore = false,
  }) async {
    try {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          transactionEvents: loadMore ? state.transactionEvents : const [],
        ),
      );

      List<TransactionEvent> events = [];

      if (bizStep != null &&
          locationGLN != null &&
          startTime != null &&
          endTime != null) {
        events = await _service.findTransactionEventsByLocationAndTimeWindow(
          locationGLN,
          startTime,
          endTime,
        );
      } else if (bizStep != null) {
        events = await _service.findTransactionEventsByBusinessStep(bizStep);
      } else if (disposition != null) {
        events =
            await _service.findTransactionEventsByDispositionAndEPC(disposition, "");
      } else {
        final addEvents = await _service.findTransactionEventsByAction("ADD");
        final observeEvents =
            await _service.findTransactionEventsByAction("OBSERVE");
        final deleteEvents = await _service.findTransactionEventsByAction("DELETE");

        events = [...addEvents, ...observeEvents, ...deleteEvents];
        events.sort((a, b) => b.eventTime.compareTo(a.eventTime));
      }

      final totalElements = events.length;
      final totalPages = size <= 0 ? 1 : ((totalElements + size - 1) ~/ size);
      final startIndex = page * size;
      final pageItems = startIndex >= totalElements
          ? <TransactionEvent>[]
          : events.skip(startIndex).take(size).toList(growable: false);
      final updated =
          loadMore ? [...state.transactionEvents, ...pageItems] : pageItems;

      emit(
        state.copyWith(
          transactionEvents: updated,
          totalElements: totalElements,
          totalPages: totalPages,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<TransactionEvent?> getTransactionEventById(String id) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));

      String cleanId;
      if (id.contains(':')) {
        cleanId = id.split(':').last;
      } else {
        cleanId = id;
      }

      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(cleanId);

      final selected = isUuid
          ? await _service.getTransactionEventById(cleanId)
          : await _service.getTransactionEventByEventId(cleanId);

      emit(state.copyWith(loading: false, selectedEvent: selected));
      return selected;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      return null;
    }
  }

  Future<TransactionEvent> createAddTransactionEvent({
    required String bizTransactionType,
    required String bizTransactionId,
    required List<String> epcs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    required DateTime eventTime,
  }) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final newEvent = await _service.createAddTransactionEvent(
        bizTransactionType,
        bizTransactionId,
        epcs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        eventTime,
      );

      emit(
        state.copyWith(
          transactionEvents: [newEvent, ...state.transactionEvents],
          totalElements: state.totalElements + 1,
          loading: false,
        ),
      );
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<TransactionEvent> createDeleteTransactionEvent({
    required String bizTransactionType,
    required String bizTransactionId,
    required List<String> epcs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    required DateTime eventTime,
  }) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final newEvent = await _service.createDeleteTransactionEvent(
        bizTransactionType,
        bizTransactionId,
        epcs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        eventTime,
      );

      emit(
        state.copyWith(
          transactionEvents: [newEvent, ...state.transactionEvents],
          totalElements: state.totalElements + 1,
          loading: false,
        ),
      );
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<TransactionEvent> createObserveTransactionEvent({
    required String bizTransactionType,
    required String bizTransactionId,
    required List<String> epcs,
    required String locationGLN,
    required String businessStep,
    required String disposition,
    required Map<String, String> bizData,
    required DateTime eventTime,
  }) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final newEvent = await _service.createObserveTransactionEvent(
        bizTransactionType,
        bizTransactionId,
        epcs,
        locationGLN,
        businessStep,
        disposition,
        bizData,
        eventTime,
      );

      emit(
        state.copyWith(
          transactionEvents: [newEvent, ...state.transactionEvents],
          totalElements: state.totalElements + 1,
          loading: false,
        ),
      );
      return newEvent;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateTransactionEvent(TransactionEvent event) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final updatedEvent = await _service.updateTransactionEvent(event.id!, event);

      final index = state.transactionEvents.indexWhere((e) => e.id == event.id);
      final updatedEvents = [...state.transactionEvents];
      if (index != -1) {
        updatedEvents[index] = updatedEvent;
      }

      final selectedEvent =
          state.selectedEvent?.id == event.id ? updatedEvent : state.selectedEvent;

      emit(
        state.copyWith(
          transactionEvents: updatedEvents,
          selectedEvent: selectedEvent,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteTransactionEvent(String id) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      await _service.deleteTransactionEvent(id);

      final updated =
          state.transactionEvents.where((event) => event.id != id).toList(growable: false);

      emit(
        state.copyWith(
          transactionEvents: updated,
          totalElements: updated.length,
          clearSelectedEvent: state.selectedEvent?.id == id,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> findEventsByEPC(String epc) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final events = await _service.findTransactionEventsByEPC(epc);
      emit(
        state.copyWith(
          transactionEvents: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findEventsByBusinessStepAndEPC(String businessStep, String epc) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final events =
          await _service.findTransactionEventsByBusinessStepAndEPC(businessStep, epc);
      emit(
        state.copyWith(
          transactionEvents: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findActiveTransactionsForEPC(String epc) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final events = await _service.findActiveTransactionsForEPC(epc);
      emit(
        state.copyWith(
          transactionEvents: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> findTransactionHistoryForEPC(String epc) async {
    try {
      emit(state.copyWith(loading: true, clearError: true));
      final events = await _service.findTransactionHistoryForEPC(epc);
      emit(
        state.copyWith(
          transactionEvents: events,
          totalElements: events.length,
          totalPages: 1,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
