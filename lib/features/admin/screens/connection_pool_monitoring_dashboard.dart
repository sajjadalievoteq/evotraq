import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/features/admin/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:http/http.dart' as http;

class ConnectionPoolMonitoringDashboard extends StatefulWidget {
  const ConnectionPoolMonitoringDashboard({Key? key}) : super(key: key);

  @override
  _ConnectionPoolMonitoringDashboardState createState() => _ConnectionPoolMonitoringDashboardState();
}

class _ConnectionPoolMonitoringDashboardState extends State<ConnectionPoolMonitoringDashboard> {
  late AdvancedPerformanceService _performanceService;
  Map<String, dynamic>? _poolStatus;
  Map<String, dynamic>? _leakDetection;
  Map<String, dynamic>? _healthCheck;
  List<dynamic>? _recommendations;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadAllData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initializeService() {
    final appConfig = getIt<AppConfig>();
    _performanceService = AdvancedPerformanceService(
      client: getIt<http.Client>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: appConfig,
    );
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadPoolStatus();
      }
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadPoolStatus(),
        _loadLeakDetection(),
        _loadHealthCheck(),
        _loadRecommendations(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load connection pool data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPoolStatus() async {
    try {
      final status = await _performanceService.getConnectionPoolStatus();
      if (mounted) {
        setState(() {
          _poolStatus = status;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load pool status: $e';
        });
      }
    }
  }

  Future<void> _loadLeakDetection() async {
    try {
      final leaks = await _performanceService.detectConnectionLeaks();
      if (mounted) {
        setState(() {
          _leakDetection = leaks;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to detect connection leaks: $e';
        });
      }
    }
  }

  Future<void> _loadHealthCheck() async {
    try {
      final health = await _performanceService.checkConnectionPoolHealth();
      if (mounted) {
        setState(() {
          _healthCheck = health;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to perform health check: $e';
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await _performanceService.getConnectionPoolRecommendations();
      if (mounted) {
        setState(() {
          _recommendations = recommendations;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load recommendations: $e';
        });
      }
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.pool), text: 'Pool Status'),
                    Tab(icon: Icon(Icons.leak_add), text: 'Leak Detection'),
                    Tab(icon: Icon(Icons.health_and_safety), text: 'Health Check'),
                    Tab(icon: Icon(Icons.lightbulb), text: 'Recommendations'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPoolStatusTab(),
                      _buildLeakDetectionTab(),
                      _buildHealthCheckTab(),
                      _buildRecommendationsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPoolStatusTab() {
    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_poolStatus == null) {
      return const Center(child: Text('No pool status data available'));
    }

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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPoolMetrics(),
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
                      _poolStatus.toString(),
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
  }

  Widget _buildPoolMetrics() {
    final activeConnections = _poolStatus?['activeConnections'] ?? 0;
    final idleConnections = _poolStatus?['idleConnections'] ?? 0;
    final totalConnections = _poolStatus?['totalConnections'] ?? 0;
    final awaitingConnections = _poolStatus?['awaitingConnections'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Active', activeConnections.toString(), Icons.play_arrow, Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard('Idle', idleConnections.toString(), Icons.pause, Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Total', totalConnections.toString(), Icons.storage, Colors.purple),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard('Awaiting', awaitingConnections.toString(), Icons.schedule, Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeakDetectionTab() {
    if (_leakDetection == null) {
      return const Center(child: Text('No leak detection data available'));
    }

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
                      _leakDetection.toString(),
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
  }

  Widget _buildHealthCheckTab() {
    if (_healthCheck == null) {
      return const Center(child: Text('No health check data available'));
    }

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
                      _healthCheck.toString(),
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
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations == null || _recommendations!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No recommendations available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _recommendations!.length,
      itemBuilder: (context, index) {
        final recommendation = _recommendations![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(Icons.lightbulb, color: Colors.orange),
            ),
            title: Text('Recommendation #${index + 1}'),
            subtitle: Text(recommendation.toString()),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
