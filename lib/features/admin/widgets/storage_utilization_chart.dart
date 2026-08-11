import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_pie_chart.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_legend.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_metrics.dart';

class StorageUtilizationChart extends StatelessWidget {
  final StorageStatistics storageStats;

  const StorageUtilizationChart({super.key, required this.storageStats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: StoragePieChart(storageStats: storageStats),
                ),
                const SizedBox(width: 16),
                Expanded(child: StorageLegend(storageStats: storageStats)),
              ],
            ),
            const SizedBox(height: 16),
            StorageMetrics(storageStats: storageStats),
          ],
        ),
      ),
    );
  }
}
