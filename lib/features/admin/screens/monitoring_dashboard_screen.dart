import 'package:flutter/material.dart';
import 'dart:async';
import '../../../data/services/monitoring_service.dart';
import '../models/monitoring_models.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import '../../../core/network/token_manager.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_drawer.dart';
import '../widgets/performance_metrics_card.dart';
import '../widgets/storage_statistics_card.dart';
import '../widgets/integrity_statistics_card.dart';
import '../widgets/alerts_panel.dart';
import '../widgets/event_type_metrics_chart.dart';
import '../widgets/performance_chart.dart';
import '../widgets/bulk_jobs_panel.dart';
import '../widgets/storage_utilization_chart.dart';
import '../widgets/monitoring_overview_card.dart';

class MonitoringDashboardScreen extends StatefulWidget {
  const MonitoringDashboardScreen({super.key});

  @override
  State<MonitoringDashboardScreen> createState() => _MonitoringDashboardScreenState();
}

class _MonitoringDashboardScreenState extends State<MonitoringDashboardScreen>
    with TickerProviderStateMixin {
  late MonitoringService _monitoringService;
  late TabController _tabController;
  
  // Data streams
  StreamSubscription<PerformanceMetrics>? _performanceSubscription;
  StreamSubscription<StorageStatistics>? _storageSubscription;
  StreamSubscription<IntegrityStatistics>? _integritySubscription;
  StreamSubscription<List<PerformanceAlert>>? _alertsSubscription;
  
  // Current data
  PerformanceMetrics? _currentPerformance;
  StorageStatistics? _currentStorage;
  IntegrityStatistics? _currentIntegrity;
  List<PerformanceAlert> _currentAlerts = [];
  List<BulkJobStatus> _currentBulkJobs = [];
  
  // Loading states
  bool _isLoading = true;
  String? _errorMessage;
  
  // Real-time data for charts
  List<PerformanceMetrics> _performanceHistory = [];
  static const int maxHistoryLength = 50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeMonitoring();
  }

  void _initializeMonitoring() async {
    try {
      // Get TokenManager and AppConfig from provider instead of creating new instances
      final tokenManager = getIt<TokenManager>();
      final appConfig = getIt<AppConfig>();
      
      _monitoringService = MonitoringServiceProvider.getInstance(tokenManager, appConfig);
      
      // Subscribe to streams
      _performanceSubscription = _monitoringService.performanceStream.listen(
        (performance) {
          if (mounted) {
            setState(() {
              _currentPerformance = performance;
              _performanceHistory.add(performance);
              if (_performanceHistory.length > maxHistoryLength) {
                _performanceHistory.removeAt(0);
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error.toString();
              _isLoading = false;
            });
          }
        },
      );
      
      _storageSubscription = _monitoringService.storageStream.listen(
        (storage) {
          if (mounted) {
            setState(() {
              _currentStorage = storage;
            });
          }
        },
        onError: (error) {
          print('Storage stream error: $error');
        },
      );
      
      _integritySubscription = _monitoringService.integrityStream.listen(
        (integrity) {
          if (mounted) {
            setState(() {
              _currentIntegrity = integrity;
            });
          }
        },
        onError: (error) {
          print('Integrity stream error: $error');
        },
      );
      
      _alertsSubscription = _monitoringService.alertsStream.listen(
        (alerts) {
          if (mounted) {
            setState(() {
              _currentAlerts = alerts;
            });
          }
        },
        onError: (error) {
          print('Alerts stream error: $error');
        },
      );
      
      // Load initial data first
      await _loadInitialData();
      
      // Only start real-time monitoring after initial load (with 10-second interval)
      _monitoringService.startRealTimeMonitoring(interval: const Duration(seconds: 10));
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize monitoring: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load initial data
      final futures = await Future.wait([
        _monitoringService.getPerformanceMetrics(),
        _monitoringService.getStorageStatistics(),
        _monitoringService.getIntegrityStatistics(),
      ]);

      if (mounted) {
        setState(() {
          _currentPerformance = futures[0] as PerformanceMetrics;
          _currentStorage = futures[1] as StorageStatistics;
          _currentIntegrity = futures[2] as IntegrityStatistics;
          _currentAlerts = (futures[0] as PerformanceMetrics).activeAlerts;
          _performanceHistory.add(futures[0] as PerformanceMetrics);
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load initial data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _performanceSubscription?.cancel();
    _storageSubscription?.cancel();
    _integritySubscription?.cancel();
    _alertsSubscription?.cancel();
    _monitoringService.stopRealTimeMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Monitoring Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archive',
                child: Text('Archive Old Events'),
              ),
              const PopupMenuItem(
                value: 'deadlocks',
                child: Text('Resolve Deadlocks'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Monitoring Settings'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.show_chart), text: 'Performance'),
            Tab(icon: Icon(Icons.storage), text: 'Storage'),
            Tab(icon: Icon(Icons.security), text: 'Integrity'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading monitoring data...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildPerformanceTab(),
        _buildStorageTab(),
        _buildIntegrityTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // System overview card
          MonitoringOverviewCard(
            performance: _currentPerformance,
            storage: _currentStorage,
            integrity: _currentIntegrity,
            alerts: _currentAlerts,
          ),
          
          const SizedBox(height: 16),
          
          // Alerts panel
          if (_currentAlerts.isNotEmpty) ...[
            AlertsPanel(
              alerts: _currentAlerts,
              onAlertAcknowledge: _acknowledgeAlert,
            ),
            const SizedBox(height: 16),
          ],
          
          // Real-time performance chart
          if (_performanceHistory.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real-time Performance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300, // Increased height to accommodate content
                      child: PerformanceChart(
                        metrics: _performanceHistory,
                        chartType: 'response_time',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Event type breakdown
          if (_currentPerformance?.eventTypeMetrics.isNotEmpty ?? false)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Type Metrics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: EventTypeMetricsChart(
                        eventTypeMetrics: _currentPerformance!.eventTypeMetrics,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_currentPerformance != null)
            PerformanceMetricsCard(
              performance: _currentPerformance!,
              onConfigureIsolation: _configureTransactionIsolation,
              onResolveDeadlocks: _resolveDeadlocks,
            ),
          
          const SizedBox(height: 16),
          
          // Bulk jobs panel
          BulkJobsPanel(
            jobs: _currentBulkJobs,
            onJobCancel: _cancelBulkJob,
            onJobRetry: _retryBulkJob,
            onRefresh: _refreshBulkJobs,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_currentStorage != null) ...[
            StorageStatisticsCard(
              storage: _currentStorage!,
              onArchiveEvents: _archiveEvents,
              onCompressEvents: _compressEvents,
            ),
            const SizedBox(height: 16),
            StorageUtilizationChart(
              storageStats: _currentStorage!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntegrityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_currentIntegrity != null)
            IntegrityStatisticsCard(
              integrity: _currentIntegrity!,
              onVerifyIntegrity: _verifyEventIntegrity,
            ),
        ],
      ),
    );
  }

  void _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Force refresh by fetching data manually
      await Future.wait([
        _monitoringService.getPerformanceMetrics(),
        _monitoringService.getStorageStatistics(),
        _monitoringService.getIntegrityStatistics(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Refresh failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'archive':
        _showArchiveDialog();
        break;
      case 'deadlocks':
        _resolveDeadlocks();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Old Events'),
        content: const Text('Archive events older than 12 months?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _archiveEvents(DateTime.now().subtract(const Duration(days: 365)));
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    // TODO: Implement monitoring settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings dialog coming soon')),
    );
  }

  // Action handlers
  void _acknowledgeAlert(String alertId) async {
    try {
      await _monitoringService.acknowledgeAlert(alertId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert acknowledged')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to acknowledge alert: $e')),
      );
    }
  }

  void _configureTransactionIsolation(String level) async {
    try {
      await _monitoringService.configureTransactionIsolation(level);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction isolation set to $level')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to configure isolation: $e')),
      );
    }
  }

  void _resolveDeadlocks() async {
    try {
      final result = await _monitoringService.resolveDeadlocks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deadlocks resolved: ${result['resolved_count'] ?? 0}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resolve deadlocks: $e')),
      );
    }
  }

  void _archiveEvents(DateTime cutoffDate) async {
    try {
      final result = await _monitoringService.archiveEvents(cutoffDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archived ${result['archived_count'] ?? 0} events')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive events: $e')),
      );
    }
  }

  void _compressEvents(List<String> eventIds) async {
    try {
      final result = await _monitoringService.compressEvents(eventIds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compressed ${result['compressed_count'] ?? 0} events')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to compress events: $e')),
      );
    }
  }

  void _verifyEventIntegrity(String eventId) async {
    try {
      final result = await _monitoringService.verifyEventIntegrity(eventId);
      final isValid = result['integrity_valid'] ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event integrity: ${isValid ? 'VALID' : 'INVALID'}'),
          backgroundColor: isValid ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify integrity: $e')),
      );
    }
  }

  void _cancelBulkJob(String jobId) async {
    // TODO: Implement bulk job cancellation when available in monitoring service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancel bulk job feature coming soon')),
    );
  }

  void _retryBulkJob(String jobId) async {
    // TODO: Implement bulk job retry when available in monitoring service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Retry bulk job feature coming soon')),
    );
  }

  void _refreshBulkJobs() async {
    // TODO: Implement bulk jobs list refresh when available in monitoring service
    setState(() {
      _currentBulkJobs = []; // For now, keep empty list
    });
  }
}
