import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_entrance_slide.dart';

class TraqStaggerItem extends StatelessWidget {
  const TraqStaggerItem({
    required this.fade,
    required this.motion,
    required this.scale,
    required this.slide,
    required this.risePx,
    required this.slidePx,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<double> motion;
  final Animation<double> scale;
  final TraqEntranceSlide slide;
  final double risePx;
  final double slidePx;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        alignment: Alignment.centerLeft,
        scale: scale,
        child: AnimatedBuilder(
          animation: motion,
          child: child,
          builder: (context, child) {
            final t = motion.value;
            final dx = slide == TraqEntranceSlide.fromRight
                ? slidePx * (1 - t)
                : 0.0;
            final dy = slide == TraqEntranceSlide.up ? risePx * (1 - t) : 0.0;
            return Transform.translate(offset: Offset(dx, dy), child: child);
          },
        ),
      ),
    );
  }
}
