import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_dashboard_section.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_empty_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_priority_bar.dart';

class JobQueuePriorityDistributionCard extends StatelessWidget {
  const JobQueuePriorityDistributionCard({
    super.key,
    required this.distribution,
  });
  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.toList()
      ..sort(
        (a, b) =>
            (int.tryParse(a.key) ?? 0).compareTo(int.tryParse(b.key) ?? 0),
      );
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    final nonZero = entries.where((entry) => entry.value > 0).toList();
    return JobQueueDashboardSection(
      title: 'Priority distribution',
      child: total <= 0 || nonZero.isEmpty
          ? const JobQueueEmptyPanel(
              title: 'No queued jobs',
              subtitle: 'Priorities appear here when work is waiting.',
              iconAsset: AppAssets.iconList,
            )
          : Column(
              children: [
                for (final entry in nonZero)
                  JobQueuePriorityBar(
                    priority: entry.key,
                    count: entry.value,
                    total: total,
                  ),
              ],
            ),
    );
  }
}
