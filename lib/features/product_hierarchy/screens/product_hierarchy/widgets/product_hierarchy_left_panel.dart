import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel_body.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_search_header.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_suggestions_dropdown.dart';

class ProductHierarchyLeftPanel extends StatelessWidget {
  const ProductHierarchyLeftPanel({super.key, required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductHierarchyCubit, ProductHierarchyState>(
      builder: (context, state) {
        final cubit = context.read<ProductHierarchyCubit>();
        return ColoredBox(
          color: context.colors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListenableBuilder(
                listenable: searchController,
                builder: (context, _) => ProductHierarchySearchHeader(
                  controller: searchController,
                  onSubmitted: (value) => cubit.openHierarchy(value),
                  onChanged: cubit.searchSuggestions,
                  isSearching: state.isSearching,
                  onClear: () {
                    searchController.clear();
                    cubit.clear();
                  },
                  onScanResult: (ScanResult result) {
                    if (!result.isValid) return;
                    searchController.text = result.data;
                    cubit.openHierarchy(result.data);
                  },
                ),
              ),
              if (state.searchResults.isNotEmpty)
                Padding(
                  padding: context.horizontalPadding,
                  child: JourneySuggestionsDropdown(
                    results: state.searchResults,
                    onTap: (result) {
                      searchController.text = result.identifier;
                      cubit.selectSuggestion(result);
                    },
                  ),
                ),
              Expanded(
                child: ProductHierarchyLeftPanelBody(
                  state: state,
                  searchController: searchController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
