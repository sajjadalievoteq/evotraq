import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/utils/admin_event_visualization_utils.dart';

class EventTypeMetricsRow extends StatelessWidget {
  const EventTypeMetricsRow(this.eventType, this.metrics, {super.key});

  final String eventType;
  final EventTypeMetrics metrics;

  @override
  Widget build(BuildContext context) {

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
              color: AdminEventVisualizationUtils.eventTypeColor(
                eventType,
                context: context,
              ),
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
                    color: StatusVisualMappers.successRateColor(
                      context,
                      metrics.successRate,
                    ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColorMapper.errorColor(context),
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
}