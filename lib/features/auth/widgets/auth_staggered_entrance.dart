import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_motion.dart';

/// One-shot staggered fade + rise for branding lines.
class AuthStaggeredEntrance extends StatefulWidget {
  const AuthStaggeredEntrance({
    super.key,
    required this.children,
    this.stagger = AuthMotion.stagger,
    this.duration = AuthMotion.entrance,
  });

  final List<Widget> children;
  final Duration stagger;
  final Duration duration;

  @override
  State<AuthStaggeredEntrance> createState() => _AuthStaggeredEntranceState();
}

class _AuthStaggeredEntranceState extends State<AuthStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AuthMotion.reduceMotion(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  Duration get _totalDuration {
    final n = widget.children.length;
    if (n <= 1) return widget.duration;
    return widget.duration + widget.stagger * (n - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AuthMotion.reduceMotion(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: widget.children,
      );
    }

    final totalMs = _totalDuration.inMilliseconds.toDouble().clamp(1, 1e9);
    final itemMs = widget.duration.inMilliseconds.toDouble();
    final staggerMs = widget.stagger.inMilliseconds.toDouble();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _StaggerItem(
                animation: _controller,
                begin: (i * staggerMs) / totalMs,
                end: ((i * staggerMs) + itemMs) / totalMs,
                child: widget.children[i],
              ),
          ],
        );
      },
    );
  }
}

class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        begin.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: AuthMotion.curve,
      ),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Cross-fades between keyed status states (verify / success / error).
class AuthStatusSwitcher extends StatelessWidget {
  const AuthStatusSwitcher({
    super.key,
    required this.statusKey,
    required this.child,
  });

  final String statusKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = AuthMotion.reduceMotion(context);
    final duration = AuthMotion.durationOf(context, AuthMotion.status);
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AuthMotion.curve,
      switchOutCurve: AuthMotion.reverseCurve,
      transitionBuilder: (widget, animation) {
        if (reduce) return widget;
        return AuthMotion.fadeRiseTransition(widget, animation);
      },
      child: KeyedSubtree(
        key: ValueKey(statusKey),
        child: child,
      ),
    );
  }
}

/// Soft scale-in for status icons.
class AuthIconPop extends StatelessWidget {
  const AuthIconPop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AuthMotion.reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: AuthMotion.status,
      curve: AuthMotion.iconPop,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
