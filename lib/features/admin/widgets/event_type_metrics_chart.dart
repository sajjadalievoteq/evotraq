import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

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
            Container(
              height: 300,
              child: _buildChart(),
            ),
            const SizedBox(height: 16),
            _buildMetricsSummary(),
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

  Widget _buildChart() {
    final eventTypes = eventTypeMetrics.keys.toList();
    final maxValue = _getMaxValue();

    if (maxValue == 0) {
      return const Center(child: Text('No data to display'));
    }

    return CustomPaint(
      painter: BarChartPainter(
        eventTypes: eventTypes,
        values: _getValues(),
        maxValue: maxValue,
        metricType: metricType,
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

  double _getMaxValue() {
    final values = _getValues();
    return values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  }

  Widget _buildMetricsSummary() {
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
          return _buildEventTypeRow(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildEventTypeRow(String eventType, EventTypeMetrics metrics) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getEventTypeColor(eventType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              eventType,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metrics.eventsPerSecond.toStringAsFixed(1)} eps',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Throughput',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metrics.averageProcessingTime.toStringAsFixed(1)}ms',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Avg Time',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metrics.successRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getSuccessRateColor(metrics.successRate),
                  ),
                ),
                Text(
                  'Success',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metrics.totalProcessed.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (metrics.totalErrors > 0)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metrics.totalErrors.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'Errors',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toUpperCase()) {
      case 'OBJECT':
        return Colors.blue;
      case 'AGGREGATION':
        return Colors.green;
      case 'TRANSACTION':
        return Colors.red;
      case 'TRANSFORMATION':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getSuccessRateColor(double successRate) {
    if (successRate >= 95) return Colors.green;
    if (successRate >= 90) return Colors.orange;
    return Colors.red;
  }
}

class BarChartPainter extends CustomPainter {
  final List<String> eventTypes;
  final List<double> values;
  final double maxValue;
  final String metricType;

  BarChartPainter({
    required this.eventTypes,
    required this.values,
    required this.maxValue,
    required this.metricType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (eventTypes.isEmpty || values.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Calculate dimensions
    final chartHeight = size.height - 60; // Leave space for labels
    final chartWidth = size.width - 80; // Leave space for Y-axis labels
    final barWidth = chartWidth / eventTypes.length * 0.7;
    final barSpacing = chartWidth / eventTypes.length * 0.3;

    // Draw Y-axis
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    canvas.drawLine(
      const Offset(60, 10),
      Offset(60, chartHeight + 10),
      axisPaint,
    );

    // Draw X-axis
    canvas.drawLine(
      Offset(60, chartHeight + 10),
      Offset(size.width - 10, chartHeight + 10),
      axisPaint,
    );

    // Draw bars
    for (int i = 0; i < eventTypes.length; i++) {
      final eventType = eventTypes[i];
      final value = values[i];
      final barHeight = (value / maxValue) * chartHeight;

      final x = 60 + (chartWidth / eventTypes.length) * i + barSpacing / 2;
      final y = chartHeight + 10 - barHeight;

      paint.color = _getEventTypeColor(eventType);

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );

      // Draw value on top of bar
      final textPainter = _createTextPainter(
        _formatValue(value),
        const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 20),
      );

      // Draw event type label
      final labelPainter = _createTextPainter(
        _formatEventType(eventType),
        const TextStyle(fontSize: 10),
      );
      labelPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - labelPainter.width / 2, chartHeight + 20),
      );
    }

    // Draw Y-axis labels
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

      // Draw grid line
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

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toUpperCase()) {
      case 'OBJECT':
        return Colors.blue;
      case 'AGGREGATION':
        return Colors.green;
      case 'TRANSACTION':
        return Colors.red;
      case 'TRANSFORMATION':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
