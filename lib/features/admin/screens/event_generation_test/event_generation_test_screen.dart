import 'package:traqtrace_app/data/services/admin/event_generation_test_data_models.dart';
import 'package:traqtrace_app/data/services/admin/event_generation_test_models.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

import 'package:traqtrace_app/data/services/admin/event_generation_test_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_data_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_generator_tab.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_simulation_tab.dart';

import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_generation_actions.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_data_cleanup_actions.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_master_data_cleanup_actions.dart';

class EventGenerationTestScreen extends StatefulWidget {
  const EventGenerationTestScreen({Key? key}) : super(key: key);

  @override
  State<EventGenerationTestScreen> createState() =>
      EventGenerationTestScreenState();
}

class EventGenerationTestScreenState extends State<EventGenerationTestScreen>
    with TickerProviderStateMixin {
  EventGenerationTestService? testService;
  bool isLoading = false;
  String? errorMessage;
  late TabController _tabController;

  String selectedEventType = 'OBJECT';
  final Map<String, dynamic> eventParams = {};
  bool _isBulkGeneration = false;
  int bulkCount = 100;
  BulkGenerationResult? lastBulkResult;

  SimulationSession? activeSimulation;
  SimulationStatus? simulationStatus;
  final Map<String, dynamic> simulationParams = {};

  TestDataStatistics? dataStatistics;
  TestEnvironment? activeEnvironment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initializeDefaults();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    testService ??= getIt<EventGenerationTestService>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Event Generation Test Tools'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: TraqIcon(AppAssets.iconSettings),
              text: 'Event Generator',
            ),
            Tab(icon: TraqIcon(AppAssets.iconArrowR), text: 'Simulation'),
            Tab(icon: TraqIcon(AppAssets.iconList), text: 'Data Management'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            Container(
              width: double.infinity,
              color: context.colors.error,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EventGeneratorTab(
                  selectedEventType: selectedEventType,
                  isBulkGeneration: _isBulkGeneration,
                  bulkCount: bulkCount,
                  isLoading: isLoading,
                  lastBulkResult: lastBulkResult,
                  onEventTypeChanged: (value) =>
                      setState(() => selectedEventType = value),
                  onBulkGenerationChanged: (value) =>
                      setState(() => _isBulkGeneration = value),
                  onBulkCountChanged: (value) => bulkCount = value,
                  onGenerate: _isBulkGeneration
                      ? generateBulkEvents
                      : generateSingleEvent,
                ),
                EventSimulationTab(
                  activeSimulation: activeSimulation,
                  simulationStatus: simulationStatus,
                  simulationParams: simulationParams,
                  isLoading: isLoading,
                  statusColor: getSimulationStatusColor(context),
                  statusText: getSimulationStatusText(),
                  onDurationChanged: (value) =>
                      simulationParams['duration'] = value,
                  onEventIntervalChanged: (value) =>
                      simulationParams['eventInterval'] = value,
                  onIncludeAnomaliesChanged: (value) => setState(
                    () => simulationParams['includeAnomalies'] = value,
                  ),
                  onAnomalyRateChanged: (value) =>
                      simulationParams['anomalyRate'] = value,
                  onStart: startSupplyChainSimulation,
                  onStop: stopSupplyChainSimulation,
                  onRefresh: pollSimulationStatus,
                  onClear: clearSimulation,
                ),
                EventDataManagementTab(
                  statistics: dataStatistics,
                  activeEnvironment: activeEnvironment,
                  isLoading: isLoading,
                  onRefresh: loadDataManagementData,
                  onCleanTestData: cleanTestData,
                  onCleanObjectEvents: cleanObjectEvents,
                  onCleanGlnData: cleanGLNTestData,
                  onCleanGtinData: cleanGTINTestData,
                  onCleanSgtinData: cleanSGTINTestData,
                  onCleanSsccTestData: cleanSSCCTestData,
                  onCleanAllSsccData: cleanAllSSCCData,
                  onCleanAggregationEvents: cleanAggregationEvents,
                  onCleanTransactionEvents: cleanTransactionEvents,
                  onCleanTransformationEvents: cleanTransformationEvents,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
