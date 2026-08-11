part of 'event_generation_test_screen.dart';

extension EventGenerationActions on _EventGenerationTestScreenState {
  void _initializeDefaults() {
    _eventParams['readPoint'] = '0614141000012';
    _eventParams['bizLocation'] = '0614141000012';

    _simulationParams['duration'] = 300;
    _simulationParams['eventInterval'] = 1000;
    _simulationParams['includeAnomalies'] = false;
    _simulationParams['anomalyRate'] = 0.05;
    _seedCbvDefaults();
  }

  Future<void> _seedCbvDefaults() async {
    final cbvCubit = getIt<CbvVocabularyCubit>();
    await cbvCubit.loadVocabulary();
    final state = cbvCubit.state;
    if (state.bizSteps.isEmpty || state.dispositions.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _eventParams['businessStep'] = state.bizSteps.first.urn;
      _eventParams['disposition'] = state.dispositions.first.urn;
    });
  }

  Future<void> _loadDataManagementData() async {
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final environments = await _testService!.getTestEnvironments();
      final statistics = await _testService!.getTestDataStatistics();

      setState(() {
        _dataStatistics = statistics;
        _activeEnvironment = environments
            .where((env) => env.isActive)
            .firstOrNull;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load data management information: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSingleEvent() async {
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.generateSingleEvent(
        _selectedEventType,
        _eventParams,
      );

      context.showSuccess('Successfully generated event: ${result['eventId']}');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate event: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateBulkEvents() async {
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.generateBulkEvents(
        _selectedEventType,
        _bulkCount,
        _eventParams,
      );

      setState(() {
        _lastBulkResult = result;
        _isLoading = false;
      });

      context.showSuccess(
        'Successfully generated ${result.generatedCount} events',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate bulk events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _startSupplyChainSimulation() async {
    if (_testService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await _testService!.startSupplyChainSimulation(
        _simulationParams,
      );

      setState(() {
        _activeSimulation = session;
        _isLoading = false;
      });

      context.showSuccess(
        'Supply chain simulation started: ${session.sessionId}',
      );

      _pollSimulationStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start simulation: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopSupplyChainSimulation() async {
    if (_testService == null || _activeSimulation == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.stopSupplyChainSimulation(
        _activeSimulation!.sessionId,
      );

      setState(() {
        _activeSimulation = null;
        _simulationStatus = null;
        _isLoading = false;
      });

      context.showSuccess(
        'Simulation stopped. Generated ${result.totalEvents} events',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to stop simulation: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _clearSimulation() {
    setState(() {
      _activeSimulation = null;
      _simulationStatus = null;
      _errorMessage = null;
    });
  }

  Future<void> _pollSimulationStatus() async {
    if (_testService == null || _activeSimulation == null) return;

    try {
      final status = await _testService!.getSimulationStatus(
        _activeSimulation!.sessionId,
      );

      if (mounted) {
        setState(() {
          _simulationStatus = status;
        });
      }

      if (status.status == 'RUNNING') {
        Future.delayed(const Duration(seconds: 2), _pollSimulationStatus);
      }
    } catch (e) {
      // Keep polling silent for transient backend errors.
    }
  }

  Color _getSimulationStatusColor(BuildContext context) {
    final c = context.colors;
    if (_simulationStatus == null) return c.primary;

    switch (_simulationStatus!.status) {
      case 'RUNNING':
        return c.success;
      case 'COMPLETED':
        return AppColorMapper.infoColor(context);
      case 'ERROR':
        return c.error;
      case 'STOPPED':
        return AppColorMapper.warningColor(context);
      default:
        return c.primary;
    }
  }

  String _getSimulationStatusText() {
    if (_simulationStatus == null) return 'Simulation Status Unknown';

    switch (_simulationStatus!.status) {
      case 'RUNNING':
        return 'Simulation Running';
      case 'COMPLETED':
        return 'Simulation Completed';
      case 'ERROR':
        return 'Simulation Error';
      case 'STOPPED':
        return 'Simulation Stopped';
      default:
        return 'Simulation ${_simulationStatus!.status}';
    }
  }
}
