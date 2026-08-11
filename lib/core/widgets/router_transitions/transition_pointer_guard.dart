import 'package:flutter/material.dart';

class TransitionPointerGuard extends StatelessWidget {
  const TransitionPointerGuard({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final animating =
            animation.status == AnimationStatus.forward ||
            animation.status == AnimationStatus.reverse;
        return IgnorePointer(ignoring: animating, child: child!);
      },
    );
  }
}
