import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_list/widgets/gtin_results_list.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';

class GtinListBody extends StatelessWidget {
  const GtinListBody({
    super.key,
    required this.searchController,
    required this.searchDebouncer,
    required this.scrollController,
    required this.pageSize,
    required this.selectedGtinCode,
    required this.onSearchImmediate,
    required this.onSearchTextChanged,
    required this.onSearch,
    required this.onShowFilterDialog,
    required this.onShowAdvancedFiltersDialog,
    required this.onPageSizeChanged,
    required this.onRefresh,
    required this.onClearFilters,
    required this.hasActiveFilters,
    this.onCreate,
    required this.onTapGtin,
    required this.onLoadMore,
  });

  final TextEditingController searchController;
  final Gs1ListSearchDebouncer searchDebouncer;
  final ScrollController scrollController;
  final int pageSize;
  final String? selectedGtinCode;
  final VoidCallback onSearchImmediate;
  final ValueChanged<String> onSearchTextChanged;
  final VoidCallback onSearch;
  final VoidCallback onShowFilterDialog;
  final VoidCallback onShowAdvancedFiltersDialog;
  final ValueChanged<int> onPageSizeChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;
  final VoidCallback? onCreate;
  final ValueChanged<String> onTapGtin;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Gs1MasterListBody(
      toolbar: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: context.padding.left,
              right: context.padding.left,
              left: context.padding.left,
            ),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: searchController,
                  builder: (context, _) {
                    return BlocBuilder<GTINCubit, GTINState>(
                      buildWhen: (prev, current) =>
                          prev.gtinListSortAscending !=
                          current.gtinListSortAscending,
                      builder: (context, cubitState) {
                        return Gs1ListSearchBar(
                          hintText: GtinUiConstants.listSearchHint,
                          controller: searchController,
                          showAdvancedFilters: false,
                          onSearch: onSearchImmediate,
                          onQueryChanged: onSearchTextChanged,
                          onRefresh: onSearchImmediate,
                          onQuickFilters: onShowFilterDialog,
                          onToggleAdvancedFilters: onShowAdvancedFiltersDialog,
                          sortTooltip: GtinUiConstants.sortByProductNameLine(
                            cubitState.gtinListSortAscending,
                          ),
                          sortOrder: cubitState.gtinListSortAscending
                              ? 'asc'
                              : 'desc',
                          onSortOrderChanged: (order) {
                            final ascending = order == 'asc';
                            if (cubitState.gtinListSortAscending != ascending) {
                              context
                                  .read<GTINCubit>()
                                  .toggleGtinListProductNameSort();
                            }
                          },
                          pageSize: pageSize,
                          pageSizeOptions: GtinUiConstants.pageSizeOptions,
                          onPageSizeChanged: onPageSizeChanged,
                          onClear: () {
                            searchDebouncer.cancel();
                            searchController.clear();
                            onSearch();
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      results: GtinResultsList(
        scrollController: scrollController,
        selectedGtinCode: selectedGtinCode,
        onRefresh: onRefresh,
        onClearFilters: onClearFilters,
        hasActiveFilters: hasActiveFilters,
        onCreate: onCreate,
        onTapGtin: onTapGtin,
        onLoadMore: onLoadMore,
      ),
    );
  }
}
