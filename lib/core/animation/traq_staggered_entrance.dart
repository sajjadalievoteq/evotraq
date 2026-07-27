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

  /// Horizontal travel for [TraqEntranceSlide.fromRight]. When null, uses the
  /// layout width (branding) or [TraqAnimationConstants.brandingSlidePx].
  final double? slidePx;

  @override
  State<TraqStaggeredEntrance> createState() => _TraqStaggeredEntranceState();
}

class _StaggerSlot {
  _StaggerSlot({
    required this.motion,
    required this.fade,
    required this.scale,
  });

  final CurvedAnimation motion;
  final CurvedAnimation fade;
  final Animation<double> scale;

  void dispose() {
    motion.dispose();
    fade.dispose();
  }
}

class _TraqStaggeredEntranceState extends State<TraqStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_StaggerSlot> _slots = const [];
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
    // Cap travel — full-panel-width slides are expensive and feel sluggish.
    if (widget.slidePx != null) return widget.slidePx!;
    return TraqAnimationConstants.brandingSlidePx;
  }

  Duration get _totalDuration {
    final n = widget.children.length;
    if (n <= 1) return _itemDuration;
    return _itemDuration + _stagger * (n - 1);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);
    _rebuildSlots();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  @override
  void didUpdateWidget(covariant TraqStaggeredEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);

    final timingChanged = oldWidget.duration != widget.duration ||
        oldWidget.stagger != widget.stagger ||
        oldWidget.slide != widget.slide ||
        oldWidget.beginScale != widget.beginScale ||
        oldWidget.children.length != widget.children.length;

    if (timingChanged) {
      _controller.duration = _totalDuration;
      _rebuildSlots();
    }

    if (oldWidget.playEntrance && !widget.playEntrance && !_started) {
      _controller.value = 1;
    }
  }

  void _rebuildSlots() {
    for (final slot in _slots) {
      slot.dispose();
    }

    final n = widget.children.length;
    if (n == 0) {
      _slots = const [];
      return;
    }

    final totalMs = _totalDuration.inMilliseconds.toDouble().clamp(1, 1e9);
    final itemMs = _itemDuration.inMilliseconds.toDouble();
    final staggerMs = _stagger.inMilliseconds.toDouble();

    _slots = List<_StaggerSlot>.generate(n, (i) {
      final t0 = ((i * staggerMs) / totalMs).clamp(0.0, 1.0);
      final t1 = (((i * staggerMs) + itemMs) / totalMs).clamp(0.0, 1.0);
      final fadeEnd = (t0 +
              (t1 - t0) * TraqAnimationConstants.entranceFadePortion)
          .clamp(t0 + 0.01, t1);

      final motion = CurvedAnimation(
        parent: _controller,
        curve: Interval(t0, t1, curve: TraqAnimationConstants.curve),
      );
      final fade = CurvedAnimation(
        parent: _controller,
        curve: Interval(t0, fadeEnd, curve: TraqAnimationConstants.curve),
      );
      final scale =
          Tween<double>(begin: widget.beginScale, end: 1).animate(motion);

      return _StaggerSlot(motion: motion, fade: fade, scale: scale);
    }, growable: false);
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
    for (final slot in _slots) {
      slot.dispose();
    }
    _slots = const [];
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

    // No outer AnimatedBuilder: FadeTransition / ScaleTransition listen to the
    // cached slot animations so the Column and children are not rebuilt every tick.
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalSlidePx = _horizontalSlidePx(constraints);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _TraqStaggerItem(
                fade: _slots[i].fade,
                motion: _slots[i].motion,
                scale: _slots[i].scale,
                slide: widget.slide,
                risePx: _risePx,
                slidePx: horizontalSlidePx,
                child: widget.children[i],
              ),
          ],
        );
      },
    );
  }
}

class _TraqStaggerItem extends StatelessWidget {
  const _TraqStaggerItem({
    required this.fade,
    required this.motion,
    required this.scale,
    required this.slide,
    required this.risePx,
    required this.slidePx,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<double> motion;
  final Animation<double> scale;
  final TraqEntranceSlide slide;
  final double risePx;
  final double slidePx;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        alignment: Alignment.centerLeft,
        scale: scale,
        child: AnimatedBuilder(
          animation: motion,
          child: child,
          builder: (context, child) {
            final t = motion.value;
            final dx =
                slide == TraqEntranceSlide.fromRight ? slidePx * (1 - t) : 0.0;
            final dy = slide == TraqEntranceSlide.up ? risePx * (1 - t) : 0.0;
            return Transform.translate(
              offset: Offset(dx, dy),
              child: child,
            );
          },
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
