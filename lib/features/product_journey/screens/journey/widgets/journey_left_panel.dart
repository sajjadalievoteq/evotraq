import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_error_view.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_empty_state.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_product_details_content.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_search_bar.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_suggestions_dropdown.dart';

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
  });

  final JourneyState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearSearch;
  final ValueChanged<ProductSearchResult> onSuggestionTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          ),
        ),
        if (state.searchResults.isNotEmpty)
          JourneySuggestionsDropdown(
            results: state.searchResults,
            onTap: onSuggestionTap,
          ),
        if (state.isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state.isLoaded && state.journey != null)
          Expanded(
            child: SingleChildScrollView(
    padding: EdgeInsetsGeometry.only(left: context.padding.top,right: context.padding.top,top: 20),
              child: JourneyProductDetailsContent(journey: state.journey!),
            ),
          )
        else
          Expanded(
            child: state.hasError
                ? OperationListErrorView(
                    errorMessage: state.errorMessage ?? 'Unknown error',
                    onRetry: onRetry,
                  )
                : const JourneyEmptyState(),
          ),
      ],
    );
  }
}
