import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_events_list/widgets/aggregation_events_results_list.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';

class AggregationEventsListBody extends StatelessWidget {
  const AggregationEventsListBody({
    super.key,
    required this.searchController,
    required this.showAdvancedFilters,
    required this.onSearchImmediate,
    required this.onSearchTextChanged,
    required this.onToggleAdvancedFilters,
    required this.onClearFilters,
    required this.onQuickFilters,
    required this.pageSize,
    required this.onPageSizeChanged,
    required this.scrollController,
    required this.selectedEventId,
    required this.onRefresh,
    required this.onTapEvent,
    required this.onLoadMore,
  });

  final TextEditingController searchController;
  final bool showAdvancedFilters;
  final VoidCallback onSearchImmediate;
  final ValueChanged<String> onSearchTextChanged;
  final VoidCallback onToggleAdvancedFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onQuickFilters;
  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;
  final ScrollController scrollController;
  final String? selectedEventId;
  final Future<void> Function() onRefresh;
  final ValueChanged<AggregationEvent> onTapEvent;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Gs1MasterListBody(
      toolbar: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.padding.top,
              context.padding.top,
              context.padding.top,
              0,
            ),
            child: BlocSelector<AggregationEventsCubit, AggregationEventsState,
                String>(
              selector: (state) => state.sortOrder,
              builder: (context, sortOrder) {
                return Gs1ListSearchBar(
                  hintText: AggregationEventUiConstants.searchHint,
                  controller: searchController,
                  showAdvancedFilters: showAdvancedFilters,
                  onSearch: onSearchImmediate,
                  onQueryChanged: onSearchTextChanged,
                  onToggleAdvancedFilters: onToggleAdvancedFilters,
                  onClear: onClearFilters,
                  onRefresh: onSearchImmediate,
                  onQuickFilters: onQuickFilters,
                  sortTooltip: AggregationEventUiConstants.sortLabelEventTime,
                  sortOrder: sortOrder.toLowerCase(),
                  onSortOrderChanged: (order) {
                    final cubit = context.read<AggregationEventsCubit>();
                    final target = order.toUpperCase();
                    if (cubit.state.sortOrder != target) {
                      cubit.toggleSortOrder();
                    }
                  },
                  pageSize: pageSize,
                  pageSizeOptions: AggregationEventUiConstants.pageSizeOptions,
                  onPageSizeChanged: onPageSizeChanged,
                );
              },
            ),
          ),
        ],
      ),
      results: AggregationEventsResultsList(
        scrollController: scrollController,
        selectedEventId: selectedEventId,
        onRefresh: onRefresh,
        onClearFilters: onClearFilters,
        onTapEvent: onTapEvent,
        onLoadMore: onLoadMore,
      ),
    );
  }
}
