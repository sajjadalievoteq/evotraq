import 'dart:math' show max;

import 'package:flutter/material.dart';

class DashboardMiniLineSparkline extends StatelessWidget {
  const DashboardMiniLineSparkline({
    super.key,
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
            painter: DashboardSparklinePainter(
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

class DashboardSparklinePainter extends CustomPainter {
  DashboardSparklinePainter({
    required this.heights,
    required this.color,
    this.strokeWidth = 1.75,
  });

  final List<double> heights;
  final Color color;
  final double strokeWidth;

  double _y(Size size, double h) => size.height * (1 - h.clamp(0.08, 1.0));

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
  bool shouldRepaint(covariant DashboardSparklinePainter oldDelegate) {
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
