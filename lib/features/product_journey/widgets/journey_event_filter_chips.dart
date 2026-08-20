import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_animated_filter_chip.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';

class JourneyEventFilterChips extends StatelessWidget {
  const JourneyEventFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final JourneyEventFilter selected;
  final ValueChanged<JourneyEventFilter> onSelected;

  static const _filters = JourneyEventFilter.values;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      color: c.surface.withValues(alpha: 0.9),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.md,
          vertical: TraqSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(TraqRadius.lg),
          border: Border.all(color: c.border.withValues(alpha: 0.7)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in _filters) ...[
                if (filter != _filters.first)
                  const SizedBox(width: TraqSpacing.sm),
                JourneyAnimatedFilterChip(
                  filter: filter,
                  isSelected: selected == filter,
                  onSelected: () => onSelected(filter),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
