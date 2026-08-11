import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/event_type_metrics_row.dart';

class EventTypeMetricsSummary extends StatelessWidget {
  const EventTypeMetricsSummary({super.key, required this.eventTypeMetrics});
  final Map<String, EventTypeMetrics> eventTypeMetrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Event Type Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...eventTypeMetrics.entries.map(
          (entry) => EventTypeMetricsRow(entry.key, entry.value),
        ),
      ],
    );
  }
}
