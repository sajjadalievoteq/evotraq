import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';

class InboxOutboxFilterChips extends StatelessWidget {
  const InboxOutboxFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final InboxOutboxListFilter selected;
  final ValueChanged<InboxOutboxListFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: InboxOutboxListFilter.values.map((filter) {
          return FilterChip(
            selectedColor: context.colors.primary,
            label: Text(filter.label),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
          );
        }).toList(),
      ),
    );
  }
}
