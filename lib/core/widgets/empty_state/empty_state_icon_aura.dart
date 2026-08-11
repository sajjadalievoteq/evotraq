import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class EmptyStateIconAura extends StatelessWidget {
  const EmptyStateIconAura({
    required this.iconAsset,
    required this.size,
    this.breath,
  });

  final String iconAsset;
  final double size;
  final Animation<double>? breath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ring = size * 1.7;

    Widget aura = Container(
      width: ring,
      height: ring,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.14),
            scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            scheme.surface.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      alignment: Alignment.center,
      child: TraqIcon(
        iconAsset,
        size: size,
        color: scheme.primary.withValues(alpha: 0.85),
      ),
    );

    if (breath == null) return aura;

    return AnimatedBuilder(
      animation: breath!,
      builder: (context, child) {
        final t = breath!.value;
        final scale = 1.0 + (t * 0.03);
        final opacity = 0.92 + (t * 0.08);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: aura,
    );
  }
}
