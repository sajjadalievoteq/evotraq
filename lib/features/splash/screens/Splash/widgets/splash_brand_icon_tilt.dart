import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SplashBrandIconTilt extends StatefulWidget {
  const SplashBrandIconTilt({super.key, required this.child});

  final Widget child;

  @override
  State<SplashBrandIconTilt> createState() => _SplashBrandIconTiltState();
}

class _SplashBrandIconTiltState extends State<SplashBrandIconTilt>
    with SingleTickerProviderStateMixin, TraqDeferredPlay {
  late final AnimationController _controller;
  late final Animation<double> _tilt;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TraqAnimationConstants.splashTiltCycle,
    );
    _tilt = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: TraqAnimationConstants.splashTiltAngle,
        ).chain(CurveTween(curve: TraqAnimationConstants.splashTiltOutCurve)),
        weight: TraqAnimationConstants.splashTiltOutDurationMs.toDouble(),
      ),
      TweenSequenceItem(
        tween:
            Tween<double>(
              begin: TraqAnimationConstants.splashTiltAngle,
              end: 0,
            ).chain(
              CurveTween(curve: TraqAnimationConstants.splashTiltReturnCurve),
            ),
        weight: TraqAnimationConstants.splashTiltReturnDurationMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: TraqAnimationConstants.splashTiltPauseMs.toDouble(),
      ),
    ]).animate(_controller);

    traqSchedulePlay(_startIfNeeded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!traqPlayStarted) traqSchedulePlay(_startIfNeeded);
  }

  void _startIfNeeded() {
    if (!mounted || traqPlayStarted) return;
    if (TraqAnimationManager.reduceMotion(context)) {
      _controller.value = 0;
      traqMarkPlayed();
      return;
    }
    traqMarkPlayed();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (TraqAnimationManager.reduceMotion(context)) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _tilt,
        child: widget.child,
        builder: (context, child) {
          return Transform.rotate(
            angle: _tilt.value,
            alignment: Alignment.bottomRight,
            child: child,
          );
        },
      ),
    );
  }
}
