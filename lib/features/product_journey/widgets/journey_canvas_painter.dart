import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class JourneyCanvasPainter extends CustomPainter {
  JourneyCanvasPainter({
    required this.positions,
    required this.color,
    this.progress = 1.0,
  }) : _fullPath = _roundedPolylinePath(positions, radius: 24) {
    // Precompute PathMetrics once — never recalculate inside paint().
    if (progress < 1.0) {
      _metrics = _fullPath.computeMetrics().toList();
      _totalLength = _metrics!.fold(0.0, (sum, m) => sum + m.length);
    }
  }

  final List<Offset> positions;
  final Color color;
  final double progress;

  final Path _fullPath;
  List<PathMetric>? _metrics;
  double _totalLength = 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    // When progress is 1.0, skip PathMetrics and draw the full path directly.
    final drawPath = progress >= 1.0
        ? _fullPath
        : _extractSubPath(progress);

    // Glow layer
    canvas.drawPath(
      drawPath,
      Paint()
        ..color = color.withValues(alpha: 0.20)
        ..strokeWidth = 16.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Main line layer
    canvas.drawPath(
      drawPath,
      Paint()
        ..color = color.withValues(alpha: 0.88)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Leading tip dot while the line is still drawing.
    if (progress < 1.0 && progress > 0.02 && _metrics != null) {
      final tipLen = (progress * _totalLength).clamp(0.0, _totalLength);
      double consumed = 0;
      for (final metric in _metrics!) {
        if (consumed + metric.length >= tipLen) {
          final tangent = metric.getTangentForOffset(tipLen - consumed);
          if (tangent != null) {
            canvas.drawCircle(
              tangent.position,
              5.0,
              Paint()..color = color.withValues(alpha: 0.95),
            );
          }
          break;
        }
        consumed += metric.length;
      }
    }
  }

  /// Extracts the first [fraction] of the cached path using precomputed metrics.
  Path _extractSubPath(double fraction) {
    final result = Path();
    final tipLen = (_totalLength * fraction).clamp(0.0, _totalLength);
    double consumed = 0;
    for (final metric in _metrics!) {
      if (consumed >= tipLen) break;
      final end = math.min(metric.length, tipLen - consumed);
      if (end > 0) {
        result.addPath(metric.extractPath(0, end), Offset.zero);
      }
      consumed += metric.length;
    }
    return result;
  }

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
      !listEquals(old.positions, positions) ||
      old.color != color ||
      old.progress != progress;
}
