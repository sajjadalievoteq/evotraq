import 'dart:async';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/services/admin/data_consistency_service.dart';
import 'package:traqtrace_app/data/services/admin/error_correction_service.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/data_consistency_integrity_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_detail_row.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';

extension DataConsistencyActions on DataConsistencyIntegrityDashboardState {
  void onPersistenceUpdate() {
    if (mounted) {
      setState(() {
        integrityJobs = persistenceService.integrityJobs;
        correctionWorkflows = persistenceService.correctionWorkflows;
        if (loadedTabs.contains(3)) {
          jobsState = integrityJobs.isEmpty
              ? const LoadState.empty()
              : LoadState.success(integrityJobs);
        }
        if (loadedTabs.contains(4)) {
          workflowDataState = correctionWorkflows.isEmpty
              ? const LoadState.empty()
              : LoadState.success(correctionWorkflows);
        }
      });
    }
  }

  void initializeServices() {
    consistencyService = getIt<DataConsistencyService>();
    correctionService = getIt<ErrorCorrectionService>();
  }

  void startAutoRefresh() {
    refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        refreshLoadedTabs();
      }
    });
  }

  Future<void> _triggerTabLoad(int index) {
    switch (index) {
      case 2:
        return loadCorrectionStatistics();
      case 3:
        refreshJobsState();
        return Future.value();
      case 4:
        return loadWorkflowData();
      default:
        return Future.value();
    }
  }

  void ensureTabLoaded(int index) {
    if (loadedTabs.contains(index)) return;
    loadedTabs.add(index);
    _triggerTabLoad(index);
  }

  Future<void> refreshLoadedTabs() async {
    if (!mounted) return;
    setState(() {
      isRefreshingAll = true;
    });
    try {
      await Future.wait(loadedTabs.map(_triggerTabLoad));
    } finally {
      if (mounted) {
        setState(() {
          isRefreshingAll = false;
        });
      }
    }
  }

  void refreshJobsState() {
    if (!mounted) return;
    setState(() {
      jobsState = integrityJobs.isEmpty
          ? const LoadState.empty()
          : LoadState.success(integrityJobs);
    });
  }

  Future<void> loadWorkflowData() async {
    if (mounted) {
      setState(() {
        if (workflowDataState.data == null) {
          workflowDataState = const LoadState.loading();
        }
      });
    }

    try {
      final workflows = await correctionService.getAllCorrectionWorkflows();
      if (!mounted) return;

      setState(() {
        correctionWorkflows.clear();

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

          correctionWorkflows.add(mappedWorkflow);
        }

        workflowDataState = correctionWorkflows.isEmpty
            ? const LoadState.empty()
            : LoadState.success(correctionWorkflows);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          workflowDataState = correctionWorkflows.isNotEmpty
              ? LoadState.success(correctionWorkflows)
              : LoadState.error('Failed to load workflows: $e');
        });
      }
    }
  }

  Future<void> generateConsistencyReport() async {
    if (!mounted) return;
    setState(() {
      isGeneratingReport = true;
      if (consistencyReportState.data == null) {
        consistencyReportState = const LoadState.loading();
      }
    });

    try {
      final report = await consistencyService.generateConsistencyReport(
        startDate,
        endDate,
        selectedEventTypes,
      );

      if (mounted) {
        setState(() {
          consistencyReportState = LoadState.success(report);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final previous = consistencyReportState.data;
          consistencyReportState = previous != null
              ? LoadState.success(previous)
              : LoadState.error('Failed to generate consistency report: $e');
        });
      }
      showErrorSnackBar('Failed to generate consistency report: $e');
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingReport = false;
        });
      }
    }
  }

  Future<void> detectAnomalies() async {
    if (!mounted) return;
    setState(() {
      isDetectingAnomalies = true;
      if (anomaliesState.data == null) {
        anomaliesState = const LoadState.loading();
      }
    });

    try {
      final anomalies = await consistencyService.detectDataAnomalies({
        'start': startDate,
        'end': endDate,
      }, selectedEventTypes);

      if (mounted) {
        setState(() {
          anomaliesState = anomalies.isEmpty
              ? const LoadState.empty()
              : LoadState.success(anomalies);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final previous = anomaliesState.data;
          anomaliesState = (previous != null && previous.isNotEmpty)
              ? LoadState.success(previous)
              : LoadState.error('Failed to detect anomalies: $e');
        });
      }
      showErrorSnackBar('Failed to detect anomalies: $e');
    } finally {
      if (mounted) {
        setState(() {
          isDetectingAnomalies = false;
        });
      }
    }
  }

  Future<void> identifyCorrectableErrors() async {
    setState(() {
      isIdentifyingErrors = true;
    });

    try {
      final errors = await correctionService.identifyCorrectableErrors(
        startDate,
        endDate,
        selectedErrorTypes,
      );

      setState(() {
        correctableErrors = errors;
      });
    } catch (e) {
      showErrorSnackBar('Failed to identify correctable errors: $e');
    } finally {
      setState(() {
        isIdentifyingErrors = false;
      });
    }
  }

  Future<void> loadCorrectionStatistics() async {
    if (mounted) {
      setState(() {
        if (correctionStatisticsState.data == null) {
          correctionStatisticsState = const LoadState.loading();
        }
      });
    }

    try {
      final statistics = await correctionService.getErrorCorrectionStatistics(
        startDate,
        endDate,
      );

      if (mounted) {
        setState(() {
          correctionStatisticsState = LoadState.success(statistics);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final previous = correctionStatisticsState.data;
          correctionStatisticsState = previous != null
              ? LoadState.success(previous)
              : LoadState.error('Failed to load correction statistics: $e');
        });
      }
    }
  }

  void showErrorSnackBar(String message) {
    context.showError(message, duration: const Duration(seconds: 5));
  }

  Future<void> correctConsistencyViolation(
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
        final errorId = await correctionService.registerRealError(
          violationType,
          description,
          violation['affected_events']?.cast<String>() ?? [],
          violation['severity'] ?? 'MEDIUM',
          {
            'violation_data': violation,
            'correction_type': 'CONSISTENCY_VIOLATION',
          },
        );

        final workflowId = await correctionService
            .initiateErrorCorrectionWorkflow(errorId, 'MANUAL', {
              'source': 'CONSISTENCY_VALIDATION',
              'violation_type': violationType,
              'violation_data': violation,
            }, 'current_user');

        context.showSuccess(
          'Correction workflow $workflowId created successfully!',
        );

        await loadWorkflowData();
      } catch (e) {
        showErrorSnackBar('Failed to create correction workflow: $e');
      }
    }
  }

  void showViolationDetails(Map<String, dynamic> violation) {
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

  Future<void> correctAnomaly(Map<String, dynamic> anomaly) async {
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
        final errorId = await correctionService.registerRealError(
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

        final workflowId = await correctionService
            .initiateErrorCorrectionWorkflow(errorId, 'MANUAL', {
              'source': 'ANOMALY_DETECTION',
              'anomaly_type': anomalyType,
              'anomaly_data': anomaly,
            }, 'current_user');

        context.showSuccess(
          'Correction workflow $workflowId created successfully!',
        );

        await loadWorkflowData();
      } catch (e) {
        showErrorSnackBar('Failed to create correction workflow: $e');
      }
    }
  }
}
