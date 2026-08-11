import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

class TraqFadeScaleTransition extends StatefulWidget {
  const TraqFadeScaleTransition({
    super.key,
    required this.animation,
    required this.beginScale,
    required this.alignment,
    required this.child,
  });

  final Animation<double> animation;
  final double beginScale;
  final Alignment alignment;
  final Widget child;

  @override
  State<TraqFadeScaleTransition> createState() =>
      _TraqFadeScaleTransitionState();
}

class _TraqFadeScaleTransitionState extends State<TraqFadeScaleTransition> {
  late CurvedAnimation _curved;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _configureAnimations();
  }

  @override
  void didUpdateWidget(TraqFadeScaleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.beginScale != widget.beginScale) {
      _curved.dispose();
      _configureAnimations();
    }
  }

  void _configureAnimations() {
    _curved = CurvedAnimation(
      parent: widget.animation,
      curve: TraqAnimationConstants.curve,
      reverseCurve: TraqAnimationConstants.reverseCurve,
    );
    _scale = Tween<double>(begin: widget.beginScale, end: 1).animate(_curved);
  }

  @override
  void dispose() {
    _curved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: ScaleTransition(
        scale: _scale,
        alignment: widget.alignment,
        child: widget.child,
      ),
    );
  }
}
