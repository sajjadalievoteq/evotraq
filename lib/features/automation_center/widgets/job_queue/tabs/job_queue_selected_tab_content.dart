import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_active_jobs_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_dashboard_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_history_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_queue_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_worker_pool_tab.dart';

/// Renders the selected tab when the panel is embedded (no [TabBarView]).
class JobQueueSelectedTabContent extends StatelessWidget {
  final int tabIndex;
  final JobQueueDashboardSnapshot dashboardSnapshot;
  final List<Map<String, dynamic>> activeJobs;
  final List<Map<String, dynamic>> queuedJobs;
  final List<Map<String, dynamic>> jobHistory;
  final Map<String, dynamic> workerPoolStats;
  final String selectedStatus;
  final List<String> statuses;
  final String selectedJobType;
  final List<String> jobTypes;
  final VoidCallback onDashboardRefresh;
  final VoidCallback onSchedule;
  final VoidCallback onOpenActive;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenWorkers;
  final ValueChanged<String> onCancel;
  final ValueChanged<String> onRetry;
  final ValueChanged<Map<String, dynamic>> onShowDetails;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onJobTypeChanged;
  final VoidCallback onConfigureWorkers;

  const JobQueueSelectedTabContent({
    super.key,
    required this.tabIndex,
    required this.dashboardSnapshot,
    required this.activeJobs,
    required this.queuedJobs,
    required this.jobHistory,
    required this.workerPoolStats,
    required this.selectedStatus,
    required this.statuses,
    required this.selectedJobType,
    required this.jobTypes,
    required this.onDashboardRefresh,
    required this.onSchedule,
    required this.onOpenActive,
    required this.onOpenQueue,
    required this.onOpenHistory,
    required this.onOpenWorkers,
    required this.onCancel,
    required this.onRetry,
    required this.onShowDetails,
    required this.onStatusChanged,
    required this.onJobTypeChanged,
    required this.onConfigureWorkers,
  });

  @override
  Widget build(BuildContext context) {
    switch (tabIndex) {
      case 0:
        return JobQueueDashboardTab(
          snapshot: dashboardSnapshot,
          embedded: true,
          onRefresh: onDashboardRefresh,
          onSchedule: onSchedule,
          onOpenActive: onOpenActive,
          onOpenQueue: onOpenQueue,
          onOpenHistory: onOpenHistory,
          onOpenWorkers: onOpenWorkers,
        );
      case 1:
        return JobQueueActiveJobsTab(
          activeJobs: activeJobs,
          fill: false,
          onCancel: onCancel,
        );
      case 2:
        return JobQueueQueueTab(
          queuedJobs: queuedJobs,
          fill: false,
          selectedStatus: selectedStatus,
          statuses: statuses,
          onStatusChanged: onStatusChanged,
          onShowDetails: onShowDetails,
          onCancel: onCancel,
        );
      case 3:
        return JobQueueHistoryTab(
          jobHistory: jobHistory,
          fill: false,
          selectedJobType: selectedJobType,
          jobTypes: jobTypes,
          onJobTypeChanged: onJobTypeChanged,
          onShowDetails: onShowDetails,
          onRetry: onRetry,
        );
      case 4:
        return JobQueueWorkerPoolTab(
          workerPoolStats: workerPoolStats,
          fill: false,
          onConfigure: onConfigureWorkers,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
