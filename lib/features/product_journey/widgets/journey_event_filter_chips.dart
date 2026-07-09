import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_animation_constants.dart';
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
                if (filter != _filters.first) const SizedBox(width: TraqSpacing.sm),
                _AnimatedFilterChip(
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

/// A single filter chip that springs into its selected state and
/// bounces back when deselected — using a single AnimationController
/// that plays forward on select and reverses on deselect.
class _AnimatedFilterChip extends StatefulWidget {
  const _AnimatedFilterChip({
    required this.filter,
    required this.isSelected,
    required this.onSelected,
  });

  final JourneyEventFilter filter;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: JourneyAnimationConstants.filterChipBounce,
      // Start at 1.0 so chips aren't invisible on first build.
      value: 1.0,
    );
    // Dips to 0.88 at the midpoint then springs back to 1.0 via easeOutBack.
    // The controller drives 0→1 and the tween maps that to 0.88→1.0→1.08→1.0.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_AnimatedFilterChip old) {
    super.didUpdateWidget(old);
    if (!old.isSelected && widget.isSelected) {
      // Newly selected — play the press-and-spring sequence.
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScaleTransition(
      scale: _scale,
      child: FilterChip(
        label: Text(widget.filter.label),
        selected: widget.isSelected,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? c.onPrimary : c.textPrimary,
            ),
        selectedColor: c.primary,
        backgroundColor: c.surface,
        side: BorderSide(
          color: widget.isSelected ? c.primary : c.border,
        ),
        onSelected: (_) => widget.onSelected(),
      ),
    );
  }
}
