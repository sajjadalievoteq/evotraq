import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_statistics_card.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_chart.dart';

class MonitoringStorageTab extends StatelessWidget {
  const MonitoringStorageTab({
    super.key,
    required this.storageState,
    required this.onRetry,
    required this.onArchiveEvents,
    required this.onCompressEvents,
  });

  final LoadState<StorageStatistics> storageState;
  final VoidCallback onRetry;
  final void Function(DateTime cutoffDate) onArchiveEvents;
  final void Function(List<String> eventIds) onCompressEvents;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LoadStateView<StorageStatistics>(
        state: storageState,
        onRetry: onRetry,
        builder: (context, storage) => Column(
          children: [
            StorageStatisticsCard(
              storage: storage,
              onArchiveEvents: onArchiveEvents,
              onCompressEvents: onCompressEvents,
            ),
            const SizedBox(height: 16),
            StorageUtilizationChart(
              storageStats: storage,
            ),
          ],
        ),
      ),
    );
  }
}
