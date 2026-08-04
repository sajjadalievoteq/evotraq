import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/partition_models.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class PartitionCard extends StatelessWidget {
  const PartitionCard(this.partition, {super.key});

  final PartitionMetadata partition;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(partition.partitionName),
        subtitle: Text(
          'Table: ${partition.tableName} | Type: ${partition.partitionType}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(partition.sizeMb ?? 0).toStringAsFixed(1)} MB',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${partition.recordCount} records',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: partition.status == 'ACTIVE'
                ? AppColorMapper.successColor(context)
                : AppColorMapper.warningColor(context),
          ),
        ),
      ),
    );
  }
}
