import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_job_detail_row.dart';

class JobQueueJobDetailsDialog extends StatelessWidget {
  const JobQueueJobDetailsDialog({super.key, required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${job['jobType'] ?? 'Job'}'),
          const SizedBox(height: TraqSpacing.xs),
          Text(
            '${job['jobId'] ?? 'ID unavailable'}',
            style: context.text.mono.copyWith(color: context.colors.textMuted),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              JobQueueJobDetailRow(
                label: 'Status',
                value: '${job['status'] ?? 'Unknown'}',
              ),
              JobQueueJobDetailRow(
                label: 'Priority',
                value: '${job['priority'] ?? 'Default'}',
              ),
              const SizedBox(height: TraqSpacing.lg),
              Text('Timing', style: context.text.h3),
              const SizedBox(height: TraqSpacing.sm),
              if (job['submittedTime'] != null)
                JobQueueJobDetailRow(
                  label: 'Submitted',
                  value: '${job['submittedTime']}',
                ),
              if (job['startTime'] != null)
                JobQueueJobDetailRow(
                  label: 'Started',
                  value: '${job['startTime']}',
                ),
              if (job['endTime'] != null)
                JobQueueJobDetailRow(
                  label: 'Completed',
                  value: '${job['endTime']}',
                ),
              if (job['executionTime'] != null)
                JobQueueJobDetailRow(
                  label: 'Duration',
                  value: '${job['executionTime']}',
                ),
              if (job['progress'] != null)
                JobQueueJobDetailRow(
                  label: 'Progress',
                  value: '${job['progress']}%',
                ),
              if (job['errorMessage'] != null) ...[
                const SizedBox(height: TraqSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TraqSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColorMapper.errorColor(
                      context,
                    ).withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColorMapper.errorColor(
                        context,
                      ).withValues(alpha: 0.35),
                    ),
                    borderRadius: TraqRadius.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Failure details',
                        style: context.text.h3.copyWith(
                          color: AppColorMapper.errorColor(context),
                        ),
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      SelectableText('${job['errorMessage']}'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
