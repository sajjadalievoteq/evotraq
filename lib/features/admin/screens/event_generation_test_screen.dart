import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

import '../../../data/services/event_generation_test_service.dart';

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

  // Event generation state
  String _selectedEventType = 'OBJECT';
  final Map<String, dynamic> _eventParams = {};
  bool _isBulkGeneration = false;
  int _bulkCount = 100;
  BulkGenerationResult? _lastBulkResult;

  // Simulation state
  SimulationSession? _activeSimulation;
  SimulationStatus? _simulationStatus;
  final Map<String, dynamic> _simulationParams = {};

  // Data management state
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
    _testService ??= EventGenerationTestService(
      appConfig: getIt<AppConfig>(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeDefaults() {
    // Event generation defaults
    _eventParams['businessStep'] = 'urn:epcglobal:cbv:bizstep:commissioning';
    _eventParams['disposition'] = 'urn:epcglobal:cbv:disp:active';
    _eventParams['readPoint'] = 'urn:epc:id:sgln:0614141.00001.0';
    _eventParams['bizLocation'] = 'urn:epc:id:sgln:0614141.00001.0';

    // Simulation defaults
    _simulationParams['duration'] = 300; // 5 minutes
    _simulationParams['eventInterval'] = 1000; // 1 second
    _simulationParams['includeAnomalies'] = false;
    _simulationParams['anomalyRate'] = 0.05; // 5%
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully generated event: ${result['eventId']}'),
          backgroundColor: AppTheme.successColor,
        ),
      );

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully generated ${result.generatedCount} events',
          ),
          backgroundColor: AppTheme.successColor,
        ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Supply chain simulation started: ${session.sessionId}',
          ),
          backgroundColor: AppTheme.successColor,
        ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Simulation stopped. Generated ${result.totalEvents} events',
          ),
          backgroundColor: AppTheme.successColor,
        ),
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
      // Silently handle polling errors
    }
  }

  Color _getSimulationStatusColor() {
    if (_simulationStatus == null) return AppTheme.primaryColor;

    switch (_simulationStatus!.status) {
      case 'RUNNING':
        return AppTheme.successColor;
      case 'COMPLETED':
        return Colors.blue;
      case 'ERROR':
        return AppTheme.errorColor;
      case 'STOPPED':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
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

  Future<void> _cleanTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cleanup'),
        content: const Text('This will delete all test data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanTestData({});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned ${result.deletedEvents} events, '
            '${result.deletedGLNs} GLNs, ${result.deletedGTINs} GTINs',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanTransformationEvents() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transformation Events Cleanup'),
        content: const Text(
          'This will delete all transformation event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanTransformationEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned ${result['deletedTransformationEvents']} transformation events',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to clean transformation events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanTransactionEvents() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transaction Events Cleanup'),
        content: const Text(
          'This will delete all transaction event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanTransactionEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned ${result['deletedTransactionEvents']} transaction events',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean transaction events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanAggregationEvents() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Aggregation Events Cleanup'),
        content: const Text(
          'This will delete all aggregation event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanAggregationEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned ${result['deletedAggregationEvents']} aggregation events',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean aggregation events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanObjectEvents() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Object Events Cleanup'),
        content: const Text(
          'This will delete all object event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanObjectEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned ${result['deletedObjectEvents']} object events',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean object events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanGLNTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm GLN Test Data Cleanup'),
        content: const Text(
          'This will delete all GLNs where location name starts with "Test Location". Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanGLNTestData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned ${result['deletedGLNs']} test GLNs'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean GLN test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanGTINTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm GTIN Test Data Cleanup'),
        content: const Text(
          'This will delete all GTINs where product name starts with "Test Product". Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanGTINTestData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned ${result['deletedGTINs']} test GTINs'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean GTIN test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanSGTINTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SGTIN Test Data Cleanup'),
        content: const Text(
          'This will delete all SGTINs where batch lot number starts with "TEST-BATCH-". Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanSGTINTestData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned ${result['deletedSGTINs']} test SGTINs'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean SGTIN test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanSSCCTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SSCC Test Data Cleanup'),
        content: const Text(
          'This will delete all SSCCs where GS1 company prefix matches test pharmaceutical companies. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanSSCCTestData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned ${result['deletedSSCCs']} test SSCCs'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean SSCC test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanAllSSCCData() async {
    if (_testService == null) return;

    // First confirmation dialog with strong warning
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DANGER - Delete ALL SSCCs'),
        content: const Text(
          'WARNING: This will delete ALL SSCCs from the system, not just test data!\n\n'
          'This is intended for debugging only when test SSCCs lack proper company prefix data.\n\n'
          'Are you absolutely sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I Understand - Continue'),
          ),
        ],
      ),
    );

    if (firstConfirmed != true) return;

    // Second confirmation dialog for extra safety
    final secondConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FINAL CONFIRMATION'),
        content: const Text(
          'This action CANNOT be undone!\n\n'
          'You are about to delete ALL SSCCs from the entire system.\n\n'
          'Type "DELETE ALL" to confirm:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Show text input dialog
              final textController = TextEditingController();
              final textConfirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Type Confirmation'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Type "DELETE ALL" exactly:'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'DELETE ALL',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          textController.text == 'DELETE ALL',
                        );
                      },
                      child: const Text('DELETE ALL SSCCs'),
                    ),
                  ],
                ),
              );
              textController.dispose();
              Navigator.pop(context, textConfirmed == true);
            },
            child: const Text('FINAL CONFIRM'),
          ),
        ],
      ),
    );

    if (secondConfirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanAllSSCCData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'DANGER: Deleted ${result['deletedSSCCs']} SSCCs from system (ALL SSCCs!)',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete all SSCC data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Event Generation Test Tools'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.build), text: 'Event Generator'),
            Tab(icon: Icon(Icons.play_circle_filled), text: 'Simulation'),
            Tab(icon: Icon(Icons.storage), text: 'Data Management'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: AppTheme.errorColor,
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
                _buildEventGeneratorTab(),
                _buildSimulationTab(),
                _buildDataManagementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Event Generator',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Event type selection
                  DropdownButtonFormField<String>(
                    value: _selectedEventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'OBJECT',
                        child: Text('Object Event'),
                      ),
                      DropdownMenuItem(
                        value: 'AGGREGATION',
                        child: Text('Aggregation Event'),
                      ),
                      DropdownMenuItem(
                        value: 'TRANSACTION',
                        child: Text('Transaction Event'),
                      ),
                      DropdownMenuItem(
                        value: 'TRANSFORMATION',
                        child: Text('Transformation Event'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedEventType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Generation type toggle
                  SwitchListTile(
                    title: const Text('Bulk Generation'),
                    subtitle: const Text('Generate multiple events at once'),
                    value: _isBulkGeneration,
                    onChanged: (value) {
                      setState(() {
                        _isBulkGeneration = value;
                      });
                    },
                  ),

                  if (_isBulkGeneration) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Event Count',
                        border: OutlineInputBorder(),
                        helperText: 'Number of events to generate',
                      ),
                      initialValue: _bulkCount.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _bulkCount = int.tryParse(value) ?? 100;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : (_isBulkGeneration
                                  ? _generateBulkEvents
                                  : _generateSingleEvent),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          _isBulkGeneration
                              ? 'Generate Bulk'
                              : 'Generate Single',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Results cards
          if (_lastBulkResult != null) ...[
            const SizedBox(height: 16),
            _buildBulkResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildBulkResultCard() {
    if (_lastBulkResult == null) return const SizedBox();

    final result = _lastBulkResult!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulk Generation Result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Generated Count',
                    result.generatedCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Status', result.status)),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Start Time',
                    result.startTime.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'End Time',
                    result.endTime?.toString() ?? 'N/A',
                  ),
                ),
              ],
            ),

            if (result.eventIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Sample Event IDs:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...result.eventIds
                  .take(5)
                  .map(
                    (id) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        id,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supply Chain Simulation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  if (_activeSimulation != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getSimulationStatusColor().withOpacity(0.1),
                        border: Border.all(color: _getSimulationStatusColor()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSimulationStatusText(),
                            style: TextStyle(
                              color: _getSimulationStatusColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Session ID: ${_activeSimulation!.sessionId}'),
                          Text('Status: ${_activeSimulation!.status}'),

                          if (_simulationStatus != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Current Events: ${_simulationStatus!.currentEvents}',
                            ),
                            Text(
                              'Progress: ${_simulationStatus!.progressPercentage.toStringAsFixed(1)}%',
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value:
                                  _simulationStatus!.progressPercentage / 100,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : (_simulationStatus?.status == 'RUNNING'
                                    ? _stopSupplyChainSimulation
                                    : null),
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Simulation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pollSimulationStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Status'),
                        ),
                        if (_simulationStatus?.status == 'COMPLETED' ||
                            _simulationStatus?.status == 'ERROR' ||
                            _simulationStatus?.status == 'STOPPED') ...[
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _clearSimulation,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    // Simulation parameters
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Duration (seconds)',
                        border: OutlineInputBorder(),
                        helperText: 'How long to run the simulation',
                      ),
                      initialValue: _simulationParams['duration'].toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _simulationParams['duration'] =
                            int.tryParse(value) ?? 300;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Event Interval (ms)',
                        border: OutlineInputBorder(),
                        helperText: 'Time between events',
                      ),
                      initialValue: _simulationParams['eventInterval']
                          .toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _simulationParams['eventInterval'] =
                            int.tryParse(value) ?? 1000;
                      },
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Include Anomalies'),
                      subtitle: const Text('Inject anomalies into simulation'),
                      value: _simulationParams['includeAnomalies'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _simulationParams['includeAnomalies'] = value;
                        });
                      },
                    ),

                    if (_simulationParams['includeAnomalies'] == true) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Anomaly Rate (0.0 - 1.0)',
                          border: OutlineInputBorder(),
                          helperText:
                              'Percentage of events that will be anomalies',
                        ),
                        initialValue: _simulationParams['anomalyRate']
                            .toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          _simulationParams['anomalyRate'] =
                              double.tryParse(value) ?? 0.05;
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : _startSupplyChainSimulation,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Simulation'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Test Data Statistics',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _loadDataManagementData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_dataStatistics != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Events',
                            _dataStatistics!.totalEvents.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Total Master Data',
                            (_dataStatistics!.totalGLNs +
                                    _dataStatistics!.totalGTINs +
                                    _dataStatistics!.totalSGTINs +
                                    _dataStatistics!.totalSSCCs)
                                .toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Data Size',
                            '${(_dataStatistics!.dataSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Event Type Distribution:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    ..._dataStatistics!.eventTypeCounts.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(entry.value.toString()),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Master Data Distribution:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    ..._dataStatistics!.masterDataDistribution.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(entry.value.toString()),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'No statistics available. Click Refresh to load.',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanTestData,
                        icon: const Icon(Icons.cleaning_services),
                        label: const Text('Clean Test Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanObjectEvents,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Clean Object Events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanGLNTestData,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Clean GLN Test Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanGTINTestData,
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Clean GTIN Test Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanSGTINTestData,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Clean SGTIN Test Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanSSCCTestData,
                        icon: const Icon(Icons.inventory),
                        label: const Text('Clean SSCC Test Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanAllSSCCData,
                        icon: const Icon(Icons.dangerous),
                        label: const Text('DANGER - Delete ALL SSCCs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanAggregationEvents,
                        icon: const Icon(Icons.group_work_outlined),
                        label: const Text('Clean Aggregation Events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cleanTransactionEvents,
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Clean Transaction Events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : _cleanTransformationEvents,
                        icon: const Icon(Icons.transform_outlined),
                        label: const Text('Clean Transformation Events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Active environment card
          if (_activeEnvironment != null) ...[
            const SizedBox(height: 16),
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Environment',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${_activeEnvironment!.name}'),
                    Text('Description: ${_activeEnvironment!.description}'),
                    Text('Created: ${_activeEnvironment!.createdAt}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
