import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class PieChartPainter extends CustomPainter {
  final Map<String, double> eventTypeDistribution;
  final Brightness brightness;

  PieChartPainter({
    required this.eventTypeDistribution,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (eventTypeDistribution.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * (3.14159 / 180);

    final paint = Paint()..style = PaintingStyle.fill;

    for (final entry in eventTypeDistribution.entries) {
      final sweepAngle = (entry.value / 100) * 2 * 3.14159;

      paint.color = AppColorMapper.eventType(
        entry.key,
        scheme: AppEventColorScheme.admin,
        brightness: brightness,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.4, centerPaint);

    final textPainter = _createTextPainter(
      '100%',
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  TextPainter _createTextPainter(String text, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PartitionBarChartPainter extends CustomPainter {
  final Map<String, int> partitionDistribution;
  final Brightness brightness;

  PartitionBarChartPainter({
    required this.partitionDistribution,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (partitionDistribution.isEmpty) return;

    final maxValue = partitionDistribution.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final barWidth = size.width / partitionDistribution.length * 0.8;
    final barSpacing = size.width / partitionDistribution.length * 0.2;
    final palette = brightness == Brightness.dark
        ? OperationPalette.dark
        : OperationPalette.light;

    final paint = Paint()..style = PaintingStyle.fill;
    final colors = palette.chartSeries;

    int index = 0;
    for (final entry in partitionDistribution.entries) {
      final barHeight = (entry.value / maxValue) * (size.height - 20);
      final x = index * (barWidth + barSpacing) + barSpacing / 2;
      final y = size.height - barHeight - 10;

      paint.color = colors[entry.key.hashCode.abs() % colors.length];

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      index++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
