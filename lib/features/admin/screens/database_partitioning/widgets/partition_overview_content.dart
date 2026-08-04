import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/models/partition_models.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_health_status_card.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_stat_card.dart';

class PartitionOverviewContent extends StatelessWidget {
  const PartitionOverviewContent({
    super.key,
    required this.statistics,
    required this.health,
  });

  final PartitionStatistics statistics;
  final Map<String, dynamic> health;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partition Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PartitionStatCard(
                  'Total Partitions',
                  statistics.totalPartitions.toString(),
                  AppAssets.iconTable,
                  AppColorMapper.infoColor(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PartitionStatCard(
                  'Active Partitions',
                  statistics.activePartitions.toString(),
                  AppAssets.iconCheckCircle,
                  AppColorMapper.successColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PartitionStatCard(
                  'Archived Partitions',
                  statistics.archivedPartitions.toString(),
                  AppAssets.iconArchive,
                  AppColorMapper.warningColor(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PartitionStatCard(
                  'Total Size',
                  '${(statistics.totalSizeGb != null && statistics.totalSizeGb! > 0) ? statistics.totalSizeGb!.toStringAsFixed(6) : (statistics.totalSizeMb != null ? (statistics.totalSizeMb! / 1024).toStringAsFixed(6) : '0.000000')} GB',
                  NavIcons.databasePartitioning,
                  AppColorMapper.chartColor(context, 5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PartitionHealthStatusCard(health),
        ],
      ),
    );
  }
}
