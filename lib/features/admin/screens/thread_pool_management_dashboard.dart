import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/data/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:http/http.dart' as http;

class ThreadPoolManagementDashboard extends StatefulWidget {
  const ThreadPoolManagementDashboard({Key? key}) : super(key: key);

  @override
  _ThreadPoolManagementDashboardState createState() => _ThreadPoolManagementDashboardState();
}

class _ThreadPoolManagementDashboardState extends State<ThreadPoolManagementDashboard> {
  late AdvancedPerformanceService _performanceService;
  Map<String, dynamic>? _threadPoolMetrics;
  Map<String, dynamic>? _contentionAnalysis;
  String _selectedBackpressureStrategy = 'CALLER_RUNS';
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  final List<String> _backpressureStrategies = [
    'CALLER_RUNS',
    'ABORT',
    'DISCARD',
    'DISCARD_OLDEST'
  ];

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadMetrics();
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
        _loadMetrics(),
        _loadContentionAnalysis(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load thread pool data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMetrics() async {
    try {
      final metrics = await _performanceService.getThreadPoolMetrics();
      if (mounted) {
        setState(() {
          _threadPoolMetrics = metrics;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load thread pool metrics: $e';
        });
      }
    }
  }

  Future<void> _loadContentionAnalysis() async {
    try {
      final contention = await _performanceService.analyzeContention();
      if (mounted) {
        setState(() {
          _contentionAnalysis = contention;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to analyze contention: $e';
        });
      }
    }
  }

  Future<void> _configureBackpressure() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final config = {'rejectedExecutionHandler': _selectedBackpressureStrategy};
      await _performanceService.configureBackpressure(_selectedBackpressureStrategy, config);
      
      _showSuccessDialog('Backpressure strategy configured successfully');
      await _loadMetrics();
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

      final settings = {
        'enableOptimization': true,
        'strategy': 'AUTO'
      };
      
      await _performanceService.optimizeThreadPools(settings);
      
      _showSuccessDialog('Thread pools optimized successfully');
      await _loadAllData();
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
                    Tab(icon: Icon(Icons.dashboard), text: 'Metrics'),
                    Tab(icon: Icon(Icons.warning), text: 'Contention'),
                    Tab(icon: Icon(Icons.settings), text: 'Backpressure'),
                    Tab(icon: Icon(Icons.tune), text: 'Optimization'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildMetricsTab(),
                      _buildContentionTab(),
                      _buildBackpressureTab(),
                      _buildOptimizationTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMetricsTab() {
    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_threadPoolMetrics == null) {
      return const Center(child: Text('No thread pool metrics available'));
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
                    'Thread Pool Metrics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThreadPoolMetrics(),
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
                      _threadPoolMetrics.toString(),
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

  Widget _buildThreadPoolMetrics() {
    final activeThreads = _threadPoolMetrics?['activeThreads'] ?? 0;
    final corePoolSize = _threadPoolMetrics?['corePoolSize'] ?? 0;
    final maximumPoolSize = _threadPoolMetrics?['maximumPoolSize'] ?? 0;
    final queueSize = _threadPoolMetrics?['queueSize'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Active Threads', activeThreads.toString(), Icons.play_arrow, Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard('Core Pool Size', corePoolSize.toString(), Icons.settings, Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Max Pool Size', maximumPoolSize.toString(), Icons.storage, Colors.purple),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard('Queue Size', queueSize.toString(), Icons.queue, Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentionTab() {
    if (_contentionAnalysis == null) {
      return const Center(child: Text('No contention analysis data available'));
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
                      _contentionAnalysis.toString(),
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
                        : const Icon(Icons.settings),
                      label: Text(_isLoading ? 'Configuring...' : 'Configure Backpressure'),
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
                  _buildStrategyDescription('CALLER_RUNS', 'Executes the task in the caller thread', Colors.green),
                  _buildStrategyDescription('ABORT', 'Throws RejectedExecutionException', Colors.red),
                  _buildStrategyDescription('DISCARD', 'Silently discards the task', Colors.orange),
                  _buildStrategyDescription('DISCARD_OLDEST', 'Discards the oldest unhandled task', Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyDescription(String strategy, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: color,
          ),
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
                        : const Icon(Icons.tune),
                      label: Text(_isLoading ? 'Optimizing...' : 'Optimize Thread Pools'),
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
