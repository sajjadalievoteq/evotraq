import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_active_jobs_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_dashboard_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_history_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_queue_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_selected_tab_content.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_worker_pool_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_filters.dart';

class JobQueuePanelContent extends StatelessWidget {
  const JobQueuePanelContent({
    super.key,
    required this.snapshot,
    required this.embedded,
    required this.tabController,
    required this.selectedStatus,
    required this.statuses,
    required this.selectedJobType,
    required this.jobTypes,
    required this.onTabChanged,
    required this.onRefresh,
    required this.onSchedule,
    required this.onOpenTab,
    required this.onCancel,
    required this.onRetry,
    required this.onShowDetails,
    required this.onStatusChanged,
    required this.onJobTypeChanged,
    required this.onConfigureWorkers,
  });

  final JobQueueDashboardSnapshot snapshot;
  final bool embedded;
  final TabController tabController;
  final String selectedStatus;
  final List<String> statuses;
  final String selectedJobType;
  final List<String> jobTypes;
  final VoidCallback onTabChanged;
  final VoidCallback onRefresh;
  final VoidCallback onSchedule;
  final ValueChanged<int> onOpenTab;
  final Future<void> Function(String jobId) onCancel;
  final Future<void> Function(String jobId) onRetry;
  final ValueChanged<Map<String, dynamic>> onShowDetails;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onJobTypeChanged;
  final VoidCallback onConfigureWorkers;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeJobs = snapshot.activeJobsList;
    final queuedJobs = JobQueueFilters.byStatus(
      snapshot.queuedJobsList,
      selectedStatus,
    );
    final jobHistory = JobQueueFilters.byJobType(
      snapshot.recentHistory,
      selectedJobType,
    );
    final workerPoolStats = snapshot.workerPoolStats;

    final tabBar = Material(
      color: colors.surface,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: colors.primary,
        indicatorWeight: 3,
        labelColor: colors.primary,
        unselectedLabelColor: colors.textMuted,
        labelStyle: context.text.bodySm.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: context.text.bodySm,
        tabs: const [
          Tab(icon: TraqIcon(NavIcons.dashboard), text: 'Overview'),
          Tab(icon: TraqIcon(AppAssets.iconPlay), text: 'Running'),
          Tab(icon: TraqIcon(AppAssets.iconList), text: 'Waiting'),
          Tab(icon: TraqIcon(AppAssets.iconClock), text: 'History'),
          Tab(icon: TraqIcon(AppAssets.iconUsers), text: 'Worker Pool'),
        ],
        onTap: (_) => onTabChanged(),
      ),
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          tabBar,
          Divider(height: 1, color: colors.border),
          const SizedBox(height: TraqSpacing.md),
          JobQueueSelectedTabContent(
            tabIndex: tabController.index,
            dashboardSnapshot: snapshot,
            activeJobs: activeJobs,
            queuedJobs: queuedJobs,
            jobHistory: jobHistory,
            workerPoolStats: workerPoolStats,
            selectedStatus: selectedStatus,
            statuses: statuses,
            selectedJobType: selectedJobType,
            jobTypes: jobTypes,
            onDashboardRefresh: onRefresh,
            onSchedule: onSchedule,
            onOpenActive: () => onOpenTab(1),
            onOpenQueue: () => onOpenTab(2),
            onOpenHistory: () => onOpenTab(3),
            onOpenWorkers: () => onOpenTab(4),
            onCancel: onCancel,
            onRetry: onRetry,
            onShowDetails: onShowDetails,
            onStatusChanged: onStatusChanged,
            onJobTypeChanged: onJobTypeChanged,
            onConfigureWorkers: onConfigureWorkers,
          ),
        ],
      );
    }

    return ColoredBox(
      color: colors.background,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                tabBar,
                Divider(height: 1, color: colors.border),
                Expanded(
                  child: ColoredBox(
                    color: colors.background,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        JobQueueDashboardTab(
                          snapshot: snapshot,
                          embedded: false,
                          onRefresh: onRefresh,
                          onSchedule: onSchedule,
                          onOpenActive: () => onOpenTab(1),
                          onOpenQueue: () => onOpenTab(2),
                          onOpenHistory: () => onOpenTab(3),
                          onOpenWorkers: () => onOpenTab(4),
                        ),
                        JobQueueActiveJobsTab(
                          activeJobs: activeJobs,
                          fill: true,
                          onCancel: onCancel,
                        ),
                        JobQueueQueueTab(
                          queuedJobs: queuedJobs,
                          priorityDistribution: snapshot.priorityDistribution,
                          fill: true,
                          selectedStatus: selectedStatus,
                          statuses: statuses,
                          onStatusChanged: onStatusChanged,
                          onShowDetails: onShowDetails,
                          onCancel: onCancel,
                        ),
                        JobQueueHistoryTab(
                          jobHistory: jobHistory,
                          jobTypeDistribution: snapshot.jobTypeDistribution,
                          fill: true,
                          selectedJobType: selectedJobType,
                          jobTypes: jobTypes,
                          onJobTypeChanged: onJobTypeChanged,
                          onShowDetails: onShowDetails,
                          onRetry: onRetry,
                        ),
                        JobQueueWorkerPoolTab(
                          workerPoolStats: workerPoolStats,
                          snapshot: snapshot,
                          fill: true,
                          onConfigure: onConfigureWorkers,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
