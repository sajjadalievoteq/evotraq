import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_metric_card.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_legend_item.dart';
import 'package:traqtrace_app/features/admin/utils/admin_event_visualization_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class StorageLegend extends StatelessWidget {
  const StorageLegend({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Types',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...storageStats.eventTypeDistribution.entries.map((entry) {
          return StorageUtilizationLegendItem(
            entry.key,
            entry.value,
            AdminEventVisualizationUtils.eventTypeColor(
              entry.key,
              context: context,
            ),
          );
        }).toList(),
      ],
    );
  }
}
