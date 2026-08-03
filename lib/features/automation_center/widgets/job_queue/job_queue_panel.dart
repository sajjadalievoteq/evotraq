import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/automation_center/job_queue_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_active_jobs_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_dashboard_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_history_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_queue_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_selected_tab_content.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/tabs/job_queue_worker_pool_tab.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_dashboard_snapshot_builder.dart';

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

class JobQueuePanelState extends State<JobQueuePanel> with TickerProviderStateMixin {
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
      final skeletons = List.generate(
        4,
        (_) => TraqCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: TraqSpacing.xl,
                width: 160,
                decoration: BoxDecoration(
                  color: c.surfaceMuted,
                  borderRadius: TraqRadius.chip,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.surfaceMuted,
                  borderRadius: TraqRadius.card,
                ),
              ),
            ],
          ),
        ),
      );
      if (embedded) {
        return Column(
          children: [
            for (var i = 0; i < skeletons.length; i++) ...[
              if (i > 0) const SizedBox(height: TraqSpacing.md),
              skeletons[i],
            ],
          ],
        );
      }
      return ListView.separated(
        padding: TraqSpacing.surfacePad,
        itemCount: skeletons.length,
        separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.md),
        itemBuilder: (_, i) => skeletons[i],
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: embedded
            ? const EdgeInsets.symmetric(vertical: TraqSpacing.lg)
            : TraqSpacing.pagePad,
        child: TraqCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TraqIcon(
                AppAssets.iconAlert,
                size: 48,
                color: AppColorMapper.errorColor(context).withValues(alpha: 0.7),
              ),
              const SizedBox(height: TraqSpacing.lg),
              Text(
                'Unable to load job queue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: c.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TraqSpacing.sm),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TraqSpacing.xl),
              FilledButton(
                onPressed: _loadInitialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
      context.showSuccess('Job resubmitted successfully');
      refreshCurrentTab();
    } catch (e) {
      context.showError('Failed to retry job: $e');
    }
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Job Details: ${job['jobId']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Job Type: ${job['jobType']}'),
              Text('Status: ${job['status']}'),
              Text('Priority: ${job['priority']}'),
              if (job['submittedTime'] != null)
                Text('Submitted: ${job['submittedTime']}'),
              if (job['startTime'] != null) Text('Started: ${job['startTime']}'),
              if (job['endTime'] != null) Text('Completed: ${job['endTime']}'),
              if (job['executionTime'] != null)
                Text('Duration: ${job['executionTime']}'),
              if (job['progress'] != null) Text('Progress: ${job['progress']}%'),
              if (job['errorMessage'] != null) ...[
                const SizedBox(height: 8),
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  job['errorMessage'],
                  style: TextStyle(color: AppColorMapper.errorColor(context)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showControlPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Job Queue Control Panel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: TraqIcon(AppAssets.iconMinus),
              title: const Text('Pause Processing'),
              onTap: () {
                Navigator.of(context).pop();
                _pauseProcessing();
              },
            ),
            ListTile(
              leading: TraqIcon(AppAssets.iconArrowR),
              title: const Text('Resume Processing'),
              onTap: () {
                Navigator.of(context).pop();
                _resumeProcessing();
              },
            ),
            ListTile(
              leading: TraqIcon(AppAssets.iconTune),
              title: const Text('Configure Worker Pool'),
              onTap: () {
                Navigator.of(context).pop();
                _showWorkerPoolConfig();
              },
            ),
            ListTile(
              leading: TraqIcon(AppAssets.iconTrash),
              title: const Text('Purge Old Jobs'),
              onTap: () {
                Navigator.of(context).pop();
                _showPurgeDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWorkerPoolConfig() {
    final coreCtrl = TextEditingController(
      text: '${_workerPoolStats['corePoolSize'] ?? 4}',
    );
    final maxCtrl = TextEditingController(
      text: '${_workerPoolStats['maximumPoolSize'] ?? 8}',
    );
    final queueCtrl = TextEditingController(text: '100');
    var saving = false;
    String? formError;

    // Prefill queue capacity from config endpoint when available.
    _service.getWorkerPoolConfig().then((config) {
      final qc = config['queueCapacity'];
      if (qc != null) queueCtrl.text = '$qc';
      final core = config['corePoolSize'];
      if (core != null) coreCtrl.text = '$core';
      final max = config['maxPoolSize'];
      if (max != null) maxCtrl.text = '$max';
    }).catchError((_) {});

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final core = int.tryParse(coreCtrl.text.trim());
              final max = int.tryParse(maxCtrl.text.trim());
              final queue = int.tryParse(queueCtrl.text.trim());
              if (core == null ||
                  core < 1 ||
                  max == null ||
                  max < 1 ||
                  queue == null ||
                  queue < 1) {
                setDialogState(
                  () => formError = 'Enter positive integers for all fields',
                );
                return;
              }
              if (max < core) {
                setDialogState(
                  () => formError = 'Max pool size must be ≥ core pool size',
                );
                return;
              }
              setDialogState(() {
                saving = true;
                formError = null;
              });
              try {
                final result = await _service.configureWorkerPool(
                  corePoolSize: core,
                  maxPoolSize: max,
                  queueCapacity: queue,
                );
                if (!dialogContext.mounted) return;
                if (result['status'] == 'error') {
                  setDialogState(() {
                    saving = false;
                    formError = '${result['message'] ?? 'Configuration failed'}';
                  });
                  return;
                }
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                context.showSuccess(
                  '${result['message'] ?? 'Worker pool configured'}',
                );
                await _loadWorkerPoolStats();
                if (_tabController.index == 4) refreshCurrentTab();
              } catch (e) {
                setDialogState(() {
                  saving = false;
                  formError = 'Failed to configure worker pool: $e';
                });
              }
            }

            return AlertDialog(
              title: Row(
                children: [
                  TraqIcon(AppAssets.iconTune),
                  const SizedBox(width: TraqSpacing.sm),
                  const Text('Configure Worker Pool'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: coreCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Core pool size',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max pool size',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextField(
                      controller: queueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Queue capacity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: TraqSpacing.md),
                      Text(
                        formError!,
                        style: TextStyle(
                          color: AppColorMapper.errorColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      coreCtrl.dispose();
      maxCtrl.dispose();
      queueCtrl.dispose();
    });
  }

  void _showPurgeDialog() {
    final daysCtrl = TextEditingController(text: '30');
    var purging = false;
    String? formError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> confirm() async {
              final days = int.tryParse(daysCtrl.text.trim());
              if (days == null || days < 1) {
                setDialogState(
                  () => formError = 'Enter a positive number of retention days',
                );
                return;
              }
              setDialogState(() {
                purging = true;
                formError = null;
              });
              try {
                final result = await _service.purgeJobs(retentionDays: days);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                final count = result['purgedCount'] ?? 0;
                context.showSuccess(
                  'Purged $count job(s) older than $days day(s)',
                );
                await Future.wait([
                  _loadJobHistory(),
                  _loadDashboardData(),
                ]);
              } catch (e) {
                setDialogState(() {
                  purging = false;
                  formError = 'Failed to purge jobs: $e';
                });
              }
            }

            return AlertDialog(
              title: Row(
                children: [
                  TraqIcon(
                    AppAssets.iconTrash,
                    color: AppColorMapper.errorColor(context),
                  ),
                  const SizedBox(width: TraqSpacing.sm),
                  const Text('Purge Old Jobs'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permanently remove completed job history older than the '
                      'retention period. This cannot be undone.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: TraqSpacing.lg),
                    TextField(
                      controller: daysCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Retain jobs from the last N days',
                        border: OutlineInputBorder(),
                        helperText: 'Jobs ending before this window are purged',
                      ),
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: TraqSpacing.md),
                      Text(
                        formError!,
                        style: TextStyle(
                          color: AppColorMapper.errorColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: purging
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorMapper.errorColor(context),
                  ),
                  onPressed: purging ? null : confirm,
                  child: purging
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Purge'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(daysCtrl.dispose);
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

  void _showQueueSettings() {
    var autoRefresh = _autoRefresh;
    final intervalCtrl = TextEditingController(
      text: '$_refreshIntervalSeconds',
    );
    String? formError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  TraqIcon(AppAssets.iconSettings),
                  const SizedBox(width: TraqSpacing.sm),
                  const Text('Queue Settings'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto refresh'),
                      subtitle: const Text(
                        'Periodically reload the active tab',
                      ),
                      value: autoRefresh,
                      onChanged: (v) => setDialogState(() => autoRefresh = v),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextField(
                      controller: intervalCtrl,
                      enabled: autoRefresh,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Refresh interval (seconds)',
                        border: OutlineInputBorder(),
                        helperText: 'Between 2 and 120 seconds',
                      ),
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: TraqSpacing.md),
                      Text(
                        formError!,
                        style: TextStyle(
                          color: AppColorMapper.errorColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final interval = int.tryParse(intervalCtrl.text.trim());
                    if (interval == null || interval < 2 || interval > 120) {
                      setDialogState(
                        () => formError =
                            'Interval must be an integer between 2 and 120',
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _applyRefreshPreferences(
                      autoRefresh: autoRefresh,
                      intervalSeconds: interval,
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(intervalCtrl.dispose);
  }

  void _showScheduleJobDialog() {
    // TODO(scheduling): real deferred/cron execution requires a backend
    // scheduled-submit endpoint + quartz/scheduler; out of scope here.
    var selectedJobType = 'NOTIFICATION_BATCH';
    var selectedPriority = 'MEDIUM';
    var jobName = '';
    var description = '';
    final parameters = <Map<String, String>>[];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  TraqIcon(
                    AppAssets.iconClock,
                    color: AppColorMapper.successColor(context),
                  ),
                  const SizedBox(width: TraqSpacing.sm),
                  const Text('Submit Job'),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submits a job to the queue immediately '
                        '(POST /jobs/submit).',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.textMuted,
                            ),
                      ),
                      const SizedBox(height: TraqSpacing.lg),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Job Name *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => jobName = value,
                      ),
                      const SizedBox(height: TraqSpacing.md),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Job Type *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedJobType,
                        items: const [
                          DropdownMenuItem(
                            value: 'NOTIFICATION_BATCH',
                            child: Text('NOTIFICATION_BATCH'),
                          ),
                        ],
                        onChanged: (value) => setDialogState(
                          () => selectedJobType = value!,
                        ),
                      ),
                      const SizedBox(height: TraqSpacing.sm),
                      Text(
                        'Runs processScheduledBatchNotifications — delivers '
                        'due BATCH/SCHEDULED notification batches.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.textMuted,
                            ),
                      ),
                      const SizedBox(height: TraqSpacing.md),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) => description = value,
                      ),
                      const SizedBox(height: TraqSpacing.md),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedPriority,
                        items: const [
                          DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                          DropdownMenuItem(
                            value: 'MEDIUM',
                            child: Text('MEDIUM'),
                          ),
                          DropdownMenuItem(value: 'LOW', child: Text('LOW')),
                        ],
                        onChanged: (value) => setDialogState(
                          () => selectedPriority = value!,
                        ),
                      ),
                      const SizedBox(height: TraqSpacing.xl),
                      Text(
                        'Additional parameters (optional)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: TraqSpacing.sm),
                      ...parameters.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: TraqSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Key',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) =>
                                      parameters[index]['key'] = value,
                                ),
                              ),
                              const SizedBox(width: TraqSpacing.sm),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Value',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) =>
                                      parameters[index]['value'] = value,
                                ),
                              ),
                              IconButton(
                                icon: TraqIcon(
                                  AppAssets.iconRemoveCircle,
                                  color: AppColorMapper.errorColor(context),
                                ),
                                onPressed: () => setDialogState(
                                  () => parameters.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: () => setDialogState(
                          () => parameters.add({'key': '', 'value': ''}),
                        ),
                        icon: TraqIcon(AppAssets.iconPlus),
                        label: const Text('Add Parameter'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (jobName.trim().isEmpty) {
                      context.showError('Job name is required');
                      return;
                    }
                    Navigator.of(context).pop();
                    _submitJobNow(
                      jobName: jobName.trim(),
                      jobType: selectedJobType,
                      description: description.trim(),
                      priorityLabel: selectedPriority,
                      parameters: parameters,
                    );
                  },
                  child: const Text('Submit Job'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _priorityFromLabel(String label) {
    switch (label.toUpperCase()) {
      case 'HIGH':
        return 2;
      case 'LOW':
        return 8;
      case 'MEDIUM':
      default:
        return 5;
    }
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
        priority: _priorityFromLabel(priorityLabel),
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
