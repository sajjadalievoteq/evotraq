import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';

class TraqIconPop extends StatefulWidget {
  const TraqIconPop({super.key, required this.child});

  final Widget child;

  @override
  State<TraqIconPop> createState() => _TraqIconPopState();
}

class _TraqIconPopState extends State<TraqIconPop> with TraqDeferredPlay {
  bool _play = false;

  @override
  void initState() {
    super.initState();
    traqSchedulePlay(_enable);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!traqPlayStarted) traqSchedulePlay(_enable);
  }

  void _enable() {
    if (!mounted || traqPlayStarted) return;
    traqMarkPlayed();
    if (TraqAnimationManager.reduceMotion(context)) return;
    setState(() => _play = true);
  }

  @override
  Widget build(BuildContext context) {
    if (TraqAnimationManager.reduceMotion(context)) {
      return widget.child;
    }
    if (!_play) {
      return Transform.scale(
        scale: TraqAnimationConstants.iconPopBeginScale,
        child: widget.child,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: TraqAnimationConstants.iconPopBeginScale, end: 1),
      duration: TraqAnimationConstants.status,
      curve: TraqAnimationConstants.curve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: widget.child,
    );
  }
}
