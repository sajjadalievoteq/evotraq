part of 'data_consistency_integrity_dashboard_screen.dart';

extension CorrectionWorkflowActions on _DataConsistencyIntegrityDashboardState {
  void _navigateToWorkflowDetails(String workflowId) {
    context.showSnackBar(
      SnackBar(
        content: Text(
          'Workflow $workflowId created. Check the Error Correction section for progress.',
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
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
                const Text(
                  'Date Range',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                        child: Text(
                          'Start: ${_startDate.toString().split(' ')[0]}',
                        ),
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
                        child: Text(
                          'End: ${_endDate.toString().split(' ')[0]}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Event Types',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...'ObjectEvent,AggregationEvent,TransactionEvent,TransformationEvent'
                    .split(',')
                    .map(
                      (type) => CheckboxListTile(
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
                      ),
                    ),
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
              const Text(
                'This error requires manual intervention or approval.',
              ),
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

      context.showSuccess(
        'Correction workflow initiated: ${result['workflow_id']}',
      );

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

      context.showInfo(
        'Integrity verification job started: ${result['job_id']}',
      );

      _pollJobStatus(result['job_id']);
    } catch (e) {
      _showErrorSnackBar('Failed to start integrity job: $e');
    }
  }

  void _pollJobStatus(String jobId) {
    _jobPollTimers[jobId]?.cancel();
    _jobPollTimers[jobId] = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      try {
        final status = await _consistencyService.getIntegrityJobStatus(jobId);

        if (mounted) {
          setState(() {
            final jobIndex = _integrityJobs.indexWhere(
              (job) => job['job_id'] == jobId,
            );
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
                  ConsistencyDetailRow(
                    'Status',
                    workflow['status'] ?? 'Unknown',
                  ),
                  ConsistencyDetailRow(
                    'Type',
                    workflow['workflow_type'] ?? 'Unknown',
                  ),
                  ConsistencyDetailRow(
                    'Source Job',
                    workflow['source_job_id'] ?? 'Unknown',
                  ),
                  ConsistencyDetailRow(
                    'Current Step',
                    '${workflow['violation_count'] ?? 0}',
                  ),
                  ConsistencyDetailRow(
                    'Initiated By',
                    workflow['initiated_by'] ?? 'Unknown',
                  ),
                  if (workflow['created_time'] != null)
                    ConsistencyDetailRow(
                      'Created',
                      workflow['created_time'].toString().substring(0, 19),
                    ),
                  if (workflow['completion_time'] != null)
                    ConsistencyDetailRow(
                      'Completed',
                      workflow['completion_time'].toString().substring(0, 19),
                    ),

                  if (correctionData != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Correction Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ConsistencyDetailRow(
                      'Correction Type',
                      correctionData['correction_type'] ?? 'Unknown',
                    ),
                    ConsistencyDetailRow(
                      'Requested By',
                      correctionData['requested_by'] ?? 'Unknown',
                    ),
                    ConsistencyDetailRow(
                      'Urgency',
                      correctionData['urgency'] ?? 'Unknown',
                    ),
                  ],

                  if (executionResults != null &&
                      executionResults['corrected_violations'] != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Corrected Violations:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...((executionResults['corrected_violations'] as List).map(
                      (violation) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text(
                          'â€¢ $violation',
                          style: TextStyle(
                            color: AppColorMapper.successColor(context),
                          ),
                        ),
                      ),
                    )).toList(),
                    const SizedBox(height: 8),
                    ConsistencyDetailRow(
                      'Success',
                      '${executionResults['success'] ?? false}',
                    ),
                    if (executionResults['correction_time'] != null)
                      ConsistencyDetailRow(
                        'Correction Time',
                        executionResults['correction_time']
                            .toString()
                            .substring(0, 19),
                      ),
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
    _workflowPollTimers[workflowId] = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        try {
          final status = await _correctionService.getCorrectionWorkflowStatus(
            workflowId,
          );

          if (mounted) {
            setState(() {
              final workflowIndex = _correctionWorkflows.indexWhere(
                (w) => w['workflow_id'] == workflowId,
              );
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

          final workflowIndex = _correctionWorkflows.indexWhere(
            (w) => w['workflow_id'] == workflowId,
          );
          if (workflowIndex >= 0) {
            _persistenceService.updateCorrectionWorkflow(
              workflowId,
              _correctionWorkflows[workflowIndex],
            );
          }

          if (status['workflow_status'] == 'COMPLETED' ||
              status['workflow_status'] == 'FAILED') {
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
      },
    );
  }
}
