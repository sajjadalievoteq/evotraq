import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';

class AppDrawerAnimatedContent extends StatefulWidget {
  const AppDrawerAnimatedContent({super.key, required this.child});

  final Widget child;

  @override
  State<AppDrawerAnimatedContent> createState() =>
      AppDrawerAnimatedContentState();
}

class AppDrawerAnimatedContentState extends State<AppDrawerAnimatedContent>
    with SingleTickerProviderStateMixin {
  static const double _closedOpacity = 0.86;
  static const double _closedScale = 0.972;
  static const double _closedDx = 0.03;

  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _curved = CurvedAnimation(
      parent: _controller,
      curve: TraqAnimationConstants.curve,
      reverseCurve: TraqAnimationConstants.reverseCurve,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDurations();
    _bindRouteAnimation();
  }

  void _syncDurations() {
    _controller.duration = TraqAnimationManager.durationOf(
      context,
      TraqAnimationConstants.navForward,
    );
    _controller.reverseDuration = TraqAnimationManager.durationOf(
      context,
      TraqAnimationConstants.navReverse,
    );
  }

  void _bindRouteAnimation() {
    final routeAnimation = ModalRoute.of(context)?.animation;
    if (_routeAnimation == routeAnimation) {
      return;
    }
    _routeAnimation?.removeStatusListener(_onRouteStatusChanged);
    _routeAnimation = routeAnimation;
    if (_routeAnimation == null) {
      _controller.value = 1.0;
      return;
    }

    _controller.value = _routeAnimation!.value.clamp(0.0, 1.0);
    _routeAnimation!.addStatusListener(_onRouteStatusChanged);
  }

  void _onRouteStatusChanged(AnimationStatus status) {
    if (!mounted) {
      return;
    }
    switch (status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        _controller.forward();
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        _controller.reverse();
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatusChanged);
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (TraqAnimationManager.reduceMotion(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _curved,
      builder: (context, _) {
        final t = _curved.value.clamp(0.0, 1.0);
        final opacity = _closedOpacity + (1 - _closedOpacity) * t;
        final scale = _closedScale + (1 - _closedScale) * t;
        final dx = _closedDx * (1 - t);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx * MediaQuery.sizeOf(context).width, 0),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
