import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/event_type_metrics_row.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class EventTypeMetricsChart extends StatelessWidget {
  final Map<String, EventTypeMetrics> eventTypeMetrics;
  final String metricType;

  const EventTypeMetricsChart({
    super.key,
    required this.eventTypeMetrics,
    this.metricType = 'throughput',
  });

  @override
  Widget build(BuildContext context) {
    if (eventTypeMetrics.isEmpty) {
      return const Center(
        child: Text('No event type metrics available'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getChartTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _EventTypeChartCanvas(
                eventTypeMetrics: eventTypeMetrics,
                metricType: metricType,
              ),
            ),
            const SizedBox(height: 16),
            _EventTypeMetricsSummary(eventTypeMetrics: eventTypeMetrics),
          ],
        ),
      ),
    );
  }

  String _getChartTitle() {
    switch (metricType) {
      case 'throughput':
        return 'Events Per Second by Type';
      case 'processing_time':
        return 'Average Processing Time by Type';
      case 'success_rate':
        return 'Success Rate by Event Type';
      case 'total_processed':
        return 'Total Events Processed by Type';
      default:
        return 'Event Type Metrics';
    }
  }

}

class _EventTypeChartCanvas extends StatelessWidget {
  const _EventTypeChartCanvas({
    required this.eventTypeMetrics,
    required this.metricType,
  });

  final Map<String, EventTypeMetrics> eventTypeMetrics;
  final String metricType;

  @override
  Widget build(BuildContext context) {
    final values = _getValues();
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((double a, double b) => a > b ? a : b);
    if (maxValue == 0) {
      return const Center(child: Text('No data to display'));
    }

    return CustomPaint(
      painter: BarChartPainter(
        eventTypes: eventTypeMetrics.keys.toList(),
        values: values,
        maxValue: maxValue,
        metricType: metricType,
        brightness: Theme.of(context).brightness,
      ),
      size: const Size(double.infinity, 300),
    );
  }

  List<double> _getValues() {
    return eventTypeMetrics.values.map((metrics) {
      switch (metricType) {
        case 'throughput':
          return metrics.eventsPerSecond;
        case 'processing_time':
          return metrics.averageProcessingTime;
        case 'success_rate':
          return metrics.successRate;
        case 'total_processed':
          return metrics.totalProcessed.toDouble();
        default:
          return 0.0;
      }
    }).toList();
  }
}

class _EventTypeMetricsSummary extends StatelessWidget {
  const _EventTypeMetricsSummary({required this.eventTypeMetrics});
  final Map<String, EventTypeMetrics> eventTypeMetrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Event Type Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...eventTypeMetrics.entries.map((entry) {
          return EventTypeMetricsRow(entry.key, entry.value);
        }).toList(),
      ],
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<String> eventTypes;
  final List<double> values;
  final double maxValue;
  final String metricType;
  final Brightness brightness;

  BarChartPainter({
    required this.eventTypes,
    required this.values,
    required this.maxValue,
    required this.metricType,
    required this.brightness,
  });

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

    for (int i = 0; i < eventTypes.length; i++) {
      final eventType = eventTypes[i];
      final value = values[i];
      final barHeight = (value / maxValue) * chartHeight;

      final x = 60 + (chartWidth / eventTypes.length) * i + barSpacing / 2;
      final y = chartHeight + 10 - barHeight;

      paint.color = AppColorMapper.eventType(
        eventType,
        scheme: AppEventColorScheme.admin,
        brightness: brightness,
      );

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );

      final textPainter = _createTextPainter(
        _formatValue(value),
        const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 20),
      );

      final labelPainter = _createTextPainter(
        _formatEventType(eventType),
        const TextStyle(fontSize: 10),
      );
      labelPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - labelPainter.width / 2, chartHeight + 20),
      );
    }

    for (int i = 0; i <= 5; i++) {
      final value = (maxValue / 5) * i;
      final y = chartHeight + 10 - (chartHeight / 5) * i;

      final labelPainter = _createTextPainter(
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
      canvas.drawLine(
        Offset(60, y),
        Offset(size.width - 10, y),
        gridPaint,
      );
    }
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

  String _formatValue(double value) {
    switch (metricType) {
      case 'throughput':
        return value.toStringAsFixed(1);
      case 'processing_time':
        return '${value.toStringAsFixed(1)}ms';
      case 'success_rate':
        return '${value.toStringAsFixed(1)}%';
      case 'total_processed':
        return value.toInt().toString();
      default:
        return value.toStringAsFixed(1);
    }
  }

  String _formatEventType(String eventType) {
    return eventType.length > 8 
        ? '${eventType.substring(0, 8)}...' 
        : eventType;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
