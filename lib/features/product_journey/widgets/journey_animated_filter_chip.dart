import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_animation_constants.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';

class JourneyAnimatedFilterChip extends StatefulWidget {
  const JourneyAnimatedFilterChip({
    required this.filter,
    required this.isSelected,
    required this.onSelected,
  });

  final JourneyEventFilter filter;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  State<JourneyAnimatedFilterChip> createState() =>
      JourneyAnimatedFilterChipState();
}

class JourneyAnimatedFilterChipState extends State<JourneyAnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: JourneyAnimationConstants.filterChipBounce,

      value: 1.0,
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.88,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.88,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(JourneyAnimatedFilterChip old) {
    super.didUpdateWidget(old);
    if (!old.isSelected && widget.isSelected) {
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
        side: BorderSide(color: widget.isSelected ? c.primary : c.border),
        onSelected: (_) => widget.onSelected(),
      ),
    );
  }
}
