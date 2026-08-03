import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class NotificationCenterFilterChips extends StatelessWidget {
  const NotificationCenterFilterChips({
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
          label: const Text('All subscriptions'),
          selected: selectedFilter == 'all',
          onSelected: (_) => onFilterSelected('all'),
        ),
        FilterChip(
          label: const Text('With deliveries'),
          selected: selectedFilter == 'activity',
          onSelected: (_) => onFilterSelected('activity'),
        ),
        FilterChip(
          label: const Text('Active only'),
          selected: selectedFilter == 'active',
          onSelected: (_) => onFilterSelected('active'),
        ),
      ],
    );
  }
}
