import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_state.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_search_header.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_content.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_skeleton.dart';
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
                    cubit.clearSuggestions();
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
                child: Builder(
                  builder: (context) {
                    if (state.isLoadingDetails) {
                      return const ProductHierarchySidebarSkeleton();
                    }
                    final journey = state.selectedJourney;
                    final root = state.root;
                    if (journey != null && root != null) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          context.padding.top,
                          15,
                          context.padding.top,
                          0,
                        ),
                        child: ProductHierarchySidebarContent(
                          root: root,
                          selectedEpc: state.selectedEpc ?? root.node.epc,
                          journey: journey,
                        ),
                      );
                    }
                    if ((state.detailsError ?? '').isNotEmpty) {
                      return AppEmptyDetail(
                        iconAsset: NavIcons.productHierarchy,
                        title: 'Unable to load node details',
                        subtitle: state.detailsError!,
                      );
                    }
                    return const AppEmptyDetail(
                      iconAsset: NavIcons.productHierarchy,
                      title: 'No node selected',
                      subtitle:
                          'Search an SSCC or SGTIN to inspect its packaging hierarchy.',
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
