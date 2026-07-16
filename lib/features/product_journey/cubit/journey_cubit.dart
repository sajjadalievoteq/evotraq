import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';

part 'journey_state.dart';

class JourneyCubit extends Cubit<JourneyState> {
  JourneyCubit({
    required ProductJourneyService service,
    required DashboardService dashboardService,
  })  : _service = service,
        _dashboardService = dashboardService,
        super(const JourneyState());

  final ProductJourneyService _service;
  final DashboardService _dashboardService;
  bool _recentEventsRequested = false;

  void maybeSearch(String? identifier) {
    if (identifier != null && identifier.isNotEmpty) {
      search(identifier);
    }
  }

  /// Loads up to 10 recent events for the initial empty panel (once).
  Future<void> loadRecentEvents() async {
    if (_recentEventsRequested) return;
    if (state.isLoaded || state.isLoading) return;
    if (state.recentEvents.isNotEmpty) return;

    _recentEventsRequested = true;
    emit(state.copyWith(recentEventsLoading: true));
    try {
      final events =
          await _dashboardService.getRecentEvents(limit: 10);
      if (isClosed) return;
      // Ignore results if a journey search already took over.
      if (state.isLoaded || state.isLoading) {
        emit(state.copyWith(recentEventsLoading: false));
        return;
      }
      emit(state.copyWith(
        recentEvents: events.take(10).toList(growable: false),
        recentEventsLoading: false,
      ));
    } catch (e, stackTrace) {
      debugPrint('[JourneyCubit] loadRecentEvents failed: $e\n$stackTrace');
      if (isClosed) return;
      emit(state.copyWith(
        recentEvents: const [],
        recentEventsLoading: false,
      ));
    }
  }

  Future<void> search(String identifier) async {
    if (identifier.trim().isEmpty) return;
    emit(state.copyWith(
      status: JourneyStatus.loading,
      journey: null,
      selectedStep: null,
      errorMessage: null,
      searchResults: const [],
      eventFilter: JourneyEventFilter.all,
    ));
    try {
      final journey = await _service.getJourneyByIdentifier(identifier.trim());
      if (isClosed) return;
      if (journey == null || journey.steps.isEmpty) {
        emit(state.copyWith(
          status: JourneyStatus.error,
          journey: null,
          errorMessage:
              'No journey data found for "$identifier". Try a full SGTIN, SSCC, or EPC URI.',
        ));
      } else {
        emit(state.copyWith(
          status: JourneyStatus.loaded,
          journey: journey,
          errorMessage: null,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('[JourneyCubit] search failed: $e\n$stackTrace');
      if (isClosed) return;
      emit(state.copyWith(
        status: JourneyStatus.error,
        journey: null,
        errorMessage: 'Failed to load journey. Check your connection.',
      ));
    }
  }

  Future<void> searchSuggestions(String query) async {
    if (query.length < 3) {
      emit(state.copyWith(searchResults: const []));
      return;
    }
    emit(state.copyWith(isSearching: true));
    try {
      final results = await _service.searchProducts(query);
      if (isClosed) return;
      emit(state.copyWith(isSearching: false, searchResults: results));
    } catch (e, stackTrace) {
      debugPrint('[JourneyCubit] searchSuggestions failed: $e\n$stackTrace');
      if (isClosed) return;
      emit(state.copyWith(isSearching: false, searchResults: const []));
    }
  }

  void selectStep(JourneyStep? step) =>
      emit(state.copyWith(selectedStep: step));

  void setEventFilter(JourneyEventFilter filter) =>
      emit(state.copyWith(eventFilter: filter));

  void clearSuggestions() => emit(state.copyWith(searchResults: const []));

  void clear() {
    final recent = state.recentEvents;
    emit(JourneyState(recentEvents: recent));
    if (recent.isEmpty) {
      _recentEventsRequested = false;
      loadRecentEvents();
    }
  }
}
