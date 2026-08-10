import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';

class JobQueueDashboardTab extends StatelessWidget {
  final JobQueueDashboardSnapshot snapshot;
  final bool embedded;
  final VoidCallback onRefresh;
  final VoidCallback onSchedule;
  final VoidCallback onOpenActive;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenWorkers;

  const JobQueueDashboardTab({
    super.key,
    required this.snapshot,
    required this.embedded,
    required this.onRefresh,
    required this.onSchedule,
    required this.onOpenActive,
    required this.onOpenQueue,
    required this.onOpenHistory,
    required this.onOpenWorkers,
  });

  @override
  Widget build(BuildContext context) {
    final body = JobQueueDashboard(
      snapshot: snapshot,
      onRefresh: onRefresh,
      onSchedule: onSchedule,
      onOpenActive: onOpenActive,
      onOpenQueue: onOpenQueue,
      onOpenHistory: onOpenHistory,
      onOpenWorkers: onOpenWorkers,
    );

    if (embedded) {
      return body;
    }

    return SingleChildScrollView(padding: TraqSpacing.surfacePad, child: body);
  }
}
