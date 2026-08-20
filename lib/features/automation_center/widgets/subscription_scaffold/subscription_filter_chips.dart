import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class SubscriptionFilterOption {
  const SubscriptionFilterOption({required this.label, required this.value});

  final String label;
  final String value;
}

/// Shared filter-chip row for subscription list screens.
///
/// Filter *logic* stays in [SubscriptionFilterUtils]; this widget only renders
/// the chip UI from a caller-supplied option list.
class SubscriptionFilterChips extends StatelessWidget {
  const SubscriptionFilterChips({
    super.key,
    required this.options,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<SubscriptionFilterOption> options;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TraqSpacing.sm,
      runSpacing: TraqSpacing.sm,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option.label),
            selected: selectedFilter == option.value,
            onSelected: (_) => onFilterSelected(option.value),
          ),
      ],
    );
  }
}
