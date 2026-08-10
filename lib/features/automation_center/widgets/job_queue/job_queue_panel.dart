import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_control_panel_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_job_details_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_purge_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_schedule_job_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_worker_pool_config_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_active_jobs_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_dashboard_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_history_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_queue_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_selected_tab_content.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_worker_pool_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_filters.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_priority_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';

class JobQueuePanel extends StatefulWidget {
  /// When true, content is intrinsic-height for a parent single-scroll pane
  /// (Automation Center). Admin full-page use keeps [embedded] false.
  final bool embedded;

  /// Optional shared cubit (Notifications workspace). When null the panel
  /// creates and owns a DI factory instance.
  final JobQueueCubit? cubit;

  const JobQueuePanel({
    Key? key,
    this.embedded = false,
    this.cubit,
  }) : super(key: key);

  @override
  JobQueuePanelState createState() => JobQueuePanelState();
}

class JobQueuePanelState extends State<JobQueuePanel>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// Owns the cubit lifecycle when [JobQueuePanel.cubit] is null: created from
  /// the DI factory, provided down to the tabs via [BlocProvider.value], and
  /// closed in [dispose]. Live updates arrive over the shared WebSocket.
  late final JobQueueCubit _cubit;
  late final bool _ownsCubit;

  late TabController _tabController;

  String _selectedJobType = 'ALL';
  String _selectedStatus = 'ALL';

  final List<String> _jobTypes = [
    'ALL',
    'NOTIFICATION_BATCH',
    'NOTIFICATION_SCHEDULED',
  ];
  final List<String> _jobStatuses = [
    'ALL',
    'QUEUED',
    'RUNNING',
    'COMPLETED',
    'FAILED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    final external = widget.cubit;
    if (external != null) {
      _cubit = external;
      _ownsCubit = false;
    } else {
      _cubit = getIt<JobQueueCubit>();
      _ownsCubit = true;
      _cubit.connectWebSocket();
    }
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _cubit.handleAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _cubit.handleAppPaused();
        break;
    }
  }

  // ---- Public API driven via GlobalKey<JobQueuePanelState> from the parent panel ----

  void refreshCurrentTab() => _cubit.refresh();

  void showScheduleJobDialog() => _showScheduleJobDialog();

  /// Opens the operations Control Panel. Exposed for the panel header action.
  void showControlPanel() => _showControlPanel();

  // ---- Filter selection over the live snapshot lists (filtering itself is in JobQueueFilters) ----

  void _onStatusFilterChanged(String value) {
    setState(() => _selectedStatus = value);
  }

  void _onJobTypeFilterChanged(String value) {
    setState(() => _selectedJobType = value);
  }

  void _openTab(int index) {
    _tabController.animateTo(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JobQueueCubit>.value(
      value: _cubit,
      child: BlocBuilder<JobQueueCubit, JobQueueState>(
        builder: (context, state) {
          final embedded = widget.embedded;
          final snapshot = state.snapshot;

          if (snapshot == null) {
            if (state.status == JobQueueStatus.error) {
              return SubscriptionErrorView(
                title: 'Unable to load job queue',
                message: state.error ?? 'Failed to load job queue data',
                onRetry: _cubit.loadInitial,
                padding: embedded
                    ? const EdgeInsets.symmetric(vertical: TraqSpacing.lg)
                    : TraqSpacing.pagePad,
              );
            }
            return SubscriptionLoadingSkeleton(
              shrinkWrap: false,
              asColumn: embedded,
              itemCount: 4,
              shape: SubscriptionSkeletonShape.jobQueueCard,
            );
          }

          return _buildContent(context, snapshot);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    JobQueueDashboardSnapshot snapshot,
  ) {
    final c = context.colors;
    final embedded = widget.embedded;

    final activeJobs = snapshot.activeJobsList;
    final queuedJobs = JobQueueFilters.byStatus(
      snapshot.queuedJobsList,
      _selectedStatus,
    );
    final jobHistory = JobQueueFilters.byJobType(
      snapshot.recentHistory,
      _selectedJobType,
    );
    final workerPoolStats = snapshot.workerPoolStats;

    final tabBar = Material(
      color: c.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: c.primary,
        indicatorWeight: 3,
        labelColor: c.primary,
        unselectedLabelColor: c.textMuted,
        labelStyle: context.text.bodySm.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: context.text.bodySm,
        tabs: const [
          Tab(icon: TraqIcon(NavIcons.dashboard), text: 'Overview'),
          Tab(icon: TraqIcon(AppAssets.iconPlay), text: 'Running'),
          Tab(icon: TraqIcon(AppAssets.iconList), text: 'Waiting'),
          Tab(icon: TraqIcon(AppAssets.iconClock), text: 'History'),
          Tab(icon: TraqIcon(AppAssets.iconUsers), text: 'Worker Pool'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          tabBar,
          Divider(height: 1, color: c.border),
          const SizedBox(height: TraqSpacing.md),
          JobQueueSelectedTabContent(
            tabIndex: _tabController.index,
            dashboardSnapshot: snapshot,
            activeJobs: activeJobs,
            queuedJobs: queuedJobs,
            jobHistory: jobHistory,
            workerPoolStats: workerPoolStats,
            selectedStatus: _selectedStatus,
            statuses: _jobStatuses,
            selectedJobType: _selectedJobType,
            jobTypes: _jobTypes,
            onDashboardRefresh: refreshCurrentTab,
            onSchedule: showScheduleJobDialog,
            onOpenActive: () => _openTab(1),
            onOpenQueue: () => _openTab(2),
            onOpenHistory: () => _openTab(3),
            onOpenWorkers: () => _openTab(4),
            onCancel: _cancelJob,
            onRetry: _retryJob,
            onShowDetails: _showJobDetails,
            onStatusChanged: _onStatusFilterChanged,
            onJobTypeChanged: _onJobTypeFilterChanged,
            onConfigureWorkers: _showWorkerPoolConfig,
          ),

        ],
      );
    }

    return ColoredBox(
      color: c.background,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                tabBar,
                Divider(height: 1, color: c.border),
                Expanded(
                  child: ColoredBox(
                    color: c.background,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        JobQueueDashboardTab(
                          snapshot: snapshot,
                          embedded: false,
                          onRefresh: refreshCurrentTab,
                          onSchedule: showScheduleJobDialog,
                          onOpenActive: () => _openTab(1),
                          onOpenQueue: () => _openTab(2),
                          onOpenHistory: () => _openTab(3),
                          onOpenWorkers: () => _openTab(4),
                        ),
                        JobQueueActiveJobsTab(
                          activeJobs: activeJobs,
                          fill: true,
                          onCancel: _cancelJob,
                        ),
                        JobQueueQueueTab(
                          queuedJobs: queuedJobs,
                          priorityDistribution: snapshot.priorityDistribution,
                          fill: true,
                          selectedStatus: _selectedStatus,
                          statuses: _jobStatuses,
                          onStatusChanged: _onStatusFilterChanged,
                          onShowDetails: _showJobDetails,
                          onCancel: _cancelJob,
                        ),
                        JobQueueHistoryTab(
                          jobHistory: jobHistory,
                          jobTypeDistribution: snapshot.jobTypeDistribution,
                          fill: true,
                          selectedJobType: _selectedJobType,
                          jobTypes: _jobTypes,
                          onJobTypeChanged: _onJobTypeFilterChanged,
                          onShowDetails: _showJobDetails,
                          onRetry: _retryJob,
                        ),
                        JobQueueWorkerPoolTab(
                          workerPoolStats: workerPoolStats,
                          snapshot: snapshot,
                          fill: true,
                          onConfigure: _showWorkerPoolConfig,
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

  Future<void> _cancelJob(String jobId) async {
    try {
      await _cubit.cancelJob(jobId);
      if (!mounted) return;
      context.showSuccess('Job cancelled successfully');
    } catch (e) {
      if (!mounted) return;
      context.showError('Failed to cancel job: $e');
    }
  }

  Future<void> _retryJob(String jobId) async {
    try {
      await _cubit.retryJob(jobId);
      if (!mounted) return;
      context.showSuccess('Job retried successfully');
    } catch (e) {
      if (!mounted) return;
      context.showError('Failed to retry job: $e');
    }
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => JobQueueJobDetailsDialog(job: job),
    );
  }

  void _showControlPanel() {
    showDialog(
      context: context,
      builder: (context) => JobQueueControlPanelDialog(
        processingPaused: _cubit.state.snapshot?.processingPaused ?? false,
        onPause: _pauseProcessing,
        onResume: _resumeProcessing,
        onConfigureWorkers: _showWorkerPoolConfig,
        onPurge: _showPurgeDialog,
      ),
    );
  }

  Future<void> _showWorkerPoolConfig() async {
    final stats = _cubit.state.snapshot?.workerPoolStats ?? const {};
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => JobQueueWorkerPoolConfigDialog(
        initialCorePoolSize: '${stats['corePoolSize'] ?? 4}',
        initialMaxPoolSize: '${stats['maximumPoolSize'] ?? 8}',
        initialQueueCapacity: '100',
        onPrefill: _cubit.getWorkerPoolConfig,
        onSave:
            ({
              required int corePoolSize,
              required int maxPoolSize,
              required int queueCapacity,
            }) {
              return _cubit.configureWorkerPool(
                corePoolSize: corePoolSize,
                maxPoolSize: maxPoolSize,
                queueCapacity: queueCapacity,
              );
            },
      ),
    );
    if (result == null || !mounted) return;
    context.showSuccess('${result['message'] ?? 'Worker pool configured'}');
  }

  Future<void> _showPurgeDialog() async {
    final outcome = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => JobQueuePurgeDialog(
        onPurge: (days) => _cubit.purgeJobs(retentionDays: days),
      ),
    );
    if (outcome == null || !mounted) return;
    final days = outcome['days'] as int? ?? 0;
    final result = outcome['result'] as Map<String, dynamic>? ?? {};
    final count = result['purgedCount'] ?? 0;
    context.showSuccess('Purged $count job(s) older than $days day(s)');
  }

  Future<void> _pauseProcessing() async {
    try {
      await _cubit.pauseQueue();
      if (!mounted) return;
      context.showInfo('Job processing paused');
    } catch (e) {
      if (!mounted) return;
      context.showError('Failed to pause processing: $e');
    }
  }

  Future<void> _resumeProcessing() async {
    try {
      await _cubit.resumeQueue();
      if (!mounted) return;
      context.showInfo('Job processing resumed');
    } catch (e) {
      if (!mounted) return;
      context.showError('Failed to resume processing: $e');
    }
  }

  Future<void> _showScheduleJobDialog() async {
    final request = await showDialog<JobQueueScheduleSubmitRequest>(
      context: context,
      builder: (context) => const JobQueueScheduleJobDialog(),
    );
    if (request == null) return;
    await _submitJobNow(
      jobName: request.jobName,
      jobType: request.jobType,
      description: request.description,
      priorityLabel: request.priorityLabel,
      parameters: request.parameters,
    );
  }

  Future<void> _submitJobNow({
    required String jobName,
    required String jobType,
    required String description,
    required String priorityLabel,
    required List<Map<String, String>> parameters,
  }) async {
    try {
      final jobPayload = <String, dynamic>{
        'name': jobName,
        'description': description,
        'parameters': {
          for (final p in parameters)
            if ((p['key'] ?? '').isNotEmpty) p['key']: p['value'],
        },
      };

      if (jobType == 'NOTIFICATION_BATCH' || jobType == 'NOTIFICATION_SCHEDULED') {
        jobPayload['operation'] = 'processScheduledBatchNotifications';
      }

      await _cubit.submitJob(
        jobType: jobType,
        priority: JobQueuePriorityUtils.fromLabel(priorityLabel),
        payload: jobPayload,
      );
      if (!mounted) return;
      context.showSuccess('Job "$jobName" submitted successfully');
    } catch (e) {
      if (!mounted) return;
      context.showError('Failed to submit job: $e');
    }
  }
}
