import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_capacity_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_worker_pool_card.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/widgets/job_queue_worker_pool_details.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';

class JobQueueWorkerPoolTab extends StatelessWidget {
  final Map<String, dynamic> workerPoolStats;
  final bool fill;
  final VoidCallback onConfigure;
  final JobQueueDashboardSnapshot snapshot;

  const JobQueueWorkerPoolTab({
    super.key,
    required this.workerPoolStats,
    required this.fill,
    required this.onConfigure,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final header = Wrap(
      spacing: TraqSpacing.sm,
      runSpacing: TraqSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Worker Pool Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        OutlinedButton.icon(
          onPressed: onConfigure,
          icon: TraqIcon(AppAssets.iconTune),
          label: const Text('Configure'),
        ),
      ],
    );

    final estimatedWait = snapshot.queuedJobs == 0
        ? '0 sec'
        : snapshot.workerActive == 0
        ? '—'
        : '~${(snapshot.queuedJobs * 5 / snapshot.workerActive.clamp(1, 999)).ceil()}s';
    final details = Column(
      children: [
        JobQueueWorkerPoolCard(
          active: snapshot.workerActive,
          poolSize: snapshot.workerPoolSize,
          max: snapshot.workerMax,
          utilization: snapshot.workerUtilization,
        ),
        const SizedBox(height: TraqSpacing.lg),
        JobQueueCapacityCard(
          queueSize: snapshot.queueSize,
          queueCapacity: snapshot.queueCapacity,
          healthy: snapshot.healthy,
          estimatedWaitLabel: estimatedWait,
        ),
        const SizedBox(height: TraqSpacing.lg),
        JobQueueWorkerPoolDetails(workerPoolStats: workerPoolStats),
      ],
    );

    if (!fill) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: TraqSpacing.lg),
          details,
        ],
      );
    }

    return Padding(
      padding: TraqSpacing.surfacePad,
      child: Column(
        children: [
          header,
          const SizedBox(height: TraqSpacing.lg),
          Expanded(child: SingleChildScrollView(child: details)),
        ],
      ),
    );
  }
}
