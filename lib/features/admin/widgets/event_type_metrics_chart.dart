import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/event_type_chart_canvas.dart';
import 'package:traqtrace_app/features/admin/widgets/event_type_metrics_summary.dart';

class EventTypeMetricsChart extends StatelessWidget {
  const EventTypeMetricsChart({
    super.key,
    required this.eventTypeMetrics,
    this.metricType = 'throughput',
  });
  final Map<String, EventTypeMetrics> eventTypeMetrics;
  final String metricType;

  @override
  Widget build(BuildContext context) {
    if (eventTypeMetrics.isEmpty) {
      return const Center(child: Text('No event type metrics available'));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _chartTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: EventTypeChartCanvas(
                eventTypeMetrics: eventTypeMetrics,
                metricType: metricType,
              ),
            ),
            const SizedBox(height: 16),
            EventTypeMetricsSummary(eventTypeMetrics: eventTypeMetrics),
          ],
        ),
      ),
    );
  }

  String get _chartTitle => switch (metricType) {
    'throughput' => 'Events Per Second by Type',
    'processing_time' => 'Average Processing Time by Type',
    'success_rate' => 'Success Rate by Event Type',
    'total_processed' => 'Total Events Processed by Type',
    _ => 'Event Type Metrics',
  };
}
