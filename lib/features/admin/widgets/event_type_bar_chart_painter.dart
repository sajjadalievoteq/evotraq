import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class EventTypeBarChartPainter extends CustomPainter {
  EventTypeBarChartPainter({
    required this.eventTypes,
    required this.values,
    required this.maxValue,
    required this.metricType,
    required this.brightness,
  });
  final List<String> eventTypes;
  final List<double> values;
  final double maxValue;
  final String metricType;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (eventTypes.isEmpty || values.isEmpty) return;
    final paint = Paint()..style = PaintingStyle.fill;
    final chartHeight = size.height - 60;
    final chartWidth = size.width - 80;
    final barWidth = chartWidth / eventTypes.length * 0.7;
    final barSpacing = chartWidth / eventTypes.length * 0.3;
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(60, 10),
      Offset(60, chartHeight + 10),
      axisPaint,
    );
    canvas.drawLine(
      Offset(60, chartHeight + 10),
      Offset(size.width - 10, chartHeight + 10),
      axisPaint,
    );
    for (var i = 0; i < eventTypes.length; i++) {
      final value = values[i];
      final barHeight = (value / maxValue) * chartHeight;
      final x = 60 + (chartWidth / eventTypes.length) * i + barSpacing / 2;
      final y = chartHeight + 10 - barHeight;
      paint.color = AppColorMapper.eventType(
        eventTypes[i],
        scheme: AppEventColorScheme.admin,
        brightness: brightness,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
      final valuePainter = _textPainter(
        _formatValue(value),
        const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      );
      valuePainter.paint(
        canvas,
        Offset(x + barWidth / 2 - valuePainter.width / 2, y - 20),
      );
      final labelPainter = _textPainter(
        _formatEventType(eventTypes[i]),
        const TextStyle(fontSize: 10),
      );
      labelPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - labelPainter.width / 2, chartHeight + 20),
      );
    }
    for (var i = 0; i <= 5; i++) {
      final value = (maxValue / 5) * i;
      final y = chartHeight + 10 - (chartHeight / 5) * i;
      final labelPainter = _textPainter(
        _formatValue(value),
        const TextStyle(fontSize: 10),
      );
      labelPainter.paint(
        canvas,
        Offset(55 - labelPainter.width, y - labelPainter.height / 2),
      );
      final gridPaint = Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 0.5;
      canvas.drawLine(Offset(60, y), Offset(size.width - 10, y), gridPaint);
    }
  }

  TextPainter _textPainter(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  String _formatValue(double value) => switch (metricType) {
    'throughput' => value.toStringAsFixed(1),
    'processing_time' => '${value.toStringAsFixed(1)}ms',
    'success_rate' => '${value.toStringAsFixed(1)}%',
    'total_processed' => value.toInt().toString(),
    _ => value.toStringAsFixed(1),
  };

  String _formatEventType(String value) =>
      value.length > 8 ? '${value.substring(0, 8)}...' : value;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
