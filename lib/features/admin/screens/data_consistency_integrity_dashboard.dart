import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/core/di/injection.dart';
import '../../../core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import '../../../data/services/data_consistency_persistence_service.dart';
import '../../../data/services/data_consistency_service.dart';
import '../../../data/services/error_correction_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';


class DataConsistencyIntegrityDashboard extends StatefulWidget {
  const DataConsistencyIntegrityDashboard({Key? key}) : super(key: key);

  @override
  _DataConsistencyIntegrityDashboardState createState() => _DataConsistencyIntegrityDashboardState();
}

class _DataConsistencyIntegrityDashboardState extends State<DataConsistencyIntegrityDashboard>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late DataConsistencyService _consistencyService;
  late ErrorCorrectionService _correctionService;
  late DataConsistencyPersistenceService _persistenceService;
  
  List<dynamic> _correctableErrors = [];
  List<dynamic> _integrityJobs = [];
  List<Map<String, dynamic>> _correctionWorkflows = [];

  
  
  
  LoadState<Map<String, dynamic>> _consistencyReportState = const LoadState.empty();
  LoadState<List<dynamic>> _anomaliesState = const LoadState.empty();
  LoadState<Map<String, dynamic>> _correctionStatisticsState = const LoadState.loading();
  LoadState<List<dynamic>> _jobsState = const LoadState.loading();
  LoadState<List<Map<String, dynamic>>> _workflowDataState = const LoadState.loading();

  
  
  
  final Set<int> _loadedTabs = {};

  bool _isGeneratingReport = false;
  bool _isDetectingAnomalies = false;
  bool _isIdentifyingErrors = false;
  bool _isRefreshingAll = false;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<String> _selectedEventTypes = ['ObjectEvent', 'AggregationEvent', 'TransactionEvent', 'TransformationEvent'];
  List<String> _selectedErrorTypes = ['MISSING_FIELD', 'INVALID_FORMAT', 'DUPLICATE_EVENT', 'TIMING_INCONSISTENCY'];

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
    _jobsState = _integrityJobs.isEmpty ? const LoadState.empty() : LoadState.success(_integrityJobs);
    _workflowDataState = _correctionWorkflows.isEmpty ? const LoadState.empty() : LoadState.success(_correctionWorkflows);

    
    
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

  void _onPersistenceUpdate() {
    if (mounted) {
      setState(() {
        _integrityJobs = _persistenceService.integrityJobs;
        _correctionWorkflows = _persistenceService.correctionWorkflows;
        if (_loadedTabs.contains(3)) {
          _jobsState = _integrityJobs.isEmpty ? const LoadState.empty() : LoadState.success(_integrityJobs);
        }
        if (_loadedTabs.contains(4)) {
          _workflowDataState = _correctionWorkflows.isEmpty ? const LoadState.empty() : LoadState.success(_correctionWorkflows);
        }
      });
    }
  }

  void _initializeServices() {
    _consistencyService = getIt<DataConsistencyService>();
    _correctionService = getIt<ErrorCorrectionService>();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        
        
        _refreshLoadedTabs();
      }
    });
  }

  
  
  
  Future<void> _triggerTabLoad(int index) {
    switch (index) {
      case 2:
        return _loadCorrectionStatistics();
      case 3:
        _refreshJobsState();
        return Future.value();
      case 4:
        return _loadWorkflowData();
      default:
        return Future.value();
    }
  }

  void _ensureTabLoaded(int index) {
    if (_loadedTabs.contains(index)) return;
    _loadedTabs.add(index);
    _triggerTabLoad(index);
  }

  
  
  
  Future<void> _refreshLoadedTabs() async {
    if (!mounted) return;
    setState(() {
      _isRefreshingAll = true;
    });
    try {
      await Future.wait(_loadedTabs.map(_triggerTabLoad));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingAll = false;
        });
      }
    }
  }

  void _refreshJobsState() {
    if (!mounted) return;
    setState(() {
      _jobsState = _integrityJobs.isEmpty ? const LoadState.empty() : LoadState.success(_integrityJobs);
    });
  }

  Future<void> _loadWorkflowData() async {
    if (mounted) {
      setState(() {
        if (_workflowDataState.data == null) {
          _workflowDataState = const LoadState.loading();
        }
      });
    }

    try {
      final workflows = await _correctionService.getAllCorrectionWorkflows();
      if (!mounted) return;

      setState(() {
        _correctionWorkflows.clear();

        for (int i = 0; i < workflows.length; i++) {
          final w = workflows[i];

          final mappedWorkflow = {
            'workflow_id': w['workflow_id'] ?? 'UNKNOWN',
            'status': w['workflow_status'] ?? 'UNKNOWN',
            'source_job_id': w['error_id'] ?? 'UNKNOWN',
            'violation_count': w['current_step'] ?? 0,
            'created_time': DateTime.now(),
            'requires_approval': false,
            'workflow_type': w['workflow_type'] ?? 'UNKNOWN',
          };

          _correctionWorkflows.add(mappedWorkflow);
        }

        _workflowDataState = _correctionWorkflows.isEmpty
            ? const LoadState.empty()
            : LoadState.success(_correctionWorkflows);
      });
    } catch (e) {
      
      
      if (mounted) {
        setState(() {
          _workflowDataState = _correctionWorkflows.isNotEmpty
              ? LoadState.success(_correctionWorkflows)
              : LoadState.error('Failed to load workflows: $e');
        });
      }
    }
  }

  Future<void> _generateConsistencyReport() async {
    if (!mounted) return;
    setState(() {
      _isGeneratingReport = true;
      if (_consistencyReportState.data == null) {
        _consistencyReportState = const LoadState.loading();
      }
    });

    try {
      final report = await _consistencyService.generateConsistencyReport(
        _startDate,
        _endDate,
        _selectedEventTypes,
      );

      if (mounted) {
        setState(() {
          _consistencyReportState = LoadState.success(report);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final previous = _consistencyReportState.data;
          _consistencyReportState = previous != null
              ? LoadState.success(previous)
              : LoadState.error('Failed to generate consistency report: $e');
        });
      }
      _showErrorSnackBar('Failed to generate consistency report: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }

  Future<void> _detectAnomalies() async {
    if (!mounted) return;
    setState(() {
      _isDetectingAnomalies = true;
      if (_anomaliesState.data == null) {
        _anomaliesState = const LoadState.loading();
      }
    });

    try {
      final anomalies = await _consistencyService.detectDataAnomalies(
        {'start': _startDate, 'end': _endDate},
        _selectedEventTypes,
      );

      if (mounted) {
        setState(() {
          _anomaliesState = anomalies.isEmpty ? const LoadState.empty() : LoadState.success(anomalies);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final previous = _anomaliesState.data;
          _anomaliesState = (previous != null && previous.isNotEmpty)
              ? LoadState.success(previous)
              : LoadState.error('Failed to detect anomalies: $e');
        });
      }
      _showErrorSnackBar('Failed to detect anomalies: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDetectingAnomalies = false;
        });
      }
    }
  }

  Future<void> _identifyCorrectableErrors() async {
    setState(() {
      _isIdentifyingErrors = true;
    });

    try {
      final errors = await _correctionService.identifyCorrectableErrors(
        _startDate,
        _endDate,
        _selectedErrorTypes,
      );
      
      setState(() {
        _correctableErrors = errors;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to identify correctable errors: $e');
    } finally {
      setState(() {
        _isIdentifyingErrors = false;
      });
    }
  }

  Future<void> _loadCorrectionStatistics() async {
    if (mounted) {
      setState(() {
        if (_correctionStatisticsState.data == null) {
          _correctionStatisticsState = const LoadState.loading();
        }
      });
    }

    try {
      final statistics = await _correctionService.getErrorCorrectionStatistics(
        _startDate,
        _endDate,
      );

      if (mounted) {
        setState(() {
          _correctionStatisticsState = LoadState.success(statistics);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final previous = _correctionStatisticsState.data;
          _correctionStatisticsState = previous != null
              ? LoadState.success(previous)
              : LoadState.error('Failed to load correction statistics: $e');
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    context.showError(message, duration: const Duration(seconds: 5));
  }

  Future<void> _correctConsistencyViolation(Map<String, dynamic> violation) async {
    final violationType = violation['violation_type'] ?? 'UNKNOWN';
    final description = violation['description'] ?? '';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct Consistency Violation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $violationType'),
            const SizedBox(height: 8),
            Text('Description: $description'),
            const SizedBox(height: 16),
            const Text('This will create a correction workflow to fix this violation. Continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create Workflow'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final errorId = await _correctionService.registerRealError(
          violationType,
          description,
          violation['affected_events']?.cast<String>() ?? [],
          violation['severity'] ?? 'MEDIUM',
          {
            'violation_data': violation,
            'correction_type': 'CONSISTENCY_VIOLATION',
          },
        );

        final workflowId = await _correctionService.initiateErrorCorrectionWorkflow(
          errorId,
          'MANUAL',
          {
            'source': 'CONSISTENCY_VALIDATION',
            'violation_type': violationType,
            'violation_data': violation,
          },
          'current_user',
        );

        context.showSuccess('Correction workflow $workflowId created successfully!');

        await _loadWorkflowData();
      } catch (e) {
        _showErrorSnackBar('Failed to create correction workflow: $e');
      }
    }
  }

  void _showViolationDetails(Map<String, dynamic> violation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(violation['violation_type'] ?? 'Violation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', violation['violation_type']),
              _buildDetailRow('Severity', violation['severity']),
              _buildDetailRow('Description', violation['description']),
              _buildDetailRow('Affected Events', violation['affected_events']?.join(', ')),
              _buildDetailRow('Detection Time', violation['detection_time']),
              _buildDetailRow('Suggested Resolution', violation['suggested_resolution']),
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

  Future<void> _correctAnomaly(Map<String, dynamic> anomaly) async {
    final anomalyType = anomaly['anomaly_type'] ?? 'UNKNOWN';
    final description = anomaly['description'] ?? '';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct Data Anomaly'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $anomalyType'),
            const SizedBox(height: 8),
            Text('Description: $description'),
            const SizedBox(height: 8),
            Text('Confidence: ${((anomaly['confidence_score'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('This will create a correction workflow to address this anomaly. Continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create Workflow'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final errorId = await _correctionService.registerRealError(
          anomalyType,
          description,
          anomaly['affected_events']?.cast<String>() ?? [],
          anomaly['severity'] ?? 'MEDIUM',
          {
            'anomaly_data': anomaly,
            'correction_type': 'DATA_ANOMALY',
            'confidence_score': anomaly['confidence_score'],
          },
        );

        final workflowId = await _correctionService.initiateErrorCorrectionWorkflow(
          errorId,
          'MANUAL',
          {
            'source': 'ANOMALY_DETECTION',
            'anomaly_type': anomalyType,
            'anomaly_data': anomaly,
          },
          'current_user',
        );

        context.showSuccess('Correction workflow $workflowId created successfully!');

        await _loadWorkflowData();
      } catch (e) {
        _showErrorSnackBar('Failed to create correction workflow: $e');
      }
    }
  }

  void _showAnomalyDetails(Map<String, dynamic> anomaly) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(anomaly['anomaly_type'] ?? 'Anomaly Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', anomaly['anomaly_type']),
              _buildDetailRow('Severity', anomaly['severity']),
              _buildDetailRow('Confidence Score', '${((anomaly['confidence_score'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Description', anomaly['description']),
              _buildDetailRow('Expected Pattern', anomaly['expected_pattern']),
              _buildDetailRow('Actual Pattern', anomaly['actual_pattern']),
              _buildDetailRow('Deviation Magnitude', anomaly['deviation_magnitude']?.toString()),
              _buildDetailRow('Affected Events', anomaly['affected_events']?.join(', ')),
              _buildDetailRow('Detection Time', anomaly['detection_time']),
              if (anomaly['suggested_actions'] != null) ...[
                const SizedBox(height: 8),
                const Text('Suggested Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...((anomaly['suggested_actions'] as List?)?.cast<String>() ?? []).map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('â€¢ $action'),
                  ),
                ).toList(),
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

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
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
            Tab(icon: TraqIcon(AppAssets.iconSearch), text: 'Anomaly Detection'),
            Tab(icon: TraqIcon(AppAssets.iconSettings), text: 'Error Correction'),
            Tab(icon: TraqIcon(AppAssets.iconLock), text: 'Integrity Monitoring'),
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
      body: _buildTabContent(),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        KeepAliveTabView(child: _buildConsistencyTab()),
        KeepAliveTabView(child: _buildAnomalyDetectionTab()),
        KeepAliveTabView(child: _buildErrorCorrectionTab()),
        KeepAliveTabView(child: _buildIntegrityMonitoringTab()),
        KeepAliveTabView(child: _buildWorkflowsTab()),
      ],
    );
  }

  Widget _buildConsistencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconList, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Consistency Validation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _isGeneratingReport ? null : _generateConsistencyReport,
                        icon: _isGeneratingReport
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : TraqIcon(AppAssets.iconArrowR),
                        label: Text(_isGeneratingReport ? 'Generating...' : 'Generate Report'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoadStateView<Map<String, dynamic>>(
                    state: _consistencyReportState,
                    onRetry: _generateConsistencyReport,
                    emptyWidget: const Text('No consistency report generated yet. Click "Generate Report" to start.'),
                    builder: (context, report) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConsistencyMetrics(report),
                        const SizedBox(height: 16),
                        _buildConsistencyViolations(report),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyMetrics(Map<String, dynamic> report) {
    final score = report['consistency_score'] ?? 0.0;
    final total = report['total_events_analyzed'] ?? 0;
    final violations = (report['consistency_violations'] as List?)?.length ?? 0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consistency Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Consistency Score',
                    '${score.toStringAsFixed(1)}%',
                    AdminHelperMappers.scoreColor(score),
                    AppAssets.iconScore,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Events Analyzed',
                    total.toString(),
                    Colors.blue,
                    NavIcons.epcisEvents,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Violations Found',
                    violations.toString(),
                    violations > 0 ? Colors.red : Colors.green,
                    AppAssets.iconAlert,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyViolations(Map<String, dynamic> report) {
    final violations = (report['consistency_violations'] as List?) ?? [];
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consistency Violations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (violations.isEmpty)
              const Text(
                'No consistency violations found.',
                style: TextStyle(color: Colors.green),
              )
            else
              ...violations.map((violation) => _buildViolationCard(violation)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationCard(Map<String, dynamic> violation) {
    final severity = violation['severity'] ?? 'UNKNOWN';
    final type = violation['violation_type'] ?? 'UNKNOWN';
    final description = violation['description'] ?? '';
    final suggestedResolution = violation['suggested_resolution'] ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: TraqIcon(AppAssets.iconAlert,
          color: AdminHelperMappers.dashboardSeverityColor(severity),
        ),
        title: Text(type),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(severity),
              backgroundColor: AdminHelperMappers.dashboardSeverityColor(
                severity,
              ).withOpacity(0.1),
              labelStyle: TextStyle(
                color: AdminHelperMappers.dashboardSeverityColor(severity),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _correctConsistencyViolation(violation),
              icon: TraqIcon(AppAssets.iconBuild, size: 16),
              label: const Text('Correct'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        children: [
          if (suggestedResolution.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Resolution:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(suggestedResolution),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _showViolationDetails(violation),
                        child: const Text('View Details'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _correctConsistencyViolation(violation),
                        icon: TraqIcon(AppAssets.iconSparkle),
                        label: const Text('Apply Fix'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnomalyDetectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconSearch, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Anomaly Detection',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _isDetectingAnomalies ? null : _detectAnomalies,
                        icon: _isDetectingAnomalies
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : TraqIcon(AppAssets.iconSearch),
                        label: Text(_isDetectingAnomalies ? 'Detecting...' : 'Detect Anomalies'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoadStateView<List<dynamic>>(
                    state: _anomaliesState,
                    onRetry: _detectAnomalies,
                    emptyWidget: const Text('No anomalies detected yet. Click "Detect Anomalies" to start scanning.'),
                    builder: (context, anomalies) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${anomalies.length} anomalies detected'),
                        const SizedBox(height: 16),
                        ...anomalies.map((anomaly) => _buildAnomalyCard(anomaly)).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyCard(Map<String, dynamic> anomaly) {
    final type = anomaly['anomaly_type'] ?? 'UNKNOWN';
    final severity = anomaly['severity'] ?? 'LOW';
    final confidence = (anomaly['confidence_score'] ?? 0.0) * 100;
    final description = anomaly['description'] ?? '';
    final suggestedActions = (anomaly['suggested_actions'] as List?)?.cast<String>() ?? [];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: TraqIcon(AppAssets.iconAlert,
          color: AdminHelperMappers.dashboardSeverityColor(severity),
        ),
        title: Text(
          type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text('${confidence.toStringAsFixed(0)}% confidence'),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _correctAnomaly(anomaly),
              icon: TraqIcon(AppAssets.iconSparkle, size: 16),
              label: const Text('Correct'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(severity),
                      backgroundColor: AdminHelperMappers.dashboardSeverityColor(
                        severity,
                      ).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: AdminHelperMappers.dashboardSeverityColor(
                          severity,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (suggestedActions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Suggested Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...suggestedActions.map((action) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        TraqIcon(AppAssets.iconChevronR, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(action)),
                      ],
                    ),
                  )).toList(),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _showAnomalyDetails(anomaly),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _correctAnomaly(anomaly),
                      icon: TraqIcon(AppAssets.iconBuild),
                      label: const Text('Apply Correction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCorrectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadStateView<Map<String, dynamic>>(
            state: _correctionStatisticsState,
            onRetry: _loadCorrectionStatistics,
            emptyWidget: const SizedBox.shrink(),
            builder: (context, stats) => _buildCorrectionStatisticsCard(stats),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconSettings, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Correctable Errors',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _isIdentifyingErrors ? null : _identifyCorrectableErrors,
                        icon: _isIdentifyingErrors
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : TraqIcon(AppAssets.iconSearch),
                        label: Text(_isIdentifyingErrors ? 'Identifying...' : 'Identify Errors'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_correctableErrors.isNotEmpty) ...[
                    Text('${_correctableErrors.length} correctable errors found'),
                    const SizedBox(height: 16),
                    ..._correctableErrors.map((error) => _buildCorrectableErrorCard(error)).toList(),
                  ] else
                    const Text('No correctable errors identified yet. Click "Identify Errors" to start scanning.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionStatisticsCard(Map<String, dynamic> stats) {
    final totalErrors = stats['total_errors_identified'] ?? 0;
    final totalWorkflows = stats['total_workflows_created'] ?? 0;
    final approvalRate = (stats['approval_rate_percentage'] ?? 0.0).toDouble();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Correction Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Errors',
                    totalErrors.toString(),
                    Colors.red,
                    AppAssets.iconXCircle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Workflows Created',
                    totalWorkflows.toString(),
                    Colors.blue,
                    AppAssets.iconWork,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Approval Rate',
                    '${approvalRate.toStringAsFixed(1)}%',
                    AdminHelperMappers.scoreColor(approvalRate),
                    AppAssets.iconCheck,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectableErrorCard(Map<String, dynamic> error) {
    final type = error['error_type'] ?? 'UNKNOWN';
    final severity = error['severity'] ?? 'MEDIUM';
    final description = error['error_description'] ?? '';
    final correctionType = error['correction_type'] ?? 'MANUAL';
    final isCorrectable = error['is_correctable'] ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  isCorrectable ? NavIcons.systemTools : AppAssets.iconAlert,
                  color: isCorrectable ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (isCorrectable)
                  ElevatedButton(
                    onPressed: () => _showCorrectionDialog(error),
                    child: const Text('Correct'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(severity),
                  backgroundColor: AdminHelperMappers.dashboardSeverityColor(
                    severity,
                  ).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AdminHelperMappers.dashboardSeverityColor(severity),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(correctionType),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrityMonitoringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconLock, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text(
                        'Integrity Monitoring',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _startIntegrityJob(),
                        icon: TraqIcon(AppAssets.iconArrowR),
                        label: const Text('Run Integrity Check'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoadStateView<List<dynamic>>(
                    state: _jobsState,
                    onRetry: _refreshJobsState,
                    emptyWidget: const Text('No integrity monitoring jobs have been run yet.'),
                    builder: (context, jobs) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Integrity Jobs',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...jobs.map((job) => _buildIntegrityJobCard(job)).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrityJobCard(Map<String, dynamic> job) {
    final jobId = job['job_id'] ?? 'UNKNOWN';
    final status = job['status'] ?? 'UNKNOWN';
    final progress = (job['progress'] ?? 0.0).toDouble();
    final results = job['results'] as Map<String, dynamic>?;
    final isCompleted = status.toUpperCase() == 'COMPLETED';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircularProgressIndicator(
          value: progress / 100.0,
          backgroundColor: Colors.grey[300],
        ),
        title: Text(jobId),
        subtitle: Text('Status: $status (${progress.toStringAsFixed(0)}%)'),
        trailing: _buildJobStatusIcon(status),
        children: [
          if (isCompleted && results != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Integrity Check Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultMetric(
                          'Events Checked',
                          '${results['events_checked'] ?? 0}',
                          AppAssets.iconCalendar,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildResultMetric(
                          'Violations Found',
                          '${results['integrity_violations'] ?? 0}',
                          AppAssets.iconAlert,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildResultMetric(
                    'Overall Integrity Score',
                    '${results['overall_integrity_score'] ?? 0}%',
                    AppAssets.iconGrade,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  if (results['integrity_violations'] != null && results['integrity_violations'] > 0)
                    ElevatedButton.icon(
                      onPressed: () => _showIntegrityViolations(jobId, results),
                      icon: TraqIcon(AppAssets.iconList),
                      label: const Text('View Violation Details'),
                    ),
                ],
              ),
            ),
          ] else if (status.toUpperCase() == 'RUNNING') ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Current Phase: ${job['phase'] ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100.0,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ] else if (status.toUpperCase() == 'FAILED') ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${job['error'] ?? 'Unknown error occurred'}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultMetric(String title, String value, String iconAsset, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showIntegrityViolations(String jobId, Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Integrity Violations - $jobId'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Found ${results['integrity_violations']} violations:'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildViolationItem(
                        'Missing Event Chain',
                        'EPC-12345: Gap detected between shipping and receiving events',
                        AppAssets.iconBrokenImage,
                        Colors.red,
                      ),
                      _buildViolationItem(
                        'Timestamp Inconsistency',
                        'EPC-67890: Receiving event timestamp precedes shipping event',
                        AppAssets.iconClock,
                        Colors.orange,
                      ),
                      _buildViolationItem(
                        'Location Mismatch',
                        'EPC-54321: Event location does not match expected business rules',
                        AppAssets.iconMapPin,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () => _startCorrectionWorkflow(jobId, results),
              child: const Text('Start Correction'),
            ),
          ],
        );
      },
    );
  }

  void _startCorrectionWorkflow(String jobId, Map<String, dynamic> results) async {
    Navigator.of(context).pop();
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Initiating correction workflow...'),
              ],
            ),
          );
        },
      );

      final errorId = 'INTEGRITY_VIOLATIONS_$jobId';
      
      final violations = [
        {
          'type': 'MISSING_EVENT_CHAIN',
          'epc': 'EPC-12345',
          'description': 'Gap detected between shipping and receiving events',
          'proposed_action': 'GENERATE_MISSING_EVENTS',
          'priority': 'HIGH'
        },
        {
          'type': 'TIMESTAMP_INCONSISTENCY',
          'epc': 'EPC-67890',
          'description': 'Receiving event timestamp precedes shipping event',
          'proposed_action': 'ADJUST_TIMESTAMPS',
          'priority': 'MEDIUM'
        },
        {
          'type': 'LOCATION_MISMATCH',
          'epc': 'EPC-54321',
          'description': 'Event location does not match expected business rules',
          'proposed_action': 'VALIDATE_LOCATION',
          'priority': 'LOW'
        },
      ];

      await _correctionService.registerIntegrityViolations(
        jobId,
        violations,
        results['overall_integrity_score']?.toDouble() ?? 0.0,
      );
      
      final proposedCorrection = {
        'source_job_id': jobId,
        'correction_type': 'BULK_INTEGRITY_CORRECTION',
        'requested_by': 'system_integrity_check',
        'urgency': results['integrity_violations'] > 5 ? 'HIGH' : 'NORMAL',
        'auto_approve': results['integrity_violations'] <= 2,
      };

      const currentUserId = 'admin_user';

      final workflowResult = await _correctionService.initiateErrorCorrectionWorkflow(
        errorId,
        'INTEGRITY_VIOLATION_CORRECTION',
        proposedCorrection,
        currentUserId,
      );

      Navigator.of(context).pop();

      setState(() {
        final workflowId = workflowResult['workflow_id'];
        final existingIndex = _correctionWorkflows.indexWhere((w) => w['workflow_id'] == workflowId);
        
        final newWorkflow = {
          'workflow_id': workflowId,
          'status': workflowResult['status'],
          'source_job_id': jobId,
          'violation_count': results['integrity_violations'],
          'created_time': DateTime.now(),
          'requires_approval': workflowResult['requires_approval'] ?? false,
        };
        
        if (existingIndex >= 0) {
          _correctionWorkflows[existingIndex] = newWorkflow;
        } else {
          _correctionWorkflows.insert(0, newWorkflow);
        }
      });
      
      final persistedWorkflow = {
        'workflow_id': workflowResult['workflow_id'],
        'status': workflowResult['status'],
        'source_job_id': jobId,
        'violation_count': results['integrity_violations'],
        'created_time': DateTime.now(),
        'requires_approval': workflowResult['requires_approval'] ?? false,
      };
      _persistenceService.addCorrectionWorkflow(persistedWorkflow);
      
      _pollWorkflowStatus(workflowResult['workflow_id']);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                TraqIcon(AppAssets.iconCheck, color: Colors.green),
                SizedBox(width: 8),
                Text('Correction Workflow Started'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error ID: $errorId'),
                Text('Workflow ID: ${workflowResult['workflow_id']}'),
                Text('Status: ${workflowResult['status']}'),
                const SizedBox(height: 12),
                Text('Violations to be corrected: ${results['integrity_violations']}'),
                if (workflowResult['requires_approval'] == true)
                  const Text(
                    'Note: This workflow requires approval before corrections are applied.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToWorkflowDetails(workflowResult['workflow_id']);
                },
                child: const Text('View Workflow'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      Navigator.of(context).pop();
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                TraqIcon(AppAssets.iconAlert, color: Colors.red),
                SizedBox(width: 8),
                Text('Workflow Creation Failed'),
              ],
            ),
            content: Text('Failed to start correction workflow: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToWorkflowDetails(String workflowId) {
    context.showSnackBar(
      SnackBar(
        content: Text('Workflow $workflowId created. Check the Error Correction section for progress.'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildViolationItem(String title, String description, String iconAsset, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: TraqIcon(iconAsset, color: color),
        title: Text(title),
        subtitle: Text(description),
        trailing: TraqIcon(AppAssets.iconChevronR, size: 16, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildJobStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return TraqIcon(AppAssets.iconCheck, color: Colors.green);
      case 'RUNNING':
        return TraqIcon(AppAssets.iconArrowR, color: Colors.blue);
      case 'FAILED':
        return TraqIcon(AppAssets.iconAlert, color: Colors.red);
      default:
        return TraqIcon(AppAssets.iconInfo, color: Colors.grey);
    }
  }

  Widget _buildMetricCard(String title, String value, Color color, String iconAsset) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TraqIcon(iconAsset, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildFiltersDialog(),
    );
  }

  Widget _buildFiltersDialog() {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Dashboard Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      child: Text('Start: ${_startDate.toString().split(' ')[0]}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      child: Text('End: ${_endDate.toString().split(' ')[0]}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text('Event Types', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...[
                'ObjectEvent',
                'AggregationEvent', 
                'TransactionEvent',
                'TransformationEvent'
              ].map((type) => CheckboxListTile(
                title: Text(type),
                value: _selectedEventTypes.contains(type),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedEventTypes.add(type);
                    } else {
                      _selectedEventTypes.remove(type);
                    }
                  });
                },
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshLoadedTabs();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showCorrectionDialog(Map<String, dynamic> error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Correct Error: ${error['error_type']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${error['error_description']}'),
            const SizedBox(height: 16),
            Text('Correction Type: ${error['correction_type']}'),
            const SizedBox(height: 16),
            if (error['correction_type'] == 'AUTOMATIC')
              const Text('This error can be corrected automatically.')
            else
              const Text('This error requires manual intervention or approval.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initiateCorrectionWorkflow(error);
            },
            child: const Text('Start Correction'),
          ),
        ],
      ),
    );
  }

  void _initiateCorrectionWorkflow(Map<String, dynamic> error) async {
    try {
      final result = await _correctionService.initiateErrorCorrectionWorkflow(
        error['error_id'],
        error['correction_type'],
        error['proposed_correction'] ?? {},
        'current_user',
      );
      
      context.showSuccess('Correction workflow initiated: ${result['workflow_id']}');
      
      _identifyCorrectableErrors();
    } catch (e) {
      _showErrorSnackBar('Failed to initiate correction workflow: $e');
    }
  }

  void _startIntegrityJob() async {
    try {
      final result = await _consistencyService.runDataIntegrityVerificationJob({
        'scope': 'FULL',
        'time_range': {
          'start': _startDate.toIso8601String(),
          'end': _endDate.toIso8601String(),
        },
        'event_types': _selectedEventTypes,
      });
      
      setState(() {
        _integrityJobs.insert(0, {
          'job_id': result['job_id'],
          'status': 'RUNNING',
          'progress': 0.0,
        });
      });
      
      _persistenceService.addIntegrityJob({
        'job_id': result['job_id'],
        'status': 'RUNNING',
        'progress': 0.0,
      });
      
      context.showInfo('Integrity verification job started: ${result['job_id']}');
      
      _pollJobStatus(result['job_id']);
    } catch (e) {
      _showErrorSnackBar('Failed to start integrity job: $e');
    }
  }

  void _pollJobStatus(String jobId) {
    _jobPollTimers[jobId]?.cancel();
    _jobPollTimers[jobId] = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final status = await _consistencyService.getIntegrityJobStatus(jobId);

        if (mounted) {
          setState(() {
            final jobIndex = _integrityJobs.indexWhere((job) => job['job_id'] == jobId);
            if (jobIndex >= 0) {
              _integrityJobs[jobIndex] = status;
            }
          });
        }

        _persistenceService.updateIntegrityJob(jobId, status);

        if (status['status'] == 'COMPLETED' || status['status'] == 'FAILED') {
          timer.cancel();
          _jobPollTimers.remove(jobId);
        }
      } catch (e) {
        timer.cancel();
        _jobPollTimers.remove(jobId);
      }
    });
  }

  Widget _buildWorkflowsTab() {
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconGlobe, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Text(
                        'Correction Workflows',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _refreshWorkflowData,
                        icon: TraqIcon(AppAssets.iconRefresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Active Workflows: ${_correctionWorkflows.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          LoadStateView<List<Map<String, dynamic>>>(
            state: _workflowDataState,
            onRetry: _loadWorkflowData,
            emptyWidget: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      TraqIcon(AppAssets.iconGlobe, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No correction workflows found (Length: ${_correctionWorkflows.length})',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start error corrections from the Error Correction tab to see workflows here.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWorkflowData,
                        child: const Text('Load Workflows'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            builder: (context, workflows) => Column(
              children: workflows.map((workflow) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCorrectionWorkflowCard(workflow),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshWorkflowData() async {
    try {
      final workflows = await _correctionService.getAllCorrectionWorkflows();
      
      setState(() {
        _correctionWorkflows.clear();
        
        for (int i = 0; i < workflows.length; i++) {
          final w = workflows[i];
          
          final mappedWorkflow = {
            'workflow_id': w['workflow_id'] ?? 'UNKNOWN',
            'status': w['workflow_status'] ?? 'UNKNOWN',
            'source_job_id': w['error_id'] ?? 'UNKNOWN',
            'violation_count': w['current_step'] ?? 0,
            'created_time': DateTime.now(),
            'requires_approval': false,
            'workflow_type': w['workflow_type'] ?? 'UNKNOWN',
          };
          
          _correctionWorkflows.add(mappedWorkflow);
        }

        _workflowDataState = _correctionWorkflows.isEmpty
            ? const LoadState.empty()
            : LoadState.success(_correctionWorkflows);
      });

      context.showSuccess('Loaded ${_correctionWorkflows.length} workflows');
    } catch (e) {
      context.showError('Error: $e');
    }
  }

  Widget _buildCorrectionWorkflowCard(Map<String, dynamic> workflow) {
    final workflowId = workflow['workflow_id'] ?? 'UNKNOWN';
    final status = workflow['status'] ?? 'UNKNOWN';
    final sourceJobId = workflow['source_job_id'] ?? 'UNKNOWN';
    final workflowType = workflow['workflow_type'] ?? 'UNKNOWN';
    final currentStep = workflow['violation_count'] ?? 0;
    final createdTime = workflow['created_time'] as DateTime?;
    final completionTime = workflow['completion_time'];
    final executionResults = workflow['execution_results'];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AdminHelperMappers.workflowStatusColor(status),
          child: TraqIcon(
            AdminHelperMappers.workflowStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text('Workflow: $workflowId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $workflowType'),
            Text('Source: $sourceJobId'),
            Text('Step: $currentStep'),
            if (createdTime != null)
              Text('Created: ${createdTime.toString().substring(0, 19)}'),
            if (status.toUpperCase() == 'COMPLETED' && executionResults != null && executionResults['corrected_violations'] != null) 
              Text('Corrected: ${(executionResults['corrected_violations'] as List).length} violations', 
                   style: const TextStyle(color: Colors.green)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AdminHelperMappers.workflowStatusColor(status),
              ),
            ),
            if (completionTime != null)
              Text(
                'Completed',
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
          ],
        ),
        onTap: () => _showWorkflowDetails(workflow),
      ),
    );
  }

  void _showWorkflowDetails(Map<String, dynamic> workflow) {
    final executionResults = workflow['execution_results'];
    final correctionData = workflow['correction_data'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Workflow Details - ${workflow['workflow_id']}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Status', workflow['status'] ?? 'Unknown'),
                  _buildDetailRow('Type', workflow['workflow_type'] ?? 'Unknown'),
                  _buildDetailRow('Source Job', workflow['source_job_id'] ?? 'Unknown'),
                  _buildDetailRow('Current Step', '${workflow['violation_count'] ?? 0}'),
                  _buildDetailRow('Initiated By', workflow['initiated_by'] ?? 'Unknown'),
                  if (workflow['created_time'] != null)
                    _buildDetailRow('Created', workflow['created_time'].toString().substring(0, 19)),
                  if (workflow['completion_time'] != null)
                    _buildDetailRow('Completed', workflow['completion_time'].toString().substring(0, 19)),
                  
                  if (correctionData != null) ...[
                    const SizedBox(height: 16),
                    const Text('Correction Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Correction Type', correctionData['correction_type'] ?? 'Unknown'),
                    _buildDetailRow('Requested By', correctionData['requested_by'] ?? 'Unknown'),
                    _buildDetailRow('Urgency', correctionData['urgency'] ?? 'Unknown'),
                  ],
                  
                  if (executionResults != null && executionResults['corrected_violations'] != null) ...[
                    const SizedBox(height: 16),
                    const Text('Corrected Violations:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...((executionResults['corrected_violations'] as List).map((violation) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text('â€¢ $violation', style: const TextStyle(color: Colors.green)),
                      )
                    )).toList(),
                    const SizedBox(height: 8),
                    _buildDetailRow('Success', '${executionResults['success'] ?? false}'),
                    if (executionResults['correction_time'] != null)
                      _buildDetailRow('Correction Time', executionResults['correction_time'].toString().substring(0, 19)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (workflow['status'] == 'AWAITING_APPROVAL')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.showInfo('Approval interface coming soon');
                },
                child: const Text('Review for Approval'),
              ),
          ],
        );
      },
    );
  }

  void _pollWorkflowStatus(String workflowId) {
    _workflowPollTimers[workflowId]?.cancel();
    _workflowPollTimers[workflowId] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await _correctionService.getCorrectionWorkflowStatus(workflowId);

        if (mounted) {
          setState(() {
            final workflowIndex = _correctionWorkflows.indexWhere((w) => w['workflow_id'] == workflowId);
            if (workflowIndex >= 0) {
              _correctionWorkflows[workflowIndex] = {
                ..._correctionWorkflows[workflowIndex],
                'status': status['workflow_status'],
                'current_step': status['current_step'],
                'total_steps': status['total_steps'],
                'last_updated': status['last_updated'],
              };
            }
          });
        }

        final workflowIndex = _correctionWorkflows.indexWhere((w) => w['workflow_id'] == workflowId);
        if (workflowIndex >= 0) {
          _persistenceService.updateCorrectionWorkflow(workflowId, _correctionWorkflows[workflowIndex]);
        }

        if (status['workflow_status'] == 'COMPLETED' || status['workflow_status'] == 'FAILED') {
          timer.cancel();
          _workflowPollTimers.remove(workflowId);

          if (status['workflow_status'] == 'COMPLETED') {
            _identifyCorrectableErrors();
          }
        }
      } catch (e) {
        timer.cancel();
        _workflowPollTimers.remove(workflowId);
      }
    });
  }
}
