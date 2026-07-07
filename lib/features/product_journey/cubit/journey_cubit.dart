import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';

part 'journey_state.dart';

class JourneyCubit extends Cubit<JourneyState> {
  JourneyCubit({required ProductJourneyService service})
      : _service = service,
        super(const JourneyState());

  final ProductJourneyService _service;

  void maybeSearch(String? identifier) {
    if (identifier != null && identifier.isNotEmpty) {
      search(identifier);
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
    ));
    try {
      final journey = await _service.getJourneyByEpc(identifier.trim());
      if (journey == null || journey.steps.isEmpty) {
        emit(state.copyWith(
          status: JourneyStatus.error,
          journey: null,
          errorMessage: 'No journey data found for "$identifier".',
        ));
      } else {
        emit(state.copyWith(
          status: JourneyStatus.loaded,
          journey: journey,
          errorMessage: null,
        ));
      }
    } catch (_) {
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
      emit(state.copyWith(isSearching: false, searchResults: results));
    } catch (_) {
      emit(state.copyWith(isSearching: false, searchResults: const []));
    }
  }

  void selectStep(JourneyStep? step) =>
      emit(state.copyWith(selectedStep: step));

  void clearSuggestions() => emit(state.copyWith(searchResults: const []));

  void clear() => emit(const JourneyState());
}
