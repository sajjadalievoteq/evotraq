import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/services/admin/performance_optimization_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_overview_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_query_optimization_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_connection_pool_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_thread_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_resource_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_stat_row.dart';

class PerformanceOptimizationDashboard extends StatefulWidget {
  const PerformanceOptimizationDashboard({super.key});

  @override
  State<PerformanceOptimizationDashboard> createState() => _PerformanceOptimizationDashboardState();
}

class _PerformanceOptimizationDashboardState extends State<PerformanceOptimizationDashboard>
    with SingleTickerProviderStateMixin {
  final PerformanceOptimizationService _performanceService =
      getIt<PerformanceOptimizationService>();
  
  late TabController _tabController;
  LoadState<Map<String, dynamic>> _reportState = const LoadState.loading();
  bool _reportLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ensureTabLoaded(_tabController.index);
      }
    });
    _ensureTabLoaded(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  
  
  
  void _ensureTabLoaded(int index) {
    if (_reportLoaded) return;
    _reportLoaded = true;
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    setState(() {
      _reportState = const LoadState.loading();
    });

    try {
      final report = await _performanceService.getPerformanceReport();

      if (!mounted) return;
      setState(() {
        _reportState = report.isEmpty ? const LoadState.empty() : LoadState.success(report);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reportState = LoadState.error('Failed to load performance data: $e');
      });
    }
  }

  void _refreshPerformanceData() {
    _reportLoaded = true;
    _loadPerformanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Optimization Dashboard'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _refreshPerformanceData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: TraqIcon(NavIcons.dashboard), text: 'Overview'),
            Tab(icon: TraqIcon(AppAssets.iconBarChart), text: 'Query Optimization'),
            Tab(icon: TraqIcon(AppAssets.iconHub), text: 'Connection Pool'),
            Tab(icon: TraqIcon(AppAssets.iconSettings), text: 'Thread Management'),
            Tab(icon: TraqIcon(AppAssets.iconRefresh), text: 'Resource Management'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(
            child: PerfOptOverviewTab(
              reportState: _reportState,
              onRetry: _refreshPerformanceData,
              onRunBenchmark: () => _runBenchmark('comprehensive'),
              onDetectSlowQueries: _detectSlowQueries,
              onOptimizeMemory: _optimizeMemory,
              onDetectLeaks: _detectConnectionLeaks,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptQueryOptimizationTab(
              reportState: _reportState,
              onRetry: _refreshPerformanceData,
              onAnalyzeQuery: _analyzeQuery,
              onDetectSlowQueries: _detectSlowQueries,
              onAnalyzeTableIndexes: _analyzeTableIndexes,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptConnectionPoolTab(
              reportState: _reportState,
              onRetry: _refreshPerformanceData,
              onOptimizePool: _showConnectionPoolOptimization,
              onDetectLeaks: _detectConnectionLeaks,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptThreadManagementTab(
              reportState: _reportState,
              onRetry: _refreshPerformanceData,
              onConfigureThreadPool: _configureThreadPool,
            ),
          ),
          KeepAliveTabView(
            child: PerfOptResourceManagementTab(
              reportState: _reportState,
              onRetry: _refreshPerformanceData,
              onOptimizeMemory: _optimizeMemory,
              onOptimizeCpu: _optimizeCpu,
              onOptimizeIo: _optimizeIo,
            ),
          ),
        ],
      ),
    );
  }






  void _analyzeQuery(String query) async {
    if (query.isEmpty) {
      context.showError('Please enter a query to analyze');
      return;
    }

    try {
      final analysis = await _performanceService.analyzeQueryExecutionPlan(query);
      _showAnalysisDialog('Query Analysis', analysis);
    } catch (e) {
      _showErrorDialog('Failed to analyze query: $e');
    }
  }

  void _detectSlowQueries() async {
    try {
      final slowQueries = await _performanceService.detectSlowQueries();
      _showSlowQueriesDialog(slowQueries);
    } catch (e) {
      _showErrorDialog('Failed to detect slow queries: $e');
    }
  }

  void _analyzeTableIndexes(String tableName) async {
    try {
      final recommendations = await _performanceService.getIndexOptimizationRecommendations(tableName);
      _showAnalysisDialog('Index Optimization for $tableName', recommendations);
    } catch (e) {
      _showErrorDialog('Failed to analyze table indexes: $e');
    }
  }

  void _showConnectionPoolOptimization() async {
    try {
      final config = await _performanceService.getOptimizedConnectionPoolConfig();
      _showAnalysisDialog('Connection Pool Optimization', config);
    } catch (e) {
      _showErrorDialog('Failed to get connection pool optimization: $e');
    }
  }

  void _detectConnectionLeaks() async {
    try {
      final leaks = await _performanceService.detectConnectionLeaks();
      _showConnectionLeaksDialog(leaks);
    } catch (e) {
      _showErrorDialog('Failed to detect connection leaks: $e');
    }
  }

  void _configureThreadPool() async {
    try {
      final result = await _performanceService.configureOptimalThreadPool(
        poolName: 'default',
        coreSize: 4,
        maxSize: 8,
        queueCapacity: 100,
      );
      _showAnalysisDialog('Thread Pool Configuration', result);
    } catch (e) {
      _showErrorDialog('Failed to configure thread pool: $e');
    }
  }

  void _optimizeMemory() async {
    try {
      final result = await _performanceService.optimizeMemoryUsage();
      _showMemoryOptimizationDialog(result);
    } catch (e) {
      _showErrorDialog('Failed to optimize memory: $e');
    }
  }

  void _optimizeCpu() async {
    try {
      final result = await _performanceService.balanceCpuUtilization();
      _showAnalysisDialog('CPU Optimization', result);
    } catch (e) {
      _showErrorDialog('Failed to balance CPU utilization: $e');
    }
  }

  void _optimizeIo() async {
    try {
      final result = await _performanceService.optimizeIoOperations();
      _showAnalysisDialog('I/O Optimization', result);
    } catch (e) {
      _showErrorDialog('Failed to optimize I/O operations: $e');
    }
  }

  void _runBenchmark(String testType) async {
    try {
      final result = await _performanceService.runPerformanceBenchmark(testType);
      _showBenchmarkResultsDialog(result);
    } catch (e) {
      _showErrorDialog('Failed to run benchmark: $e');
    }
  }

  void _showSlowQueriesDialog(Map<String, dynamic> data) {
    final List<dynamic> slowQueries = data['slowQueries'] ?? [];
    final String summary = data['summary'] ?? 'No summary available';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(AppAssets.iconBarChart, color: AppColorMapper.errorColor(context)),
            const SizedBox(width: 8),
            const Text('Slow Query Detection Results'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorMapper.infoColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColorMapper.infoColor(context).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(summary),
                    const SizedBox(height: 8),
                    Text(
                      'Found ${slowQueries.length} slow queries',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: slowQueries.isNotEmpty ? AppColorMapper.errorColor(context) : AppColorMapper.successColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Detected Slow Queries:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: slowQueries.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColorMapper.successColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TraqIcon(AppAssets.iconCheck, size: 48, color: AppColorMapper.successColor(context)),
                            const SizedBox(height: 16),
                            Text(
                              'Excellent! No slow queries detected.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColorMapper.successColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your database is performing well.',
                              style: TextStyle(color: AppColorMapper.successColor(context)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: slowQueries.length,
                        itemBuilder: (context, index) {
                          final query = slowQueries[index];
                          final String sql = query['sql'] ?? 'Unknown query';
                          final double executionTime = (query['executionTime'] ?? 0.0).toDouble();
                          final String tableName = query['tableName'] ?? 'Unknown';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColorMapper.errorColor(context).withValues(alpha: 0.15),
                                child: Text('${index + 1}', style: TextStyle(color: AppColorMapper.errorColor(context))),
                              ),
                              title: Text(
                                'Query #${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Table: $tableName'),
                                  Text(
                                    'Execution Time: ${executionTime.toStringAsFixed(2)}ms',
                                    style: TextStyle(
                                      color: executionTime > 1000 ? AppColorMapper.errorColor(context) : AppColorMapper.warningColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SQL Query:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          sql,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (query['recommendation'] != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColorMapper.infoColor(context).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColorMapper.infoColor(context).withValues(alpha: 0.3)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TraqIcon(AppAssets.iconLightbulb, color: AppColorMapper.infoColor(context), size: 16),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    'Recommendation:',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(query['recommendation']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMemoryOptimizationDialog(Map<String, dynamic> data) {
    final String status = data['status'] ?? 'Unknown';
    final List<dynamic> optimizations = data['optimizations'] ?? [];
    final Map<String, dynamic> memoryStats = data['memoryStats'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(AppAssets.iconRefresh, color: AppColorMapper.successColor(context)),
            const SizedBox(width: 8),
            const Text('Memory Optimization Results'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: status == 'optimized' ? AppColorMapper.successColor(context).withValues(alpha: 0.1) : AppColorMapper.warningColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status == 'optimized' ? AppColorMapper.successColor(context).withValues(alpha: 0.3) : AppColorMapper.warningColor(context).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      TraqIcon(
                        status == 'optimized' ? AppAssets.iconCheckCircle : AppAssets.iconSettings,
                        color: status == 'optimized' ? AppColorMapper.successColor(context) : AppColorMapper.warningColor(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status == 'optimized' ? 'Optimization Complete' : 'Optimization in Progress',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status == 'optimized' 
                                  ? 'Memory usage has been successfully optimized'
                                  : 'Running memory optimization processes...',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                if (memoryStats.isNotEmpty) ...[
                  const Text(
                    'Memory Statistics:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColorMapper.infoColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        PerfOptStatRow('Used Memory', memoryStats['usedMemory'] ?? 'N/A'),
                        PerfOptStatRow('Free Memory', memoryStats['freeMemory'] ?? 'N/A'),
                        PerfOptStatRow('Total Memory', memoryStats['totalMemory'] ?? 'N/A'),
                        PerfOptStatRow('Memory Usage', memoryStats['memoryUsagePercent'] ?? 'N/A'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                const Text(
                  'Optimizations Applied:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                
                if (optimizations.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No specific optimizations were applied.'),
                  )
                else
                  ...optimizations.map<Widget>((opt) {
                    return Card(
                      child: ListTile(
                        leading: TraqIcon(AppAssets.iconCheck, color: AppColorMapper.successColor(context)),
                        title: Text(opt['action'] ?? 'Unknown action'),
                        subtitle: opt['description'] != null ? Text(opt['description']) : null,
                        trailing: opt['improvement'] != null
                            ? Chip(
                                label: Text(opt['improvement']),
                                backgroundColor: AppColorMapper.successColor(context).withValues(alpha: 0.15),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBenchmarkResultsDialog(Map<String, dynamic> data) {
    final String testType = data['testType'] ?? 'Unknown';
    final String status = data['status'] ?? 'Unknown';
    final List<dynamic> results = data['results'] ?? [];
    final Map<String, dynamic> summary = data['summary'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(AppAssets.iconClock, color: AppColorMapper.infoColor(context)),
            const SizedBox(width: 8),
            Text('Performance Benchmark Results'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorMapper.infoColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColorMapper.infoColor(context).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benchmark: ${testType.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TraqIcon(
                          status == 'completed' ? AppAssets.iconCheckCircle : AppAssets.iconPending,
                          color: status == 'completed' ? AppColorMapper.successColor(context) : AppColorMapper.warningColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${status.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'completed' ? AppColorMapper.successColor(context) : AppColorMapper.warningColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              if (summary.isNotEmpty) ...[
                const Text(
                  'Performance Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorMapper.successColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      PerfOptStatRow('Average Response Time', summary['avgResponseTime'] ?? 'N/A'),
                      PerfOptStatRow('Throughput', summary['throughput'] ?? 'N/A'),
                      PerfOptStatRow('Success Rate', summary['successRate'] ?? 'N/A'),
                      PerfOptStatRow('Total Requests', summary['totalRequests'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              const Text(
                'Detailed Results:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: results.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TraqIcon(AppAssets.iconInfo, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No detailed results available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          final String testName = result['testName'] ?? 'Test ${index + 1}';
                          final String responseTime = result['responseTime']?.toString() ?? 'N/A';
                          final String status = result['status'] ?? 'Unknown';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: status == 'success' ? AppColorMapper.successColor(context).withValues(alpha: 0.15) : AppColorMapper.errorColor(context).withValues(alpha: 0.15),
                                child: TraqIcon(
                                  status == 'success' ? AppAssets.iconCheck : AppAssets.iconX,
                                  color: status == 'success' ? AppColorMapper.successColor(context) : AppColorMapper.errorColor(context),
                                ),
                              ),
                              title: Text(
                                testName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Response Time: ${responseTime}ms'),
                                  Text(
                                    'Status: ${status.toUpperCase()}',
                                    style: TextStyle(
                                      color: status == 'success' ? AppColorMapper.successColor(context) : AppColorMapper.errorColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: result['score'] != null
                                  ? Chip(
                                      label: Text('Score: ${result['score']}'),
                                      backgroundColor: AppColorMapper.infoColor(context).withValues(alpha: 0.15),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showConnectionLeaksDialog(Map<String, dynamic> data) {
    final List<dynamic> leaks = data['leaks'] ?? [];
    final Map<String, dynamic> summary = data['summary'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(AppAssets.iconHub, color: AppColorMapper.warningColor(context)),
            const SizedBox(width: 8),
            const Text('Connection Leak Detection'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: leaks.isEmpty ? AppColorMapper.successColor(context).withValues(alpha: 0.1) : AppColorMapper.errorColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: leaks.isEmpty ? AppColorMapper.successColor(context).withValues(alpha: 0.3) : AppColorMapper.errorColor(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    TraqIcon(
                      leaks.isEmpty ? AppAssets.iconCheckCircle : AppAssets.iconAlert,
                      color: leaks.isEmpty ? AppColorMapper.successColor(context) : AppColorMapper.errorColor(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leaks.isEmpty ? 'No Leaks Detected' : '${leaks.length} Connection Leaks Found',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            leaks.isEmpty 
                                ? 'All connections are properly managed'
                                : 'Immediate attention required to prevent resource exhaustion',
                            style: TextStyle(
                              color: leaks.isEmpty ? AppColorMapper.successColor(context) : AppColorMapper.errorColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              if (summary.isNotEmpty) ...[
                const Text(
                  'Connection Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorMapper.infoColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      PerfOptStatRow('Total Connections', summary['totalConnections'] ?? 'N/A'),
                      PerfOptStatRow('Active Connections', summary['activeConnections'] ?? 'N/A'),
                      PerfOptStatRow('Idle Connections', summary['idleConnections'] ?? 'N/A'),
                      PerfOptStatRow('Leak Detection Time', summary['scanTime'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              const Text(
                'Connection Leaks:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: leaks.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColorMapper.successColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TraqIcon(AppAssets.iconCheck, size: 48, color: AppColorMapper.successColor(context)),
                            const SizedBox(height: 16),
                            Text(
                              'Excellent! No connection leaks detected.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColorMapper.successColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your application is managing connections properly.',
                              style: TextStyle(color: AppColorMapper.successColor(context)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: leaks.length,
                        itemBuilder: (context, index) {
                          final leak = leaks[index];
                          final String connectionId = leak['connectionId'] ?? 'Unknown';
                          final String threadName = leak['threadName'] ?? 'Unknown Thread';
                          final String leakDuration = leak['leakDuration']?.toString() ?? 'Unknown';
                          final String stackTrace = leak['stackTrace'] ?? 'No stack trace available';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColorMapper.errorColor(context).withValues(alpha: 0.15),
                                child: TraqIcon(AppAssets.iconAlert, color: AppColorMapper.errorColor(context), size: 20),
                              ),
                              title: Text(
                                'Connection Leak #${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Connection ID: $connectionId'),
                                  Text('Thread: $threadName'),
                                  Text(
                                    'Duration: $leakDuration',
                                    style: TextStyle(
                                      color: AppColorMapper.errorColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Stack Trace:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          stackTrace,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColorMapper.warningColor(context).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColorMapper.warningColor(context).withValues(alpha: 0.3)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TraqIcon(AppAssets.iconLightbulb, color: AppColorMapper.warningColor(context), size: 16),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Recommended Action:',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Close this connection immediately and review the code that created it. '
                                              'Ensure all database connections are properly closed in finally blocks or use try-with-resources.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          if (leaks.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.showWarning('Automatic leak cleanup initiated...');
              },
              icon: TraqIcon(AppAssets.iconSparkle),
              label: const Text('Auto Fix'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAnalysisDialog(String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(AppAssets.iconBarChart, color: AppColorMapper.infoColor(context)),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorMapper.infoColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColorMapper.infoColor(context).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analysis Results',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('Operation: $title'),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${data['status'] ?? 'Completed'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...data.entries.map<Widget>((entry) {
                  if (entry.key == 'status') return const SizedBox.shrink();
                  
                  return Card(
                    child: ListTile(
                      title: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(entry.value.toString()),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}