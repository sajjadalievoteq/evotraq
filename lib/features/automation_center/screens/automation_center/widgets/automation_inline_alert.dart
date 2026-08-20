import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Cross-cutting health rollup â€” no duplicated tab content (metrics, activity
/// feeds, live toggles, or job dashboards live on their own tabs).

class AutomationInlineAlert extends StatelessWidget {
  const AutomationInlineAlert({
    required this.tone,
    required this.title,
    required this.message,
  });

  final JobQueueStatusTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (tone) {
      JobQueueStatusTone.ok => AppColorMapper.successColor(context),
      JobQueueStatusTone.warn => AppColorMapper.warningColor(context),
      JobQueueStatusTone.err => AppColorMapper.errorColor(context),
      JobQueueStatusTone.info => AppColorMapper.infoColor(context),
      JobQueueStatusTone.muted => c.textMuted,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: TraqRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TraqIcon(AppAssets.iconAlert, size: 18, color: color),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  Text(
                    message,
                    style: context.text.cap.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
