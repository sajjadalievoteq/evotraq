import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_error_view.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_recent_events_section.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_search_bar.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_sidebar_content.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_sidebar_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_suggestions_dropdown.dart';

class JourneyLeftPanel extends StatelessWidget {
  const JourneyLeftPanel({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onSuggestionTap,
    required this.onRetry,
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
  final ValueChanged<RecentEvent> onRecentEventTap;
  final ValueChanged<ScanResult>? onScanResult;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ColoredBox(
      color: c.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            Padding(
              padding: context.horizontalPadding,
              child: JourneySuggestionsDropdown(
                results: state.searchResults,
                onTap: onSuggestionTap,
              ),
            ),
          if (state.isLoading)
            const Expanded(child: JourneySidebarSkeleton())
          else if (state.isLoaded && state.journey != null)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.padding.top,
                  15,
                  context.padding.top,
                  0,
                ),
                child: JourneySidebarContent(journey: state.journey!),
              ),
            )
          else if (state.hasError)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TraqSpacing.lg),
                child: OperationListErrorView(
                  errorMessage: state.errorMessage ?? 'Unknown error',
                  onRetry: onRetry,
                ),
              ),
            )
          else if (state.searchResults.isEmpty)
            Expanded(
              child: JourneyRecentEventsSection(
                events: state.recentEvents,
                isLoading: state.recentEventsLoading,
                onEventTap: onRecentEventTap,
              ),
            ),
        ],
      ),
    );
  }
}
