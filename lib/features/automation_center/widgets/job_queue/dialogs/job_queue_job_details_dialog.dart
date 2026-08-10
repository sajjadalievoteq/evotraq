import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

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
              _DetailRow(
                label: 'Status',
                value: '${job['status'] ?? 'Unknown'}',
              ),
              _DetailRow(
                label: 'Priority',
                value: '${job['priority'] ?? 'Default'}',
              ),
              const SizedBox(height: TraqSpacing.lg),
              Text('Timing', style: context.text.h3),
              const SizedBox(height: TraqSpacing.sm),
              if (job['submittedTime'] != null)
                _DetailRow(
                  label: 'Submitted',
                  value: '${job['submittedTime']}',
                ),
              if (job['startTime'] != null)
                _DetailRow(label: 'Started', value: '${job['startTime']}'),
              if (job['endTime'] != null)
                _DetailRow(label: 'Completed', value: '${job['endTime']}'),
              if (job['executionTime'] != null)
                _DetailRow(label: 'Duration', value: '${job['executionTime']}'),
              if (job['progress'] != null)
                _DetailRow(label: 'Progress', value: '${job['progress']}%'),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: context.text.bodySm.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
