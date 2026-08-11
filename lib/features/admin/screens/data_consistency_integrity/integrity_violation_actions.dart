part of 'data_consistency_integrity_dashboard_screen.dart';

extension IntegrityViolationActions on _DataConsistencyIntegrityDashboardState {
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

  void _startCorrectionWorkflow(
    String jobId,
    Map<String, dynamic> results,
  ) async {
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
          'priority': 'HIGH',
        },
        {
          'type': 'TIMESTAMP_INCONSISTENCY',
          'epc': 'EPC-67890',
          'description': 'Receiving event timestamp precedes shipping event',
          'proposed_action': 'ADJUST_TIMESTAMPS',
          'priority': 'MEDIUM',
        },
        {
          'type': 'LOCATION_MISMATCH',
          'epc': 'EPC-54321',
          'description':
              'Event location does not match expected business rules',
          'proposed_action': 'VALIDATE_LOCATION',
          'priority': 'LOW',
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

      final workflowResult = await _correctionService
          .initiateErrorCorrectionWorkflow(
            errorId,
            'INTEGRITY_VIOLATION_CORRECTION',
            proposedCorrection,
            currentUserId,
          );

      Navigator.of(context).pop();

      setState(() {
        final workflowId = workflowResult['workflow_id'];
        final existingIndex = _correctionWorkflows.indexWhere(
          (w) => w['workflow_id'] == workflowId,
        );

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
                TraqIcon(
                  AppAssets.iconCheck,
                  color: AppColorMapper.successColor(context),
                ),
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
                Text(
                  'Violations to be corrected: ${results['integrity_violations']}',
                ),
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
                TraqIcon(
                  AppAssets.iconAlert,
                  color: AppColorMapper.errorColor(context),
                ),
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
              ConsistencyDetailRow(
                'Confidence Score',
                '${((anomaly['confidence_score'] ?? 0.0) * 100).toStringAsFixed(1)}%',
              ),
              ConsistencyDetailRow('Description', anomaly['description']),
              ConsistencyDetailRow(
                'Expected Pattern',
                anomaly['expected_pattern'],
              ),
              ConsistencyDetailRow('Actual Pattern', anomaly['actual_pattern']),
              ConsistencyDetailRow(
                'Deviation Magnitude',
                anomaly['deviation_magnitude']?.toString(),
              ),
              ConsistencyDetailRow(
                'Affected Events',
                anomaly['affected_events']?.join(', '),
              ),
              ConsistencyDetailRow('Detection Time', anomaly['detection_time']),
              if (anomaly['suggested_actions'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Suggested Actions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...((anomaly['suggested_actions'] as List?)?.cast<String>() ??
                        [])
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text('â€¢ $action'),
                      ),
                    )
                    .toList(),
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
}
