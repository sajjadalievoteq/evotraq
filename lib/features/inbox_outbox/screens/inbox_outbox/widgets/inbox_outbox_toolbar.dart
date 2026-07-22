import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/widgets/inbox_outbox_filter_chips.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/widgets/inbox_outbox_filter_hint.dart';

class InboxOutboxToolbar extends StatelessWidget {
  const InboxOutboxToolbar({
    super.key,
    required this.searchController,
    required this.showFilterChips,
    required this.selectedFilter,
    required this.onRefresh,
    required this.onQueryChanged,
    required this.onClear,
    required this.onFilterSelected,
  });

  final TextEditingController searchController;
  final bool showFilterChips;
  final InboxOutboxListFilter selectedFilter;
  final VoidCallback onRefresh;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ValueChanged<InboxOutboxListFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
      child: Column(
        children: [
          Gs1ListSearchBar(
            hintText: 'Search in-transit shipments',
            controller: searchController,
            showAdvancedFilters: showFilterChips,
            showAdvancedFilterIcon: false,
            onSearch: onRefresh,
            onQueryChanged: onQueryChanged,
            onRefresh: onRefresh,
            onToggleAdvancedFilters: () {},
            onClear: onClear,
          ),
          if (showFilterChips) ...[
            const SizedBox(height: 12),
            InboxOutboxFilterChips(
              selected: selectedFilter,
              onSelected: onFilterSelected,
            ),
            InboxOutboxFilterHint(filter: selectedFilter),
          ],
        ],
      ),
    );
  }
}
