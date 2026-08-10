import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

class JobQueueHistoryJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final ValueChanged<Map<String, dynamic>> onShowDetails;
  final ValueChanged<String> onRetry;

  const JobQueueHistoryJobCard({
    super.key,
    required this.job,
    required this.onShowDetails,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final jobType = '${job['jobType'] ?? ''}';
    final status = '${job['status'] ?? ''}';
    final executionTime = '${job['executionTime'] ?? ''}';
    final endTime = '${job['endTime'] ?? ''}';
    final typeColor = StatusVisualMappers.jobTypeColor(context, jobType);
    final statusColor = StatusVisualMappers.queueJobStatusColor(
      context,
      status,
    );
    final c = context.colors;
    final canRetry = status.toUpperCase() == 'FAILED';

    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: TraqCard(
        padding: TraqSpacing.surfacePad,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.sm,
                vertical: TraqSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: OperationPalette.soft(typeColor),
                borderRadius: TraqRadius.chip,
                border: Border.all(color: typeColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                jobType,
                style: context.text.cap.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${job['jobId'] ?? ''}',
                    style: context.text.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  Wrap(
                    spacing: TraqSpacing.sm,
                    runSpacing: TraqSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      JobQueueStatusBadgeInline(
                        label: status,
                        color: statusColor,
                      ),
                      if (executionTime.isNotEmpty)
                        Text(
                          'Duration: $executionTime',
                          style: context.text.cap.copyWith(color: c.textMuted),
                        ),
                    ],
                  ),
                  if (endTime.isNotEmpty)
                    Text(
                      'Completed: $endTime',
                      style: context.text.cap.copyWith(color: c.textMuted),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onShowDetails(job),
              icon: TraqIcon(AppAssets.iconInfo),
              tooltip: 'Job Details',
            ),
            if (canRetry)
              IconButton(
                onPressed: () => onRetry('${job['jobId']}'),
                icon: TraqIcon(
                  AppAssets.iconRefresh,
                  color: AppColorMapper.infoColor(context),
                ),
                tooltip: 'Retry Job',
              ),
          ],
        ),
      ),
    );
  }
}
