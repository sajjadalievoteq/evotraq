import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_animation_constants.dart';

class JourneyAnimatedPin extends StatefulWidget {
  const JourneyAnimatedPin({
    super.key,
    required this.index,
    required this.totalCount,
    required this.entranceCtrl,
    required this.dimmed,
    required this.child,
    this.startOffset = JourneyAnimationConstants.pinStaggerStartOffset,
  });
  final int index;
  final int totalCount;
  final AnimationController entranceCtrl;
  final bool dimmed;
  final Widget child;
  final double startOffset;

  @override
  State<JourneyAnimatedPin> createState() => _JourneyAnimatedPinState();
}

class _JourneyAnimatedPinState extends State<JourneyAnimatedPin>
    with SingleTickerProviderStateMixin {
  late CurvedAnimation _curve;
  late final AnimationController _filterBounceCtrl;
  late final Animation<double> _filterBounceScale;

  @override
  void initState() {
    super.initState();
    _curve = _buildCurve();
    _filterBounceCtrl = AnimationController(
      vsync: this,
      duration: JourneyAnimationConstants.pinFilterBounce,
    )..value = 1.0;
    _filterBounceScale = CurvedAnimation(
      parent: _filterBounceCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(JourneyAnimatedPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.totalCount != widget.totalCount ||
        oldWidget.startOffset != widget.startOffset ||
        oldWidget.entranceCtrl != widget.entranceCtrl) {
      _curve.dispose();
      _curve = _buildCurve();
    }
    if (oldWidget.dimmed && !widget.dimmed) {
      _filterBounceCtrl.forward(from: 0.0);
    }
  }

  CurvedAnimation _buildCurve() {
    final available = 1.0 - widget.startOffset;
    final step = widget.totalCount > 1
        ? available / widget.totalCount
        : available;
    final start = (widget.startOffset + widget.index * step).clamp(
      0.0,
      JourneyAnimationConstants.pinStaggerMaxStart,
    );
    final end = (start + JourneyAnimationConstants.pinStaggerWindow).clamp(
      start + 0.01,
      1.0,
    );
    return CurvedAnimation(
      parent: widget.entranceCtrl,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _filterBounceCtrl.dispose();
    _curve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: ScaleTransition(
        scale: _curve,
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          opacity: widget.dimmed ? 0.22 : 1.0,
          duration: JourneyAnimationConstants.pinFilterDim,
          curve: Curves.easeInOut,
          child: ScaleTransition(
            scale: _filterBounceScale,
            alignment: Alignment.bottomCenter,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
