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

class AutomationHealthSignalTile extends StatelessWidget {
  const AutomationHealthSignalTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.tone,
    this.onTap,
  });

  final String icon;
  final String title;
  final String value;
  final String detail;
  final JobQueueStatusTone tone;
  final VoidCallback? onTap;

  Color _toneColor(BuildContext context) => switch (tone) {
    JobQueueStatusTone.ok => AppColorMapper.successColor(context),
    JobQueueStatusTone.warn => AppColorMapper.warningColor(context),
    JobQueueStatusTone.err => AppColorMapper.errorColor(context),
    JobQueueStatusTone.info => AppColorMapper.infoColor(context),
    JobQueueStatusTone.muted => context.colors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = _toneColor(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: TraqRadius.card,
          child: Padding(
            padding: TraqSpacing.surfacePad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TraqIcon(icon, size: 16, color: accent),
                    const SizedBox(width: TraqSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: context.text.cap.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TraqSpacing.sm),
                Text(
                  value,
                  style: context.text.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: TraqSpacing.xs),
                Text(
                  detail,
                  style: context.text.cap.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
