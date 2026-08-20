import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_status_badge.dart';

/// Cross-cutting health rollup â€” no duplicated tab content (metrics, activity
/// feeds, live toggles, or job dashboards live on their own tabs).

class AutomationHealthSummary {
  const AutomationHealthSummary({
    required this.overallLabel,
    required this.overallTone,
    required this.pulse,
    required this.activeSubscriptions,
    required this.failedDeliveries,
    required this.live,
    required this.connecting,
    required this.livePaused,
    required this.queueLabel,
    required this.queueOk,
    required this.queuePaused,
    required this.workerSummary,
    required this.workerUtilization,
    required this.lastUpdated,
  });

  final String overallLabel;
  final JobQueueStatusTone overallTone;
  final bool pulse;
  final int activeSubscriptions;
  final int failedDeliveries;
  final bool live;
  final bool connecting;
  final bool livePaused;
  final String queueLabel;
  final bool queueOk;
  final bool queuePaused;
  final String workerSummary;
  final double workerUtilization;
  final DateTime? lastUpdated;
}
