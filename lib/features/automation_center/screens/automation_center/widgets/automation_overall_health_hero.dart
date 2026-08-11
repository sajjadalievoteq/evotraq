import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_state.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

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
