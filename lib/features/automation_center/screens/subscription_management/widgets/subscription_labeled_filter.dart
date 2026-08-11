import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_filter_chips.dart';

class SubscriptionLabeledFilter extends StatelessWidget {
  const SubscriptionLabeledFilter({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final List<SubscriptionFilterOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TraqSpacing.sm,
      runSpacing: TraqSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          label,
          style: context.text.bodySm.copyWith(
            color: context.colors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        SubscriptionFilterChips(
          options: options,
          selectedFilter: selected,
          onFilterSelected: onSelected,
        ),
      ],
    );
  }
}
