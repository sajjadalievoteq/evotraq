import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

class JobQueueActiveJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final ValueChanged<String> onCancel;

  const JobQueueActiveJobCard({
    super.key,
    required this.job,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (job['progress'] as num?)?.toDouble() ?? 0;
    final jobType = '${job['jobType'] ?? ''}';
    final status = '${job['status'] ?? ''}';
    final startTime = '${job['startTime'] ?? ''}';
    final elapsedTime = '${job['elapsedTime'] ?? ''}';
    final statusColor = StatusVisualMappers.queueJobStatusColor(
      context,
      status,
    );
    final c = context.colors;

    return TraqCard(
      padding: TraqSpacing.surfacePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TraqSpacing.sm,
                  vertical: TraqSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: OperationPalette.soft(
                    StatusVisualMappers.jobTypeColor(context, jobType),
                  ),
                  borderRadius: TraqRadius.chip,
                  border: Border.all(
                    color: StatusVisualMappers.jobTypeColor(
                      context,
                      jobType,
                    ).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  jobType,
                  style: context.text.cap.copyWith(
                    color: StatusVisualMappers.jobTypeColor(context, jobType),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: TraqSpacing.sm),
              JobQueueStatusBadgeInline(label: status, color: statusColor),
              const Spacer(),
              Text(
                'Priority ${job['priority'] ?? 5}',
                style: context.text.cap.copyWith(color: c.textMuted),
              ),
              IconButton(
                onPressed: () => onCancel('${job['jobId']}'),
                icon: TraqIcon(
                  AppAssets.iconX,
                  color: AppColorMapper.errorColor(context),
                ),
                tooltip: 'Cancel Job',
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.xs),
          Text(
            '${job['jobId'] ?? ''}',
            style: context.text.bodySm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: TraqSpacing.md),
          LinearProgressIndicator(
            value: (progress / 100.0).clamp(0.0, 1.0),
            backgroundColor: c.surfaceMuted,
            color: statusColor,
            minHeight: 6,
          ),
          const SizedBox(height: TraqSpacing.sm),
          Row(
            children: [
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: context.text.cap.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              if (elapsedTime.isNotEmpty)
                Text(
                  'Elapsed: $elapsedTime',
                  style: context.text.cap.copyWith(color: c.textMuted),
                ),
            ],
          ),
          if (startTime.isNotEmpty) ...[
            const SizedBox(height: TraqSpacing.xs),
            Text(
              'Started: $startTime',
              style: context.text.cap.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
