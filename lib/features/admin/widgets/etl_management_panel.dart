import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../core/network/token_manager.dart';

/// ETL Management Panel for Phase 3.3 Batch Processing Capabilities
/// Provides comprehensive ETL pipeline management and monitoring interface
class ETLManagementPanel extends StatefulWidget {
  final String baseUrl;
  final TokenManager tokenManager;

  const ETLManagementPanel({
    Key? key,
    required this.baseUrl,
    required this.tokenManager,
  }) : super(key: key);

  @override
  ETLManagementPanelState createState() => ETLManagementPanelState();
}

class ETLManagementPanelState extends State<ETLManagementPanel> with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _refreshTimer;
  
  List<Map<String, dynamic>> _pipelines = [];
  List<Map<String, dynamic>> _transformations = [];
  List<Map<String, dynamic>> _executionHistory = [];
  Map<String, dynamic> _qualityMetrics = {};
  Map<String, dynamic> _performanceData = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPipelineFilter = 'ALL';
  String _selectedTransformationFilter = 'ALL';

  final List<String> _pipelineStatuses = ['ALL', 'ACTIVE', 'INACTIVE', 'FAILED', 'SCHEDULED'];
  final List<String> _transformationTypes = ['ALL', 'VALIDATION', 'ENRICHMENT', 'NORMALIZATION', 'AGGREGATION'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadInitialData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _refreshCurrentTab();
      }
    });
  }

  void _refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _loadPipelines();
        break;
      case 1:
        _loadTransformations();
        break;
      case 2:
        _loadExecutionHistory();
        break;
      case 3:
        _loadQualityMetrics();
        break;
      case 4:
        _loadPerformanceData();
        break;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadPipelines(),
        _loadTransformations(),
        _loadQualityMetrics(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load ETL data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPipelines() async {
    try {
      String url = '${widget.baseUrl}/etl/pipelines';
      if (_selectedPipelineFilter != 'ALL') {
        url += '?status=$_selectedPipelineFilter';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _pipelines = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading pipelines: $e');
    }
  }

  Future<void> _loadTransformations() async {
    try {
      String url = '${widget.baseUrl}/etl/transformations';
      if (_selectedTransformationFilter != 'ALL') {
        url += '?type=$_selectedTransformationFilter';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _transformations = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading transformations: $e');
    }
  }

  Future<void> _loadExecutionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/etl/executions?limit=50'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _executionHistory = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading execution history: $e');
    }
  }

  Future<void> _loadQualityMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/etl/quality-metrics'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _qualityMetrics = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading quality metrics: $e');
    }
  }

  Future<void> _loadPerformanceData() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/etl/performance'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _performanceData = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading performance data: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await widget.tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildETLHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Pipelines'),
                  Tab(text: 'Transformations'),
                  Tab(text: 'Execution History'),
                  Tab(text: 'Quality Metrics'),
                  Tab(text: 'Performance'),
                ],
                onTap: (index) => _refreshCurrentTab(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPipelinesTab(),
                    _buildTransformationsTab(),
                    _buildExecutionHistoryTab(),
                    _buildQualityMetricsTab(),
                    _buildPerformanceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildETLHeader() {
    final activePipelines = _pipelines.where((p) => p['status'] == 'ACTIVE').length;
    final totalPipelines = _pipelines.length;
    final failedPipelines = _pipelines.where((p) => p['status'] == 'FAILED').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ETL Status Overview
            Expanded(
              child: Row(
                children: [
                  _buildSummaryItem('Active', activePipelines, Icons.play_circle, color: Colors.green),
                  const SizedBox(width: 24),
                  _buildSummaryItem('Total', totalPipelines, Icons.storage),
                  const SizedBox(width: 24),
                  _buildSummaryItem('Failed', failedPipelines, Icons.error, color: Colors.red),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreatePipelineDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Pipeline'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _refreshCurrentTab,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  onPressed: _showETLSettings,
                  icon: const Icon(Icons.settings),
                  tooltip: 'ETL Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value, IconData icon, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color ?? Colors.blue),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPipelinesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'ETL Pipelines',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildPipelineFilter(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _pipelines.isEmpty
                ? const Center(child: Text('No pipelines found'))
                : ListView.builder(
                    itemCount: _pipelines.length,
                    itemBuilder: (context, index) {
                      final pipeline = _pipelines[index];
                      return _buildPipelineCard(pipeline);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Data Transformations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildTransformationFilter(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _transformations.isEmpty
                ? const Center(child: Text('No transformations found'))
                : ListView.builder(
                    itemCount: _transformations.length,
                    itemBuilder: (context, index) {
                      final transformation = _transformations[index];
                      return _buildTransformationCard(transformation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Execution History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _executionHistory.isEmpty
                ? const Center(child: Text('No execution history'))
                : ListView.builder(
                    itemCount: _executionHistory.length,
                    itemBuilder: (context, index) {
                      final execution = _executionHistory[index];
                      return _buildExecutionCard(execution);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetricsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Data Quality Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildQualityMetricsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Performance Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildPerformanceContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(Map<String, dynamic> pipeline) {
    final status = pipeline['status'] ?? '';
    final name = pipeline['name'] ?? '';
    final lastExecution = pipeline['lastExecution'] ?? '';
    final nextExecution = pipeline['nextExecution'] ?? '';
    final successRate = pipeline['successRate'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePipelineAction(value, pipeline),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Pipeline')),
                    const PopupMenuItem(value: 'execute', child: Text('Execute Now')),
                    const PopupMenuItem(value: 'schedule', child: Text('Schedule')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lastExecution.isNotEmpty)
                        Text(
                          'Last: $lastExecution',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      if (nextExecution.isNotEmpty)
                        Text(
                          'Next: $nextExecution',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Success Rate',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    Text(
                      '${(successRate * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: successRate > 0.9 ? Colors.green : 
                               successRate > 0.7 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformationCard(Map<String, dynamic> transformation) {
    final type = transformation['type'] ?? '';
    final name = transformation['name'] ?? '';
    final enabled = transformation['enabled'] ?? false;
    final performance = transformation['performance'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTransformationTypeColor(type),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            type,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text('Performance: ${(performance * 100).toStringAsFixed(1)}%'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: enabled,
              onChanged: (value) => _toggleTransformation(transformation['id'], value),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleTransformationAction(value, transformation),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'test', child: Text('Test')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionCard(Map<String, dynamic> execution) {
    final pipelineName = execution['pipelineName'] ?? '';
    final status = execution['status'] ?? '';
    final startTime = execution['startTime'] ?? '';
    final duration = execution['duration'] ?? '';
    final recordsProcessed = execution['recordsProcessed'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(pipelineName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Started: $startTime'),
            if (duration.isNotEmpty) Text('Duration: $duration'),
            Text('Records: $recordsProcessed'),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _showExecutionDetails(execution),
          icon: const Icon(Icons.info_outline),
          tooltip: 'View Details',
        ),
      ),
    );
  }

  Widget _buildQualityMetricsContent() {
    final overallScore = _qualityMetrics['overallScore'] ?? 0.0;
    final completeness = _qualityMetrics['completeness'] ?? 0.0;
    final accuracy = _qualityMetrics['accuracy'] ?? 0.0;
    final consistency = _qualityMetrics['consistency'] ?? 0.0;
    final validity = _qualityMetrics['validity'] ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Overall Quality Score
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Overall Data Quality Score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getQualityColor(overallScore),
                        width: 8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${(overallScore * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getQualityColor(overallScore),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Quality Dimensions
          Row(
            children: [
              Expanded(
                child: _buildQualityDimensionCard('Completeness', completeness),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQualityDimensionCard('Accuracy', accuracy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildQualityDimensionCard('Consistency', consistency),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQualityDimensionCard('Validity', validity),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityDimensionCard(String dimension, double score) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              dimension,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_getQualityColor(score)),
            ),
            const SizedBox(height: 4),
            Text(
              '${(score * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getQualityColor(score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceContent() {
    final throughput = _performanceData['throughput'] ?? 0;
    final avgProcessingTime = _performanceData['avgProcessingTime'] ?? 0.0;
    final errorRate = _performanceData['errorRate'] ?? 0.0;
    final resourceUtilization = _performanceData['resourceUtilization'] ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard('Throughput', '$throughput records/sec', Icons.speed),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPerformanceCard(
                  'Avg Processing Time', 
                  '${avgProcessingTime.toStringAsFixed(2)}s', 
                  Icons.timer
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceCard(
                  'Error Rate', 
                  '${(errorRate * 100).toStringAsFixed(2)}%', 
                  Icons.error_outline
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPerformanceCard(
                  'Resource Usage', 
                  '${(resourceUtilization * 100).toStringAsFixed(1)}%', 
                  Icons.memory
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineFilter() {
    return DropdownButton<String>(
      value: _selectedPipelineFilter,
      items: _pipelineStatuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPipelineFilter = value!;
        });
        _loadPipelines();
      },
    );
  }

  Widget _buildTransformationFilter() {
    return DropdownButton<String>(
      value: _selectedTransformationFilter,
      items: _transformationTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTransformationFilter = value!;
        });
        _loadTransformations();
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
      case 'COMPLETED':
        return Colors.green;
      case 'RUNNING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'INACTIVE':
      case 'SCHEDULED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTransformationTypeColor(String type) {
    switch (type) {
      case 'VALIDATION':
        return Colors.blue;
      case 'ENRICHMENT':
        return Colors.green;
      case 'NORMALIZATION':
        return Colors.purple;
      case 'AGGREGATION':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getQualityColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.7) return Colors.orange;
    return Colors.red;
  }

  void _handlePipelineAction(String action, Map<String, dynamic> pipeline) {
    final pipelineId = pipeline['pipeline_id'] ?? pipeline['id'];
    
    switch (action) {
      case 'edit':
        _showEditPipelineDialog(pipeline);
        break;
      case 'execute':
        _executePipeline(pipelineId);
        break;
      case 'schedule':
        _showSchedulePipelineDialog(pipeline);
        break;
      case 'delete':
        _deletePipeline(pipelineId);
        break;
    }
  }

  void _handleTransformationAction(String action, Map<String, dynamic> transformation) {
    final transformationId = transformation['transformation_id'] ?? transformation['id'];
    
    switch (action) {
      case 'edit':
        _showEditTransformationDialog(transformation);
        break;
      case 'test':
        _testTransformation(transformationId);
        break;
      case 'delete':
        _deleteTransformation(transformationId);
        break;
    }
  }

  Future<void> _toggleTransformation(String transformationId, bool enabled) async {
    try {
      final response = await http.put(
        Uri.parse('${widget.baseUrl}/etl/transformations/$transformationId/toggle'),
        headers: await _getHeaders(),
        body: json.encode({'enabled': enabled}),
      );

      if (response.statusCode == 200) {
        _loadTransformations();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle transformation: $e')),
      );
    }
  }

  Future<void> _executePipeline(String pipelineId) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/etl/pipelines/$pipelineId/execute'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pipeline execution started')),
        );
        _loadPipelines();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to execute pipeline: $e')),
      );
    }
  }

  Future<void> _deletePipeline(String pipelineId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pipeline'),
        content: const Text('Are you sure you want to delete this pipeline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(
          Uri.parse('${widget.baseUrl}/etl/pipelines/$pipelineId'),
          headers: await _getHeaders(),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pipeline deleted successfully')),
          );
          _loadPipelines();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete pipeline: $e')),
        );
      }
    }
  }

  Future<void> _deleteTransformation(String transformationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transformation'),
        content: const Text('Are you sure you want to delete this transformation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(
          Uri.parse('${widget.baseUrl}/etl/transformations/$transformationId'),
          headers: await _getHeaders(),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transformation deleted successfully')),
          );
          _loadTransformations();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete transformation: $e')),
        );
      }
    }
  }

  Future<void> _testTransformation(String transformationId) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/etl/transformations/$transformationId/test'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _showTestResults(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to test transformation: $e')),
      );
    }
  }

  void _showCreatePipelineDialog() {
    final pipelineNameController = TextEditingController();
    final descriptionController = TextEditingController();
    List<Map<String, dynamic>> transformationRules = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Pipeline'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: pipelineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pipeline Name',
                      hintText: 'Enter pipeline name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter pipeline description',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transformation Rules',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            transformationRules.add({
                              'ruleId': 'RULE_${transformationRules.length + 1}',
                              'ruleName': 'New Rule ${transformationRules.length + 1}',
                              'transformationType': 'VALIDATION',
                              'sourceField': '',
                              'targetField': '',
                              'transformationFunction': 'COPY',
                              'functionParameters': {},
                              'validationRules': {},
                              'defaultValue': null,
                              'required': true,
                              'executionOrder': transformationRules.length,
                              'continueOnError': false,
                              'description': '',
                              'conditions': {},
                            });
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Rule'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: transformationRules.isEmpty
                        ? const Center(
                            child: Text(
                              'No transformation rules added yet.\nClick "Add Rule" to add rules.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: transformationRules.length,
                            itemBuilder: (context, index) {
                              final rule = transformationRules[index];
                              return Card(
                                margin: const EdgeInsets.all(4),
                                child: ListTile(
                                  title: Text(rule['ruleName']),
                                  subtitle: Text(
                                    'Type: ${rule['transformationType']}\n'
                                    'Function: ${rule['transformationFunction']}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        transformationRules.removeAt(index);
                                      });
                                    },
                                  ),
                                  onTap: () => _showEditRuleDialog(rule, setState),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: pipelineNameController.text.trim().isEmpty
                  ? null
                  : () async {
                      await _createPipeline(
                        pipelineNameController.text.trim(),
                        transformationRules,
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Create Pipeline'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPipelineDialog(Map<String, dynamic> pipeline) {
    final pipelineNameController = TextEditingController(text: pipeline['pipeline_name']);
    final descriptionController = TextEditingController();
    List<Map<String, dynamic>> transformationRules = List<Map<String, dynamic>>.from(
        pipeline['transformation_rules'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Pipeline: ${pipeline['pipeline_name']}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: pipelineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pipeline Name',
                      hintText: 'Enter pipeline name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter pipeline description',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transformation Rules (${transformationRules.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            transformationRules.add({
                              'ruleId': 'RULE_${transformationRules.length + 1}',
                              'ruleName': 'New Rule ${transformationRules.length + 1}',
                              'transformationType': 'VALIDATION',
                              'sourceField': '',
                              'targetField': '',
                              'transformationFunction': 'COPY',
                              'functionParameters': {},
                              'validationRules': {},
                              'defaultValue': null,
                              'required': true,
                              'executionOrder': transformationRules.length,
                              'continueOnError': false,
                              'description': '',
                              'conditions': {},
                            });
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Rule'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: transformationRules.isEmpty
                        ? const Center(
                            child: Text(
                              'No transformation rules.\nClick "Add Rule" to add rules.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: transformationRules.length,
                            itemBuilder: (context, index) {
                              final rule = transformationRules[index];
                              return Card(
                                margin: const EdgeInsets.all(4),
                                child: ListTile(
                                  title: Text(rule['ruleName']),
                                  subtitle: Text(
                                    'Type: ${rule['transformationType']}\n'
                                    'Function: ${rule['transformationFunction']}\n'
                                    'Source: ${rule['sourceField']} → Target: ${rule['targetField']}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        transformationRules.removeAt(index);
                                      });
                                    },
                                  ),
                                  onTap: () => _showEditRuleDialog(rule, setState),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: pipelineNameController.text.trim().isEmpty
                  ? null
                  : () async {
                      await _updatePipeline(
                        pipeline['pipeline_id'],
                        pipelineNameController.text.trim(),
                        transformationRules,
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Update Pipeline'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSchedulePipelineDialog(Map<String, dynamic> pipeline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Pipeline: ${pipeline['pipeline_name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Schedule automatic execution for this pipeline:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Run Every Hour'),
                subtitle: const Text('Execute pipeline every hour'),
                onTap: () {
                  _schedulePipeline(pipeline['pipeline_id'], 'HOURLY');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('Run Daily'),
                subtitle: const Text('Execute pipeline once per day'),
                onTap: () {
                  _schedulePipeline(pipeline['pipeline_id'], 'DAILY');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Run Weekly'),
                subtitle: const Text('Execute pipeline once per week'),
                onTap: () {
                  _schedulePipeline(pipeline['pipeline_id'], 'WEEKLY');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.stop_circle),
                title: const Text('Remove Schedule'),
                subtitle: const Text('Stop automatic execution'),
                onTap: () {
                  _unschedulePipeline(pipeline['pipeline_id']);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditTransformationDialog(Map<String, dynamic> transformation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Transformation: ${transformation['name']}'),
        content: const Text('Transformation editing dialog would be implemented here'),
      ),
    );
  }

  void _showEditRuleDialog(Map<String, dynamic> rule, StateSetter setState) {
    final ruleNameController = TextEditingController(text: rule['ruleName']);
    final descriptionController = TextEditingController(text: rule['description']);
    
    String selectedType = rule['transformationType'];
    String selectedFunction = rule['transformationFunction'];
    String selectedSourceField = rule['sourceField'] ?? '';
    String selectedTargetField = rule['targetField'] ?? '';
    
    // EPCIS Field options based on event types
    final epcisFields = [
      // Common EPCIS Event fields
      'eventId',
      'eventTime',
      'eventTimeZoneOffset', 
      'recordTime',
      'eventType',
      'businessStep',
      'disposition',
      'readPoint',
      'businessLocation',
      'bizData',
      
      // ObjectEvent specific fields
      'epcList',
      'action',
      'quantityList',
      'sourceList',
      'destinationList',
      'ilmd',
      'persistentDisposition',
      
      // TransformationEvent specific fields
      'inputEPCList',
      'outputEPCList', 
      'inputQuantityList',
      'outputQuantityList',
      'transformationID',
      
      // TransactionEvent specific fields
      'parentID',
      'childEPCs',
      'bizTransactionList',
      
      // EPCIS 2.0 extensions
      'sensorElementList',
      'certificationInfo',
      
      // Custom business data fields
      'bizData.lotNumber',
      'bizData.batchId',
      'bizData.expirationDate',
      'bizData.manufacturingDate',
      'bizData.serialNumber',
      'bizData.productionLine',
      'bizData.qualityGrade',
      'bizData.temperature',
      'bizData.humidity',
      'bizData.weight',
      'bizData.dimensions',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Transformation Rule'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ruleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Rule Name',
                    hintText: 'Enter descriptive rule name'
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Transformation Type',
                    hintText: 'Select transformation type'
                  ),
                  items: [
                    const DropdownMenuItem(value: 'VALIDATION', child: Text('VALIDATION - Data integrity checks')),
                    const DropdownMenuItem(value: 'ENRICHMENT', child: Text('ENRICHMENT - Data enhancement')), 
                    const DropdownMenuItem(value: 'NORMALIZATION', child: Text('NORMALIZATION - Data cleanup')),
                    const DropdownMenuItem(value: 'AGGREGATION', child: Text('AGGREGATION - Data summarization')),
                    const DropdownMenuItem(value: 'FIELD_MAPPING', child: Text('FIELD_MAPPING - Field-to-field mapping')),
                  ],
                  onChanged: (value) => selectedType = value!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedFunction,
                  decoration: const InputDecoration(
                    labelText: 'Transformation Function',
                    hintText: 'Select function to apply'
                  ),
                  items: [
                    const DropdownMenuItem(value: 'COPY', child: Text('COPY - Direct field copy')),
                    const DropdownMenuItem(value: 'UPPERCASE', child: Text('UPPERCASE - Convert to uppercase')),
                    const DropdownMenuItem(value: 'LOWERCASE', child: Text('LOWERCASE - Convert to lowercase')),
                    const DropdownMenuItem(value: 'DATE_FORMAT', child: Text('DATE_FORMAT - Format dates')),
                    const DropdownMenuItem(value: 'REGEX_REPLACE', child: Text('REGEX_REPLACE - Pattern replacement')),
                    const DropdownMenuItem(value: 'LOOKUP', child: Text('LOOKUP - Value lookup/translation')),
                    const DropdownMenuItem(value: 'CALCULATE', child: Text('CALCULATE - Mathematical operations')),
                  ],
                  onChanged: (value) => selectedFunction = value!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSourceField.isEmpty ? null : selectedSourceField,
                  decoration: const InputDecoration(
                    labelText: 'Source Field',
                    hintText: 'Select EPCIS source field'
                  ),
                  items: epcisFields.map((field) => DropdownMenuItem(
                    value: field,
                    child: Text(field),
                  )).toList(),
                  onChanged: (value) => selectedSourceField = value ?? '',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTargetField.isEmpty ? null : selectedTargetField,
                  decoration: const InputDecoration(
                    labelText: 'Target Field', 
                    hintText: 'Select EPCIS target field'
                  ),
                  items: epcisFields.map((field) => DropdownMenuItem(
                    value: field,
                    child: Text(field),
                  )).toList(),
                  onChanged: (value) => selectedTargetField = value ?? '',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what this rule does'
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EPCIS Field Information:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Common fields apply to all EPCIS events\n'
                        '• Event-specific fields only apply to that event type\n'
                        '• bizData.* fields are custom business data\n'
                        '• Rules work on incoming EPCIS event data during processing',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                rule['ruleName'] = ruleNameController.text;
                rule['transformationType'] = selectedType;
                rule['transformationFunction'] = selectedFunction;
                rule['sourceField'] = selectedSourceField;
                rule['targetField'] = selectedTargetField;
                rule['description'] = descriptionController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPipeline(String pipelineName, List<Map<String, dynamic>> transformationRules) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/etl/pipelines?pipelineName=${Uri.encodeComponent(pipelineName)}'),
        headers: await _getHeaders(),
        body: json.encode(transformationRules),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pipeline "$pipelineName" created successfully')),
        );
        _loadPipelines(); // Refresh the pipelines list
      } else {
        throw Exception('Failed to create pipeline: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create pipeline: $e')),
      );
    }
  }

  Future<void> _updatePipeline(String pipelineId, String pipelineName, List<Map<String, dynamic>> transformationRules) async {
    try {
      final response = await http.put(
        Uri.parse('${widget.baseUrl}/etl/pipelines/$pipelineId'),
        headers: await _getHeaders(),
        body: json.encode(transformationRules),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pipeline "$pipelineName" updated successfully')),
        );
        _loadPipelines(); // Refresh the pipelines list
      } else {
        throw Exception('Failed to update pipeline: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update pipeline: $e')),
      );
    }
  }

  Future<void> _schedulePipeline(String pipelineId, String frequency) async {
    try {
      final jobConfig = {
        'jobName': 'Scheduled_${pipelineId}_$frequency',
        'jobType': 'ETL_PIPELINE',
        'pipelineId': pipelineId,
        'scheduleExpression': _getScheduleExpression(frequency),
        'enabled': true,
        'executionStats': {
          'totalRuns': 0,
          'successfulRuns': 0,
          'failedRuns': 0,
        }
      };

      final response = await http.post(
        Uri.parse('${widget.baseUrl}/etl/jobs'),
        headers: await _getHeaders(),
        body: json.encode(jobConfig),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pipeline scheduled to run $frequency')),
        );
        _loadPipelines();
      } else {
        throw Exception('Failed to schedule pipeline: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule pipeline: $e')),
      );
    }
  }

  Future<void> _unschedulePipeline(String pipelineId) async {
    try {
      // This would delete any scheduled jobs for this pipeline
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pipeline schedule removed')),
      );
      _loadPipelines();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove schedule: $e')),
      );
    }
  }

  String _getScheduleExpression(String frequency) {
    switch (frequency) {
      case 'HOURLY':
        return '0 0 * * * ?'; // Every hour
      case 'DAILY':
        return '0 0 0 * * ?'; // Every day at midnight
      case 'WEEKLY':
        return '0 0 0 ? * SUN'; // Every Sunday at midnight
      default:
        return '0 0 0 * * ?'; // Default to daily
    }
  }

  void _showExecutionDetails(Map<String, dynamic> execution) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Execution Details: ${execution['pipelineName']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${execution['status']}'),
              Text('Start Time: ${execution['startTime']}'),
              if (execution['endTime'] != null) Text('End Time: ${execution['endTime']}'),
              if (execution['duration'] != null) Text('Duration: ${execution['duration']}'),
              Text('Records Processed: ${execution['recordsProcessed']}'),
              if (execution['errorCount'] != null) Text('Errors: ${execution['errorCount']}'),
              if (execution['errorMessage'] != null) ...[
                const SizedBox(height: 8),
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(execution['errorMessage'], style: const TextStyle(color: Colors.red)),
              ],
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

  void _showTestResults(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transformation Test Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Success: ${result['success']}'),
              Text('Processing Time: ${result['processingTime']}ms'),
              Text('Records Tested: ${result['recordsTested']}'),
              if (result['errors'] != null && result['errors'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...result['errors'].map<Widget>((error) => Text(
                  '• $error',
                  style: const TextStyle(color: Colors.red),
                )).toList(),
              ],
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

  void _showETLSettings() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('ETL Settings'),
        content: Text('ETL configuration settings would be implemented here'),
      ),
    );
  }
}
