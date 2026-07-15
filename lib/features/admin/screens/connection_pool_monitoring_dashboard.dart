import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

import '../../../data/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';

class ConnectionPoolMonitoringDashboard extends StatefulWidget {
  const ConnectionPoolMonitoringDashboard({Key? key}) : super(key: key);

  @override
  _ConnectionPoolMonitoringDashboardState createState() =>
      _ConnectionPoolMonitoringDashboardState();
}

class _ConnectionPoolMonitoringDashboardState
    extends State<ConnectionPoolMonitoringDashboard>
    with SingleTickerProviderStateMixin {
  late AdvancedPerformanceService _performanceService;
  late final TabController _tabController;

  LoadState<Map<String, dynamic>> _poolStatusState = const LoadState.loading();
  LoadState<Map<String, dynamic>> _leakDetectionState =
      const LoadState.loading();
  LoadState<Map<String, dynamic>> _healthCheckState =
      const LoadState.loading();
  LoadState<String> _recommendationsState = const LoadState.loading();

  /// All four tabs render fields derived from the single merged
  /// `getConnectionPoolDashboard()` response, so one fetch satisfies every
  /// tab. Guards against re-fetching every time the user switches tabs.
  bool _dataLoaded = false;

  Timer? _refreshTimer;

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _dataLoaded) {
        _loadAllData();
      }
    });
  }

  void _ensureTabLoaded(int index) {
    if (_dataLoaded) return;
    _dataLoaded = true;
    _loadAllData();
  }

  /// Reloads all previously-loaded data by re-triggering the one merged
  /// fetch. Used by both the refresh button and per-tab retry actions.
  void _refreshData() {
    _dataLoaded = true;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (mounted) {
      setState(() {
        _poolStatusState = const LoadState.loading();
        _leakDetectionState = const LoadState.loading();
        _healthCheckState = const LoadState.loading();
        _recommendationsState = const LoadState.loading();
      });
    }

    try {
      final result = await _performanceService.getConnectionPoolDashboard();

      if (!mounted) return;

      final status = result['status'] as Map<String, dynamic>?;
      final leaks = result['leaks'] as Map<String, dynamic>?;
      final health = result['health'] as Map<String, dynamic>?;
      final recommendations = result['recommendations'];
      final recommendationsText = recommendations?.toString();

      setState(() {
        _poolStatusState = (status == null || status.isEmpty)
            ? const LoadState.empty()
            : LoadState.success(status);
        _leakDetectionState = (leaks == null || leaks.isEmpty)
            ? const LoadState.empty()
            : LoadState.success(leaks);
        _healthCheckState = (health == null || health.isEmpty)
            ? const LoadState.empty()
            : LoadState.success(health);
        _recommendationsState =
            (recommendationsText == null || recommendationsText.isEmpty)
            ? const LoadState.empty()
            : LoadState.success(recommendationsText);
      });
    } catch (e) {
      if (!mounted) return;
      final message = 'Failed to load connection pool data: $e';
      setState(() {
        _poolStatusState = LoadState.error(message);
        _leakDetectionState = LoadState.error(message);
        _healthCheckState = LoadState.error(message);
        _recommendationsState = LoadState.error(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Pool Monitoring'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: TraqIcon(AppAssets.iconHub), text: 'Pool Status'),
              Tab(
                icon: TraqIcon(AppAssets.iconSignal),
                text: 'Leak Detection',
              ),
              Tab(
                icon: TraqIcon(AppAssets.iconSecurity),
                text: 'Health Check',
              ),
              Tab(
                icon: TraqIcon(AppAssets.iconLightbulb),
                text: 'Recommendations',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveTabView(child: _buildPoolStatusTab()),
                KeepAliveTabView(child: _buildLeakDetectionTab()),
                KeepAliveTabView(child: _buildHealthCheckTab()),
                KeepAliveTabView(child: _buildRecommendationsTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolStatusTab() {
    return LoadStateView<Map<String, dynamic>>(
      state: _poolStatusState,
      onRetry: _refreshData,
      emptyWidget: const Center(child: Text('No pool status data available')),
      builder: (context, poolStatus) {
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
                        'HikariCP Connection Pool Status',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildPoolMetrics(poolStatus),
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
                        'Detailed Status',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                          poolStatus.toString(),
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

  Widget _buildPoolMetrics(Map<String, dynamic> poolStatus) {
    final activeConnections = poolStatus['activeConnections'] ?? 0;
    final idleConnections = poolStatus['idleConnections'] ?? 0;
    final totalConnections = poolStatus['totalConnections'] ?? 0;
    final awaitingConnections = poolStatus['awaitingConnections'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Active',
                activeConnections.toString(),
                AppAssets.iconPlay,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Idle',
                idleConnections.toString(),
                AppAssets.iconPause,
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
                'Total',
                totalConnections.toString(),
                NavIcons.databasePartitioning,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Awaiting',
                awaitingConnections.toString(),
                AppAssets.iconClock,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeakDetectionTab() {
    return LoadStateView<Map<String, dynamic>>(
      state: _leakDetectionState,
      onRetry: _refreshData,
      emptyWidget: const Center(
        child: Text('No leak detection data available'),
      ),
      builder: (context, leakDetection) {
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
                        'Connection Leak Detection Results',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                          leakDetection.toString(),
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

  Widget _buildHealthCheckTab() {
    return LoadStateView<Map<String, dynamic>>(
      state: _healthCheckState,
      onRetry: _refreshData,
      emptyWidget: const Center(child: Text('No health check data available')),
      builder: (context, healthCheck) {
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
                        'Connection Pool Health Check',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                          healthCheck.toString(),
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

  Widget _buildRecommendationsTab() {
    return LoadStateView<String>(
      state: _recommendationsState,
      onRetry: _refreshData,
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
          ],
        ),
      ),
      builder: (context, recommendations) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: TraqIcon(
                      AppAssets.iconLightbulb,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendations,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
