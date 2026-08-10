import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/cards/job_queue_queued_job_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/filters/job_queue_status_filter.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/priority_distribution_card.dart';

class JobQueueQueueTab extends StatelessWidget {
  final List<Map<String, dynamic>> queuedJobs;
  final bool fill;
  final String selectedStatus;
  final List<String> statuses;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<Map<String, dynamic>> onShowDetails;
  final ValueChanged<String> onCancel;
  final Map<String, int> priorityDistribution;

  const JobQueueQueueTab({
    super.key,
    required this.queuedJobs,
    required this.fill,
    required this.selectedStatus,
    required this.statuses,
    required this.onStatusChanged,
    required this.onShowDetails,
    required this.onCancel,
    required this.priorityDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final header = Row(
      children: [
        Text(
          'Job Queue',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        const Spacer(),
        JobQueueStatusFilter(
          selectedStatus: selectedStatus,
          statuses: statuses,
          onChanged: onStatusChanged,
        ),
      ],
    );

    final list = queuedJobs.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.xl),
            child: Center(
              child: Text(
                'No jobs in queue',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: c.textMuted),
              ),
            ),
          )
        : Column(
            children: [
              JobQueuePriorityDistributionCard(
                distribution: priorityDistribution,
              ),
              const SizedBox(height: TraqSpacing.lg),
              for (final job in queuedJobs)
                JobQueueQueuedJobCard(
                  job: job,
                  onShowDetails: onShowDetails,
                  onCancel: onCancel,
                ),
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
          JobQueuePriorityDistributionCard(distribution: priorityDistribution),
          const SizedBox(height: TraqSpacing.lg),
          Expanded(
            child: queuedJobs.isEmpty
                ? Center(
                    child: Text(
                      'No jobs in queue',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: c.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: queuedJobs.length,
                    itemBuilder: (context, index) {
                      return JobQueueQueuedJobCard(
                        job: queuedJobs[index],
                        onShowDetails: onShowDetails,
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
