import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_health_signals.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

/// Cross-cutting health rollup â€” no duplicated tab content (metrics, activity
/// feeds, live toggles, or job dashboards live on their own tabs).
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_health_summary.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_overall_health_hero.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_inline_alert.dart';

class AutomationHealthDashboard extends StatelessWidget {
  const AutomationHealthDashboard({
    required this.notification,
    required this.snapshot,
    required this.jobLoading,
    required this.jobError,
    required this.onOpenSubscriptions,
    required this.onOpenActivity,
    required this.onOpenJobOperations,
  });

  final NotificationState notification;
  final JobQueueDashboardSnapshot? snapshot;
  final bool jobLoading;
  final String? jobError;
  final VoidCallback? onOpenSubscriptions;
  final VoidCallback? onOpenActivity;
  final VoidCallback? onOpenJobOperations;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final summary = _buildSummary(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutomationOverallHealthHero(summary: summary),
          const SizedBox(height: TraqSpacing.lg),
          AutomationHealthSignals(
            summary: summary,
            onOpenSubscriptions: onOpenSubscriptions,
            onOpenActivity: onOpenActivity,
            onOpenJobOperations: onOpenJobOperations,
          ),
          if (jobError != null) ...[
            const SizedBox(height: TraqSpacing.lg),
            AutomationInlineAlert(
              tone: JobQueueStatusTone.err,
              title: 'Job queue unavailable',
              message: jobError!,
            ),
          ] else if (jobLoading) ...[
            const SizedBox(height: TraqSpacing.lg),
            AutomationInlineAlert(
              tone: JobQueueStatusTone.info,
              title: 'Loading job queue',
              message: 'Queue health will appear shortly.',
            ),
          ],
          if (snapshot != null && snapshot!.issues.isNotEmpty) ...[
            const SizedBox(height: TraqSpacing.lg),
            AutomationInlineAlert(
              tone: JobQueueStatusTone.warn,
              title: 'Detected issues',
              message: snapshot!.issues.join('\n'),
            ),
          ],
          const SizedBox(height: TraqSpacing.md),
          Text(
            'Use Subscriptions to manage configs, Activity for delivery events, '
            'and Job Operations for queue details.',
            style: context.text.cap.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }

  AutomationHealthSummary _buildSummary(BuildContext context) {
    final live =
        notification.notificationLiveEnabled &&
        notification.connectionStatus == NotificationConnectionStatus.connected;
    final connecting =
        notification.notificationLiveEnabled &&
        notification.connectionStatus ==
            NotificationConnectionStatus.connecting;
    final activeCount = notification.subscriptions
        .where((s) => s.status.toUpperCase() == 'ACTIVE')
        .length;
    final failed = notification.subscriptions.fold<int>(
      0,
      (sum, s) => sum + (s.stats?.failedNotifications ?? 0),
    );

    final deliveryOk = notification.subscriptions.isEmpty || failed == 0;
    final wsOk = live || !notification.notificationLiveEnabled;
    final queueOk = snapshot == null
        ? jobError == null
        : snapshot!.healthy && !snapshot!.processingPaused;

    final overallOk = deliveryOk && wsOk && queueOk && jobError == null;
    final overallWarn =
        connecting ||
        (snapshot?.processingPaused ?? false) ||
        (!overallOk && (deliveryOk || wsOk));

    return AutomationHealthSummary(
      overallLabel: overallOk
          ? 'All systems healthy'
          : overallWarn
          ? 'Attention needed'
          : 'Degraded',
      overallTone: overallOk
          ? JobQueueStatusTone.ok
          : overallWarn
          ? JobQueueStatusTone.warn
          : JobQueueStatusTone.err,
      pulse: live && overallOk,
      activeSubscriptions: activeCount,
      failedDeliveries: failed,
      live: live,
      connecting: connecting,
      livePaused: !notification.notificationLiveEnabled,
      queueLabel:
          snapshot?.statusLabel ??
          (jobError != null
              ? 'Unavailable'
              : jobLoading
              ? 'Loadingâ€¦'
              : 'â€”'),
      queueOk: queueOk,
      queuePaused: snapshot?.processingPaused ?? false,
      workerSummary: snapshot == null
          ? 'â€”'
          : '${snapshot!.workerActive} / ${snapshot!.workerMax} busy',
      workerUtilization: snapshot?.workerUtilization ?? 0,
      lastUpdated: snapshot?.lastUpdated,
    );
  }
}
