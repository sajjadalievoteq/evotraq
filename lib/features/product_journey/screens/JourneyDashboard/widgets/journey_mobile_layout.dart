import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_error_view.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_empty_state.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_mobile_bottom_sheet.dart';
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
  final ValueChanged<ScanResult>? onScanResult;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Stack(
      children: [
        if (state.isLoading)
          const Positioned.fill(child: JourneyCanvasSkeleton()),
        if (state.isLoaded && state.journey != null)
          Positioned.fill(
            child: Stack(
              children: [
                JourneyPinsCanvas(
                  journey: state.journey!,
                  selectedStep: state.selectedStep,
                  onStepTapped: onStepTapped,
                  eventFilter: state.eventFilter,
                ),
                Positioned(
                  top: 72,
                  left: 16,
                  right: 16,
                  child: JourneyEventFilterChips(
                    selected: state.eventFilter,
                    onSelected: (filter) =>
                        context.read<JourneyCubit>().setEventFilter(filter),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          top: 8,
          left: 16,
          right: 16,
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
                ),
              ),
              if (state.searchResults.isNotEmpty)
                JourneySuggestionsDropdown(
                  results: state.searchResults,
                  onTap: onSuggestionTap,
                ),
            ],
          ),
        ),
        if (state.isLoading)
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.18,
            maxChildSize: 0.90,
            builder: (context, scrollController) => JourneyMobileBottomSheet(
              scrollController: scrollController,
              child: const JourneySidebarSkeleton(),
            ),
          ),
        if (state.isLoaded && state.journey != null)
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.10,
            maxChildSize: 0.75,
            builder: (context, scrollController) => JourneyMobileBottomSheet(
              scrollController: scrollController,
              child: JourneySidebarContent(journey: state.journey!),
            ),
          ),
        if (!state.isLoaded && !state.isLoading)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: state.hasError
                      ? OperationListErrorView(
                          errorMessage: state.errorMessage ?? 'Unknown error',
                          onRetry: onRetry,
                        )
                      : const JourneyEmptyState(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
