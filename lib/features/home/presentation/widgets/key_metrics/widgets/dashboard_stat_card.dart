import 'dart:math' show log, max, pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconAsset,
    required this.color,
    this.width,
    this.onTap,
    this.valueTextColor,
    this.labelTextColor,
    this.sparkline,
    this.sparklineColor,
    this.dense = false,
  }) : assert(
          icon != null || iconAsset != null,
          'Provide icon or iconAsset',
        );

  final String title;
  final String value;
  final IconData? icon;
  final String? iconAsset;
  final Color color;
  final double? width;
  final VoidCallback? onTap;
  final Color? valueTextColor;
  final Color? labelTextColor;
  final List<double>? sparkline;
  final Color? sparklineColor;
  /// Tighter padding and sparkline for fixed-aspect tiles (e.g. 16:9 wrap).
  final bool dense;

  bool get _usesAsset => iconAsset != null;

  /// Digits-only parse of the value shown on the card (e.g. counts).
  static int? _parseMetricValue(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// Sparkline Y samples (0 = bottom of track). Derived from [n] only; null for [n] <= 0.
  static List<double>? _sparklineFromMetric(int n) {
    if (n <= 0) return null;
    const points = 22;
    final logN = log(n + 1);
    final logRef = log(100001);
    final hi = (logN / logRef).clamp(0.2, 0.92);
    final lo = (hi * 0.5).clamp(0.14, hi);
    return List.generate(points, (i) {
      final t = points <= 1 ? 0.0 : i / (points - 1);
      final mid = lo + (hi - lo) * t;
      final ripple = 0.035 * sin(2 * pi * 2.5 * t + n % 7);
      return (mid + ripple).clamp(0.1, 0.98);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueColor = valueTextColor ?? color;
    final captionColor = labelTextColor ?? context.colors.textMuted;
    final metric = _parseMetricValue(value);
    final sparkHeights = metric == 0
        ? null
        : (sparkline ??
            (_usesAsset && metric != null
                ? _sparklineFromMetric(metric)
                : null));
    final lineColor = sparklineColor ?? color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width ?? 140);
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        return InkWell(
          onTap: onTap,

          child: Container(
            width: w,
            height: h,
            padding: EdgeInsets.all(dense ? 18 : 22),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          if (iconAsset != null)
                            SvgPicture.asset(
                              iconAsset!,
                              width: dense ? 18 : 24,
                              height: dense ? 18 : 24,
                              colorFilter:
                                  ColorFilter.mode(color, BlendMode.srcIn),
                            )
                          else
                            Icon(icon!, color: color, size: dense ? 24 : 32),
                          Expanded(
                            child: Text(
                              title,
                              style: context.text.cap.copyWith(
                                fontSize: dense ? 14 : 20,
                                color: captionColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        value,
                        style: context.text.h2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                          fontSize: dense ? 26 : 44,
                          height: dense ? 1.1 : 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (sparkHeights != null) ...[
                  SizedBox(width: dense ? 12 : 20),
                  Expanded(
                    child: _MiniLineSparkline(
                      heights: sparkHeights,
                      lineColor: lineColor,
                      minTrackHeight: dense ? 18 : 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniLineSparkline extends StatelessWidget {
  const _MiniLineSparkline({
    required this.heights,
    required this.lineColor,
    this.minTrackHeight = 22,
  });

  final List<double> heights;
  final Color lineColor;
  final double minTrackHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight.isFinite && c.maxHeight > 0
            ? max(minTrackHeight, c.maxHeight)
            : minTrackHeight;
        return SizedBox(
          height: h,
          width: double.infinity,
          child: CustomPaint(
            painter: _SparklinePainter(
              heights: heights,
              color: lineColor,
              strokeWidth: h < 20 ? 1.35 : 1.75,
            ),
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.heights,
    required this.color,
    this.strokeWidth = 1.75,
  });

  final List<double> heights;
  final Color color;
  final double strokeWidth;

  double _y(Size size, double h) =>
      size.height * (1 - h.clamp(0.08, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (heights.isEmpty) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    if (heights.length == 1) {
      final x = size.width / 2;
      final y = _y(size, heights[0]);
      canvas.drawCircle(Offset(x, y), 2, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path();
    final n = heights.length;
    final dx = size.width / (n - 1);

    path.moveTo(0, _y(size, heights[0]));
    for (var i = 1; i < n; i++) {
      path.lineTo(i * dx, _y(size, heights[i]));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    if (oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.heights.length != heights.length) {
      return true;
    }
    for (var i = 0; i < heights.length; i++) {
      if (oldDelegate.heights[i] != heights[i]) return true;
    }
    return false;
  }
}
