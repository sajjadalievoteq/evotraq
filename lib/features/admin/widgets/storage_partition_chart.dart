import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/number_format_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';

class StoragePartitionChart extends StatelessWidget {
  const StoragePartitionChart({super.key, required this.storage});
  final StorageStatistics storage;

  @override
  Widget build(BuildContext context) {
    final maxCount = storage.partitionDistribution.values.isNotEmpty
        ? storage.partitionDistribution.values.reduce((a, b) => a > b ? a : b)
        : 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: storage.partitionDistribution.entries.map((entry) {
          final height = (entry.value / maxCount) * 160;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  NumberFormatUtils.compactKilo(entry.value),
                  style: const TextStyle(fontSize: 10),
                ),
                Container(
                  width: 40,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColorMapper.infoColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 40,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
