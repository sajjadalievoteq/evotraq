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
              ConsistencyDetailRow('Type', violation['violation_type']),
              ConsistencyDetailRow('Severity', violation['severity']),
              ConsistencyDetailRow('Description', violation['description']),
              ConsistencyDetailRow('Affected Events', violation['affected_events']?.join(', ')),
              ConsistencyDetailRow('Detection Time', violation['detection_time']),
              ConsistencyDetailRow('Suggested Resolution', violation['suggested_resolution']),
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
              ConsistencyDetailRow('Type', anomaly['anomaly_type']),
              ConsistencyDetailRow('Severity', anomaly['severity']),
              ConsistencyDetailRow('Confidence Score', '${((anomaly['confidence_score'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
              ConsistencyDetailRow('Description', anomaly['description']),
              ConsistencyDetailRow('Expected Pattern', anomaly['expected_pattern']),
              ConsistencyDetailRow('Actual Pattern', anomaly['actual_pattern']),
              ConsistencyDetailRow('Deviation Magnitude', anomaly['deviation_magnitude']?.toString()),
              ConsistencyDetailRow('Affected Events', anomaly['affected_events']?.join(', ')),
              ConsistencyDetailRow('Detection Time', anomaly['detection_time']),
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
                      ConsistencyViolationItem(
                        'Missing Event Chain',
                        'EPC-12345: Gap detected between shipping and receiving events',
                        AppAssets.iconBrokenImage,
                        AppColorMapper.errorColor(context),
                      ),
                      ConsistencyViolationItem(
                        'Timestamp Inconsistency',
                        'EPC-67890: Receiving event timestamp precedes shipping event',
                        AppAssets.iconClock,
                        AppColorMapper.warningColor(context),
                      ),
                      ConsistencyViolationItem(
                        'Location Mismatch',
                        'EPC-54321: Event location does not match expected business rules',
                        AppAssets.iconMapPin,
                        AppColorMapper.infoColor(context),
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
            title: Row(
              children: [
                TraqIcon(AppAssets.iconCheck, color: AppColorMapper.successColor(context)),
                const SizedBox(width: 8),
                const Text('Correction Workflow Started'),
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
            title: Row(
              children: [
                TraqIcon(AppAssets.iconAlert, color: AppColorMapper.errorColor(context)),
                const SizedBox(width: 8),
                const Text('Workflow Creation Failed'),
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




  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
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
                ...'ObjectEvent,AggregationEvent,TransactionEvent,TransformationEvent'
                    .split(',')
                    .map((type) => CheckboxListTile(
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
                        )),
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
                  ConsistencyDetailRow('Status', workflow['status'] ?? 'Unknown'),
                  ConsistencyDetailRow('Type', workflow['workflow_type'] ?? 'Unknown'),
                  ConsistencyDetailRow('Source Job', workflow['source_job_id'] ?? 'Unknown'),
                  ConsistencyDetailRow('Current Step', '${workflow['violation_count'] ?? 0}'),
                  ConsistencyDetailRow('Initiated By', workflow['initiated_by'] ?? 'Unknown'),
                  if (workflow['created_time'] != null)
                    ConsistencyDetailRow('Created', workflow['created_time'].toString().substring(0, 19)),
                  if (workflow['completion_time'] != null)
                    ConsistencyDetailRow('Completed', workflow['completion_time'].toString().substring(0, 19)),
                  
                  if (correctionData != null) ...[
                    const SizedBox(height: 16),
                    const Text('Correction Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ConsistencyDetailRow('Correction Type', correctionData['correction_type'] ?? 'Unknown'),
                    ConsistencyDetailRow('Requested By', correctionData['requested_by'] ?? 'Unknown'),
                    ConsistencyDetailRow('Urgency', correctionData['urgency'] ?? 'Unknown'),
                  ],
                  
                  if (executionResults != null && executionResults['corrected_violations'] != null) ...[
                    const SizedBox(height: 16),
                    const Text('Corrected Violations:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...((executionResults['corrected_violations'] as List).map((violation) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text('â€¢ $violation', style: TextStyle(color: AppColorMapper.successColor(context))),
                      )
                    )).toList(),
                    const SizedBox(height: 8),
                    ConsistencyDetailRow('Success', '${executionResults['success'] ?? false}'),
                    if (executionResults['correction_time'] != null)
                      ConsistencyDetailRow('Correction Time', executionResults['correction_time'].toString().substring(0, 19)),
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
