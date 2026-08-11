import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/event_type_bar_chart_painter.dart';

class EventTypeChartCanvas extends StatelessWidget {
  const EventTypeChartCanvas({
    super.key,
    required this.eventTypeMetrics,
    required this.metricType,
  });
  final Map<String, EventTypeMetrics> eventTypeMetrics;
  final String metricType;

  @override
  Widget build(BuildContext context) {
    final values = eventTypeMetrics.values.map((metrics) {
      return switch (metricType) {
        'throughput' => metrics.eventsPerSecond,
        'processing_time' => metrics.averageProcessingTime,
        'success_rate' => metrics.successRate,
        'total_processed' => metrics.totalProcessed.toDouble(),
        _ => 0.0,
      };
    }).toList();
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return const Center(child: Text('No data to display'));
    return CustomPaint(
      painter: EventTypeBarChartPainter(
        eventTypes: eventTypeMetrics.keys.toList(),
        values: values,
        maxValue: maxValue,
        metricType: metricType,
        brightness: Theme.of(context).brightness,
      ),
      size: const Size(double.infinity, 300),
    );
  }
}
