import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/data/services/admin/monitoring_service.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard/widgets/monitoring_integrity_tab.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard/widgets/monitoring_overview_tab.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard/widgets/monitoring_performance_tab.dart';
import 'package:traqtrace_app/features/admin/screens/monitoring_dashboard/widgets/monitoring_storage_tab.dart';

class MonitoringDashboardScreen extends StatefulWidget {
  const MonitoringDashboardScreen({super.key});

  @override
  State<MonitoringDashboardScreen> createState() => _MonitoringDashboardScreenState();
}

class _MonitoringDashboardScreenState extends State<MonitoringDashboardScreen>
    with TickerProviderStateMixin {
  late MonitoringService _monitoringService;
  late TabController _tabController;
  
  StreamSubscription<PerformanceMetrics>? _performanceSubscription;
  StreamSubscription<StorageStatistics>? _storageSubscription;
  StreamSubscription<IntegrityStatistics>? _integritySubscription;
  StreamSubscription<List<PerformanceAlert>>? _alertsSubscription;

  
  
  
  LoadState<PerformanceMetrics> _performanceState = const LoadState.loading();
  LoadState<StorageStatistics> _storageState = const LoadState.loading();
  LoadState<IntegrityStatistics> _integrityState = const LoadState.loading();
  LoadState<List<PerformanceAlert>> _alertsState = const LoadState.loading();

  List<BulkJobStatus> _currentBulkJobs = [];

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
      _monitoringService = getIt<MonitoringService>();
      
      _performanceSubscription = _monitoringService.performanceStream.listen(
        (performance) {
          if (mounted) {
            setState(() {
              _performanceState = LoadState.success(performance);
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
              _performanceState = LoadState.error(error.toString());
            });
          }
        },
      );

      _storageSubscription = _monitoringService.storageStream.listen(
        (storage) {
          if (mounted) {
            setState(() {
              _storageState = LoadState.success(storage);
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _storageState = LoadState.error(error.toString());
            });
          }
        },
      );

      _integritySubscription = _monitoringService.integrityStream.listen(
        (integrity) {
          if (mounted) {
            setState(() {
              _integrityState = LoadState.success(integrity);
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _integrityState = LoadState.error(error.toString());
            });
          }
        },
      );

      _alertsSubscription = _monitoringService.alertsStream.listen(
        (alerts) {
          if (mounted) {
            setState(() {
              _alertsState = LoadState.success(alerts);
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _alertsState = LoadState.error(error.toString());
            });
          }
        },
      );

      await _loadInitialData();

      _monitoringService.startRealTimeMonitoring(interval: const Duration(seconds: 10));

    } catch (e) {
      
      
      
      
      if (mounted) {
        setState(() {
          final message = 'Failed to initialize monitoring: $e';
          _performanceState = LoadState.error(message);
          _storageState = LoadState.error(message);
          _integrityState = LoadState.error(message);
          _alertsState = LoadState.error(message);
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadPerformanceMetrics(),
      _loadStorageStatistics(),
      _loadIntegrityStatistics(),
    ]);
  }

  Future<void> _loadPerformanceMetrics() async {
    try {
      final performance = await _monitoringService.getPerformanceMetrics();
      if (mounted) {
        setState(() {
          _performanceState = LoadState.success(performance);
          _alertsState = LoadState.success(performance.activeAlerts);
          _performanceHistory.add(performance);
          if (_performanceHistory.length > maxHistoryLength) {
            _performanceHistory.removeAt(0);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _performanceState = LoadState.error('Failed to load performance metrics: $e');
        });
      }
    }
  }

  Future<void> _loadStorageStatistics() async {
    try {
      final storage = await _monitoringService.getStorageStatistics();
      if (mounted) {
        setState(() {
          _storageState = LoadState.success(storage);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _storageState = LoadState.error('Failed to load storage statistics: $e');
        });
      }
    }
  }

  Future<void> _loadIntegrityStatistics() async {
    try {
      final integrity = await _monitoringService.getIntegrityStatistics();
      if (mounted) {
        setState(() {
          _integrityState = LoadState.success(integrity);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _integrityState = LoadState.error('Failed to load integrity statistics: $e');
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
            icon: TraqIcon(AppAssets.iconRefresh),
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
            Tab(icon: TraqIcon(NavIcons.dashboard), text: 'Overview'),
            Tab(icon: TraqIcon(AppAssets.iconEye), text: 'Performance'),
            Tab(icon: TraqIcon(AppAssets.iconList), text: 'Storage'),
            Tab(icon: TraqIcon(AppAssets.iconLock), text: 'Integrity'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          MonitoringOverviewTab(
            performanceState: _performanceState,
            storageState: _storageState,
            integrityState: _integrityState,
            alertsState: _alertsState,
            performanceHistory: _performanceHistory,
            onRetry: _refreshData,
            onAlertAcknowledge: _acknowledgeAlert,
          ),
          MonitoringPerformanceTab(
            performanceState: _performanceState,
            currentBulkJobs: _currentBulkJobs,
            onRetry: _refreshData,
            onConfigureIsolation: _configureTransactionIsolation,
            onResolveDeadlocks: _resolveDeadlocks,
            onJobCancel: _cancelBulkJob,
            onJobRetry: _retryBulkJob,
            onRefreshJobs: _refreshBulkJobs,
          ),
          MonitoringStorageTab(
            storageState: _storageState,
            onRetry: _refreshData,
            onArchiveEvents: _archiveEvents,
            onCompressEvents: _compressEvents,
          ),
          MonitoringIntegrityTab(
            integrityState: _integrityState,
            onRetry: _refreshData,
            onVerifyIntegrity: _verifyEventIntegrity,
          ),
        ],
      ),
    );
  }

  void _refreshData() async {
    setState(() {
      _performanceState = const LoadState.loading();
      _storageState = const LoadState.loading();
      _integrityState = const LoadState.loading();
      _alertsState = const LoadState.loading();
    });

    await _loadInitialData();
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
    context.showInfo('Settings dialog coming soon');
  }

  void _acknowledgeAlert(String alertId) async {
    try {
      await _monitoringService.acknowledgeAlert(alertId);
      context.showSuccess('Alert acknowledged');
    } catch (e) {
      context.showError('Failed to acknowledge alert: $e');
    }
  }

  void _configureTransactionIsolation(String level) async {
    try {
      await _monitoringService.configureTransactionIsolation(level);
      context.showSuccess('Transaction isolation set to $level');
    } catch (e) {
      context.showError('Failed to configure isolation: $e');
    }
  }

  void _resolveDeadlocks() async {
    try {
      final result = await _monitoringService.resolveDeadlocks();
      context.showSuccess('Deadlocks resolved: ${result['resolved_count'] ?? 0}');
    } catch (e) {
      context.showError('Failed to resolve deadlocks: $e');
    }
  }

  void _archiveEvents(DateTime cutoffDate) async {
    try {
      final result = await _monitoringService.archiveEvents(cutoffDate);
      context.showSuccess('Archived ${result['archived_count'] ?? 0} events');
    } catch (e) {
      context.showError('Failed to archive events: $e');
    }
  }

  void _compressEvents(List<String> eventIds) async {
    try {
      final result = await _monitoringService.compressEvents(eventIds);
      context.showSuccess('Compressed ${result['compressed_count'] ?? 0} events');
    } catch (e) {
      context.showError('Failed to compress events: $e');
    }
  }

  void _verifyEventIntegrity(String eventId) async {
    try {
      final result = await _monitoringService.verifyEventIntegrity(eventId);
      final isValid = result['integrity_valid'] ?? false;
      if (isValid) {
        context.showSuccess('Event integrity: VALID');
      } else {
        context.showError('Event integrity: INVALID');
      }
    } catch (e) {
      context.showError('Failed to verify integrity: $e');
    }
  }

  void _cancelBulkJob(String jobId) async {
    context.showInfo('Cancel bulk job feature coming soon');
  }

  void _retryBulkJob(String jobId) async {
    context.showInfo('Retry bulk job feature coming soon');
  }

  void _refreshBulkJobs() async {
    setState(() {
      _currentBulkJobs = [];
    });
  }
}
