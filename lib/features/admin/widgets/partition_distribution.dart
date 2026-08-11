import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_metric_card.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_legend_item.dart';
import 'package:traqtrace_app/features/admin/utils/admin_event_visualization_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_painters.dart';

class PartitionDistribution extends StatelessWidget {
  const PartitionDistribution({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
    if (storageStats.partitionDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Partition Distribution',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: CustomPaint(
            painter: PartitionBarChartPainter(
              partitionDistribution: storageStats.partitionDistribution,
              brightness: Theme.of(context).brightness,
            ),
            size: const Size(double.infinity, 100),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: storageStats.partitionDistribution.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AdminEventVisualizationUtils.partitionColor(
                      entry.key,
                      context: context,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
