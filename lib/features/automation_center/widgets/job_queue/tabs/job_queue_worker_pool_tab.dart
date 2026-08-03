import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/widgets/job_queue_worker_pool_details.dart';

class JobQueueWorkerPoolTab extends StatelessWidget {
  final Map<String, dynamic> workerPoolStats;
  final bool fill;
  final VoidCallback onConfigure;

  const JobQueueWorkerPoolTab({
    super.key,
    required this.workerPoolStats,
    required this.fill,
    required this.onConfigure,
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

    final details = JobQueueWorkerPoolDetails(
      workerPoolStats: workerPoolStats,
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
          Expanded(child: details),
        ],
      ),
    );
  }
}
