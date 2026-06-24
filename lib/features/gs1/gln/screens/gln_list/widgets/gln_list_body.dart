import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_list/widgets/gln_record_info_section.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_list/widgets/gln_results_list.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';

class GlnListBody extends StatelessWidget {
  const GlnListBody({
    super.key,
    required this.searchController,
    required this.searchDebouncer,
    required this.scrollController,
    required this.pageSize,
    required this.selectedGlnCode,
    required this.sortOrder,
    required this.sortFieldLabel,
    required this.onSearchImmediate,
    required this.onSearchTextChanged,
    required this.onSearch,
    required this.onShowFilterDialog,
    required this.onShowAdvancedFiltersDialog,
    required this.onPageSizeChanged,
    required this.onToggleSortOrder,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onTapGln,
    required this.onRowMenuAction,
    required this.onLoadMore,
  });

  final TextEditingController searchController;
  final Gs1ListSearchDebouncer searchDebouncer;
  final ScrollController scrollController;
  final int pageSize;
  final String? selectedGlnCode;
  final String sortOrder;
  final String sortFieldLabel;
  final VoidCallback onSearchImmediate;
  final ValueChanged<String> onSearchTextChanged;
  final VoidCallback onSearch;
  final VoidCallback onShowFilterDialog;
  final VoidCallback onShowAdvancedFiltersDialog;
  final ValueChanged<int> onPageSizeChanged;
  final VoidCallback onToggleSortOrder;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onTapGln;
  final void Function(GLN gln, String action) onRowMenuAction;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Gs1MasterListBody(
      toolbar: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.horizontalPadding.left,
              right: context.horizontalPadding.left,
              top: context.horizontalPadding.left,
            ),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: searchController,
                  builder: (context, _) {
                    return Gs1ListSearchBar(
                      hintText: GlnUiConstants.listSearchHint,
                      controller: searchController,
                      showAdvancedFilters: false,
                      onSearch: onSearchImmediate,
                      onQueryChanged: onSearchTextChanged,
                      onRefresh: onSearchImmediate,
                      onQuickFilters: onShowFilterDialog,
                      onToggleAdvancedFilters: onShowAdvancedFiltersDialog,
                      onClear: () {
                        searchDebouncer.cancel();
                        searchController.clear();
                        onSearch();
                      },
                    );
                  },
                ),
                GlnRecordInfoSection(
                  pageSize: pageSize,
                  onPageSizeChanged: onPageSizeChanged,
                ),
                SizedBox(height: Constants.spacing),
                Gs1ListSortingControls(
                  label: GlnUiConstants.sortByLine(
                    sortFieldLabel,
                    sortOrder == 'asc'
                        ? GlnUiConstants.sortAscendingLabel
                        : GlnUiConstants.sortDescendingLabel,
                  ),
                  sortOrder: sortOrder,
                  onToggleSortOrder: onToggleSortOrder,
                ),
              ],
            ),
          ),
        ],
      ),
      results: GlnResultsList(
        scrollController: scrollController,
        selectedGlnCode: selectedGlnCode,
        onRefresh: onRefresh,
        onClearFilters: onClearFilters,
        onTapGln: onTapGln,
        onRowMenuAction: onRowMenuAction,
        onLoadMore: onLoadMore,
      ),
    );
  }
}
