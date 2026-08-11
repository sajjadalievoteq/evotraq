import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_health_signal_tile.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_health_summary.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

class AutomationHealthSignals extends StatelessWidget {
  const AutomationHealthSignals({
    super.key,
    required this.summary,
    this.onOpenSubscriptions,
    this.onOpenActivity,
    this.onOpenJobOperations,
  });

  final AutomationHealthSummary summary;
  final VoidCallback? onOpenSubscriptions;
  final VoidCallback? onOpenActivity;
  final VoidCallback? onOpenJobOperations;

  @override
  Widget build(BuildContext context) {
    final wsValue = summary.livePaused
        ? 'Paused'
        : summary.connecting
        ? 'Connecting'
        : summary.live
        ? 'Connected'
        : 'Offline';
    final signals = <Widget>[
      AutomationHealthSignalTile(
        icon: NavIcons.manageSubscriptions,
        title: 'Subscriptions',
        value: '${summary.activeSubscriptions} active',
        detail: summary.failedDeliveries > 0
            ? '${summary.failedDeliveries} failed deliveries'
            : 'Manage configs',
        tone: summary.failedDeliveries > 0
            ? JobQueueStatusTone.warn
            : JobQueueStatusTone.ok,
        onTap: onOpenSubscriptions,
      ),
      AutomationHealthSignalTile(
        icon: NavIcons.notificationCenter,
        title: 'Live feed',
        value: wsValue,
        detail: 'Delivery events',
        tone: summary.live
            ? JobQueueStatusTone.ok
            : summary.connecting
            ? JobQueueStatusTone.warn
            : JobQueueStatusTone.muted,
        onTap: onOpenActivity,
      ),
      AutomationHealthSignalTile(
        icon: NavIcons.jobQueueManagement,
        title: 'Job queue',
        value: summary.queueLabel,
        detail: summary.queuePaused
            ? 'Processing paused'
            : 'Open Job Operations',
        tone: summary.queuePaused
            ? JobQueueStatusTone.warn
            : summary.queueOk
            ? JobQueueStatusTone.ok
            : JobQueueStatusTone.err,
        onTap: onOpenJobOperations,
      ),
      AutomationHealthSignalTile(
        icon: AppAssets.iconUsers,
        title: 'Workers',
        value: summary.workerSummary,
        detail: onOpenJobOperations == null
            ? 'Admin only'
            : 'Worker pool details',
        tone: summary.workerUtilization > 0.9
            ? JobQueueStatusTone.warn
            : JobQueueStatusTone.ok,
        onTap: onOpenJobOperations,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < signals.length; i++) ...[
                Expanded(child: signals[i]),
                if (i != signals.length - 1)
                  const SizedBox(width: TraqSpacing.md),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < signals.length; i++) ...[
              signals[i],
              if (i != signals.length - 1)
                const SizedBox(height: TraqSpacing.md),
            ],
          ],
        );
      },
    );
  }
}
