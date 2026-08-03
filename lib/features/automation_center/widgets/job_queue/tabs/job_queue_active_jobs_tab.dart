import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/cards/job_queue_active_job_card.dart';

class JobQueueActiveJobsTab extends StatelessWidget {
  final List<Map<String, dynamic>> activeJobs;
  final bool fill;
  final ValueChanged<String> onCancel;

  const JobQueueActiveJobsTab({
    super.key,
    required this.activeJobs,
    required this.fill,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final header = Row(
      children: [
        Text(
          'Active Jobs',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
        ),
        const Spacer(),
        Text(
          '${activeJobs.length} jobs running',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: c.textMuted,
              ),
        ),
      ],
    );

    final list = activeJobs.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.xl),
            child: Center(
              child: Text(
                'No active jobs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.textMuted,
                    ),
              ),
            ),
          )
        : Column(
            children: [
              for (final job in activeJobs)
                JobQueueActiveJobCard(job: job, onCancel: onCancel),
            ],
          );

    if (!fill) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: TraqSpacing.lg),
          list,
        ],
      );
    }

    return Padding(
      padding: TraqSpacing.surfacePad,
      child: Column(
        children: [
          header,
          const SizedBox(height: TraqSpacing.lg),
          Expanded(
            child: activeJobs.isEmpty
                ? Center(
                    child: Text(
                      'No active jobs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: c.textMuted,
                          ),
                    ),
                  )
                : ListView.builder(
                    itemCount: activeJobs.length,
                    itemBuilder: (context, index) {
                      return JobQueueActiveJobCard(
                        job: activeJobs[index],
                        onCancel: onCancel,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
