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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? TraqAnimationConstants.formDuration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  @override
  void didUpdateWidget(covariant TraqFadeScaleEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.playEntrance && !_started) {
      _controller.value = 1;
    }
  }

  void _startIfNeeded() {
    if (!mounted || _started) return;
    if (!widget.playEntrance || TraqAnimationManager.reduceMotion(context)) {
      _controller.value = 1;
      _started = true;
      return;
    }
    _started = true;
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
        (!widget.playEntrance && !_started)) {
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
