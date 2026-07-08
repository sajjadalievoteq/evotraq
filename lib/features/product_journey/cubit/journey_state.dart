part of 'journey_cubit.dart';

const _unset = Object();

enum JourneyStatus { initial, loading, loaded, error }

class JourneyState extends Equatable {
  const JourneyState({
    this.status = JourneyStatus.initial,
    this.journey,
    this.searchResults = const [],
    this.isSearching = false,
    this.selectedStep,
    this.errorMessage,
    this.eventFilter = JourneyEventFilter.all,
  });

  final JourneyStatus status;
  final ProductJourney? journey;
  final List<ProductSearchResult> searchResults;
  final bool isSearching;
  final JourneyStep? selectedStep;
  final String? errorMessage;
  final JourneyEventFilter eventFilter;

  bool get isLoading => status == JourneyStatus.loading;
  bool get isLoaded => status == JourneyStatus.loaded;
  bool get hasError => status == JourneyStatus.error;

  JourneyState copyWith({
    JourneyStatus? status,
    Object? journey = _unset,
    List<ProductSearchResult>? searchResults,
    bool? isSearching,
    Object? selectedStep = _unset,
    Object? errorMessage = _unset,
    JourneyEventFilter? eventFilter,
  }) {
    return JourneyState(
      status: status ?? this.status,
      journey: identical(journey, _unset)
          ? this.journey
          : journey as ProductJourney?,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      selectedStep: identical(selectedStep, _unset)
          ? this.selectedStep
          : selectedStep as JourneyStep?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      eventFilter: eventFilter ?? this.eventFilter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        journey,
        searchResults,
        isSearching,
        selectedStep,
        errorMessage,
        eventFilter,
      ];
}
