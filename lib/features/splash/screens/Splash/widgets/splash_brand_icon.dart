import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SplashBrandIcon extends StatelessWidget {
  const SplashBrandIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return TraqIcon(
              AppAssets.iconBrokenImage,
              size: size * 0.7,
              color: c.primary,
            );
          },
        ),
      ),
    );
  }
}

/// Subtle looping lean: tilt clockwise on [Alignment.bottomRight], then settle.
class SplashBrandIconTilt extends StatefulWidget {
  const SplashBrandIconTilt({super.key, required this.child});

  final Widget child;

  @override
  State<SplashBrandIconTilt> createState() => _SplashBrandIconTiltState();
}

class _SplashBrandIconTiltState extends State<SplashBrandIconTilt>
    with SingleTickerProviderStateMixin {
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
        tween: Tween<double>(
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  void _startIfNeeded() {
    if (!mounted) return;
    if (TraqAnimationManager.reduceMotion(context)) {
      _controller.value = 0;
      return;
    }
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
