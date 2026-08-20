import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

/// Cross-cutting health rollup â€” no duplicated tab content (metrics, activity
/// feeds, live toggles, or job dashboards live on their own tabs).
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_health_summary.dart';

class AutomationOverallHealthHero extends StatelessWidget {
  const AutomationOverallHealthHero({required this.summary});

  final AutomationHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final last = summary.lastUpdated == null
        ? 'â€”'
        : DateFormat.Hms().format(summary.lastUpdated!.toLocal());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Health',
                    style: context.text.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  Text(
                    'Cross-cutting rollup Â· queue updated $last',
                    style: context.text.bodySm.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            JobQueueStatusBadge(
              label: summary.overallLabel,
              tone: summary.overallTone,
              pulse: summary.pulse,
            ),
          ],
        ),
      ),
    );
  }
}
