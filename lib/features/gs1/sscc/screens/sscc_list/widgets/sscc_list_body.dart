import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_list/widgets/sscc_results_list.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';

class SsccListBody extends StatelessWidget {
  const SsccListBody({
    super.key,
    required this.searchController,
    required this.searchDebouncer,
    required this.scrollController,
    required this.pageSize,
    required this.selectedSsccCode,
    required this.showAdvancedFilters,
    required this.sortLabel,
    required this.sortDirection,
    required this.onSearchImmediate,
    required this.onSearchTextChanged,
    required this.onSearch,
    required this.onShowFilterDialog,
    required this.onShowAdvancedFiltersDialog,
    required this.onPageSizeChanged,
    required this.onSortOrderChanged,
    required this.onRefresh,
    required this.onClearFilters,
    required this.hasActiveFilters,
    this.onCreate,
    required this.onTapSscc,
    required this.onRowMenuAction,
    required this.onLoadMore,
  });

  final TextEditingController searchController;
  final Gs1ListSearchDebouncer searchDebouncer;
  final ScrollController scrollController;
  final int pageSize;
  final String? selectedSsccCode;
  final bool showAdvancedFilters;
  final String sortLabel;
  final String sortDirection;
  final VoidCallback onSearchImmediate;
  final ValueChanged<String> onSearchTextChanged;
  final VoidCallback onSearch;
  final VoidCallback onShowFilterDialog;
  final VoidCallback onShowAdvancedFiltersDialog;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<String> onSortOrderChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;
  final VoidCallback? onCreate;
  final ValueChanged<String> onTapSscc;
  final void Function(SSCC sscc, String action) onRowMenuAction;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Gs1MasterListBody(
      toolbar: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: context.padding.left,
              left: context.padding.left,
              right: context.padding.left,
            ),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: searchController,
                  builder: (context, _) {
                    return Gs1ListSearchBar(
                      hintText: SsccUiConstants.listSearchHint,
                      controller: searchController,
                      showAdvancedFilters: showAdvancedFilters,
                      onSearch: onSearchImmediate,
                      onQueryChanged: onSearchTextChanged,
                      onRefresh: onSearchImmediate,
                      onQuickFilters: onShowFilterDialog,
                      onToggleAdvancedFilters: onShowAdvancedFiltersDialog,
                      sortTooltip: sortLabel,
                      sortOrder: sortDirection.toLowerCase(),
                      onSortOrderChanged: onSortOrderChanged,
                      pageSize: pageSize,
                      pageSizeOptions: SsccUiConstants.pageSizeOptions,
                      onPageSizeChanged: onPageSizeChanged,
                      onClear: () {
                        searchDebouncer.cancel();
                        searchController.clear();
                        onSearch();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      results: SsccResultsList(
        scrollController: scrollController,
        selectedSsccCode: selectedSsccCode,
        onRefresh: onRefresh,
        onClearFilters: onClearFilters,
        hasActiveFilters: hasActiveFilters,
        onCreate: onCreate,
        onTapSscc: onTapSscc,
        onRowMenuAction: onRowMenuAction,
        onLoadMore: onLoadMore,
      ),
    );
  }
}
