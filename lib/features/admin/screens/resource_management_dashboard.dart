import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/features/admin/services/advanced_performance_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:http/http.dart' as http;

class ResourceManagementDashboard extends StatefulWidget {
  const ResourceManagementDashboard({Key? key}) : super(key: key);

  @override
  _ResourceManagementDashboardState createState() => _ResourceManagementDashboardState();
}

class _ResourceManagementDashboardState extends State<ResourceManagementDashboard> {
  late AdvancedPerformanceService _performanceService;
  Map<String, dynamic>? _systemMetrics;
  List<dynamic>? _recommendations;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;
  String? _lastOptimizationResult;

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
    final appConfig = Provider.of<AppConfig>(context, listen: false);
    _performanceService = AdvancedPerformanceService(
      client: http.Client(),
      tokenManager: TokenManager(),
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

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadSystemMetrics(),
        _loadRecommendations(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load resource data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSystemMetrics() async {
    try {
      final metrics = await _performanceService.getSystemResourceMetrics();
      if (mounted) {
        setState(() {
          _systemMetrics = metrics;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load system metrics: $e';
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await _performanceService.getResourceRecommendations();
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

  Future<void> _optimizeMemoryUsage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _performanceService.optimizeMemoryUsage();
      
      setState(() {
        _lastOptimizationResult = 'Memory usage optimized successfully';
      });
      
      _showSuccessDialog('Memory optimization completed successfully');
      await _loadSystemMetrics();
    } catch (e) {
      _showErrorDialog('Failed to optimize memory usage: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _optimizeCpuUsage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _performanceService.optimizeCpuUsage();
      
      setState(() {
        _lastOptimizationResult = 'CPU usage optimized successfully';
      });
      
      _showSuccessDialog('CPU optimization completed successfully');
      await _loadSystemMetrics();
    } catch (e) {
      _showErrorDialog('Failed to optimize CPU usage: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _optimizeIoPerformance() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _performanceService.optimizeIoPerformance();
      
      setState(() {
        _lastOptimizationResult = 'I/O performance optimized successfully';
      });
      
      _showSuccessDialog('I/O optimization completed successfully');
      await _loadSystemMetrics();
    } catch (e) {
      _showErrorDialog('Failed to optimize I/O performance: $e');
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
        title: const Text('Resource Management'),
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
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.monitor), text: 'System Monitor'),
                Tab(icon: Icon(Icons.tune), text: 'Optimization'),
                Tab(icon: Icon(Icons.lightbulb), text: 'Recommendations'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSystemMonitorTab(),
                  _buildOptimizationTab(),
                  _buildRecommendationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMonitorTab() {
    if (_isLoading && _systemMetrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_systemMetrics == null) {
      return const Center(child: Text('No system metrics available'));
    }

    return RefreshIndicator(
      onRefresh: _loadSystemMetrics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optimization Result
            if (_lastOptimizationResult != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
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
                    _buildSystemMetrics(),
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
                        _systemMetrics.toString(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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

  Widget _buildSystemMetrics() {
    final memory = _systemMetrics?['memory'] ?? {};
    final cpu = _systemMetrics?['cpu'] ?? {};
    final disk = _systemMetrics?['disk'] ?? {};
    final network = _systemMetrics?['network'] ?? {};

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
                Icons.memory, 
                _getUsageColor(memoryUsage.toDouble())
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'CPU Usage', 
                '${cpuUsage.toStringAsFixed(1)}%', 
                Icons.speed, 
                _getUsageColor(cpuUsage.toDouble())
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
                Icons.storage, 
                _getUsageColor(diskUsage.toDouble())
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Network Load', 
                '${networkLoad.toStringAsFixed(1)}%', 
                Icons.network_check, 
                _getUsageColor(networkLoad.toDouble())
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getUsageColor(double usage) {
    if (usage < 50) return Colors.green;
    if (usage < 80) return Colors.orange;
    return Colors.red;
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
                        : const Icon(Icons.memory),
                      label: Text(_isLoading ? 'Optimizing...' : 'Optimize Memory'),
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
                        : const Icon(Icons.speed),
                      label: Text(_isLoading ? 'Optimizing...' : 'Optimize CPU'),
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
                        : const Icon(Icons.storage),
                      label: Text(_isLoading ? 'Optimizing...' : 'Optimize I/O'),
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
            SizedBox(height: 8),
            Text(
              'System is performing optimally',
              style: TextStyle(color: Colors.grey),
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
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.lightbulb, color: Colors.blue),
            ),
            title: Text('Recommendation #${index + 1}'),
            subtitle: Text(recommendation.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _showRecommendationDetails(recommendation);
              },
            ),
          ),
        );
      },
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
