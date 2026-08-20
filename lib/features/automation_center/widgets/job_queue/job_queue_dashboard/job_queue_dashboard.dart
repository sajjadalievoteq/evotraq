import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/queue_status_strip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_metrics_grid.dart';

/// Production operations console for the Job Queue dashboard tab.
class JobQueueDashboard extends StatelessWidget {
  const JobQueueDashboard({
    super.key,
    required this.snapshot,
    required this.onRefresh,
    required this.onSchedule,
    this.onOpenActive,
    this.onOpenQueue,
    this.onOpenHistory,
    this.onOpenWorkers,
  });

  final JobQueueDashboardSnapshot snapshot;
  final VoidCallback onRefresh;
  final VoidCallback onSchedule;
  final VoidCallback? onOpenActive;
  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenWorkers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JobQueueStatusStrip(
          snapshot: snapshot,
          onRefresh: onRefresh,
          onSchedule: onSchedule,
        ),
        const SizedBox(height: TraqSpacing.lg),
        JobQueueMetricsGrid(
          snapshot: snapshot,
          onOpenActive: onOpenActive,
          onOpenQueue: onOpenQueue,
          onOpenHistory: onOpenHistory,
        ),
      ],
    );
  }
}
