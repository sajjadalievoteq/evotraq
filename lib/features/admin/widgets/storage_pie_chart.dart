import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_painters.dart';

class StoragePieChart extends StatelessWidget {
  const StoragePieChart({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: PieChartPainter(
          eventTypeDistribution: storageStats.eventTypeDistribution,
          brightness: Theme.of(context).brightness,
        ),
        size: const Size(200, 200),
      ),
    );
  }
}
