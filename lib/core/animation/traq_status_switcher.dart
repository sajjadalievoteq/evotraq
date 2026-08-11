import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_fade_scale_transition.dart';

class TraqStatusSwitcher extends StatelessWidget {
  const TraqStatusSwitcher({
    super.key,
    required this.statusKey,
    required this.child,
  });

  final String statusKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = TraqAnimationManager.reduceMotion(context);
    final duration = TraqAnimationManager.durationOf(
      context,
      TraqAnimationConstants.status,
    );
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: TraqAnimationConstants.curve,
      switchOutCurve: TraqAnimationConstants.reverseCurve,
      transitionBuilder: (widget, animation) {
        if (reduce) return widget;
        return TraqFadeScaleTransition(
          animation: animation,
          beginScale: TraqAnimationConstants.statusInitialScale,
          alignment: Alignment.topCenter,
          child: widget,
        );
      },
      child: KeyedSubtree(key: ValueKey(statusKey), child: child),
    );
  }
}
