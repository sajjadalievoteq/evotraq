import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/automation_center/job_queue_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_control_panel_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_job_details_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_purge_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_schedule_job_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_settings_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/dialogs/job_queue_worker_pool_config_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_active_jobs_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_dashboard_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_history_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_queue_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_selected_tab_content.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_worker_pool_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_dashboard_snapshot_builder.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_priority_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/widgets/job_queue_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/widgets/job_queue_loading_view.dart';

class JobQueuePanel extends StatefulWidget {
  final String baseUrl;
  final TokenManager tokenManager;

  /// When true, content is intrinsic-height for a parent single-scroll pane
  /// (Automation Center). Admin full-page use keeps [embedded] false.
  final bool embedded;

  const JobQueuePanel({
    Key? key,
    required this.baseUrl,
    required this.tokenManager,
    this.embedded = false,
  }) : super(key: key);

  @override
  JobQueuePanelState createState() => JobQueuePanelState();
}

class JobQueuePanelState extends State<JobQueuePanel>
    with TickerProviderStateMixin {
  JobQueueService get _service => getIt<JobQueueService>();

  late TabController _tabController;
  late Timer _refreshTimer;

  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _activeJobs = [];
  List<Map<String, dynamic>> _queuedJobs = [];
  List<Map<String, dynamic>> _jobHistory = [];
  Map<String, dynamic> _workerPoolStats = {};
  Map<String, dynamic> _queueHealth = {};

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedJobType = 'ALL';
  String _selectedStatus = 'ALL';
  bool _autoRefresh = true;
  int _refreshIntervalSeconds = 5;
  DateTime? _lastUpdated;
  final List<double> _activeSparkline = <double>[];
  final List<double> _queuedSparkline = <double>[];

  final List<String> _jobTypes = ['ALL', 'NOTIFICATION_BATCH'];
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
    _tabController = TabController(length: 5, vsync: this);
    _loadInitialData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshIntervalSeconds),
      (timer) {
        if (mounted && _autoRefresh) {
          refreshCurrentTab();
        }
      },
    );
  }

  void _restartRefreshTimer() {
    _refreshTimer.cancel();
    _startPeriodicRefresh();
  }

  void _setAutoRefresh(bool enabled) {
    setState(() => _autoRefresh = enabled);
  }

  void _applyRefreshPreferences({
    required bool autoRefresh,
    required int intervalSeconds,
  }) {
    setState(() {
      _autoRefresh = autoRefresh;
      _refreshIntervalSeconds = intervalSeconds.clamp(2, 120);
    });
    _restartRefreshTimer();
  }

  void _recordSparklineSample() {
    _activeSparkline.add(_activeJobs.length.toDouble());
    _queuedSparkline.add(_queuedJobs.length.toDouble());
    if (_activeSparkline.length > 16) {
      _activeSparkline.removeAt(0);
    }
    if (_queuedSparkline.length > 16) {
      _queuedSparkline.removeAt(0);
    }
    _lastUpdated = DateTime.now();
  }

  void refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _loadDashboardData();
        break;
      case 1:
        _loadActiveJobs();
        break;
      case 2:
        _loadQueuedJobs();
        break;
      case 3:
        _loadJobHistory();
        break;
      case 4:
        _loadWorkerPoolStats();
        break;
    }
  }

  void showScheduleJobDialog() => _showScheduleJobDialog();

  /// Opens the operations Control Panel. Exposed for the panel header action now
  /// that the duplicate top summary header (which used to host it) was removed.
  void showControlPanel() => _showControlPanel();

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadDashboardData(),
        _loadActiveJobs(),
        _loadQueueHealth(),
        _loadQueuedJobs(),
        _loadJobHistory(),
        _loadWorkerPoolStats(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load job queue data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _service.getDashboard();
      setState(() {
        _dashboardData = data;
        _recordSparklineSample();
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  Future<void> _loadActiveJobs() async {
    try {
      final jobs = await _service.getActiveJobs();
      setState(() {
        _activeJobs = jobs;
      });
    } catch (e) {
      debugPrint('Error loading active jobs: $e');
    }
  }

  Future<void> _loadQueuedJobs() async {
    try {
      final jobs = await _service.getQueuedJobs(
        status: _selectedStatus,
        limit: 100,
      );
      setState(() {
        _queuedJobs = jobs;
      });
    } catch (e) {
      debugPrint('Error loading queued jobs: $e');
    }
  }

  Future<void> _loadJobHistory() async {
    try {
      final history = await _service.getJobHistory(
        jobType: _selectedJobType,
        limit: 100,
      );
      setState(() {
        _jobHistory = history;
      });
    } catch (e) {
      debugPrint('Error loading job history: $e');
    }
  }

  Future<void> _loadWorkerPoolStats() async {
    try {
      final stats = await _service.getWorkerPoolStats();
      setState(() {
        _workerPoolStats = stats;
      });
    } catch (e) {
      debugPrint('Error loading worker pool stats: $e');
    }
  }

  Future<void> _loadQueueHealth() async {
    try {
      final health = await _service.getQueueHealth();
      setState(() {
        _queueHealth = health;
      });
    } catch (e) {
      debugPrint('Error loading queue health: $e');
    }
  }

  void _openTab(int index) {
    _tabController.animateTo(index);
    setState(() {});
    refreshCurrentTab();
  }

  void _onStatusFilterChanged(String value) {
    setState(() => _selectedStatus = value);
    _loadQueuedJobs();
  }

  void _onJobTypeFilterChanged(String value) {
    setState(() => _selectedJobType = value);
    _loadJobHistory();
  }

  void _refreshDashboard() {
    _loadDashboardData();
    _loadActiveJobs();
    _loadQueueHealth();
    _loadQueuedJobs();
    _loadJobHistory();
    _loadWorkerPoolStats();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final embedded = widget.embedded;

    if (_isLoading) {
      return JobQueueLoadingView(embedded: embedded);
    }

    if (_errorMessage != null) {
      return JobQueueErrorView(
        message: _errorMessage!,
        onRetry: _loadInitialData,
        embedded: embedded,
      );
    }

    final dashboardSnapshot = buildJobQueueDashboardSnapshot(
      dashboardData: _dashboardData,
      workerPoolStats: _workerPoolStats,
      queueHealth: _queueHealth,
      activeJobs: _activeJobs,
      queuedJobs: _queuedJobs,
      jobHistory: _jobHistory,
      activeSparkline: _activeSparkline,
      queuedSparkline: _queuedSparkline,
      lastUpdated: _lastUpdated,
      autoRefresh: _autoRefresh,
    );

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
          Tab(
            icon: TraqIcon(NavIcons.dashboard),
            text: 'Dashboard',
          ),
          Tab(
            icon: TraqIcon(AppAssets.iconPlay),
            text: 'Active Jobs',
          ),
          Tab(
            icon: TraqIcon(AppAssets.iconList),
            text: 'Queue',
          ),
          Tab(
            icon: TraqIcon(AppAssets.iconClock),
            text: 'History',
          ),
          Tab(
            icon: TraqIcon(AppAssets.iconUsers),
            text: 'Workers',
          ),
        ],
        onTap: (_) {
          setState(() {});
          refreshCurrentTab();
        },
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
            dashboardSnapshot: dashboardSnapshot,
            activeJobs: _activeJobs,
            queuedJobs: _queuedJobs,
            jobHistory: _jobHistory,
            workerPoolStats: _workerPoolStats,
            selectedStatus: _selectedStatus,
            statuses: _jobStatuses,
            selectedJobType: _selectedJobType,
            jobTypes: _jobTypes,
            onDashboardRefresh: _refreshDashboard,
            onSchedule: showScheduleJobDialog,
            onToggleAutoRefresh: _setAutoRefresh,
            onSettings: _showQueueSettings,
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
                          snapshot: dashboardSnapshot,
                          embedded: false,
                          onRefresh: _refreshDashboard,
                          onSchedule: showScheduleJobDialog,
                          onToggleAutoRefresh: _setAutoRefresh,
                          onSettings: _showQueueSettings,
                          onOpenActive: () => _openTab(1),
                          onOpenQueue: () => _openTab(2),
                          onOpenHistory: () => _openTab(3),
                          onOpenWorkers: () => _openTab(4),
                        ),
                        JobQueueActiveJobsTab(
                          activeJobs: _activeJobs,
                          fill: true,
                          onCancel: _cancelJob,
                        ),
                        JobQueueQueueTab(
                          queuedJobs: _queuedJobs,
                          fill: true,
                          selectedStatus: _selectedStatus,
                          statuses: _jobStatuses,
                          onStatusChanged: _onStatusFilterChanged,
                          onShowDetails: _showJobDetails,
                          onCancel: _cancelJob,
                        ),
                        JobQueueHistoryTab(
                          jobHistory: _jobHistory,
                          fill: true,
                          selectedJobType: _selectedJobType,
                          jobTypes: _jobTypes,
                          onJobTypeChanged: _onJobTypeFilterChanged,
                          onShowDetails: _showJobDetails,
                          onRetry: _retryJob,
                        ),
                        JobQueueWorkerPoolTab(
                          workerPoolStats: _workerPoolStats,
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
      await _service.cancelJob(jobId);
      context.showSuccess('Job cancelled successfully');
      refreshCurrentTab();
    } catch (e) {
      context.showError('Failed to cancel job: $e');
    }
  }

  Future<void> _retryJob(String jobId) async {
    try {
      await _service.retryJob(jobId);
      context.showSuccess('Job retried successfully');
      refreshCurrentTab();
    } catch (e) {
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
        onPause: _pauseProcessing,
        onResume: _resumeProcessing,
        onConfigureWorkers: _showWorkerPoolConfig,
        onPurge: _showPurgeDialog,
      ),
    );
  }

  Future<void> _showWorkerPoolConfig() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => JobQueueWorkerPoolConfigDialog(
        initialCorePoolSize: '${_workerPoolStats['corePoolSize'] ?? 4}',
        initialMaxPoolSize: '${_workerPoolStats['maximumPoolSize'] ?? 8}',
        initialQueueCapacity: '100',
        onPrefill: _service.getWorkerPoolConfig,
        onSave: ({
          required int corePoolSize,
          required int maxPoolSize,
          required int queueCapacity,
        }) {
          return _service.configureWorkerPool(
            corePoolSize: corePoolSize,
            maxPoolSize: maxPoolSize,
            queueCapacity: queueCapacity,
          );
        },
      ),
    );
    if (result == null || !mounted) return;
    context.showSuccess('${result['message'] ?? 'Worker pool configured'}');
    await _loadWorkerPoolStats();
    if (_tabController.index == 4) refreshCurrentTab();
  }

  Future<void> _showPurgeDialog() async {
    final outcome = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => JobQueuePurgeDialog(
        onPurge: (days) => _service.purgeJobs(retentionDays: days),
      ),
    );
    if (outcome == null || !mounted) return;
    final days = outcome['days'] as int? ?? 0;
    final result = outcome['result'] as Map<String, dynamic>? ?? {};
    final count = result['purgedCount'] ?? 0;
    context.showSuccess('Purged $count job(s) older than $days day(s)');
    await Future.wait([
      _loadJobHistory(),
      _loadDashboardData(),
    ]);
  }

  Future<void> _pauseProcessing() async {
    try {
      await _service.pauseQueue();
      context.showInfo('Job processing paused');
      _loadDashboardData();
    } catch (e) {
      context.showError('Failed to pause processing: $e');
    }
  }

  Future<void> _resumeProcessing() async {
    try {
      await _service.resumeQueue();
      context.showInfo('Job processing resumed');
      _loadDashboardData();
    } catch (e) {
      context.showError('Failed to resume processing: $e');
    }
  }

  Future<void> _showQueueSettings() async {
    final result = await showDialog<JobQueueSettingsResult>(
      context: context,
      builder: (context) => JobQueueSettingsDialog(
        initialAutoRefresh: _autoRefresh,
        initialIntervalSeconds: _refreshIntervalSeconds,
      ),
    );
    if (result == null) return;
    _applyRefreshPreferences(
      autoRefresh: result.autoRefresh,
      intervalSeconds: result.intervalSeconds,
    );
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

      if (jobType == 'NOTIFICATION_BATCH') {
        jobPayload['operation'] = 'processScheduledBatchNotifications';
      }

      await _service.submitJob(
        jobType: jobType,
        priority: JobQueuePriorityUtils.fromLabel(priorityLabel),
        payload: jobPayload,
      );
      if (!mounted) return;
      context.showSuccess('Job "$jobName" submitted successfully');
      _loadInitialData();
    } catch (e) {
      if (!mounted) return;
      context.showError('Failed to submit job: $e');
    }
  }
}
