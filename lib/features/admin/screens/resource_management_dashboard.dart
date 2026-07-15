import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/data/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';

class ResourceManagementDashboard extends StatefulWidget {
  const ResourceManagementDashboard({Key? key}) : super(key: key);

  @override
  _ResourceManagementDashboardState createState() =>
      _ResourceManagementDashboardState();
}

class _ResourceManagementDashboardState
    extends State<ResourceManagementDashboard>
    with SingleTickerProviderStateMixin {
  late AdvancedPerformanceService _performanceService;
  late final TabController _tabController;
  LoadState<Map<String, dynamic>> _systemMetricsState =
      const LoadState.loading();
  LoadState<List<dynamic>> _recommendationsState = const LoadState.loading();

  /// Guards the single merged fetch (`getComprehensiveAnalysis`) so the two
  /// tabs that depend on it (System Monitor + Recommendations) share one
  /// network call instead of each tab triggering its own.
  bool _dataLoaded = false;
  bool _isLoading = false;
  Timer? _refreshTimer;
  String? _lastOptimizationResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ensureTabLoaded(_tabController.index);
      }
    });
    _initializeService();
    _ensureTabLoaded(_tabController.index);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Lazily triggers the shared merged fetch the first time a tab that
  /// needs it (System Monitor = 0, Recommendations = 2) is viewed. The
  /// Optimization tab (1) has no data dependency, so viewing it alone
  /// never triggers a network call.
  void _ensureTabLoaded(int index) {
    if (_dataLoaded) return;
    if (index == 0 || index == 2) {
      _loadAllData();
    }
  }

  void _initializeService() {
    final appConfig = getIt<AppConfig>();
    _performanceService = AdvancedPerformanceService(
      dioService: getIt<DioService>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: appConfig,
    );
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadSystemMetrics();
      }
    });
  }

  /// Reloads all resource-management data via the merged comprehensive
  /// analysis endpoint (superset of the old system-metrics +
  /// recommendations fan-out). Also used by the refresh button, which
  /// re-triggers this shared fetch and repopulates both tabs' states.
  Future<void> _loadAllData() async {
    if (mounted) {
      setState(() {
        _systemMetricsState = const LoadState.loading();
        _recommendationsState = const LoadState.loading();
      });
    }

    try {
      final result = await _performanceService.getComprehensiveAnalysis();
      if (!mounted) return;

      final systemResources =
          result['systemResources'] as Map<String, dynamic>?;
      final recommendations = result['recommendations'] as List<dynamic>?;

      setState(() {
        _systemMetricsState =
            (systemResources != null && systemResources.isNotEmpty)
            ? LoadState.success(systemResources)
            : const LoadState.empty();
        _recommendationsState =
            (recommendations != null && recommendations.isNotEmpty)
            ? LoadState.success(recommendations)
            : const LoadState.empty();
        _dataLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _systemMetricsState = LoadState.error(
            'Failed to load resource data: $e',
          );
          _recommendationsState = LoadState.error(
            'Failed to load resource data: $e',
          );
        });
      }
    }
  }

  Future<void> _loadSystemMetrics() async {
    try {
      final metrics = await _performanceService.getSystemResourceMetrics();
      if (mounted) {
        setState(() {
          _systemMetricsState = metrics.isNotEmpty
              ? LoadState.success(metrics)
              : const LoadState.empty();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _systemMetricsState = LoadState.error(
            'Failed to load system metrics: $e',
          );
        });
      }
    }
  }

  Future<void> _optimizeMemoryUsage() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      await _performanceService.optimizeMemoryUsage();

      if (mounted) {
        setState(() {
          _lastOptimizationResult = 'Memory usage optimized successfully';
        });
      }

      _showSuccessDialog('Memory optimization completed successfully');
      await _loadSystemMetrics();
    } catch (e) {
      _showErrorDialog('Failed to optimize memory usage: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _optimizeCpuUsage() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      await _performanceService.optimizeCpuUsage();

      if (mounted) {
        setState(() {
          _lastOptimizationResult = 'CPU usage optimized successfully';
        });
      }

      _showSuccessDialog('CPU optimization completed successfully');
      await _loadSystemMetrics();
    } catch (e) {
      _showErrorDialog('Failed to optimize CPU usage: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _optimizeIoPerformance() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      await _performanceService.optimizeIoPerformance();

      if (mounted) {
        setState(() {
          _lastOptimizationResult = 'I/O performance optimized successfully';
        });
      }

      _showSuccessDialog('I/O optimization completed successfully');
      await _loadSystemMetrics();
    } catch (e) {
      _showErrorDialog('Failed to optimize I/O performance: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: TraqIcon(AppAssets.iconComputer), text: 'System Monitor'),
              Tab(icon: TraqIcon(AppAssets.iconFilter), text: 'Optimization'),
              Tab(icon: TraqIcon(AppAssets.iconLightbulb), text: 'Recommendations'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveTabView(child: _buildSystemMonitorTab()),
                KeepAliveTabView(child: _buildOptimizationTab()),
                KeepAliveTabView(child: _buildRecommendationsTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMonitorTab() {
    return LoadStateView<Map<String, dynamic>>(
      state: _systemMetricsState,
      onRetry: _loadAllData,
      emptyWidget: const Center(child: Text('No system metrics available')),
      builder: (context, metrics) => _buildSystemMonitorContent(metrics),
    );
  }

  Widget _buildSystemMonitorContent(Map<String, dynamic> metrics) {
    return RefreshIndicator(
      onRefresh: _loadSystemMetrics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastOptimizationResult != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      TraqIcon(AppAssets.iconCheck, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _lastOptimizationResult!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_lastOptimizationResult != null) const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Resource Metrics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSystemMetrics(metrics),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed System Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        metrics.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetrics(Map<String, dynamic> metrics) {
    final memory = metrics['memory'] ?? {};
    final cpu = metrics['cpu'] ?? {};
    final disk = metrics['disk'] ?? {};
    final network = metrics['network'] ?? {};

    final memoryUsage = memory['usagePercentage'] ?? 0;
    final cpuUsage = (cpu['systemCpuLoad'] ?? 0) * 100;
    final diskUsage = disk['usagePercentage'] ?? 0;
    final networkLoad = network['loadPercentage'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Memory Usage',
                '${memoryUsage.toStringAsFixed(1)}%',
                NavIcons.eventSerialization,
                AdminHelperMappers.usageColor(memoryUsage.toDouble()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'CPU Usage',
                '${cpuUsage.toStringAsFixed(1)}%',
                NavIcons.performanceOptimization,
                AdminHelperMappers.usageColor(cpuUsage.toDouble()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Disk Usage',
                '${diskUsage.toStringAsFixed(1)}%',
                NavIcons.databasePartitioning,
                AdminHelperMappers.usageColor(diskUsage.toDouble()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Network Load',
                '${networkLoad.toStringAsFixed(1)}%',
                NavIcons.integrationValidation,
                AdminHelperMappers.usageColor(networkLoad.toDouble()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memory Optimization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optimize memory usage by clearing caches, running garbage collection, and adjusting heap settings.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _optimizeMemoryUsage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TraqIcon(AppAssets.iconRefresh),
                      label: Text(
                        _isLoading ? 'Optimizing...' : 'Optimize Memory',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CPU Optimization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Balance CPU utilization across cores and optimize thread allocation for better performance.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _optimizeCpuUsage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TraqIcon(AppAssets.iconClock),
                      label: Text(
                        _isLoading ? 'Optimizing...' : 'Optimize CPU',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I/O Performance Optimization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optimize disk I/O operations, buffer sizes, and file system caching for improved throughput.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _optimizeIoPerformance,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TraqIcon(AppAssets.iconList),
                      label: Text(
                        _isLoading ? 'Optimizing...' : 'Optimize I/O',
                      ),
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

  Widget _buildRecommendationsTab() {
    return LoadStateView<List<dynamic>>(
      state: _recommendationsState,
      onRetry: _loadAllData,
      emptyWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(AppAssets.iconLightbulb, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No recommendations available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'System is performing optimally',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      builder: (context, recommendations) => ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: TraqIcon(AppAssets.iconLightbulb, color: Colors.blue),
              ),
              title: Text('Recommendation #${index + 1}'),
              subtitle: Text(recommendation.toString()),
              trailing: IconButton(
                icon: TraqIcon(AppAssets.iconInfo),
                onPressed: () {
                  _showRecommendationDetails(recommendation);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRecommendationDetails(dynamic recommendation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recommendation Details'),
          content: SingleChildScrollView(
            child: Text(recommendation.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String iconAsset,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
      