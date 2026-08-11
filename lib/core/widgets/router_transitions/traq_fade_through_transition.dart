import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

class TraqFadeThroughTransition extends StatelessWidget {
  const TraqFadeThroughTransition({
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
    final incoming = CurvedAnimation(
      parent: animation,
      curve: TraqAnimationConstants.navCurve,
      reverseCurve: TraqAnimationConstants.navReverseCurve,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TraqAnimationConstants.navCurve,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final enterDx = isRtl
        ? -TraqAnimationConstants.navSharedAxisDx
        : TraqAnimationConstants.navSharedAxisDx;
    final exitDx = isRtl
        ? TraqAnimationConstants.navSharedAxisOutgoingDx
        : -TraqAnimationConstants.navSharedAxisOutgoingDx;
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(outgoing),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(exitDx, 0),
        ).animate(outgoing),
        child: FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(enterDx, 0),
              end: Offset.zero,
            ).animate(incoming),
            child: child,
          ),
        ),
      ),
    );
  }
}
