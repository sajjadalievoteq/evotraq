import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class JobQueueQueuedJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final ValueChanged<Map<String, dynamic>> onShowDetails;
  final ValueChanged<String> onCancel;

  const JobQueueQueuedJobCard({
    super.key,
    required this.job,
    required this.onShowDetails,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final jobType = '${job['jobType'] ?? ''}';
    final priority = job['priority'] ?? 5;
    final queuePosition = job['queuePosition'] ?? 0;
    final submittedTime = '${job['submittedTime'] ?? ''}';
    final typeColor = StatusVisualMappers.jobTypeColor(context, jobType);
    final c = context.colors;

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
                  Text(
                    'Priority: $priority · Position: $queuePosition',
                    style: context.text.bodySm.copyWith(color: c.textSecondary),
                  ),
                  if (submittedTime.isNotEmpty)
                    Text(
                      'Submitted: $submittedTime',
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
      ),
    );
  }
}
