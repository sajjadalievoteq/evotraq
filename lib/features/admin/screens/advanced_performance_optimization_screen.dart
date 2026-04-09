import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/admin/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:http/http.dart' as http;

class AdvancedPerformanceOptimizationScreen extends StatefulWidget {
  const AdvancedPerformanceOptimizationScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedPerformanceOptimizationScreen> createState() => _AdvancedPerformanceOptimizationScreenState();
}

class _AdvancedPerformanceOptimizationScreenState extends State<AdvancedPerformanceOptimizationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AdvancedPerformanceService _performanceService;
  
  Map<String, dynamic>? _comprehensiveAnalysis;
  bool _isLoading = false;
  bool _isOptimizing = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeService();
    _loadComprehensiveAnalysis();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _initializeService() {
    final appConfig = Provider.of<AppConfig>(context, listen: false);
    _performanceService = AdvancedPerformanceService(
      client: http.Client(),
      tokenManager: TokenManager(), // Assuming this is available
      appConfig: appConfig,
    );
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isOptimizing) {
        _loadComprehensiveAnalysis();
      }
    });
  }

  Future<void> _loadComprehensiveAnalysis() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final analysis = await _performanceService.getComprehensiveAnalysis();
      if (mounted) {
        setState(() {
          _comprehensiveAnalysis = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load comprehensive analysis: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performAutomatedOptimization() async {
    if (!mounted) return;
    
    setState(() {
      _isOptimizing = true;
    });

    try {
      await _performanceService.performAutomatedOptimization();
      if (mounted) {
        _showSuccessDialog('Automated optimization completed successfully');
        await _loadComprehensiveAnalysis();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to perform automated optimization: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOptimizing = false;
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
        title: const Text('Advanced Performance Optimization'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Query Analysis'),
            Tab(icon: Icon(Icons.pool), text: 'Connection Pool'),
            Tab(icon: Icon(Icons.settings), text: 'Thread Pool'),
            Tab(icon: Icon(Icons.computer), text: 'Resources'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isOptimizing ? null : _loadComprehensiveAnalysis,
            tooltip: 'Refresh Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _isOptimizing ? null : _performAutomatedOptimization,
            tooltip: 'Auto Optimize',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildQueryAnalysisTab(),
          _buildConnectionPoolTab(),
          _buildThreadPoolTab(),
          _buildResourcesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadComprehensiveAnalysis,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error Message
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_errorMessage != null) const SizedBox(height: 16),

            // Loading or Overview Content
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Performance Metrics Overview
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Performance Overview',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPerformanceMetrics(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Automated Optimization Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_fix_high, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Automated Optimization',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Perform comprehensive optimization across all performance components including memory, CPU, I/O, connection pools, and thread pools.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isOptimizing ? null : _performAutomatedOptimization,
                              icon: _isOptimizing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_fix_high),
                              label: Text(_isOptimizing ? 'Optimizing...' : 'Start Auto Optimization'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comprehensive Analysis Results
                  if (_comprehensiveAnalysis != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Comprehensive Analysis Results',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _comprehensiveAnalysis.toString(),
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    if (_comprehensiveAnalysis == null) {
      return const Text('Loading performance metrics...');
    }

    final systemResources = _comprehensiveAnalysis?['systemResources'] ?? {};
    final connectionPool = _comprehensiveAnalysis?['connectionPool'] ?? {};
    final threadPools = _comprehensiveAnalysis?['threadPools'] ?? {};

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Memory Usage',
                _getMemoryUsage(systemResources),
                Icons.memory,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'CPU Usage',
                _getCpuUsage(systemResources),
                Icons.speed,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Active Connections',
                _getActiveConnections(connectionPool),
                Icons.link,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Active Threads',
                _getActiveThreads(threadPools),
                Icons.settings,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildQueryAnalysisTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Query Plan Analysis',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Advanced SQL query execution plan analysis and optimization',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPoolTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pool, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Connection Pool Monitoring',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'HikariCP connection pool monitoring and leak detection',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadPoolTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Thread Pool Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Advanced thread pool management with backpressure strategies',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Resource Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'System-wide resource monitoring and optimization',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getMemoryUsage(Map<String, dynamic> systemResources) {
    final memory = systemResources['memory'] ?? {};
    return '${memory['usagePercentage'] ?? '0'}%';
  }

  String _getCpuUsage(Map<String, dynamic> systemResources) {
    final cpu = systemResources['cpu'] ?? {};
    final cpuLoad = cpu['systemCpuLoad'] ?? 0;
    return '${(cpuLoad * 100).toStringAsFixed(1)}%';
  }

  String _getActiveConnections(Map<String, dynamic> connectionPool) {
    return connectionPool['activeConnections']?.toString() ?? '0';
  }

  String _getActiveThreads(Map<String, dynamic> threadPools) {
    return threadPools['activeThreads']?.toString() ?? '0';
  }
}
