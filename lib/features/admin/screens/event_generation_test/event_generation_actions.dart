import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_generation_test_screen.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';

extension EventGenerationActions on EventGenerationTestScreenState {
  void initializeDefaults() {
    eventParams['readPoint'] = '0614141000012';
    eventParams['bizLocation'] = '0614141000012';

    simulationParams['duration'] = 300;
    simulationParams['eventInterval'] = 1000;
    simulationParams['includeAnomalies'] = false;
    simulationParams['anomalyRate'] = 0.05;
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
      eventParams['businessStep'] = state.bizSteps.first.urn;
      eventParams['disposition'] = state.dispositions.first.urn;
    });
  }

  Future<void> loadDataManagementData() async {
    if (testService == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final environments = await testService!.getTestEnvironments();
      final statistics = await testService!.getTestDataStatistics();

      setState(() {
        dataStatistics = statistics;
        activeEnvironment = environments
            .where((env) => env.isActive)
            .firstOrNull;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Failed to load data management information: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> generateSingleEvent() async {
    if (testService == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.generateSingleEvent(
        selectedEventType,
        eventParams,
      );

      context.showSuccess('Successfully generated event: ${result['eventId']}');

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate event: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> generateBulkEvents() async {
    if (testService == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.generateBulkEvents(
        selectedEventType,
        bulkCount,
        eventParams,
      );

      setState(() {
        lastBulkResult = result;
        isLoading = false;
      });

      context.showSuccess(
        'Successfully generated ${result.generatedCount} events',
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate bulk events: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> startSupplyChainSimulation() async {
    if (testService == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final session = await testService!.startSupplyChainSimulation(
        simulationParams,
      );

      setState(() {
        activeSimulation = session;
        isLoading = false;
      });

      context.showSuccess(
        'Supply chain simulation started: ${session.sessionId}',
      );

      pollSimulationStatus();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to start simulation: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> stopSupplyChainSimulation() async {
    if (testService == null || activeSimulation == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.stopSupplyChainSimulation(
        activeSimulation!.sessionId,
      );

      setState(() {
        activeSimulation = null;
        simulationStatus = null;
        isLoading = false;
      });

      context.showSuccess(
        'Simulation stopped. Generated ${result.totalEvents} events',
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to stop simulation: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void clearSimulation() {
    setState(() {
      activeSimulation = null;
      simulationStatus = null;
      errorMessage = null;
    });
  }

  Future<void> pollSimulationStatus() async {
    if (testService == null || activeSimulation == null) return;

    try {
      final status = await testService!.getSimulationStatus(
        activeSimulation!.sessionId,
      );

      if (mounted) {
        setState(() {
          simulationStatus = status;
        });
      }

      if (status.status == 'RUNNING') {
        Future.delayed(const Duration(seconds: 2), pollSimulationStatus);
      }
    } catch (e) {
      // Keep polling silent for transient backend errors.
    }
  }

  Color getSimulationStatusColor(BuildContext context) {
    final c = context.colors;
    if (simulationStatus == null) return c.primary;

    switch (simulationStatus!.status) {
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

  String getSimulationStatusText() {
    if (simulationStatus == null) return 'Simulation Status Unknown';

    switch (simulationStatus!.status) {
      case 'RUNNING':
        return 'Simulation Running';
      case 'COMPLETED':
        return 'Simulation Completed';
      case 'ERROR':
        return 'Simulation Error';
      case 'STOPPED':
        return 'Simulation Stopped';
      default:
        return 'Simulation ${simulationStatus!.status}';
    }
  }
}
