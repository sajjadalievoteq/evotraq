import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/widgets/object_event_record_info_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/widgets/object_events_results_list.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';

class ObjectEventsListBody extends StatelessWidget {
  const ObjectEventsListBody({
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
  final ValueChanged<ObjectEvent> onTapEvent;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObjectEventsCubit, ObjectEventsState>(
      buildWhen: (prev, curr) => prev.sortOrder != curr.sortOrder,
      builder: (context, state) {
        final toolbar = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.padding.top,
                context.padding.top,
                context.padding.top,
                0,
              ),
              child: Gs1ListSearchBar(
                hintText: ObjectEventListUiConstants.searchHint,
                controller: searchController,
                showAdvancedFilters: showAdvancedFilters,
                onSearch: onSearchImmediate,
                onQueryChanged: onSearchTextChanged,
                onToggleAdvancedFilters: onToggleAdvancedFilters,
                onClear: onClearFilters,
                onRefresh: onSearchImmediate,
                onQuickFilters: onQuickFilters,
              ),
            ),
            const SizedBox(height: Constants.spacing),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.padding.top,
                0,
                context.padding.top,
                0,
              ),
              child: ObjectEventRecordInfoSection(
                pageSize: pageSize,
                onPageSizeChanged: onPageSizeChanged,
              ),
            ),
            const SizedBox(height: Constants.spacing),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.padding.top,
                0,
                context.padding.top,
                0,
              ),
              child: Gs1ListSortingControls(
                label: ObjectEventListUiConstants.sortLabelEventTime,
                sortOrder: state.sortOrder.toLowerCase(),
                onToggleSortOrder: () =>
                    context.read<ObjectEventsCubit>().toggleSortOrder(),
              ),
            ),
          ],
        );

        final results = ObjectEventsResultsList(
          scrollController: scrollController,
          selectedEventId: selectedEventId,
          onRefresh: onRefresh,
          onClearFilters: onClearFilters,
          onTapEvent: onTapEvent,
          onLoadMore: onLoadMore,
        );

        return Gs1MasterListBody(toolbar: toolbar, results: results);
      },
    );
  }
}
