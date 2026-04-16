import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../core/network/token_manager.dart';

/// Bulk Export Panel for Phase 3.3 Batch Processing Capabilities
/// Provides comprehensive bulk export management and monitoring interface
class BulkExportPanel extends StatefulWidget {
  final String baseUrl;
  final TokenManager tokenManager;

  const BulkExportPanel({
    Key? key,
    required this.baseUrl,
    required this.tokenManager,
  }) : super(key: key);

  @override
  BulkExportPanelState createState() => BulkExportPanelState();
}

class BulkExportPanelState extends State<BulkExportPanel> with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _refreshTimer;

  List<Map<String, dynamic>> _exportJobs = [];
  List<Map<String, dynamic>> _exportTemplates = [];
  List<Map<String, dynamic>> _exportHistory = [];
  Map<String, dynamic> _exportStats = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFormat = 'ALL';
  String _selectedStatus = 'ALL';

  final List<String> _exportFormats = ['ALL', 'CSV', 'JSON', 'XML', 'EPCIS', 'GS1_DIGITAL_LINK'];
  final List<String> _exportStatuses = ['ALL', 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        _loadExportJobs();
        break;
      case 1:
        _loadExportTemplates();
        break;
      case 2:
        _loadExportHistory();
        break;
      case 3:
        _loadExportStats();
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
        _loadExportJobs(),
        _loadExportTemplates(),
        _loadExportStats(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load export data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExportJobs() async {
    try {
      String url = '${widget.baseUrl}/bulk-export/jobs';
      List<String> params = [];

      if (_selectedFormat != 'ALL') {
        params.add('format=$_selectedFormat');
      }
      if (_selectedStatus != 'ALL') {
        params.add('status=$_selectedStatus');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _exportJobs = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading export jobs: $e');
    }
  }

  Future<void> _loadExportTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/bulk-export/templates'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _exportTemplates = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading export templates: $e');
    }
  }

  Future<void> _loadExportHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/bulk-export/history?limit=100'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _exportHistory = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading export history: $e');
    }
  }

  Future<void> _loadExportStats() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/bulk-export/statistics'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _exportStats = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading export stats: $e');
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
        _buildExportHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Export Jobs'),
                  Tab(text: 'Templates'),
                  Tab(text: 'History'),
                  Tab(text: 'Statistics'),
                ],
                onTap: (index) => _refreshCurrentTab(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExportJobsTab(),
                    _buildTemplatesTab(),
                    _buildHistoryTab(),
                    _buildStatisticsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportHeader() {
    final activeExports = _exportJobs.where((job) => job['status'] == 'PROCESSING').length;
    final pendingExports = _exportJobs.where((job) => job['status'] == 'PENDING').length;
    final failedExports = _exportJobs.where((job) => job['status'] == 'FAILED').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Export Status Overview
            Expanded(
              child: Row(
                children: [
                  _buildSummaryItem('Active', activeExports, Icons.play_circle, color: Colors.green),
                  const SizedBox(width: 24),
                  _buildSummaryItem('Pending', pendingExports, Icons.schedule, color: Colors.orange),
                  const SizedBox(width: 24),
                  _buildSummaryItem('Failed', failedExports, Icons.error, color: Colors.red),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreateExportDialog,
                  icon: const Icon(Icons.download),
                  label: const Text('New Export'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showBulkExportDialog,
                  icon: const Icon(Icons.archive),
                  label: const Text('Bulk Export'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _refreshCurrentTab,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  onPressed: _showExportSettings,
                  icon: const Icon(Icons.settings),
                  tooltip: 'Export Settings',
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

  Widget _buildExportJobsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Export Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildFormatFilter(),
              const SizedBox(width: 8),
              _buildStatusFilter(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _exportJobs.isEmpty
                ? const Center(child: Text('No export jobs found'))
                : ListView.builder(
                    itemCount: _exportJobs.length,
                    itemBuilder: (context, index) {
                      final job = _exportJobs[index];
                      return _buildExportJobCard(job);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Export Templates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateTemplateDialog,
                icon: const Icon(Icons.add),
                label: const Text('New Template'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _exportTemplates.isEmpty
                ? const Center(child: Text('No export templates found'))
                : ListView.builder(
                    itemCount: _exportTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _exportTemplates[index];
                      return _buildTemplateCard(template);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Export History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _exportHistory.isEmpty
                ? const Center(child: Text('No export history'))
                : ListView.builder(
                    itemCount: _exportHistory.length,
                    itemBuilder: (context, index) {
                      final export = _exportHistory[index];
                      return _buildHistoryCard(export);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Export Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildStatisticsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildExportJobCard(Map<String, dynamic> job) {
    final status = job['status'] ?? '';
    final format = job['format'] ?? '';
    final progress = job['progress'] ?? 0;
    // Extract record count from nested structure
    int recordCount = 0;
    if (job['execution_result'] != null && 
        job['execution_result']['export_result'] != null) {
      recordCount = job['execution_result']['export_result']['record_count'] ?? 0;
    }
    final createdAt = job['createdAt'] ?? '';
    final estimatedCompletion = job['estimatedCompletion'] ?? '';

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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getFormatColor(format),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    format,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['name'] ?? job['jobId'] ?? 'Unnamed Export',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job['job_id'] != null)
                        Text(
                          'ID: ${job['job_id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleJobAction(value, job),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'details', child: Text('View Details')),
                    if (status == 'SCHEDULED')
                      const PopupMenuItem(value: 'execute', child: Text('Execute Now')),
                    if (status == 'PROCESSING' || status == 'PENDING')
                      const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                    if (status == 'COMPLETED')
                      const PopupMenuItem(value: 'download', child: Text('Download')),
                    if (status == 'FAILED')
                      const PopupMenuItem(value: 'retry', child: Text('Retry')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (status == 'PROCESSING') ...[
              LinearProgressIndicator(
                value: progress / 100.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('$progress%'),
                  const Spacer(),
                  if (estimatedCompletion.isNotEmpty) Text('ETA: $estimatedCompletion'),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Records: ${_formatNumber(recordCount)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                if (createdAt.isNotEmpty)
                  Text(
                    'Created: $createdAt',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final name = template['name'] ?? '';
    final format = template['format'] ?? '';
    final description = template['description'] ?? '';
    final usageCount = template['usageCount'] ?? 0;
    final lastUsed = template['lastUsed'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getFormatColor(format),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            format,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) Text(description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Used $usageCount times'),
                if (lastUsed.isNotEmpty) ...[
                  const Text(' • '),
                  Text('Last: $lastUsed'),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _useTemplate(template),
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              tooltip: 'Use Template',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleTemplateAction(value, template),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                const PopupMenuItem(value: 'export', child: Text('Export Config')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> export) {
    final format = export['format'] ?? '';
    final status = export['status'] ?? '';
    // Extract record count from nested structure
    int recordCount = 0;
    if (export['execution_result'] != null && 
        export['execution_result']['export_result'] != null) {
      recordCount = export['execution_result']['export_result']['record_count'] ?? 0;
    }
    final createdAt = export['createdAt'] ?? '';
    final completedAt = export['completedAt'] ?? '';
    final duration = export['duration'] ?? '';
    // Extract file size from nested structure
    int fileSize = 0;
    if (export['execution_result'] != null && 
        export['execution_result']['export_result'] != null) {
      fileSize = export['execution_result']['export_result']['file_size'] ?? 0;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getFormatColor(format),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            format,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(export['name'] ?? export['jobId'] ?? 'Unnamed Export')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(8),
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
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Records: ${_formatNumber(recordCount)} • Size: ${_formatFileSize(fileSize)}'),
            if (duration.isNotEmpty) Text('Duration: $duration'),
            Row(
              children: [
                Text('Created: $createdAt'),
                if (completedAt.isNotEmpty) ...[
                  const Text(' • '),
                  Text('Completed: $completedAt'),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'COMPLETED')
              IconButton(
                onPressed: () => _downloadExport(export['job_id'] ?? export['jobId'] ?? ''),
                icon: const Icon(Icons.download, color: Colors.blue),
                tooltip: 'Download',
              ),
            IconButton(
              onPressed: () => _showExportDetails(export),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Details',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final totalExports = _exportStats['totalExports'] ?? 0;
    final successfulExports = _exportStats['successfulExports'] ?? 0;
    final failedExports = _exportStats['failedExports'] ?? 0;
    final totalRecords = _exportStats['totalRecords'] ?? 0;
    final totalSize = _exportStats['totalSize'] ?? 0;
    final avgExportTime = _exportStats['avgExportTime'] ?? 0.0;
    final formatDistribution = _exportStats['formatDistribution'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      child: Column(
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Exports', totalExports.toString(), Icons.archive),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Success Rate', '${((successfulExports / (totalExports > 0 ? totalExports : 1)) * 100).toStringAsFixed(1)}%', Icons.check_circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Records', _formatNumber(totalRecords), Icons.storage),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Total Size', _formatFileSize(totalSize), Icons.file_present),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Avg Export Time', '${avgExportTime.toStringAsFixed(1)}s', Icons.timer),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Failed Exports', failedExports.toString(), Icons.error),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Format Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export Format Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...formatDistribution.entries.map((entry) {
                    final format = entry.key;
                    final count = entry.value;
                    final percentage = totalExports > 0 ? (count / totalExports) * 100 : 0.0;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getFormatColor(format),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Text(format),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(_getFormatColor(format)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text('$count (${percentage.toStringAsFixed(1)}%)'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildFormatFilter() {
    return DropdownButton<String>(
      value: _selectedFormat,
      items: _exportFormats.map((format) {
        return DropdownMenuItem(
          value: format,
          child: Text(format),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedFormat = value!;
        });
        _loadExportJobs();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButton<String>(
      value: _selectedStatus,
      items: _exportStatuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
        _loadExportJobs();
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      case 'PENDING':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getFormatColor(String format) {
    switch (format) {
      case 'CSV':
        return Colors.green;
      case 'JSON':
        return Colors.blue;
      case 'XML':
        return Colors.purple;
      case 'EPCIS':
        return Colors.orange;
      case 'GS1_DIGITAL_LINK':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  void _handleJobAction(String action, Map<String, dynamic> job) {
    final jobId = job['job_id'] ?? job['jobId'] ?? '';
    switch (action) {
      case 'details':
        _showExportDetails(job);
        break;
      case 'execute':
        _executeExportJob(jobId);
        break;
      case 'cancel':
        _cancelExport(jobId);
        break;
      case 'download':
        _downloadExport(jobId);
        break;
      case 'retry':
        _retryExport(jobId);
        break;
      case 'delete':
        _deleteExport(jobId);
        break;
    }
  }

  void _handleTemplateAction(String action, Map<String, dynamic> template) {
    switch (action) {
      case 'edit':
        _showEditTemplateDialog(template);
        break;
      case 'duplicate':
        _duplicateTemplate(template['id']);
        break;
      case 'export':
        _exportTemplateConfig(template['id']);
        break;
      case 'delete':
        _deleteTemplate(template['id']);
        break;
    }
  }

  void _showEditTemplateDialog(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Template: ${template['name']}'),
        content: const Text('Template editing dialog would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelExport(String jobId) async {
    try {
      final response = await http.delete(
        Uri.parse('${widget.baseUrl}/bulk-export/jobs/$jobId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export cancelled successfully')),
        );
        _loadExportJobs();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel export: $e')),
      );
    }
  }

  Future<void> _downloadExport(String jobId) async {
    try {
      // First get the job details to find the file ID
      final jobResponse = await http.get(
        Uri.parse('${widget.baseUrl}/bulk-export/jobs'),
        headers: await _getHeaders(),
      );

      if (jobResponse.statusCode == 200) {
        final jobs = List<Map<String, dynamic>>.from(json.decode(jobResponse.body));
        final job = jobs.firstWhere((j) => j['job_id'] == jobId, orElse: () => {});
        
        if (job.isNotEmpty &&
            job['execution_result']?['export_result']?['file_id'] != null) {
          final fileId = job['execution_result']['export_result']['file_id'];

          // Use the file download endpoint from the API response
          final downloadUrl = job['execution_result']['export_result']['download_url'];
          final response = await http.get(
            Uri.parse('${widget.baseUrl}$downloadUrl'),
            headers: await _getHeaders(),
          );

          if (response.statusCode == 200) {
            // In a real implementation, this would trigger file download
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download started for file: $fileId'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No export file available for download'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download export: $e')),
      );
    }
  }

  Future<void> _retryExport(String jobId) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/bulk-export/jobs/$jobId/retry'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export retry started')),
        );
        _loadExportJobs();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retry export: $e')),
      );
    }
  }

  Future<void> _executeExportJob(String jobId) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/bulk-export/jobs/$jobId/execute'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export job executed successfully: ${result['status']}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadExportJobs();
      } else {
        throw Exception('Failed to execute export job');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to execute export job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteExport(String jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Export'),
        content: const Text('Are you sure you want to delete this export job?'),
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
          Uri.parse('${widget.baseUrl}/bulk-export/jobs/$jobId/delete'),
          headers: await _getHeaders(),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export deleted successfully')),
          );
          _loadExportJobs();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete export: $e')),
        );
      }
    }
  }

  Future<void> _useTemplate(Map<String, dynamic> template) async {
    _showCreateExportDialog(templateId: template['id']);
  }

  Future<void> _duplicateTemplate(String templateId) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/bulk-export/templates/$templateId/duplicate'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template duplicated successfully')),
        );
        _loadExportTemplates();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to duplicate template: $e')),
      );
    }
  }

  Future<void> _exportTemplateConfig(String templateId) async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/bulk-export/templates/$templateId/export'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template configuration exported')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export template: $e')),
      );
    }
  }

  Future<void> _deleteTemplate(String templateId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('Are you sure you want to delete this template?'),
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
          Uri.parse('${widget.baseUrl}/bulk-export/templates/$templateId'),
          headers: await _getHeaders(),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted successfully')),
          );
          _loadExportTemplates();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete template: $e')),
        );
      }
    }
  }

  void _showCreateExportDialog({String? templateId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateExportDialog(
        initialTemplateId: templateId,
        onExportCreated: _refreshData,
        baseUrl: widget.baseUrl,
        tokenManager: widget.tokenManager,
      ),
    );
  }

  void _showBulkExportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BulkExportDialog(
        onExportCreated: _refreshData,
        baseUrl: widget.baseUrl,
        tokenManager: widget.tokenManager,
      ),
    );
  }

  void _refreshData() {
    _loadInitialData();
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Create Export Template'),
        content: Text('Template creation dialog would be implemented here'),
      ),
    );
  }

  void _showExportDetails(Map<String, dynamic> export) {
    // Extract values from nested structure
    int recordCount = 0;
    int fileSize = 0;
    if (export['execution_result'] != null && 
        export['execution_result']['export_result'] != null) {
      final exportResult = export['execution_result']['export_result'];
      recordCount = exportResult['record_count'] ?? 0;
      fileSize = exportResult['file_size'] ?? 0;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Details: ${export['job_id'] ?? export['jobId']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${export['status']}'),
              Text('Format: ${export['format']}'),
              Text('Record Count: $recordCount'),
              if (fileSize > 0) Text('File Size: ${_formatFileSize(fileSize)}'),
              Text('Created: ${export['created_at'] ?? export['createdAt']}'),
              if (export['last_executed_at'] != null) Text('Last Executed: ${export['last_executed_at']}'),
              if (export['execution_result']?['execution_time_ms'] != null) 
                Text('Execution Time: ${export['execution_result']['execution_time_ms']} ms'),
              if (export['execution_result']?['status'] == 'FAILED') ...[
                const SizedBox(height: 8),
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(export['execution_result']['error_message'] ?? 'Unknown error', 
                     style: const TextStyle(color: Colors.red)),
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

  void _showExportSettings() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Export Settings'),
        content: Text('Export configuration settings would be implemented here'),
      ),
    );
  }
}

// Create Export Dialog Widget
class CreateExportDialog extends StatefulWidget {
  final String? initialTemplateId;
  final VoidCallback onExportCreated;
  final String baseUrl;
  final TokenManager tokenManager;

  const CreateExportDialog({
    Key? key,
    this.initialTemplateId,
    required this.onExportCreated,
    required this.baseUrl,
    required this.tokenManager,
  }) : super(key: key);

  @override
  State<CreateExportDialog> createState() => _CreateExportDialogState();
}

class _CreateExportDialogState extends State<CreateExportDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTemplateId;
  String _exportName = '';
  String _selectedFormat = 'EPCIS_JSON_LD';
  Map<String, dynamic> _exportConfig = {};
  bool _isLoading = false;
  List<dynamic> _templates = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _availableFormats = [
    'EPCIS_XML',
    'EPCIS_JSON_LD',
    'CSV',
    'PDF',
    'EXCEL',
    'HTML'
  ];

  @override
  void initState() {
    super.initState();
    _selectedTemplateId = widget.initialTemplateId;
    
    // Set default date range to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
    
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final token = await widget.tokenManager.getToken();
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/bulk-export/templates'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _templates = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error loading templates: $e');
    }
  }

  Future<void> _createExport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> exportData;

      if (_selectedTemplateId != null) {
        // Prepare parameters for template application
        Map<String, dynamic> templateParams = {
          'name': _exportName,
          'format': _selectedFormat,
          ..._exportConfig,
        };
        
        // Add date range if specified
        if (_startDate != null && _endDate != null) {
          templateParams['start_date'] = _startDate!.toIso8601String();
          templateParams['end_date'] = _endDate!.toIso8601String();
        } else {
          // Set default date range to last 30 days if no dates specified
          final now = DateTime.now();
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          templateParams['start_date'] = thirtyDaysAgo.toIso8601String();
          templateParams['end_date'] = now.toIso8601String();
        }
        
        // Use template
        final token = await widget.tokenManager.getToken();
        final response = await http.post(
          Uri.parse('${widget.baseUrl}/bulk-export/templates/$_selectedTemplateId/apply'),
          headers: {
            'Authorization': 'Bearer ${token ?? ''}',
            'Content-Type': 'application/json',
          },
          body: json.encode(templateParams),
        );

        if (response.statusCode == 201) {
          exportData = json.decode(response.body);
        } else {
          throw Exception('Failed to create export from template');
        }
      } else {
        // Create custom export job
        final token = await widget.tokenManager.getToken();
        final response = await http.post(
          Uri.parse('${widget.baseUrl}/bulk-export/jobs'),
          headers: {
            'Authorization': 'Bearer ${token ?? ''}',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': _exportName,
            'format': _selectedFormat,
            'configuration': _exportConfig,
            'schedule': null, // One-time export
          }),
        );

        if (response.statusCode == 201) {
          exportData = json.decode(response.body);
        } else {
          throw Exception('Failed to create export job');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onExportCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export "${exportData['name']}" created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTemplateId != null ? 'Create Export from Template' : 'Create New Export'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Export Name
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Export Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Please enter export name' : null,
                  onChanged: (value) => _exportName = value,
                ),
                const SizedBox(height: 16),

                // Template Selection (if not pre-selected)
                if (widget.initialTemplateId == null) ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Template (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTemplateId,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No Template (Custom Export)'),
                      ),
                      ..._templates.map<DropdownMenuItem<String>>((template) {
                        return DropdownMenuItem<String>(
                          value: template['id'],
                          child: Text(template['name']),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) => setState(() => _selectedTemplateId = value),
                  ),
                  const SizedBox(height: 16),
                ],

                // Format Selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Export Format',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedFormat,
                  items: _availableFormats.map<DropdownMenuItem<String>>((format) {
                    return DropdownMenuItem<String>(
                      value: format,
                      child: Text(format.replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedFormat = value!),
                ),
                const SizedBox(height: 16),

                // Date Range Selection
                const Text(
                  'Date Range (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Start Date
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _startDate?.toString().substring(0, 10) ?? '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // End Date
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _endDate?.toString().substring(0, 10) ?? '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _endDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _startDate != null && _endDate != null
                    ? 'Selected: ${_startDate!.toLocal().toString().split(' ')[0]} to ${_endDate!.toLocal().toString().split(' ')[0]}'
                    : 'Default: Last 30 days will be used',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Configuration Options
                ExpansionTile(
                  title: const Text('Advanced Configuration'),
                  children: [
                    SwitchListTile(
                      title: const Text('Include Headers'),
                      value: _exportConfig['include_headers'] ?? true,
                      onChanged: (value) => setState(() => _exportConfig['include_headers'] = value),
                    ),
                    SwitchListTile(
                      title: const Text('Validate Schema'),
                      value: _exportConfig['validate_schema'] ?? false,
                      onChanged: (value) => setState(() => _exportConfig['validate_schema'] = value),
                    ),
                    SwitchListTile(
                      title: const Text('Compress Output'),
                      value: _exportConfig['compression'] != null,
                      onChanged: (value) => setState(() => 
                        _exportConfig['compression'] = value ? 'gzip' : null),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createExport,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Export'),
        ),
      ],
    );
  }
}

// Bulk Export Dialog Widget
class BulkExportDialog extends StatefulWidget {
  final VoidCallback onExportCreated;
  final String baseUrl;
  final TokenManager tokenManager;

  const BulkExportDialog({
    Key? key,
    required this.onExportCreated,
    required this.baseUrl,
    required this.tokenManager,
  }) : super(key: key);

  @override
  State<BulkExportDialog> createState() => _BulkExportDialogState();
}

class _BulkExportDialogState extends State<BulkExportDialog> {
  final _formKey = GlobalKey<FormState>();
  String _exportName = '';
  String _selectedFormat = 'EPCIS_JSON_LD';
  String _exportType = 'streaming';
  Map<String, dynamic> _queryParams = {};
  Map<String, dynamic> _config = {};
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _pageSize = 1000;

  final List<String> _availableFormats = [
    'EPCIS_XML',
    'EPCIS_JSON_LD',
    'CSV',
    'PDF',
    'EXCEL',
  ];

  Future<void> _createBulkExport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare query parameters
      Map<String, dynamic> queryData = {
        'name': _exportName,
        ..._queryParams,
      };

      if (_startDate != null && _endDate != null) {
        queryData['start_date'] = _startDate!.toIso8601String();
        queryData['end_date'] = _endDate!.toIso8601String();
      }

      // Choose API endpoint based on export type
      String endpoint;
      Map<String, dynamic> requestBody;

      if (_exportType == 'streaming') {
        endpoint = '${widget.baseUrl}/bulk-export/streaming';
        requestBody = queryData;
      } else {
        endpoint = '${widget.baseUrl}/bulk-export/paginated';
        requestBody = queryData;
      }

      final token = await widget.tokenManager.getToken();
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final exportData = json.decode(response.body);

        if (mounted) {
          Navigator.of(context).pop();
          widget.onExportCreated();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bulk export session "${exportData['session_id']}" created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to create bulk export');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating bulk export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Bulk Export'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Export Name
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Export Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Please enter export name' : null,
                  onChanged: (value) => _exportName = value,
                ),
                const SizedBox(height: 16),

                // Export Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Export Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _exportType,
                  items: const [
                    DropdownMenuItem(value: 'streaming', child: Text('Streaming Export')),
                    DropdownMenuItem(value: 'paginated', child: Text('Paginated Export')),
                  ],
                  onChanged: (value) => setState(() => _exportType = value!),
                ),
                const SizedBox(height: 16),

                // Format Selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Export Format',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedFormat,
                  items: _availableFormats.map<DropdownMenuItem<String>>((format) {
                    return DropdownMenuItem<String>(
                      value: format,
                      child: Text(format.replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedFormat = value!),
                ),
                const SizedBox(height: 16),

                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _startDate?.toString().substring(0, 10) ?? '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _endDate?.toString().substring(0, 10) ?? '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _endDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Page Size (for paginated exports)
                if (_exportType == 'paginated') ...[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Page Size',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _pageSize.toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final intValue = int.tryParse(value ?? '');
                      if (intValue == null || intValue < 1 || intValue > 10000) {
                        return 'Please enter a valid page size (1-10000)';
                      }
                      return null;
                    },
                    onChanged: (value) => _pageSize = int.tryParse(value) ?? 1000,
                  ),
                  const SizedBox(height: 16),
                ],

                // Advanced Options
                ExpansionTile(
                  title: const Text('Advanced Options'),
                  children: [
                    SwitchListTile(
                      title: const Text('Include Metadata'),
                      value: _config['include_metadata'] ?? true,
                      onChanged: (value) => setState(() => _config['include_metadata'] = value),
                    ),
                    SwitchListTile(
                      title: const Text('Compress Output'),
                      value: _config['compression'] != null,
                      onChanged: (value) => setState(() => 
                        _config['compression'] = value ? 'gzip' : null),
                    ),
                    SwitchListTile(
                      title: const Text('Include Signatures'),
                      value: _config['include_signatures'] ?? false,
                      onChanged: (value) => setState(() => _config['include_signatures'] = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createBulkExport,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Bulk Export'),
        ),
      ],
    );
  }
}
