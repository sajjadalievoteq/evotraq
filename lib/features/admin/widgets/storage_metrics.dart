import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_metric_card.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/admin/widgets/partition_distribution.dart';

class StorageMetrics extends StatelessWidget {
  const StorageMetrics({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StorageUtilizationMetricCard(
                'Total Storage',
                '${storageStats.totalStorageCapacityGB.toStringAsFixed(0)} GB',
                NavIcons.databasePartitioning,
                AppColorMapper.chartColor(context, 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StorageUtilizationMetricCard(
                'Compression',
                '${storageStats.compressionRatio.toStringAsFixed(1)}:1',
                AppAssets.iconCompress,
                AppColorMapper.chartColor(context, 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StorageUtilizationMetricCard(
                'Partitions',
                storageStats.partitionDistribution.length.toString(),
                NavIcons.masterData,
                AppColorMapper.chartColor(context, 2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StorageUtilizationMetricCard(
                'Avg Size',
                '${storageStats.averagePartitionSize.toStringAsFixed(1)} MB',
                AppAssets.iconFolder,
                AppColorMapper.chartColor(context, 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PartitionDistribution(storageStats: storageStats),
      ],
    );
  }
}
