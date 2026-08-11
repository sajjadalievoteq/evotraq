import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/partition_models.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class PartitionSummaryCard extends StatelessWidget {
  const PartitionSummaryCard(this.statistics, {super.key});

  final PartitionStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColorMapper.infoColor(context).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partition Data Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total Records (in partitions): ${statistics.totalRecords}'),
            Text('Total Size Bytes: ${statistics.totalSizeBytes}'),
            Text(
              'Total Size MB: ${statistics.totalSizeMb?.toStringAsFixed(2) ?? 'null'}',
            ),
            Text(
              'Total Size GB: ${statistics.totalSizeGb?.toStringAsFixed(6) ?? 'null'}',
            ),
            Text(
              'Average Partition Size: ${statistics.averagePartitionSizeMb?.toStringAsFixed(2) ?? 'N/A'} MB',
            ),
          ],
        ),
      ),
    );
  }
}
