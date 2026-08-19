import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_fade_scale_transition.dart';

class TraqFadeScaleEntrance extends StatefulWidget {
  const TraqFadeScaleEntrance({
    super.key,
    required this.child,
    this.playEntrance = true,
    this.duration,
    this.beginScale = TraqAnimationConstants.formInitialScale,
  });

  final Widget child;
  final bool playEntrance;
  final Duration? duration;
  final double beginScale;

  @override
  State<TraqFadeScaleEntrance> createState() => _TraqFadeScaleEntranceState();
}

class _TraqFadeScaleEntranceState extends State<TraqFadeScaleEntrance>
    with SingleTickerProviderStateMixin, TraqDeferredPlay {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? TraqAnimationConstants.formDuration,
    );
    traqSchedulePlay(_startIfNeeded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!traqPlayStarted) traqSchedulePlay(_startIfNeeded);
  }

  @override
  void didUpdateWidget(covariant TraqFadeScaleEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.playEntrance && !traqPlayStarted) {
      _controller.value = 1;
      traqMarkPlayed();
    }
  }

  void _startIfNeeded() {
    if (!mounted || traqPlayStarted) return;
    if (!widget.playEntrance || TraqAnimationManager.reduceMotion(context)) {
      _controller.value = 1;
      traqMarkPlayed();
      return;
    }
    traqMarkPlayed();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (TraqAnimationManager.reduceMotion(context) ||
        (!widget.playEntrance && !traqPlayStarted)) {
      return widget.child;
    }
    return TraqFadeScaleTransition(
      child: widget.child,
      animation: _controller,
      beginScale: widget.beginScale,
      alignment: Alignment.topCenter,
    );
  }
}
