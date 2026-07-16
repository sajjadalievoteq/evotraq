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
    this.recentEvents = const [],
    this.recentEventsLoading = false,
  });

  final JourneyStatus status;
  final ProductJourney? journey;
  final List<ProductSearchResult> searchResults;
  final bool isSearching;
  final JourneyStep? selectedStep;
  final String? errorMessage;
  final JourneyEventFilter eventFilter;
  final List<RecentEvent> recentEvents;
  final bool recentEventsLoading;

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
    List<RecentEvent>? recentEvents,
    bool? recentEventsLoading,
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
      recentEvents: recentEvents ?? this.recentEvents,
      recentEventsLoading: recentEventsLoading ?? this.recentEventsLoading,
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
        recentEvents,
        recentEventsLoading,
      ];
}
