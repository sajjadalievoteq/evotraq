import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class JourneyCanvasPainter extends CustomPainter {
  const JourneyCanvasPainter({
    required this.positions,
    required this.color,
  });

  final List<Offset> positions;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final path = _roundedPolylinePath(positions, radius: 24);

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.20)
        ..strokeWidth = 16.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.88)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Filleted polyline — rounds each bend instead of a sharp 90° corner.
  static Path _roundedPolylinePath(List<Offset> points, {required double radius}) {
    final path = Path();
    if (points.isEmpty) return path;
    if (points.length == 1) {
      path.moveTo(points[0].dx, points[0].dy);
      return path;
    }
    if (points.length == 2) {
      path
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy);
      return path;
    }

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final corner = points[i];
      final next = points[i + 1];

      final inVec = corner - prev;
      final outVec = next - corner;
      final inLen = inVec.distance;
      final outLen = outVec.distance;
      if (inLen == 0 || outLen == 0) continue;

      final r = math.min(radius, math.min(inLen / 2, outLen / 2));
      final inStop = corner - Offset(inVec.dx / inLen, inVec.dy / inLen) * r;
      final outStop = corner + Offset(outVec.dx / outLen, outVec.dy / outLen) * r;

      path
        ..lineTo(inStop.dx, inStop.dy)
        ..quadraticBezierTo(corner.dx, corner.dy, outStop.dx, outStop.dy);
    }

    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(JourneyCanvasPainter old) =>
      !listEquals(old.positions, positions) || old.color != color;
}
