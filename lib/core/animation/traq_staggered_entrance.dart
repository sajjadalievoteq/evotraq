import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';


enum TraqEntranceSlide {
  
  up,

  
  fromRight,
}


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
    return TraqAnimationManager.fadeScaleTransition(
      widget.child,
      _controller,
      beginScale: widget.beginScale,
      alignment: Alignment.topCenter,
    );
  }
}


class TraqStaggeredEntrance extends StatefulWidget {
  const TraqStaggeredEntrance({
    super.key,
    required this.children,
    this.stagger,
    this.duration,
    this.slide = TraqEntranceSlide.up,
    this.playEntrance = true,
    this.beginScale = TraqAnimationConstants.fieldInitialScale,
    this.risePx,
    this.slidePx,
  });

  final List<Widget> children;
  final Duration? stagger;
  final Duration? duration;
  final TraqEntranceSlide slide;
  final bool playEntrance;
  final double beginScale;
  final double? risePx;

  
  
  final double? slidePx;

  @override
  State<TraqStaggeredEntrance> createState() => _TraqStaggeredEntranceState();
}

class _TraqStaggeredEntranceState extends State<TraqStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  bool get _isBranding => widget.slide == TraqEntranceSlide.fromRight;

  Duration get _itemDuration =>
      widget.duration ??
      (_isBranding
          ? TraqAnimationConstants.brandingEntrance
          : TraqAnimationConstants.entrance);

  Duration get _stagger =>
      widget.stagger ??
      (_isBranding
          ? TraqAnimationConstants.brandingStagger
          : TraqAnimationConstants.staggerDelay);

  double get _risePx {
    if (widget.slide == TraqEntranceSlide.fromRight) {
      return widget.risePx ?? 0;
    }
    return widget.risePx ?? TraqAnimationConstants.fieldOffsetPx;
  }

  double _horizontalSlidePx(BoxConstraints constraints) {
    if (widget.slide != TraqEntranceSlide.fromRight) return 0;
    if (widget.slidePx != null) return widget.slidePx!;
    if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite) {
      return constraints.maxWidth;
    }
    return TraqAnimationConstants.brandingSlidePx;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  @override
  void didUpdateWidget(covariant TraqStaggeredEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playEntrance && !widget.playEntrance && !_started) {
      _controller.value = 1;
    }
  }

  Duration get _totalDuration {
    final n = widget.children.length;
    if (n <= 1) return _itemDuration;
    return _itemDuration + _stagger * (n - 1);
  }

  void _startIfNeeded() {
    if (!mounted || _started) return;

    if (TraqAnimationManager.reduceMotion(context)) {
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: widget.children,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalMs = _totalDuration.inMilliseconds.toDouble().clamp(1, 1e9);
        final itemMs = _itemDuration.inMilliseconds.toDouble();
        final staggerMs = _stagger.inMilliseconds.toDouble();
        final horizontalSlidePx = _horizontalSlidePx(constraints);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.children.length; i++)
                  _TraqStaggerItem(
                    animation: _controller,
                    begin: (i * staggerMs) / totalMs,
                    end: ((i * staggerMs) + itemMs) / totalMs,
                    slide: widget.slide,
                    beginScale: widget.beginScale,
                    risePx: _risePx,
                    slidePx: horizontalSlidePx,
                    child: widget.children[i],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TraqStaggerItem extends StatelessWidget {
  const _TraqStaggerItem({
    required this.animation,
    required this.begin,
    required this.end,
    required this.slide,
    required this.beginScale,
    required this.risePx,
    required this.slidePx,
    required this.child,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final TraqEntranceSlide slide;
  final double beginScale;
  final double risePx;
  final double slidePx;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t0 = begin.clamp(0.0, 1.0);
    final t1 = end.clamp(0.0, 1.0);
    final motion = CurvedAnimation(
      parent: animation,
      curve: Interval(t0, t1, curve: TraqAnimationConstants.curve),
    );
    final fadeEnd = (t0 +
            (t1 - t0) * TraqAnimationConstants.entranceFadePortion)
        .clamp(t0 + 0.01, t1);
    final fade = CurvedAnimation(
      parent: animation,
      curve: Interval(t0, fadeEnd, curve: TraqAnimationConstants.curve),
    );

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        alignment: Alignment.centerLeft,
        scale: Tween<double>(begin: beginScale, end: 1).animate(motion),
        child: AnimatedBuilder(
          animation: motion,
          builder: (context, child) {
            final t = motion.value;
            final dx = slide == TraqEntranceSlide.fromRight
                ? slidePx * (1 - t)
                : 0.0;
            final dy = slide == TraqEntranceSlide.up ? risePx * (1 - t) : 0.0;
            return Transform.translate(
              offset: Offset(dx, dy),
              child: child,
            );
          },
          child: child,
        ),
      ),
    );
  }
}


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
        return TraqAnimationManager.fadeRiseTransition(widget, animation);
      },
      child: KeyedSubtree(
        key: ValueKey(statusKey),
        child: child,
      ),
    );
  }
}


class TraqIconPop extends StatelessWidget {
  const TraqIconPop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (TraqAnimationManager.reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: TraqAnimationConstants.iconPopBeginScale,
        end: 1,
      ),
      duration: TraqAnimationConstants.status,
      curve: TraqAnimationConstants.curve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
