import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

class TraqModalTransition extends StatelessWidget {
  const TraqModalTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = CurvedAnimation(
      parent: animation,
      curve: TraqAnimationConstants.navCurve,
      reverseCurve: TraqAnimationConstants.navReverseCurve,
    );
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TraqAnimationConstants.navCurve,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.75).animate(secondary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.02),
        ).animate(secondary),
        child: FadeTransition(
          opacity: primary,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, TraqAnimationConstants.navModalDy),
              end: Offset.zero,
            ).animate(primary),
            child: child,
          ),
        ),
      ),
    );
  }
}
