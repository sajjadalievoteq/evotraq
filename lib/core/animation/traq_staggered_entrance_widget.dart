import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/animation/traq_entrance_slide.dart';
import 'package:traqtrace_app/core/animation/traq_stagger_item.dart';

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
  _StaggerSlot({required this.motion, required this.fade, required this.scale});

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
    // Cap travel â€” full-panel-width slides are expensive and feel sluggish.
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

    final timingChanged =
        oldWidget.duration != widget.duration ||
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
      final fadeEnd =
          (t0 + (t1 - t0) * TraqAnimationConstants.entranceFadePortion).clamp(
            t0 + 0.01,
            t1,
          );

      final motion = CurvedAnimation(
        parent: _controller,
        curve: Interval(t0, t1, curve: TraqAnimationConstants.curve),
      );
      final fade = CurvedAnimation(
        parent: _controller,
        curve: Interval(t0, fadeEnd, curve: TraqAnimationConstants.curve),
      );
      final scale = Tween<double>(
        begin: widget.beginScale,
        end: 1,
      ).animate(motion);

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
              TraqStaggerItem(
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
