import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/admin/data_consistency_persistence_service.dart';
import 'package:traqtrace_app/data/services/admin/data_consistency_service.dart';
import 'package:traqtrace_app/data/services/admin/error_correction_service.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_anomaly_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_error_correction_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_integrity_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_validation_tab.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_workflows_tab.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';

import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/data_consistency_actions.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/integrity_violation_actions.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/correction_workflow_actions.dart';

class DataConsistencyIntegrityDashboard extends StatefulWidget {
  const DataConsistencyIntegrityDashboard({Key? key}) : super(key: key);

  @override
  DataConsistencyIntegrityDashboardState createState() =>
      DataConsistencyIntegrityDashboardState();
}

class DataConsistencyIntegrityDashboardState
    extends State<DataConsistencyIntegrityDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DataConsistencyService consistencyService;
  late ErrorCorrectionService correctionService;
  late DataConsistencyPersistenceService persistenceService;

  List<dynamic> correctableErrors = [];
  List<dynamic> integrityJobs = [];
  List<Map<String, dynamic>> correctionWorkflows = [];

  LoadState<Map<String, dynamic>> consistencyReportState =
      const LoadState.empty();
  LoadState<List<dynamic>> anomaliesState = const LoadState.empty();
  LoadState<Map<String, dynamic>> correctionStatisticsState =
      const LoadState.loading();
  LoadState<List<dynamic>> jobsState = const LoadState.loading();
  LoadState<List<Map<String, dynamic>>> workflowDataState =
      const LoadState.loading();

  final Set<int> loadedTabs = {};

  bool isGeneratingReport = false;
  bool isDetectingAnomalies = false;
  bool isIdentifyingErrors = false;
  bool isRefreshingAll = false;

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  List<String> selectedEventTypes = [
    'ObjectEvent',
    'AggregationEvent',
    'TransactionEvent',
    'TransformationEvent',
  ];
  List<String> selectedErrorTypes = [
    'MISSING_FIELD',
    'INVALID_FORMAT',
    'DUPLICATE_EVENT',
    'TIMING_INCONSISTENCY',
  ];

  Timer? refreshTimer;
  final Map<String, Timer> jobPollTimers = {};
  final Map<String, Timer> workflowPollTimers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ensureTabLoaded(_tabController.index);
      }
    });
    persistenceService = DataConsistencyPersistenceService();
    initializeServices();

    persistenceService.addListener(onPersistenceUpdate);

    integrityJobs = persistenceService.integrityJobs;
    correctionWorkflows = persistenceService.correctionWorkflows;
    jobsState = integrityJobs.isEmpty
        ? const LoadState.empty()
        : LoadState.success(integrityJobs);
    workflowDataState = correctionWorkflows.isEmpty
        ? const LoadState.empty()
        : LoadState.success(correctionWorkflows);

    ensureTabLoaded(_tabController.index);
    startAutoRefresh();
  }

  @override
  void dispose() {
    persistenceService.removeListener(onPersistenceUpdate);
    _tabController.dispose();
    refreshTimer?.cancel();
    for (final timer in jobPollTimers.values) {
      timer.cancel();
    }
    for (final timer in workflowPollTimers.values) {
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
            onPressed: isRefreshingAll ? null : refreshLoadedTabs,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconSettings),
            onPressed: showFiltersDialog,
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
              reportState: consistencyReportState,
              isGeneratingReport: isGeneratingReport,
              onGenerateReport: generateConsistencyReport,
              onCorrectViolation: correctConsistencyViolation,
              onViewViolationDetails: showViolationDetails,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyAnomalyTab(
              anomaliesState: anomaliesState,
              isDetectingAnomalies: isDetectingAnomalies,
              onDetectAnomalies: detectAnomalies,
              onCorrectAnomaly: correctAnomaly,
              onViewAnomalyDetails: showAnomalyDetails,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyErrorCorrectionTab(
              correctionStatisticsState: correctionStatisticsState,
              correctableErrors: correctableErrors,
              isIdentifyingErrors: isIdentifyingErrors,
              onLoadCorrectionStatistics: loadCorrectionStatistics,
              onIdentifyCorrectableErrors: identifyCorrectableErrors,
              onShowCorrectionDialog: showCorrectionDialog,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyIntegrityTab(
              jobsState: jobsState,
              onRefreshJobs: refreshJobsState,
              onStartIntegrityJob: startIntegrityJob,
              onViewViolations: showIntegrityViolations,
            ),
          ),
          KeepAliveTabView(
            child: ConsistencyWorkflowsTab(
              workflowDataState: workflowDataState,
              correctionWorkflowsCount: correctionWorkflows.length,
              onRefreshWorkflowData: refreshWorkflowData,
              onLoadWorkflowData: loadWorkflowData,
              onShowWorkflowDetails: showWorkflowDetails,
            ),
          ),
        ],
      ),
    );
  }
}
