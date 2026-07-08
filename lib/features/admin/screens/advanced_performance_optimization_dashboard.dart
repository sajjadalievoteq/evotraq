import 'package:flutter/material.dart';
import 'dart:async';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

import '../../../data/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_performance_data_utils.dart';

class AdvancedPerformanceOptimizationDashboard extends StatefulWidget {
  const AdvancedPerformanceOptimizationDashboard({Key? key}) : super(key: key);

  @override
  _AdvancedPerformanceOptimizationDashboardState createState() =>
      _AdvancedPerformanceOptimizationDashboardState();
}

class _AdvancedPerformanceOptimizationDashboardState
    extends State<AdvancedPerformanceOptimizationDashboard> {
  late AdvancedPerformanceService _performanceService;
  Map<String, dynamic>? _comprehensiveAnalysis;
  bool _isLoading = false;
  bool _isAutoOptimizing = false;
  String? _errorMessage;
  Timer? _refreshTimer;
  String? _lastAutoOptimizationResult;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadComprehensiveAnalysis();
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
      dioService: getIt<DioService>(),
      tokenManager: getIt<TokenManager>(),
      appConfig: appConfig,
    );
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isAutoOptimizing) {
        _loadComprehensiveAnalysis();
      }
    });
  }

  Future<void> _loadComprehensiveAnalysis() async {
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
    setState(() {
      _isAutoOptimizing = true;
    });

    try {
      await _performanceService.performAutomatedOptimization();
      setState(() {
        _lastAutoOptimizationResult =
            'Automated optimization completed successfully';
      });
      _showSuccessDialog(
        'Automated Optimization',
        'All performance optimizations completed successfully',
      );

      await _loadComprehensiveAnalysis();
    } catch (e) {
      _showErrorDialog('Failed to perform automated optimization: $e');
    } finally {
      setState(() {
        _isAutoOptimizing = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _isAutoOptimizing ? null : _loadComprehensiveAnalysis,
            tooltip: 'Refresh Analysis',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconSparkle),
            onPressed: _isAutoOptimizing ? null : _performAutomatedOptimization,
            tooltip: 'Auto Optimize',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_lastAutoOptimizationResult != null)
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
                                _lastAutoOptimizationResult!,
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_lastAutoOptimizationResult != null)
                    const SizedBox(height: 16),

                  if (_errorMessage != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            TraqIcon(AppAssets.iconAlert, color: Colors.red),
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

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TraqIcon(AppAssets.iconDashboard,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Performance Overview',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildOverviewMetrics(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Performance Components',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildComponentCards(),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TraqIcon(AppAssets.iconSparkle,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Automated Optimization',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                              onPressed: _isAutoOptimizing
                                  ? null
                                  : _performAutomatedOptimization,
                              icon: _isAutoOptimizing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : TraqIcon(AppAssets.iconSparkle),
                              label: Text(
                                _isAutoOptimizing
                                    ? 'Optimizing...'
                                    : 'Start Auto Optimization',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_comprehensiveAnalysis != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TraqIcon(AppAssets.iconBarChart, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Comprehensive Analysis Results',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildOverviewMetrics() {
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
              child: _buildOverviewCard(
                'Memory Usage',
                _getMemoryUsage(systemResources),
                AppAssets.iconChip,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewCard(
                'CPU Usage',
                _getCpuUsage(systemResources),
                AppAssets.iconGauge,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Active Connections',
                _getActiveConnections(connectionPool),
                AppAssets.iconLink,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewCard(
                'Active Threads',
                _getActiveThreads(threadPools),
                AppAssets.iconSettings,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
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

  Widget _buildComponentCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildComponentCard(
                'Query Plan Analysis',
                'Analyze SQL execution plans and optimize query performance',
                AppAssets.iconBarChart,
                Colors.blue,
                () => _showComingSoonDialog('Query Plan Analysis'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildComponentCard(
                'Connection Pool Monitoring',
                'Monitor HikariCP connections and detect leaks',
                AppAssets.iconHub,
                Colors.green,
                () => _showComingSoonDialog('Connection Pool Monitoring'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildComponentCard(
                'Thread Pool Management',
                'Manage thread pools with backpressure strategies',
                AppAssets.iconSettings,
                Colors.orange,
                () => _showComingSoonDialog('Thread Pool Management'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildComponentCard(
                'Resource Management',
                'Monitor and optimize system resources',
                AppAssets.iconComputer,
                Colors.purple,
                () => _showComingSoonDialog('Resource Management'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentCard(
    String title,
    String description,
    String iconAsset,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: TraqIcon(iconAsset, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TraqIcon(AppAssets.iconChevronR, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text(
            '$feature detailed dashboard is available through the comprehensive analysis above. Individual dashboards are coming soon!',
          ),
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

  String _getMemoryUsage(Map<String, dynamic> systemResources) =>
      AdminPerformanceDataUtils.memoryUsage(systemResources);

  String _getCpuUsage(Map<String, dynamic> systemResources) =>
      AdminPerformanceDataUtils.cpuUsage(systemResources);

  String _getActiveConnections(Map<String, dynamic> connectionPool) =>
      AdminPerformanceDataUtils.activeConnections(connectionPool);

  String _getActiveThreads(Map<String, dynamic> threadPools) =>
      AdminPerformanceDataUtils.activeThreads(threadPools);
}