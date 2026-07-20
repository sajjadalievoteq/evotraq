import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Thin, rounded indeterminate progress for splash / calm loading states.
///
/// A soft track with a pill-shaped brand fill that glides smoothly end-to-end.
class TraqIndeterminateProgress extends StatefulWidget {
  const TraqIndeterminateProgress({
    super.key,
    this.width = 192,
    this.height = 6,
  });

  final double width;
  final double height;

  @override
  State<TraqIndeterminateProgress> createState() =>
      _TraqIndeterminateProgressState();
}

class _TraqIndeterminateProgressState extends State<TraqIndeterminateProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _motion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TraqAnimationConstants.splashProgressCycle,
    );
    _motion = CurvedAnimation(
      parent: _controller,
      curve: TraqAnimationConstants.splashProgressCurve,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  void _startIfNeeded() {
    if (!mounted) return;
    if (TraqAnimationManager.reduceMotion(context)) {
      _controller.value = 0.42;
      return;
    }
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduce = TraqAnimationManager.reduceMotion(context);

    final trackColor = c.primary.withValues(alpha: isDark ? 0.14 : 0.09);
    final fillStart = c.primary.withValues(alpha: isDark ? 0.55 : 0.72);
    final fillMid = c.primary;
    final fillEnd = c.primary.withValues(alpha: isDark ? 0.88 : 0.95);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, _) {
          return CustomPaint(
            painter: _TraqProgressPainter(
              progress: _motion.value,
              trackColor: trackColor,
              fillStart: fillStart,
              fillMid: fillMid,
              fillEnd: fillEnd,
              segmentFraction: 0.34,
              staticFill: reduce,
            ),
          );
        },
      ),
    );
  }
}

class _TraqProgressPainter extends CustomPainter {
  const _TraqProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.fillStart,
    required this.fillMid,
    required this.fillEnd,
    required this.segmentFraction,
    required this.staticFill,
  });

  final double progress;
  final Color trackColor;
  final Color fillStart;
  final Color fillMid;
  final Color fillEnd;
  final double segmentFraction;
  final bool staticFill;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    canvas.drawRRect(track, Paint()..color = trackColor);

    final segmentWidth = size.width * segmentFraction;
    final travel = size.width - segmentWidth;
    final left = staticFill
        ? (size.width - segmentWidth) * 0.5
        : progress.clamp(0.0, 1.0) * travel;

    final fillRect = Rect.fromLTWH(left, 0, segmentWidth, size.height);
    final fillRRect = RRect.fromRectAndRadius(fillRect, radius);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [fillStart, fillMid, fillEnd],
        stops: const [0, 0.55, 1],
      ).createShader(fillRect);

    canvas.drawRRect(fillRRect, fillPaint);

    // Soft leading highlight — reads as light catching the pill edge.
    final highlightWidth = segmentWidth * 0.22;
    final highlightRect = Rect.fromLTWH(
      left + 1,
      0.5,
      highlightWidth.clamp(0, segmentWidth - 2),
      (size.height - 1).clamp(0, size.height),
    );
    if (highlightRect.width > 0 && highlightRect.height > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(highlightRect, radius),
        Paint()
          ..color = Colors.white.withValues(alpha: staticFill ? 0.08 : 0.14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TraqProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillStart != fillStart ||
        oldDelegate.fillMid != fillMid ||
        oldDelegate.fillEnd != fillEnd ||
        oldDelegate.staticFill != staticFill;
  }
}
