import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class SubscriptionManagementFilterChips extends StatelessWidget {
  const SubscriptionManagementFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TraqSpacing.sm,
      runSpacing: TraqSpacing.sm,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selectedFilter == 'all',
          onSelected: (_) => onFilterSelected('all'),
        ),
        FilterChip(
          label: const Text('Email Only'),
          selected: selectedFilter == 'email',
          onSelected: (_) => onFilterSelected('email'),
        ),
        FilterChip(
          label: const Text('Active'),
          selected: selectedFilter == 'active',
          onSelected: (_) => onFilterSelected('active'),
        ),
        FilterChip(
          label: const Text('Paused'),
          selected: selectedFilter == 'paused',
          onSelected: (_) => onFilterSelected('paused'),
        ),
      ],
    );
  }
}
