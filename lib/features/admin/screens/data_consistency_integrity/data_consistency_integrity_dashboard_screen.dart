import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/admin/data_consistency_persistence_service.dart';
import 'package:traqtrace_app/data/services/admin/data_consistency_service.dart';
import 'package:traqtrace_app/data/services/admin/error_correction_service.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_anomaly_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_detail_row.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_error_correction_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_integrity_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_validation_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_violation_item.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_workflows_tab.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';

part 'data_consistency_actions.dart';
part 'integrity_violation_actions.dart';
part 'correction_workflow_actions.dart';

class DataConsistencyIntegrityDashboard extends StatefulWidget {
  const DataConsistencyIntegrityDashboard({Key? key}) : super(key: key);

  @override
  _DataConsistencyIntegrityDashboardState createState() =>
      _DataConsistencyIntegrityDashboardState();
}

class _DataConsistencyIntegrityDashboardState
    extends State<DataConsistencyIntegrityDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DataConsistencyService _consistencyService;
  late ErrorCorrectionService _correctionService;
  late DataConsistencyPersistenceService _persistenceService;

  List<dynamic> _correctableErrors = [];
  List<dynamic> _integrityJobs = [];
  List<Map<String, dynamic>> _correctionWorkflows = [];

  LoadState<Map<String, dynamic>> _consistencyReportState =
      const LoadState.empty();
  LoadState<List<dynamic>> _anomaliesState = const LoadState.empty();
  LoadState<Map<String, dynamic>> _correctionStatisticsState =
      const LoadState.loading();
  LoadState<List<dynamic>> _jobsState = const LoadState.loading();
  LoadState<List<Map<String, dynamic>>> _workflowDataState =
      const LoadState.loading();

  final Set<int> _loadedTabs = {};

  bool _isGeneratingReport = false;
  bool _isDetectingAnomalies = false;
  bool _isIdentifyingErrors = false;
  bool _isRefreshingAll = false;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<String> _selectedEventTypes = [
    'ObjectEvent',
    'AggregationEvent',
    'TransactionEvent',
    'TransformationEvent',
  ];
  List<String> _selectedErrorTypes = [
    'MISSING_FIELD',
    'INVALID_FORMAT',
    'DUPLICATE_EVENT',
    'TIMING_INCONSISTENCY',
  ];

  Timer? _refreshTimer;
  final Map<String, Timer> _jobPollTimers = {};
  final Map<String, Timer> _workflowPollTimers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ensureTabLoaded(_tabController.index);
      }
    });
    _persistenceService = DataConsistencyPersistenceService();
    _initializeServices();

    _persistenceService.addListener(_onPersistenceUpdate);

    _integrityJobs = _persistenceService.integrityJobs;
    _correctionWorkflows = _persistenceService.correctionWorkflows;
    _jobsState = _integrityJobs.isEmpty
        ? const LoadState.empty()
        : LoadState.success(_integrityJobs);
    _workflowDataState = _correctionWorkflows.isEmpty
        ? const LoadState.empty()
        : LoadState.success(_correctionWorkflows);

    _ensureTabLoaded(_tabController.index);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _persistenceService.removeListener(_onPersistenceUpdate);
    _tabController.dispose();
    _refreshTimer?.cancel();
    for (final timer in _jobPollTimers.values) {
      timer.cancel();
    }
    for (final timer in _workflowPollTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Consistency & Integrity Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: TraqIcon(AppAssets.iconList), text: 'Consistency'),
            Tab(
              icon: TraqIcon(AppAssets.iconSearch),
              text: 'Anomaly Detection',
            ),
            Tab(
              icon: TraqIcon(AppAssets.iconSettings),
              text: 'Error Correction',
            ),
            Tab(
              icon: TraqIcon(AppAssets.iconLock),
              text: 'Integrity Monitoring',
            ),
            Tab(icon: TraqIcon(AppAssets.iconGlobe), text: 'Workflows'),
          ],
        ),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _isRefreshingAll ? null : _refreshLoadedTabs,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconSettings),
            onPressed: _showFiltersDialog,
            tooltip: 'Filters',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(
            child: ConsistencyValidationTab(
              reportState: _consistencyReportState,
              isGeneratingReport: _isGeneratingReport,
              onGenerateReport: _generateConsistencyReport,
              onCorrectViolation: _correctConsistencyViolation,
              onViewViolationDetails: _showViolationDetails,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyAnomalyTab(
              anomaliesState: _anomaliesState,
              isDetectingAnomalies: _isDetectingAnomalies,
              onDetectAnomalies: _detectAnomalies,
              onCorrectAnomaly: _correctAnomaly,
              onViewAnomalyDetails: _showAnomalyDetails,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyErrorCorrectionTab(
              correctionStatisticsState: _correctionStatisticsState,
              correctableErrors: _correctableErrors,
              isIdentifyingErrors: _isIdentifyingErrors,
              onLoadCorrectionStatistics: _loadCorrectionStatistics,
              onIdentifyCorrectableErrors: _identifyCorrectableErrors,
              onShowCorrectionDialog: _showCorrectionDialog,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyIntegrityTab(
              jobsState: _jobsState,
              onRefreshJobs: _refreshJobsState,
              onStartIntegrityJob: _startIntegrityJob,
              onViewViolations: _showIntegrityViolations,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyWorkflowsTab(
              workflowDataState: _workflowDataState,
              correctionWorkflowsCount: _correctionWorkflows.length,
              onRefreshWorkflowData: _refreshWorkflowData,
              onLoadWorkflowData: _loadWorkflowData,
              onShowWorkflowDetails: _showWorkflowDetails,
            ),
          ),
        ],
      ),
    );
  }
}
