part of 'performance_optimization_dashboard_screen.dart';

extension PerformanceDashboardActions
    on _PerformanceOptimizationDashboardState {
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
        _reportState = report.isEmpty
            ? const LoadState.empty()
            : LoadState.success(report);
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

  void _analyzeQuery(String query) async {
    if (query.isEmpty) {
      context.showError('Please enter a query to analyze');
      return;
    }

    try {
      final analysis = await _performanceService.analyzeQueryExecutionPlan(
        query,
      );
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
      final recommendations = await _performanceService
          .getIndexOptimizationRecommendations(tableName);
      _showAnalysisDialog('Index Optimization for $tableName', recommendations);
    } catch (e) {
      _showErrorDialog('Failed to analyze table indexes: $e');
    }
  }

  void _showConnectionPoolOptimization() async {
    try {
      final config = await _performanceService
          .getOptimizedConnectionPoolConfig();
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
      final result = await _performanceService.runPerformanceBenchmark(
        testType,
      );
      _showBenchmarkResultsDialog(result);
    } catch (e) {
      _showErrorDialog('Failed to run benchmark: $e');
    }
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
            TraqIcon(
              AppAssets.iconBarChart,
              color: AppColorMapper.infoColor(context),
            ),
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
                    color: AppColorMapper.infoColor(
                      context,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColorMapper.infoColor(
                        context,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analysis Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
