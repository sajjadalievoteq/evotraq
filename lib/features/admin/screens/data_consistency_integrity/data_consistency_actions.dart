part of 'data_consistency_integrity_dashboard_screen.dart';

extension DataConsistencyActions on _DataConsistencyIntegrityDashboardState {
  void _onPersistenceUpdate() {
    if (mounted) {
      setState(() {
        _integrityJobs = _persistenceService.integrityJobs;
        _correctionWorkflows = _persistenceService.correctionWorkflows;
        if (_loadedTabs.contains(3)) {
          _jobsState = _integrityJobs.isEmpty
              ? const LoadState.empty()
              : LoadState.success(_integrityJobs);
        }
        if (_loadedTabs.contains(4)) {
          _workflowDataState = _correctionWorkflows.isEmpty
              ? const LoadState.empty()
              : LoadState.success(_correctionWorkflows);
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
      _jobsState = _integrityJobs.isEmpty
          ? const LoadState.empty()
          : LoadState.success(_integrityJobs);
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
      final anomalies = await _consistencyService.detectDataAnomalies({
        'start': _startDate,
        'end': _endDate,
      }, _selectedEventTypes);

      if (mounted) {
        setState(() {
          _anomaliesState = anomalies.isEmpty
              ? const LoadState.empty()
              : LoadState.success(anomalies);
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

  Future<void> _correctConsistencyViolation(
    Map<String, dynamic> violation,
  ) async {
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
            const Text(
              'This will create a correction workflow to fix this violation. Continue?',
            ),
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

        final workflowId = await _correctionService
            .initiateErrorCorrectionWorkflow(errorId, 'MANUAL', {
              'source': 'CONSISTENCY_VALIDATION',
              'violation_type': violationType,
              'violation_data': violation,
            }, 'current_user');

        context.showSuccess(
          'Correction workflow $workflowId created successfully!',
        );

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
              ConsistencyDetailRow(
                'Affected Events',
                violation['affected_events']?.join(', '),
              ),
              ConsistencyDetailRow(
                'Detection Time',
                violation['detection_time'],
              ),
              ConsistencyDetailRow(
                'Suggested Resolution',
                violation['suggested_resolution'],
              ),
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
            Text(
              'Confidence: ${((anomaly['confidence_score'] ?? 0.0) * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),
            const Text(
              'This will create a correction workflow to address this anomaly. Continue?',
            ),
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

        final workflowId = await _correctionService
            .initiateErrorCorrectionWorkflow(errorId, 'MANUAL', {
              'source': 'ANOMALY_DETECTION',
              'anomaly_type': anomalyType,
              'anomaly_data': anomaly,
            }, 'current_user');

        context.showSuccess(
          'Correction workflow $workflowId created successfully!',
        );

        await _loadWorkflowData();
      } catch (e) {
        _showErrorSnackBar('Failed to create correction workflow: $e');
      }
    }
  }
}
