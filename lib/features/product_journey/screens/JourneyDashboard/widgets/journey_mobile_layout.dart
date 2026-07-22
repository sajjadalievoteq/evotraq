import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_error_view.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_mobile_bottom_sheet.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_recent_events_section.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_search_bar.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_sidebar_content.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_sidebar_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_suggestions_dropdown.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_event_filter_chips.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_pin_canvas.dart';

class JourneyMobileLayout extends StatelessWidget {
  const JourneyMobileLayout({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onSuggestionTap,
    required this.onRetry,
    required this.onStepTapped,
    required this.onRecentEventTap,
    this.onScanResult,
  });

  final JourneyState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearSearch;
  final ValueChanged<ProductSearchResult> onSuggestionTap;
  final VoidCallback onRetry;
  final ValueChanged<JourneyStep> onStepTapped;
  final ValueChanged<RecentEvent> onRecentEventTap;
  final ValueChanged<ScanResult>? onScanResult;

  @override
  Widget build(BuildContext context) {
    final loaded = state.isLoaded && state.journey != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(context.padding.top, context.padding.top, context.padding.top, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: searchController,
                builder: (context, _) => JourneySearchBar(
                  controller: searchController,
                  onSubmitted: onSearchSubmitted,
                  onChanged: onSearchChanged,
                  isSearching: state.isSearching,
                  onClear: onClearSearch,
                  onScanResult: onScanResult,
                  compactMargins: true,
                ),
              ),
              if (state.searchResults.isNotEmpty)
                JourneySuggestionsDropdown(
                  results: state.searchResults,
                  onTap: onSuggestionTap,
                ),
              if (loaded) ...[
                const SizedBox(height: TraqSpacing.sm),
                JourneyEventFilterChips(
                  selected: state.eventFilter,
                  onSelected: (filter) =>
                      context.read<JourneyCubit>().setEventFilter(filter),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              if (state.isLoading)
                const Positioned.fill(
                  child: JourneyCanvasSkeleton(includeHeader: false),
                ),
              if (loaded)
                Positioned.fill(
                  child: JourneyPinsCanvas(
                    journey: state.journey!,
                    selectedStep: state.selectedStep,
                    onStepTapped: onStepTapped,
                    eventFilter: state.eventFilter,
                  ),
                ),
              if (state.isLoading)
                DraggableScrollableSheet(
                  initialChildSize: 0.07,
                  minChildSize: 0.07,
                  maxChildSize: 1,
                  snap: true,
                  snapSizes: const [0.28, 0.55, 0.90],
                  builder: (context, scrollController) =>
                      JourneyMobileBottomSheet(
                    scrollController: scrollController,
                    child: const JourneySidebarSkeleton(),
                  ),
                ),
              if (loaded)
                DraggableScrollableSheet(

                  initialChildSize: 0.075,
                  minChildSize: 0.075,
                  maxChildSize: 1,
                  snap: true,
                  snapSizes: const [0.28, 0.55, 0.90],
                  builder: (context, scrollController) =>
                      JourneyMobileBottomSheet(
                    scrollController: scrollController,
                    child: JourneySidebarContent(journey: state.journey!),
                  ),
                ),
              if (!state.isLoaded && !state.isLoading)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: state.hasError
                          ? OperationListErrorView(
                              errorMessage:
                                  state.errorMessage ?? 'Unknown error',
                              onRetry: onRetry,
                            )
                          : state.searchResults.isNotEmpty
                              ? const SizedBox.shrink()
                              : JourneyRecentEventsSection(
                                  events: state.recentEvents,
                                  isLoading: state.recentEventsLoading,
                                  onEventTap: onRecentEventTap,
                                ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
