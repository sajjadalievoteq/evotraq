import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

class TraqSharedAxisHorizontalTransition extends StatelessWidget {
  const TraqSharedAxisHorizontalTransition({
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
      reverseCurve: TraqAnimationConstants.navReverseCurve,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final enterDx = isRtl
        ? -TraqAnimationConstants.navSharedAxisDx
        : TraqAnimationConstants.navSharedAxisDx;
    final exitDx = isRtl
        ? TraqAnimationConstants.navSharedAxisOutgoingDx
        : -TraqAnimationConstants.navSharedAxisOutgoingDx;
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.55, curve: TraqAnimationConstants.navCurve),
      reverseCurve: const Interval(
        0.45,
        1,
        curve: TraqAnimationConstants.navReverseCurve,
      ),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.65).animate(secondary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(exitDx, 0),
        ).animate(secondary),
        child: FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(enterDx, 0),
              end: Offset.zero,
            ).animate(primary),
            child: child,
          ),
        ),
      ),
    );
  }
}
