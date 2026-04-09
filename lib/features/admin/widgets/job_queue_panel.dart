import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart' as web_download;
import '../../../core/network/token_manager.dart';

/// Job Queue Panel for Phase 3.3 Batch Processing Capabilities
/// Provides comprehensive job queue monitoring and management interface
class JobQueuePanel extends StatefulWidget {
  final String baseUrl;
  final TokenManager tokenManager;

  const JobQueuePanel({
    Key? key,
    required this.baseUrl,
    required this.tokenManager,
  }) : super(key: key);

  @override
  JobQueuePanelState createState() => JobQueuePanelState();
}

class JobQueuePanelState extends State<JobQueuePanel> with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _refreshTimer;
  
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _activeJobs = [];
  List<Map<String, dynamic>> _queuedJobs = [];
  List<Map<String, dynamic>> _jobHistory = [];
  Map<String, dynamic> _workerPoolStats = {};
  Map<String, dynamic> _queueHealth = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedJobType = 'ALL';
  String _selectedStatus = 'ALL';

  final List<String> _jobTypes = ['ALL', 'ETL', 'EXPORT', 'BULK_IMPORT', 'NOTIFICATION_BATCH'];
  final List<String> _jobStatuses = ['ALL', 'QUEUED', 'RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED'];

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _refreshCurrentTab();
      }
    });
  }

  void _refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _loadDashboardData();
        break;
      case 1:
        _loadActiveJobs();
        break;
      case 2:
        _loadQueuedJobs();
        break;
      case 3:
        _loadJobHistory();
        break;
      case 4:
        _loadWorkerPoolStats();
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
        _loadDashboardData(),
        _loadActiveJobs(),
        _loadQueueHealth(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load job queue data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/jobs/dashboard'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  Future<void> _loadActiveJobs() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/jobs/active'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _activeJobs = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading active jobs: $e');
    }
  }

  Future<void> _loadQueuedJobs() async {
    try {
      String url = '${widget.baseUrl}/jobs/queue?limit=100';
      if (_selectedStatus != 'ALL') {
        url += '&status=$_selectedStatus';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _queuedJobs = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading queued jobs: $e');
    }
  }

  Future<void> _loadJobHistory() async {
    try {
      String url = '${widget.baseUrl}/jobs/history?limit=100';
      if (_selectedJobType != 'ALL') {
        url += '&jobType=$_selectedJobType';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _jobHistory = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      debugPrint('Error loading job history: $e');
    }
  }

  Future<void> _loadWorkerPoolStats() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/jobs/worker-pool/stats'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _workerPoolStats = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading worker pool stats: $e');
    }
  }

  Future<void> _loadQueueHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/jobs/health'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _queueHealth = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading queue health: $e');
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildJobQueueHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                // Enhanced Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.indigo.shade600,
                    indicatorWeight: 3,
                    labelColor: Colors.indigo.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.dashboard),
                        text: 'Dashboard',
                      ),
                      Tab(
                        icon: Icon(Icons.play_circle_filled),
                        text: 'Active Jobs',
                      ),
                      Tab(
                        icon: Icon(Icons.queue),
                        text: 'Queue',
                      ),
                      Tab(
                        icon: Icon(Icons.history),
                        text: 'History',
                      ),
                      Tab(
                        icon: Icon(Icons.groups),
                        text: 'Workers',
                      ),
                    ],
                    onTap: (index) => _refreshCurrentTab(),
                  ),
                ),
                // Tab Content
                Expanded(
                  child: Container(
                    color: Colors.grey.shade50,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDashboardTab(),
                        _buildActiveJobsTab(),
                        _buildQueueTab(),
                        _buildHistoryTab(),
                        _buildWorkerPoolTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobQueueHeader() {
    final bool isHealthy = _queueHealth['healthy'] ?? true;
    final int queuedJobs = _dashboardData['queuedJobs'] ?? 0;
    final int activeJobs = _dashboardData['activeJobs'] ?? 0;
    final bool processingPaused = _dashboardData['processingPaused'] ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Health Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.error,
                    color: isHealthy ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isHealthy ? 'Healthy' : 'Issues',
                    style: TextStyle(
                      color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Queue Summary
            Expanded(
              child: Row(
                children: [
                  _buildSummaryItem('Queued', queuedJobs, Icons.queue),
                  const SizedBox(width: 24),
                  _buildSummaryItem('Active', activeJobs, Icons.play_circle_fill),
                  const SizedBox(width: 24),
                  _buildSummaryItem(
                    'Status', 
                    processingPaused ? 'Paused' : 'Running',
                    processingPaused ? Icons.pause_circle : Icons.play_circle,
                    color: processingPaused ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ),
            
            // Control Buttons
            Row(
              children: [
                IconButton(
                  onPressed: _refreshCurrentTab,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  onPressed: _showControlPanel,
                  icon: const Icon(Icons.settings),
                  tooltip: 'Control Panel',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic value, IconData icon, {Color? color}) {
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

  Widget _buildDashboardTab() {
    final priorityDistribution = _dashboardData['priorityDistribution'] as Map<String, dynamic>? ?? {};
    final jobTypeDistribution = _dashboardData['jobTypeDistribution'] as Map<String, dynamic>? ?? {};
    final workerPool = _dashboardData['workerPool'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Action Bar with better visibility
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title with better styling
                Text(
                  'Job Queue Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                // Enhanced Action Buttons
                Row(
                  children: [
                    // Schedule Job Button - More Prominent
                    ElevatedButton.icon(
                      onPressed: _showScheduleJobDialog,
                      icon: Icon(Icons.schedule, color: Colors.white),
                      label: Text(
                        'Schedule Job',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Refresh Button - Better Styling
                    ElevatedButton.icon(
                      onPressed: _loadJobData,
                      icon: Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Settings Button
                    IconButton(
                      onPressed: () => _showQueueSettings(),
                      icon: Icon(Icons.settings, color: Colors.indigo.shade600),
                      tooltip: 'Queue Settings',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Enhanced Status Cards
          Row(
            children: [
              // Active Jobs Card
              Expanded(
                child: _buildEnhancedStatusCard(
                  'Active Jobs',
                  '${_activeJobs.length}',
                  Icons.play_circle_filled,
                  Colors.green.shade600,
                  Colors.green.shade50,
                ),
              ),
              SizedBox(width: 12),
              // Queued Jobs Card
              Expanded(
                child: _buildEnhancedStatusCard(
                  'Queued Jobs',
                  '${_queuedJobs.length}',
                  Icons.queue,
                  Colors.orange.shade600,
                  Colors.orange.shade50,
                ),
              ),
              SizedBox(width: 12),
              // Total Jobs Card
              Expanded(
                child: _buildEnhancedStatusCard(
                  'Total Jobs',
                  '${_activeJobs.length + _queuedJobs.length + _jobHistory.length}',
                  Icons.work,
                  Colors.blue.shade600,
                  Colors.blue.shade50,
                ),
              ),
              SizedBox(width: 12),
              // Worker Pool Card
              Expanded(
                child: _buildEnhancedStatusCard(
                  'Workers',
                  '${_workerPoolStats['active'] ?? 0}/${_workerPoolStats['total'] ?? 0}',
                  Icons.groups,
                  Colors.purple.shade600,
                  Colors.purple.shade50,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Enhanced Queue Health Status
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.teal.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Queue Health Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    // Health Indicator
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getHealthColor(),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getHealthColor().withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${_dashboardData['queue_health'] ?? 'Healthy'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Spacer(),
                    // Performance Metrics
                    Text(
                      'Avg Processing: ${_dashboardData['avg_processing_time'] ?? 'N/A'}ms',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Original Charts Row
          Row(
            children: [
              Expanded(
                child: _buildPriorityChart(priorityDistribution),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildJobTypeChart(jobTypeDistribution),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWorkerPoolSummary(workerPool),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQueueHealthCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Active Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('${_activeJobs.length} jobs running'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _activeJobs.isEmpty
                ? const Center(child: Text('No active jobs'))
                : ListView.builder(
                    itemCount: _activeJobs.length,
                    itemBuilder: (context, index) {
                      final job = _activeJobs[index];
                      return _buildActiveJobCard(job);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Job Queue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildStatusFilter(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _queuedJobs.isEmpty
                ? const Center(child: Text('No jobs in queue'))
                : ListView.builder(
                    itemCount: _queuedJobs.length,
                    itemBuilder: (context, index) {
                      final job = _queuedJobs[index];
                      return _buildQueuedJobCard(job);
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
          Row(
            children: [
              const Text(
                'Job History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildJobTypeFilter(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _jobHistory.isEmpty
                ? const Center(child: Text('No job history'))
                : ListView.builder(
                    itemCount: _jobHistory.length,
                    itemBuilder: (context, index) {
                      final job = _jobHistory[index];
                      return _buildHistoryJobCard(job);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerPoolTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Worker Pool Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showWorkerPoolConfig,
                icon: const Icon(Icons.settings),
                label: const Text('Configure'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildWorkerPoolDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(Map<String, dynamic> job) {
    final progress = job['progress'] ?? 0;
    final jobType = job['jobType'] ?? '';
    final status = job['status'] ?? '';
    final startTime = job['startTime'] ?? '';
    final elapsedTime = job['elapsedTime'] ?? '';

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
                    color: _getJobTypeColor(jobType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    jobType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  job['jobId'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'Priority ${job['priority'] ?? 5}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _cancelJob(job['jobId']),
                  icon: const Icon(Icons.stop, color: Colors.red),
                  tooltip: 'Cancel Job',
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                if (elapsedTime.isNotEmpty) Text('Elapsed: $elapsedTime'),
              ],
            ),
            if (startTime.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Started: $startTime',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueuedJobCard(Map<String, dynamic> job) {
    final jobType = job['jobType'] ?? '';
    final priority = job['priority'] ?? 5;
    final queuePosition = job['queuePosition'] ?? 0;
    final submittedTime = job['submittedTime'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getJobTypeColor(jobType),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            jobType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(job['jobId'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: $priority | Position: $queuePosition'),
            if (submittedTime.isNotEmpty)
              Text(
                'Submitted: $submittedTime',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showJobDetails(job),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Job Details',
            ),
            IconButton(
              onPressed: () => _cancelJob(job['jobId']),
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'Cancel Job',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryJobCard(Map<String, dynamic> job) {
    final jobType = job['jobType'] ?? '';
    final status = job['status'] ?? '';
    final executionTime = job['executionTime'] ?? '';
    final endTime = job['endTime'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getJobTypeColor(jobType),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            jobType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(job['jobId'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                const SizedBox(width: 8),
                if (executionTime.isNotEmpty) Text('Duration: $executionTime'),
              ],
            ),
            if (endTime.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Completed: $endTime',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showJobDetails(job),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Job Details',
            ),
            if (status == 'FAILED')
              IconButton(
                onPressed: () => _retryJob(job['jobId']),
                icon: const Icon(Icons.refresh, color: Colors.orange),
                tooltip: 'Retry Job',
              ),
            if (status == 'COMPLETED' && (jobType == 'DATA_EXPORT' || jobType == 'EXPORT'))
              IconButton(
                onPressed: () => _downloadJobResult(job['jobId']),
                icon: const Icon(Icons.download, color: Colors.green),
                tooltip: 'Download Result',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButton<String>(
      value: _selectedStatus,
      items: _jobStatuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
        _loadQueuedJobs();
      },
    );
  }

  Widget _buildJobTypeFilter() {
    return DropdownButton<String>(
      value: _selectedJobType,
      items: _jobTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedJobType = value!;
        });
        _loadJobHistory();
      },
    );
  }

  Widget _buildPriorityChart(Map<String, dynamic> priorityDistribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...priorityDistribution.entries.map((entry) {
              final priority = entry.key;
              final count = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text('P$priority:'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: count > 0 ? count / 10.0 : 0.0,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text('$count'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeChart(Map<String, dynamic> jobTypeDistribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Type Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...jobTypeDistribution.entries.map((entry) {
              final jobType = entry.key;
              final count = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getJobTypeColor(jobType),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(jobType)),
                    Text('$count'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerPoolSummary(Map<String, dynamic> workerPool) {
    final activeThreads = workerPool['activeThreads'] ?? 0;
    final poolSize = workerPool['poolSize'] ?? 0;
    final maxPoolSize = workerPool['maxPoolSize'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Worker Pool',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Active Threads: $activeThreads'),
            Text('Pool Size: $poolSize'),
            Text('Max Pool Size: $maxPoolSize'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: maxPoolSize > 0 ? activeThreads / maxPoolSize : 0.0,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                activeThreads / maxPoolSize > 0.8 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueHealthCard() {
    final healthy = _queueHealth['healthy'] ?? true;
    final issues = _queueHealth['issues'] as List? ?? [];
    final queueSize = _queueHealth['queueSize'] ?? 0;
    final queueCapacity = _queueHealth['queueCapacity'] ?? 1000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Queue Health',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(
                  healthy ? Icons.check_circle : Icons.warning,
                  color: healthy ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Queue Size: $queueSize / $queueCapacity'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: queueCapacity > 0 ? queueSize / queueCapacity : 0.0,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                queueSize / queueCapacity > 0.8 ? Colors.red : Colors.green,
              ),
            ),
            if (issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Issues:', style: TextStyle(fontWeight: FontWeight.w600)),
              ...issues.map((issue) => Text(
                '• $issue',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerPoolDetails() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2,
      children: [
        _buildStatCard('Active Count', _workerPoolStats['activeCount']?.toString() ?? '0'),
        _buildStatCard('Pool Size', _workerPoolStats['poolSize']?.toString() ?? '0'),
        _buildStatCard('Core Pool Size', _workerPoolStats['corePoolSize']?.toString() ?? '0'),
        _buildStatCard('Max Pool Size', _workerPoolStats['maximumPoolSize']?.toString() ?? '0'),
        _buildStatCard('Queue Size', _workerPoolStats['queueSize']?.toString() ?? '0'),
        _buildStatCard('Completed Tasks', _workerPoolStats['completedTaskCount']?.toString() ?? '0'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getJobTypeColor(String jobType) {
    switch (jobType) {
      case 'ETL':
        return Colors.purple;
      case 'EXPORT':
        return Colors.blue;
      case 'BULK_IMPORT':
        return Colors.green;
      case 'NOTIFICATION_BATCH':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'RUNNING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      case 'QUEUED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelJob(String jobId) async {
    try {
      final response = await http.delete(
        Uri.parse('${widget.baseUrl}/jobs/$jobId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job cancelled successfully')),
        );
        _refreshCurrentTab();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel job: $e')),
      );
    }
  }

  Future<void> _retryJob(String jobId) async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/jobs/$jobId/retry'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job resubmitted successfully')),
        );
        _refreshCurrentTab();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retry job: $e')),
      );
    }
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Job Details: ${job['jobId']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Job Type: ${job['jobType']}'),
              Text('Status: ${job['status']}'),
              Text('Priority: ${job['priority']}'),
              if (job['submittedTime'] != null) Text('Submitted: ${job['submittedTime']}'),
              if (job['startTime'] != null) Text('Started: ${job['startTime']}'),
              if (job['endTime'] != null) Text('Completed: ${job['endTime']}'),
              if (job['executionTime'] != null) Text('Duration: ${job['executionTime']}'),
              if (job['progress'] != null) Text('Progress: ${job['progress']}%'),
              if (job['errorMessage'] != null) ...[
                const SizedBox(height: 8),
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(job['errorMessage'], style: const TextStyle(color: Colors.red)),
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

  void _showControlPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Job Queue Control Panel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('Pause Processing'),
              onTap: () {
                Navigator.of(context).pop();
                _pauseProcessing();
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Resume Processing'),
              onTap: () {
                Navigator.of(context).pop();
                _resumeProcessing();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configure Worker Pool'),
              onTap: () {
                Navigator.of(context).pop();
                _showWorkerPoolConfig();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Purge Old Jobs'),
              onTap: () {
                Navigator.of(context).pop();
                _showPurgeDialog();
              },
            ),
          ],
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

  void _showWorkerPoolConfig() {
    // Implementation for worker pool configuration dialog
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Worker Pool Configuration'),
        content: Text('Worker pool configuration dialog would be implemented here'),
      ),
    );
  }

  void _showPurgeDialog() {
    // Implementation for purge old jobs dialog
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Purge Old Jobs'),
        content: Text('Purge old jobs dialog would be implemented here'),
      ),
    );
  }

  Future<void> _pauseProcessing() async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/jobs/pause'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job processing paused')),
        );
        _loadDashboardData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pause processing: $e')),
      );
    }
  }

  Future<void> _resumeProcessing() async {
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/jobs/resume'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job processing resumed')),
        );
        _loadDashboardData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resume processing: $e')),
      );
    }
  }

  // Enhanced UI Helper Methods
  Widget _buildEnhancedStatusCard(String title, String value, IconData icon, Color primaryColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor() {
    String health = _dashboardData['queue_health'] ?? 'Healthy';
    switch (health.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  void _showQueueSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.settings, color: Colors.indigo.shade600),
              SizedBox(width: 8),
              Text('Queue Settings'),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Worker Pool Settings
                ListTile(
                  leading: Icon(Icons.groups, color: Colors.purple.shade600),
                  title: Text('Worker Pool Size'),
                  subtitle: Text('Current: ${_workerPoolStats['total'] ?? 0} workers'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implement worker pool configuration
                  },
                ),
                Divider(),
                // Queue Limits
                ListTile(
                  leading: Icon(Icons.queue, color: Colors.orange.shade600),
                  title: Text('Queue Limits'),
                  subtitle: Text('Max queue size and priority settings'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implement queue limit configuration
                  },
                ),
                Divider(),
                // Auto-refresh Settings
                ListTile(
                  leading: Icon(Icons.refresh, color: Colors.blue.shade600),
                  title: Text('Auto Refresh'),
                  subtitle: Text('Currently: Every 5 seconds'),
                  trailing: Switch(
                    value: true, // You can make this dynamic
                    onChanged: (value) {
                      // Implement auto-refresh toggle
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Save settings
              },
              child: Text('Save Settings'),
            ),
          ],
        );
      },
    );
  }

  void _loadJobData() {
    _loadInitialData();
  }

  void _showScheduleJobDialog() {
    String selectedJobType = 'DATA_EXPORT';
    String selectedPriority = 'MEDIUM';
    String selectedScheduleType = 'IMMEDIATE';
    String jobName = '';
    String description = '';
    DateTime? selectedDateTime;
    DateTime? endDateTime;
    int recurringValue = 1;
    String recurringUnit = 'hours';
    String cronExpression = '';
    List<Map<String, String>> parameters = [];

    // Job-specific configuration variables
    String exportDataType = 'EVENTS';
    String exportFormat = 'CSV';
    DateTime? dataFromDate;
    DateTime? dataToDate;
    String etlSourceTable = 'EPCIS_EVENTS';
    String etlTargetTable = 'PROCESSED_EVENTS';
    String reportType = 'SUMMARY';
    String importDataSource = 'CSV_FILE';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.green.shade600),
                  SizedBox(width: 8),
                  Text('Schedule New Job'),
                ],
              ),
              content: Container(
                width: 500,
                height: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Job Information
                      Text('Job Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 12),
                      
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Job Name *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => jobName = value,
                      ),
                      SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Job Type *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedJobType,
                        items: [
                          'DATA_EXPORT',
                          'ETL_PIPELINE',
                          'BULK_IMPORT',
                          'SYSTEM_MAINTENANCE',
                          'REPORT_GENERATION',
                        ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                        onChanged: (value) => setState(() => selectedJobType = value!),
                      ),
                      SizedBox(height: 12),
                      
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) => description = value,
                      ),
                      SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedPriority,
                        items: ['HIGH', 'MEDIUM', 'LOW']
                            .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedPriority = value!),
                      ),
                      SizedBox(height: 20),
                      
                      // Scheduling Options
                      Text('Schedule Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Schedule Type *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedScheduleType,
                        items: ['IMMEDIATE', 'ONCE', 'RECURRING', 'CRON']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedScheduleType = value!),
                      ),
                      SizedBox(height: 12),
                      
                      // Conditional scheduling fields based on type
                      if (selectedScheduleType == 'ONCE' || selectedScheduleType == 'RECURRING') ...[
                        ListTile(
                          title: Text('Start Date/Time: ${selectedDateTime?.toString().split('.')[0] ?? 'Not set'}'),
                          trailing: Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(Duration(hours: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                                });
                              }
                            }
                          },
                        ),
                      ],
                      
                      if (selectedScheduleType == 'RECURRING') ...[
                        Row(
                          children: [
                            Text('Repeat every: '),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                decoration: InputDecoration(border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => recurringValue = int.tryParse(value) ?? 1,
                              ),
                            ),
                            SizedBox(width: 8),
                            DropdownButton<String>(
                              value: recurringUnit,
                              items: ['minutes', 'hours', 'days', 'weeks', 'months']
                                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                                  .toList(),
                              onChanged: (value) => setState(() => recurringUnit = value!),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ListTile(
                          title: Text('End Date (Optional): ${endDateTime?.toString().split('.')[0] ?? 'Never'}'),
                          trailing: Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => endDateTime = date);
                            }
                          },
                        ),
                      ],
                      
                      if (selectedScheduleType == 'CRON') ...[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Cron Expression *',
                            border: OutlineInputBorder(),
                            hintText: '0 0 * * * (every day at midnight)',
                          ),
                          onChanged: (value) => cronExpression = value,
                        ),
                        SizedBox(height: 8),
                        Text('Examples: "0 */2 * * *" (every 2 hours), "0 0 9 * * MON-FRI" (weekdays at 9am)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                      
                      SizedBox(height: 20),
                      
                      // Job-Specific Configuration
                      Text('Job Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 12),
                      
                      // Dynamic configuration based on job type
                      ..._buildJobTypeSpecificFields(selectedJobType, setState),
                      
                      SizedBox(height: 20),
                      
                      // Additional Parameters
                      Text('Additional Parameters (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 12),
                      
                      ...parameters.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> param = entry.value;
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(labelText: 'Key'),
                                    controller: TextEditingController(text: param['key']),
                                    onChanged: (value) => parameters[index]['key'] = value,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(labelText: 'Value'),
                                    controller: TextEditingController(text: param['value']),
                                    onChanged: (value) => parameters[index]['value'] = value,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => setState(() => parameters.removeAt(index)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      
                      ElevatedButton.icon(
                        onPressed: () => setState(() => parameters.add({'key': '', 'value': ''})),
                        icon: Icon(Icons.add),
                        label: Text('Add Parameter'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_validateJobForm(jobName, selectedJobType, selectedScheduleType, selectedDateTime, cronExpression)) {
                      Navigator.of(context).pop();
                      _createScheduledJob(
                        jobName,
                        selectedJobType,
                        description,
                        selectedPriority,
                        selectedScheduleType,
                        selectedDateTime,
                        endDateTime,
                        recurringValue,
                        recurringUnit,
                        cronExpression,
                        parameters,
                        // Job-specific configuration
                        exportDataType,
                        exportFormat,
                        dataFromDate,
                        dataToDate,
                        etlSourceTable,
                        etlTargetTable,
                        reportType,
                        importDataSource,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                  child: Text('Schedule Job', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateJobForm(String jobName, String jobType, String scheduleType, DateTime? dateTime, String cronExpression) {
    if (jobName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Job name is required')));
      return false;
    }
    if (scheduleType == 'ONCE' && dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Date/time is required for one-time jobs')));
      return false;
    }
    if (scheduleType == 'CRON' && cronExpression.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cron expression is required')));
      return false;
    }
    return true;
  }

  Future<void> _createScheduledJob(
    String jobName,
    String jobType,
    String description,
    String priority,
    String scheduleType,
    DateTime? startDateTime,
    DateTime? endDateTime,
    int recurringValue,
    String recurringUnit,
    String cronExpression,
    List<Map<String, String>> parameters,
    // Job-specific configuration
    String exportDataType,
    String exportFormat,
    DateTime? dataFromDate,
    DateTime? dataToDate,
    String etlSourceTable,
    String etlTargetTable,
    String reportType,
    String importDataSource,
  ) async {
    try {
      // Build job payload for backend
      Map<String, dynamic> jobPayload = {
        'name': jobName,
        'description': description,
        'scheduleType': scheduleType,
        'parameters': Map.fromIterable(parameters, key: (p) => p['key'], value: (p) => p['value']),
      };

      // Add job-specific configuration based on job type
      switch (jobType) {
        case 'DATA_EXPORT':
          jobPayload['exportConfig'] = {
            'dataType': exportDataType,
            'format': exportFormat,
            'fromDate': dataFromDate?.toIso8601String(),
            'toDate': dataToDate?.toIso8601String(),
          };
          break;
        case 'ETL_PIPELINE':
          jobPayload['etlConfig'] = {
            'sourceTable': etlSourceTable,
            'targetTable': etlTargetTable,
          };
          break;
        case 'REPORT_GENERATION':
          jobPayload['reportConfig'] = {
            'reportType': reportType,
            'fromDate': dataFromDate?.toIso8601String(),
            'toDate': dataToDate?.toIso8601String(),
          };
          break;
        case 'BULK_IMPORT':
          jobPayload['importConfig'] = {
            'dataSource': importDataSource,
            'targetTable': etlTargetTable,
          };
          break;
      }

      if (startDateTime != null) {
        jobPayload['startDateTime'] = startDateTime.toIso8601String();
      }
      if (endDateTime != null) {
        jobPayload['endDateTime'] = endDateTime.toIso8601String();
      }
      if (scheduleType == 'RECURRING') {
        jobPayload['recurringValue'] = recurringValue;
        jobPayload['recurringUnit'] = recurringUnit;
      }
      if (scheduleType == 'CRON') {
        jobPayload['cronExpression'] = cronExpression;
      }

      // Convert priority to integer
      int priorityInt = int.tryParse(priority) ?? 5;

      final token = await widget.tokenManager.getToken();
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/jobs/submit?jobType=$jobType&priority=$priorityInt'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode(jobPayload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job "$jobName" scheduled successfully!'), backgroundColor: Colors.green),
        );
        _loadInitialData();
      } else {
        throw Exception('Failed to schedule job: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule job: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<Widget> _buildJobTypeSpecificFields(String jobType, void Function(void Function()) setState) {
    switch (jobType) {
      case 'DATA_EXPORT':
        return [
          Text('Export Configuration', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Data Type to Export',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.storage),
            ),
            value: 'EVENTS',
            items: [
              DropdownMenuItem(value: 'EVENTS', child: Text('EPCIS Events')),
              DropdownMenuItem(value: 'MASTER_DATA', child: Text('Master Data')),
              DropdownMenuItem(value: 'LOCATIONS', child: Text('Locations')),
              DropdownMenuItem(value: 'PRODUCTS', child: Text('Products')),
              DropdownMenuItem(value: 'ALL', child: Text('All Data')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Export Format',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.file_download),
            ),
            value: 'CSV',
            items: [
              DropdownMenuItem(value: 'CSV', child: Text('CSV')),
              DropdownMenuItem(value: 'JSON', child: Text('JSON')),
              DropdownMenuItem(value: 'XML', child: Text('XML')),
              DropdownMenuItem(value: 'EXCEL', child: Text('Excel')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text('From Date'),
                  subtitle: Text('${DateTime.now().subtract(Duration(days: 30)).toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(Duration(days: 30)),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {});
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  title: Text('To Date'),
                  subtitle: Text('${DateTime.now().toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ];

      case 'ETL_PIPELINE':
        return [
          Text('ETL Configuration', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Source Table',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.input),
            ),
            value: 'EPCIS_EVENTS',
            items: [
              DropdownMenuItem(value: 'EPCIS_EVENTS', child: Text('EPCIS Events')),
              DropdownMenuItem(value: 'RAW_EVENTS', child: Text('Raw Events')),
              DropdownMenuItem(value: 'MASTER_DATA', child: Text('Master Data')),
              DropdownMenuItem(value: 'EXTERNAL_FEED', child: Text('External Feed')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Target Table',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.output),
            ),
            value: 'PROCESSED_EVENTS',
            items: [
              DropdownMenuItem(value: 'PROCESSED_EVENTS', child: Text('Processed Events')),
              DropdownMenuItem(value: 'ANALYTICS_DATA', child: Text('Analytics Data')),
              DropdownMenuItem(value: 'AGGREGATED_METRICS', child: Text('Aggregated Metrics')),
              DropdownMenuItem(value: 'REPORTING_DATA', child: Text('Reporting Data')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Transformation Rules (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.transform),
              hintText: 'Enter transformation logic or rule IDs',
            ),
            maxLines: 2,
          ),
        ];

      case 'BULK_IMPORT':
        return [
          Text('Import Configuration', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple.shade700)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Data Source Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cloud_upload),
            ),
            value: 'CSV_FILE',
            items: [
              DropdownMenuItem(value: 'CSV_FILE', child: Text('CSV File')),
              DropdownMenuItem(value: 'JSON_FILE', child: Text('JSON File')),
              DropdownMenuItem(value: 'XML_FILE', child: Text('XML File')),
              DropdownMenuItem(value: 'DATABASE', child: Text('External Database')),
              DropdownMenuItem(value: 'API_ENDPOINT', child: Text('API Endpoint')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Source Path/URL',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
              hintText: 'File path or API endpoint URL',
            ),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Target Table',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.table_chart),
            ),
            value: 'EPCIS_EVENTS',
            items: [
              DropdownMenuItem(value: 'EPCIS_EVENTS', child: Text('EPCIS Events')),
              DropdownMenuItem(value: 'MASTER_DATA', child: Text('Master Data')),
              DropdownMenuItem(value: 'LOCATIONS', child: Text('Locations')),
              DropdownMenuItem(value: 'PRODUCTS', child: Text('Products')),
            ],
            onChanged: (value) => setState(() {}),
          ),
        ];

      case 'REPORT_GENERATION':
        return [
          Text('Report Configuration', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange.shade700)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Report Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.analytics),
            ),
            value: 'SUMMARY',
            items: [
              DropdownMenuItem(value: 'SUMMARY', child: Text('Summary Report')),
              DropdownMenuItem(value: 'DETAILED', child: Text('Detailed Report')),
              DropdownMenuItem(value: 'ANALYTICS', child: Text('Analytics Report')),
              DropdownMenuItem(value: 'COMPLIANCE', child: Text('Compliance Report')),
              DropdownMenuItem(value: 'TRACEABILITY', child: Text('Traceability Report')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text('Report Period From'),
                  subtitle: Text('${DateTime.now().subtract(Duration(days: 7)).toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(Duration(days: 7)),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {});
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  title: Text('Report Period To'),
                  subtitle: Text('${DateTime.now().toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ];

      case 'SYSTEM_MAINTENANCE':
        return [
          Text('Maintenance Configuration', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Maintenance Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.build),
            ),
            value: 'DATABASE_CLEANUP',
            items: [
              DropdownMenuItem(value: 'DATABASE_CLEANUP', child: Text('Database Cleanup')),
              DropdownMenuItem(value: 'LOG_ARCHIVAL', child: Text('Log Archival')),
              DropdownMenuItem(value: 'INDEX_REBUILD', child: Text('Index Rebuild')),
              DropdownMenuItem(value: 'CACHE_CLEAR', child: Text('Cache Clear')),
              DropdownMenuItem(value: 'BACKUP', child: Text('Backup')),
            ],
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Retention Days (for cleanup tasks)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule),
              hintText: '30',
            ),
            keyboardType: TextInputType.number,
          ),
        ];

      default:
        return [
          Text('No specific configuration required for this job type.',
              style: TextStyle(color: Colors.grey.shade600)),
        ];
    }
  }

  Future<void> _downloadJobResult(String jobId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final token = await widget.tokenManager.getToken();
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/jobs/$jobId/download'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (response.statusCode == 200) {
        // Get filename from Content-Disposition header or use default
        String filename = 'export_data.csv';
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          final match = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
          if (match != null) {
            filename = match.group(1)!;
          }
        }

        // Create blob and download link (web-specific)
        final bytes = response.bodyBytes;
        web_download.downloadBytes(bytes: bytes, filename: filename);

        _showSuccessSnackBar('File downloaded successfully: $filename');
      } else if (response.statusCode == 404) {
        _showErrorSnackBar('File not found. The export may have been cleaned up.');
      } else {
        _showErrorSnackBar('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if still open
      _showErrorSnackBar('Error downloading file: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
