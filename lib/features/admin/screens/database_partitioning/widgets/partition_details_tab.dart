import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/partition_models.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_card.dart';
import 'package:traqtrace_app/features/admin/screens/database_partitioning/widgets/partition_summary_card.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class PartitionDetailsTab<TOverview> extends StatelessWidget {
  const PartitionDetailsTab({
    super.key,
    required this.overviewState,
    required this.metadataState,
    required this.onRetryOverview,
    required this.onRetryMetadata,
    required this.statisticsOf,
  });

  final LoadState<TOverview> overviewState;
  final LoadState<List<PartitionMetadata>> metadataState;
  final VoidCallback onRetryOverview;
  final VoidCallback onRetryMetadata;
  final PartitionStatistics Function(TOverview data) statisticsOf;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partition Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          LoadStateView<TOverview>(
            state: overviewState,
            onRetry: onRetryOverview,
            builder: (context, data) =>
                PartitionSummaryCard(statisticsOf(data)),
          ),
          const SizedBox(height: 20),
          LoadStateView<List<PartitionMetadata>>(
            state: metadataState,
            onRetry: onRetryMetadata,
            emptyWidget: const Center(
              child: Text('No partition data available'),
            ),
            builder: (context, metadata) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metadata.length,
              itemBuilder: (context, index) {
                final partition = metadata[index];
                return PartitionCard(partition);
              },
            ),
          ),
        ],
      ),
    );
  }
}
