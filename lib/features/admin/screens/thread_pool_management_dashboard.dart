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
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';

class ThreadPoolManagementDashboard extends StatefulWidget {
  const ThreadPoolManagementDashboard({Key? key}) : super(key: key);

  @override
  _ThreadPoolManagementDashboardState createState() =>
      _ThreadPoolManagementDashboardState();
}

class _ThreadPoolManagementDashboardState
    extends State<ThreadPoolManagementDashboard>
    with SingleTickerProviderStateMixin {
  late AdvancedPerformanceService _performanceService;
  late final TabController _tabController;

  
  
  bool _dashboardLoaded = false;
  LoadState<Map<String, dynamic>> _metricsState = const LoadState.loading();
  LoadState<Map<String, dynamic>> _contentionState =
      const LoadState.loading();

  String _selectedBackpressureStrategy = 'CALLER_RUNS';
  bool _isLoading = false;
  Timer? _refreshTimer;

  final List<String> _backpressureStrategies = [
    'CALLER_RUNS',
    'ABORT',
    'DISCARD',
    'DISCARD_OLDEST',
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ensureTabLoaded(_tabController.index);
      }
    });
    _ensureTabLoaded(_tabController.index);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
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
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadThreadPoolDashboard();
      }
    });
  }

  
  
  
  void _ensureTabLoaded(int index) {
    if (_dashboardLoaded) return;
    _dashboardLoaded = true;
    _loadThreadPoolDashboard();
  }

  Future<void> _loadThreadPoolDashboard() async {
    if (mounted) {
      setState(() {
        _metricsState = const LoadState.loading();
        _contentionState = const LoadState.loading();
      });
    }

    try {
      final result = await _performanceService.getThreadPoolDashboard();
      final metrics = result['metrics'] as Map<String, dynamic>?;
      final contention = result['contention'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _metricsState = (metrics == null || metrics.isEmpty)
            ? const LoadState.empty()
            : LoadState.success(metrics);
        _contentionState = (contention == null || contention.isEmpty)
            ? const LoadState.empty()
            : LoadState.success(contention);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metricsState = LoadState.error('Failed to load thread pool metrics: $e');
        _contentionState = LoadState.error('Failed to analyze contention: $e');
      });
    }
  }

  
  
  void _refreshDashboardData() {
    _dashboardLoaded = true;
    _loadThreadPoolDashboard();
  }

  Future<void> _configureBackpressure() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final config = {
        'rejectedExecutionHandler': _selectedBackpressureStrategy,
      };
      await _performanceService.configureBackpressure(
        _selectedBackpressureStrategy,
        config,
      );

      _showSuccessDialog('Backpressure strategy configured successfully');
      await _loadThreadPoolDashboard();
    } catch (e) {
      _showErrorDialog('Failed to configure backpressure: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _optimizeThreadPool() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final settings = {'enableOptimization': true, 'strategy': 'AUTO'};

      await _performanceService.optimizeThreadPools(settings);

      _showSuccessDialog('Thread pools optimized successfully');
      await _loadThreadPoolDashboard();
    } catch (e) {
      _showErrorDialog('Failed to optimize thread pools: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text('Thread Pool Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _refreshDashboardData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: TraqIcon(NavIcons.dashboard), text: 'Metrics'),
            Tab(icon: TraqIcon(AppAssets.iconAlert), text: 'Contention'),
            Tab(icon: TraqIcon(AppAssets.iconSettings), text: 'Backpressure'),
            Tab(icon: TraqIcon(AppAssets.iconFilter), text: 'Optimization'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(child: _buildMetricsTab()),
          KeepAliveTabView(child: _buildContentionTab()),
          KeepAliveTabView(child: _buildBackpressureTab()),
          KeepAliveTabView(child: _buildOptimizationTab()),
        ],
      ),
    );
  }

  Widget _buildMetricsTab() {
    return LoadStateView<Map<String, dynamic>>(
      state: _metricsState,
      onRetry: _loadThreadPoolDashboard,
      emptyWidget: const Center(
        child: Text('No thread pool metrics available'),
      ),
      builder: (context, metrics) {
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
                        'Thread Pool Metrics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildThreadPoolMetrics(metrics),
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
                        'Detailed Metrics',
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
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThreadPoolMetrics(Map<String, dynamic> metrics) {
    final activeThreads = metrics['activeThreads'] ?? 0;
    final corePoolSize = metrics['corePoolSize'] ?? 0;
    final maximumPoolSize = metrics['maximumPoolSize'] ?? 0;
    final queueSize = metrics['queueSize'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Active Threads',
                activeThreads.toString(),
                AppAssets.iconPlay,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Core Pool Size',
                corePoolSize.toString(),
                AppAssets.iconSettings,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Max Pool Size',
                maximumPoolSize.toString(),
                NavIcons.databasePartitioning,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Queue Size',
                queueSize.toString(),
                NavIcons.jobQueueManagement,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentionTab() {
    return LoadStateView<Map<String, dynamic>>(
      state: _contentionState,
      onRetry: _loadThreadPoolDashboard,
      emptyWidget: const Center(
        child: Text('No contention analysis data available'),
      ),
      builder: (context, contentionAnalysis) {
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
                        'Thread Contention Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          contentionAnalysis.toString(),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackpressureTab() {
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
                    'Backpressure Strategy Configuration',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBackpressureStrategy,
                    decoration: const InputDecoration(
                      labelText: 'Backpressure Strategy',
                      border: OutlineInputBorder(),
                      helperText: 'Select how to handle rejected tasks',
                    ),
                    items: _backpressureStrategies.map((strategy) {
                      return DropdownMenuItem<String>(
                        value: strategy,
                        child: Text(strategy),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedBackpressureStrategy = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _configureBackpressure,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TraqIcon(AppAssets.iconSettings),
                      label: Text(
                        _isLoading
                            ? 'Configuring...'
                            : 'Configure Backpressure',
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
                    'Backpressure Strategy Descriptions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStrategyDescription(
                    'CALLER_RUNS',
                    'Executes the task in the caller thread',
                    Colors.green,
                  ),
                  _buildStrategyDescription(
                    'ABORT',
                    'Throws RejectedExecutionException',
                    Colors.red,
                  ),
                  _buildStrategyDescription(
                    'DISCARD',
                    'Silently discards the task',
                    Colors.orange,
                  ),
                  _buildStrategyDescription(
                    'DISCARD_OLDEST',
                    'Discards the oldest unhandled task',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyDescription(
    String strategy,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    'Thread Pool Optimization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Automatically optimize thread pool configurations based on current workload and performance metrics.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _optimizeThreadPool,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TraqIcon(AppAssets.iconFilter),
                      label: Text(
                        _isLoading ? 'Optimizing...' : 'Optimize Thread Pools',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
