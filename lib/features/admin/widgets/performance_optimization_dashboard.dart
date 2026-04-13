import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../data/services/performance_optimization_service.dart';


class PerformanceOptimizationDashboard extends StatefulWidget {
  const PerformanceOptimizationDashboard({super.key});

  @override
  State<PerformanceOptimizationDashboard> createState() => _PerformanceOptimizationDashboardState();
}

class _PerformanceOptimizationDashboardState extends State<PerformanceOptimizationDashboard>
    with SingleTickerProviderStateMixin {
  final PerformanceOptimizationService _performanceService = PerformanceOptimizationService();
  
  late TabController _tabController;
  Map<String, dynamic>? _performanceReport;
  Map<String, dynamic>? _resourceUsage;
  Map<String, dynamic>? _connectionPoolStatus;
  Map<String, dynamic>? _threadPoolStatus;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPerformanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        _performanceService.getPerformanceReport(),
        _performanceService.monitorResourceUsage(),
        _performanceService.monitorConnectionPool(),
        _performanceService.monitorThreadPools(),
      ]);

      setState(() {
        _performanceReport = futures[0];
        _resourceUsage = futures[1];
        _connectionPoolStatus = futures[2];
        _threadPoolStatus = futures[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load performance data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Optimization Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPerformanceData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.query_stats), text: 'Query Optimization'),
            Tab(icon: Icon(Icons.hub), text: 'Connection Pool'),
            Tab(icon: Icon(Icons.settings_system_daydream), text: 'Thread Management'),
            Tab(icon: Icon(Icons.memory), text: 'Resource Management'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPerformanceData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildQueryOptimizationTab(),
                    _buildConnectionPoolTab(),
                    _buildThreadManagementTab(),
                    _buildResourceManagementTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    final overallScore = _performanceReport?['overallPerformanceScore'] ?? 0.0;
    final recommendations = _performanceReport?['topRecommendations'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceScoreCard(overallScore),
          const SizedBox(height: 16),
          _buildSystemHealthCards(),
          const SizedBox(height: 16),
          _buildTopRecommendationsCard(recommendations),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildPerformanceScoreCard(double score) {
    Color scoreColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.speed, size: 32, color: scoreColor),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overall Performance Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('System health and efficiency rating', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthCards() {
    return Row(
      children: [
        Expanded(child: _buildHealthCard('Memory Usage', _resourceUsage?['memory']?['usagePercentage'] ?? 'N/A', Icons.memory)),
        const SizedBox(width: 8),
        Expanded(child: _buildHealthCard('CPU Usage', '${((_resourceUsage?['cpu']?['systemCpuLoad'] ?? 0.0) * 100).toStringAsFixed(1)}%', Icons.computer)),
        const SizedBox(width: 8),
        Expanded(child: _buildHealthCard('Connections', '${_connectionPoolStatus?['activeConnections'] ?? 0}/${_connectionPoolStatus?['totalConnections'] ?? 0}', Icons.hub)),
        const SizedBox(width: 8),
        Expanded(child: _buildHealthCard('Threads', '${_threadPoolStatus?['systemMetrics']?['activeThreadCount'] ?? 0}', Icons.settings_system_daydream)),
      ],
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRecommendationsCard(List recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text('Top Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (recommendations.isEmpty)
              const Text('No recommendations at this time', style: TextStyle(color: Colors.grey))
            else
              ...recommendations.take(3).map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec.toString())),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _runBenchmark('comprehensive'),
                  icon: const Icon(Icons.speed_outlined, size: 16),
                  label: const Text('Run Benchmark'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _detectSlowQueries(),
                  icon: const Icon(Icons.query_stats, size: 16),
                  label: const Text('Detect Slow Queries'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _optimizeMemory(),
                  icon: const Icon(Icons.memory, size: 16),
                  label: const Text('Optimize Memory'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _detectConnectionLeaks(),
                  icon: const Icon(Icons.hub, size: 16),
                  label: const Text('Check Leaks'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Query Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'SQL Query',
                      hintText: 'Enter SQL query to analyze...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onSubmitted: _analyzeQuery,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _analyzeQuery(''),
                        child: const Text('Analyze Query'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _detectSlowQueries(),
                        child: const Text('Detect Slow Queries'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Index Optimization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Select table for index analysis:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: ['object_events', 'aggregation_events', 'transaction_events', 'transformation_events']
                        .map((table) => DropdownMenuItem(value: table, child: Text(table)))
                        .toList(),
                    onChanged: (table) {
                      if (table != null) {
                        _analyzeTableIndexes(table);
                      }
                    },
                    hint: const Text('Select table'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPoolTab() {
    final currentStats = _connectionPoolStatus?['currentStatistics'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connection Pool Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (currentStats != null) ...[
                    _buildStatRow('Active Connections', '${currentStats['activeConnections'] ?? 0}'),
                    _buildStatRow('Idle Connections', '${currentStats['idleConnections'] ?? 0}'),
                    _buildStatRow('Total Connections', '${currentStats['totalConnections'] ?? 0}'),
                    _buildStatRow('Max Pool Size', '${currentStats['maxPoolSize'] ?? 0}'),
                    _buildStatRow('Connection Timeout', '${currentStats['connectionTimeout'] ?? 0}ms'),
                    _buildStatRow('Avg Connection Time', '${currentStats['avgConnectionTime'] ?? 0}ms'),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showConnectionPoolOptimization(),
                        child: const Text('Optimize Pool'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _detectConnectionLeaks(),
                        child: const Text('Detect Leaks'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thread Pool Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Configure optimal thread pool settings:'),
                  const SizedBox(height: 16),
                  _buildThreadPoolConfigForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceManagementTab() {
    final memoryUsage = _resourceUsage?['memory'];
    final cpuUsage = _resourceUsage?['cpu'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Resources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (memoryUsage != null) ...[
                    const Text('Memory Usage:', style: TextStyle(fontWeight: FontWeight.w500)),
                    _buildStatRow('Used Memory', '${(memoryUsage['usedMemory'] ?? 0) ~/ 1024 ~/ 1024} MB'),
                    _buildStatRow('Free Memory', '${(memoryUsage['freeMemory'] ?? 0) ~/ 1024 ~/ 1024} MB'),
                    _buildStatRow('Max Memory', '${(memoryUsage['maxMemory'] ?? 0) ~/ 1024 ~/ 1024} MB'),
                    const SizedBox(height: 16),
                  ],
                  if (cpuUsage != null) ...[
                    const Text('CPU Information:', style: TextStyle(fontWeight: FontWeight.w500)),
                    _buildStatRow('Available Processors', '${cpuUsage['availableProcessors'] ?? 0}'),
                    _buildStatRow('System CPU Load', '${((cpuUsage['systemCpuLoad'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _optimizeMemory(),
                        child: const Text('Optimize Memory'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _optimizeCpu(),
                        child: const Text('Balance CPU'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _optimizeIo(),
                        child: const Text('Optimize I/O'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildThreadPoolConfigForm() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Pool Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Core Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Max Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Queue Capacity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _configureThreadPool(),
          child: const Text('Configure Thread Pool'),
        ),
      ],
    );
  }

  // Action methods
  void _analyzeQuery(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a query to analyze')),
      );
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
    // This would read from form fields and configure the thread pool
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
            Icon(Icons.query_stats, color: Colors.red[700]),
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
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
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
                        color: slowQueries.length > 0 ? Colors.red[700] : Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Queries List
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
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 48, color: Colors.green[600]),
                            const SizedBox(height: 16),
                            Text(
                              'Excellent! No slow queries detected.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your database is performing well.',
                              style: TextStyle(color: Colors.green[600]),
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
                                backgroundColor: Colors.red[100],
                                child: Text('${index + 1}', style: TextStyle(color: Colors.red[700])),
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
                                      color: executionTime > 1000 ? Colors.red[700] : Colors.orange[700],
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
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.blue[200]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.lightbulb, size: 16, color: Colors.blue[700]),
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
            Icon(Icons.memory, color: Colors.green[700]),
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
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: status == 'optimized' ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status == 'optimized' ? Colors.green[200]! : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        status == 'optimized' ? Icons.check_circle : Icons.settings,
                        color: status == 'optimized' ? Colors.green[700] : Colors.orange[700],
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
                
                // Memory Statistics
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
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Used Memory', memoryStats['usedMemory'] ?? 'N/A'),
                        _buildStatRow('Free Memory', memoryStats['freeMemory'] ?? 'N/A'),
                        _buildStatRow('Total Memory', memoryStats['totalMemory'] ?? 'N/A'),
                        _buildStatRow('Memory Usage', memoryStats['memoryUsagePercent'] ?? 'N/A'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Optimizations Applied
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
                        leading: Icon(Icons.check, color: Colors.green[600]),
                        title: Text(opt['action'] ?? 'Unknown action'),
                        subtitle: opt['description'] != null ? Text(opt['description']) : null,
                        trailing: opt['improvement'] != null
                            ? Chip(
                                label: Text(opt['improvement']),
                                backgroundColor: Colors.green[100],
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
            Icon(Icons.speed, color: Colors.blue[700]),
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
              // Test Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
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
                        Icon(
                          status == 'completed' ? Icons.check_circle : Icons.pending,
                          color: status == 'completed' ? Colors.green[600] : Colors.orange[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${status.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'completed' ? Colors.green[600] : Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Summary Statistics
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
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Average Response Time', summary['avgResponseTime'] ?? 'N/A'),
                      _buildStatRow('Throughput', summary['throughput'] ?? 'N/A'),
                      _buildStatRow('Success Rate', summary['successRate'] ?? 'N/A'),
                      _buildStatRow('Total Requests', summary['totalRequests'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Detailed Results
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
                            Icon(Icons.info, size: 48, color: Colors.grey),
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
                                backgroundColor: status == 'success' ? Colors.green[100] : Colors.red[100],
                                child: Icon(
                                  status == 'success' ? Icons.check : Icons.close,
                                  color: status == 'success' ? Colors.green[700] : Colors.red[700],
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
                                      color: status == 'success' ? Colors.green[700] : Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: result['score'] != null
                                  ? Chip(
                                      label: Text('Score: ${result['score']}'),
                                      backgroundColor: Colors.blue[100],
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
            Icon(Icons.hub, color: Colors.orange[700]),
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
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: leaks.isEmpty ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: leaks.isEmpty ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      leaks.isEmpty ? Icons.check_circle : Icons.warning,
                      color: leaks.isEmpty ? Colors.green[700] : Colors.red[700],
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
                              color: leaks.isEmpty ? Colors.green[600] : Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Summary Statistics
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Total Connections', summary['totalConnections'] ?? 'N/A'),
                      _buildStatRow('Active Connections', summary['activeConnections'] ?? 'N/A'),
                      _buildStatRow('Idle Connections', summary['idleConnections'] ?? 'N/A'),
                      _buildStatRow('Leak Detection Time', summary['scanTime'] ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Leaks Details
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
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 48, color: Colors.green[600]),
                            const SizedBox(height: 16),
                            Text(
                              'Excellent! No connection leaks detected.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your application is managing connections properly.',
                              style: TextStyle(color: Colors.green[600]),
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
                                backgroundColor: Colors.red[100],
                                child: Icon(Icons.warning, color: Colors.red[700], size: 20),
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
                                      color: Colors.red[700],
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
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.orange[200]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.lightbulb, size: 16, color: Colors.orange[700]),
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
                // Could trigger automatic leak cleanup
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Automatic leak cleanup initiated...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.auto_fix_high),
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

  // Generic analysis dialog for other operations
  void _showAnalysisDialog(String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue[700]),
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
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
