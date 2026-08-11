import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';

class TraqIconPop extends StatelessWidget {
  const TraqIconPop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (TraqAnimationManager.reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: TraqAnimationConstants.iconPopBeginScale, end: 1),
      duration: TraqAnimationConstants.status,
      curve: TraqAnimationConstants.curve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
