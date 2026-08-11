import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

import 'package:traqtrace_app/data/services/admin/event_generation_test_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_data_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_generator_tab.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_simulation_tab.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';

part 'event_generation_actions.dart';
part 'event_data_cleanup_actions.dart';
part 'event_master_data_cleanup_actions.dart';

class EventGenerationTestScreen extends StatefulWidget {
  const EventGenerationTestScreen({Key? key}) : super(key: key);

  @override
  State<EventGenerationTestScreen> createState() =>
      _EventGenerationTestScreenState();
}

class _EventGenerationTestScreenState extends State<EventGenerationTestScreen>
    with TickerProviderStateMixin {
  EventGenerationTestService? _testService;
  bool _isLoading = false;
  String? _errorMessage;
  late TabController _tabController;

  String _selectedEventType = 'OBJECT';
  final Map<String, dynamic> _eventParams = {};
  bool _isBulkGeneration = false;
  int _bulkCount = 100;
  BulkGenerationResult? _lastBulkResult;

  SimulationSession? _activeSimulation;
  SimulationStatus? _simulationStatus;
  final Map<String, dynamic> _simulationParams = {};

  TestDataStatistics? _dataStatistics;
  TestEnvironment? _activeEnvironment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDefaults();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _testService ??= getIt<EventGenerationTestService>();
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
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: context.colors.error,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EventGeneratorTab(
                  selectedEventType: _selectedEventType,
                  isBulkGeneration: _isBulkGeneration,
                  bulkCount: _bulkCount,
                  isLoading: _isLoading,
                  lastBulkResult: _lastBulkResult,
                  onEventTypeChanged: (value) =>
                      setState(() => _selectedEventType = value),
                  onBulkGenerationChanged: (value) =>
                      setState(() => _isBulkGeneration = value),
                  onBulkCountChanged: (value) => _bulkCount = value,
                  onGenerate: _isBulkGeneration
                      ? _generateBulkEvents
                      : _generateSingleEvent,
                ),
                EventSimulationTab(
                  activeSimulation: _activeSimulation,
                  simulationStatus: _simulationStatus,
                  simulationParams: _simulationParams,
                  isLoading: _isLoading,
                  statusColor: _getSimulationStatusColor(context),
                  statusText: _getSimulationStatusText(),
                  onDurationChanged: (value) =>
                      _simulationParams['duration'] = value,
                  onEventIntervalChanged: (value) =>
                      _simulationParams['eventInterval'] = value,
                  onIncludeAnomaliesChanged: (value) => setState(
                    () => _simulationParams['includeAnomalies'] = value,
                  ),
                  onAnomalyRateChanged: (value) =>
                      _simulationParams['anomalyRate'] = value,
                  onStart: _startSupplyChainSimulation,
                  onStop: _stopSupplyChainSimulation,
                  onRefresh: _pollSimulationStatus,
                  onClear: _clearSimulation,
                ),
                EventDataManagementTab(
                  statistics: _dataStatistics,
                  activeEnvironment: _activeEnvironment,
                  isLoading: _isLoading,
                  onRefresh: _loadDataManagementData,
                  onCleanTestData: _cleanTestData,
                  onCleanObjectEvents: _cleanObjectEvents,
                  onCleanGlnData: _cleanGLNTestData,
                  onCleanGtinData: _cleanGTINTestData,
                  onCleanSgtinData: _cleanSGTINTestData,
                  onCleanSsccTestData: _cleanSSCCTestData,
                  onCleanAllSsccData: _cleanAllSSCCData,
                  onCleanAggregationEvents: _cleanAggregationEvents,
                  onCleanTransactionEvents: _cleanTransactionEvents,
                  onCleanTransformationEvents: _cleanTransformationEvents,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
