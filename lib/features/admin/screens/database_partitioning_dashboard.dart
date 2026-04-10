import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import '../../../../core/services/database_partitioning_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../shared/models/partition_models.dart';
import '../../../../core/widgets/app_drawer.dart';

/// Database Partitioning Dashboard Screen for Phase 3.1 implementation
class DatabasePartitioningDashboard extends StatefulWidget {
  const DatabasePartitioningDashboard({Key? key}) : super(key: key);

  @override
  State<DatabasePartitioningDashboard> createState() =>
      _DatabasePartitioningDashboardState();
}

class _DatabasePartitioningDashboardState
    extends State<DatabasePartitioningDashboard>
    with TickerProviderStateMixin {
  late final DatabasePartitioningService _partitioningService;
  late TabController _tabController;

  PartitionStatistics? _statistics;
  Map<String, dynamic>? _healthStatus;
  List<PartitionMetadata>? _metadata;
  bool _isLoading = true;
  String? _error;

  final List<String> _validTables = [
    'epcis_events',
    'object_events',
    'aggregation_events',
    'transaction_events',
    'transformation_events',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize service with proper dependencies
    final dio = getIt<Dio>();
    final config = getIt<AppConfig>();
    final tokenManager = getIt<TokenManager>();
    _partitioningService = DatabasePartitioningService(
      dio,
      config,
      tokenManager,
    );

    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _partitioningService.getPartitionMonitoringReport(),
        _partitioningService.getPartitionHealthStatus(),
        _partitioningService.getPartitionMetadata(),
      ]);

      setState(() {
        _statistics = results[0] as PartitionStatistics;
        _healthStatus = results[1] as Map<String, dynamic>;
        _metadata = results[2] as List<PartitionMetadata>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Database Table Partitions Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Partitions', icon: Icon(Icons.table_chart)),
            Tab(text: 'Archive', icon: Icon(Icons.archive)),
            Tab(text: 'Maintenance', icon: Icon(Icons.build)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help & Information',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDashboardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPartitionsTab(),
                _buildArchiveTab(),
                _buildMaintenanceTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partition Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (_statistics != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Partitions',
                    _statistics!.totalPartitions.toString(),
                    Icons.table_chart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Active Partitions',
                    _statistics!.activePartitions.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Archived Partitions',
                    _statistics!.archivedPartitions.toString(),
                    Icons.archive,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Size',
                    '${(_statistics!.totalSizeGb != null && _statistics!.totalSizeGb! > 0) ? _statistics!.totalSizeGb!.toStringAsFixed(6) : (_statistics!.totalSizeMb != null ? (_statistics!.totalSizeMb! / 1024).toStringAsFixed(6) : '0.000000')} GB',
                    Icons.storage,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Health Status
            if (_healthStatus != null) _buildHealthStatusCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildPartitionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partition Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Partition Data Summary
          if (_statistics != null) ...[
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Partition Data Summary:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Records (in partitions): ${_statistics!.totalRecords}',
                    ),
                    Text('Total Size Bytes: ${_statistics!.totalSizeBytes}'),
                    Text(
                      'Total Size MB: ${_statistics!.totalSizeMb?.toStringAsFixed(2) ?? 'null'}',
                    ),
                    Text(
                      'Total Size GB: ${_statistics!.totalSizeGb?.toStringAsFixed(6) ?? 'null'}',
                    ),
                    Text(
                      'Average Partition Size: ${_statistics!.averagePartitionSizeMb?.toStringAsFixed(2) ?? 'N/A'} MB',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_metadata != null && _metadata!.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metadata!.length,
              itemBuilder: (context, index) {
                final partition = _metadata![index];
                return _buildPartitionCard(partition);
              },
            ),
          ] else ...[
            const Center(child: Text('No partition data available')),
          ],
        ],
      ),
    );
  }

  Widget _buildArchiveTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Archive Management'),
          Text('Feature implementation in progress'),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partition Maintenance',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildMaintenanceActions(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    final status = _healthStatus!['overall_status'] ?? 'UNKNOWN';
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'HEALTHY':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'WARNING':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'CRITICAL':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'System Health: $status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (_healthStatus!['issues'] != null &&
                (_healthStatus!['issues'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${(_healthStatus!['issues'] as List).length} issue(s) found',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPartitionCard(PartitionMetadata partition) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(partition.partitionName),
        subtitle: Text(
          'Table: ${partition.tableName} | Type: ${partition.partitionType}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(partition.sizeMb ?? 0).toStringAsFixed(1)} MB',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${partition.recordCount} records',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: partition.status == 'ACTIVE' ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceActions() {
    return Column(
      children: [
        _buildMaintenanceButton(
          'Create Future Partitions',
          'Create partitions for next 3 months (epcis_events only)',
          Icons.add,
          () => _performMaintenance('CREATE_FUTURE'),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceButton(
          'Update Statistics',
          'Refresh partition statistics',
          Icons.refresh,
          () => _performMaintenance('UPDATE_STATS'),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceButton(
          'Archive Old Partitions',
          'Archive partitions older than 12 months',
          Icons.archive,
          () => _performMaintenance('ARCHIVE_OLD'),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceButton(
          'Health Check',
          'Perform comprehensive health check',
          Icons.health_and_safety,
          () => _performMaintenance('HEALTH_CHECK'),
        ),
      ],
    );
  }

  Widget _buildMaintenanceButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: const Text('Run'),
        ),
      ),
    );
  }

  Future<void> _performMaintenance(String action) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Performing maintenance...'),
          ],
        ),
      ),
    );

    try {
      switch (action) {
        case 'CREATE_FUTURE':
          await _partitioningService.automatePartitionCreation();
          break;
        case 'UPDATE_STATS':
          for (final table in _validTables) {
            await _partitioningService.updatePartitionStatistics(
              tableName: table,
            );
          }
          break;
        case 'ARCHIVE_OLD':
          final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
          await _partitioningService.archiveOldPartitions(
            cutoffDate: cutoffDate,
          );
          break;
        case 'HEALTH_CHECK':
          final healthData = await _partitioningService
              .getPartitionHealthStatus();
          Navigator.of(context).pop(); // Close loading dialog
          _showHealthCheckResults(healthData);
          return; // Don't show generic success message
      }

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance operation completed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _loadDashboardData(); // Refresh data
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maintenance failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showHealthCheckResults(Map<String, dynamic> healthData) {
    final status = healthData['overall_status'] ?? 'UNKNOWN';
    final issues = healthData['issues'] as List<dynamic>? ?? [];
    final recommendations =
        healthData['recommendations'] as List<dynamic>? ?? [];
    final tableHealth =
        healthData['table_health'] as Map<String, dynamic>? ?? {};
    final lastCheck = healthData['last_check'] ?? DateTime.now().toString();

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'HEALTHY':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'WARNING':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'CRITICAL':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 8),
            Text('Health Check Results', style: TextStyle(color: statusColor)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Overall Status: $status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Issues Section
                if (issues.isNotEmpty) ...[
                  const Text(
                    'Issues Found:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: issues
                          .map(
                            (issue) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(issue.toString())),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Recommendations Section
                if (recommendations.isNotEmpty) ...[
                  const Text(
                    'Recommendations:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recommendations
                          .map(
                            (rec) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(rec.toString())),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Table Health Details
                if (tableHealth.isNotEmpty) ...[
                  const Text(
                    'Table Health Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...tableHealth.entries.map((entry) {
                    final tableName = entry.key;
                    final stats = entry.value as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tableName.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Partitions: ${stats['partition_count'] ?? 'N/A'}',
                            ),
                            Text(
                              'Avg Size: ${(stats['avg_size_mb'] ?? 0).toStringAsFixed(1)} MB',
                            ),
                            Text(
                              'Max Size: ${(stats['max_size_mb'] ?? 0).toStringAsFixed(1)} MB',
                            ),
                            Text(
                              'Unmaintained: ${stats['unmaintained_partitions'] ?? 0}',
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],

                // No issues message
                if (issues.isEmpty && recommendations.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'All partitions are healthy!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Timestamp
                Text(
                  'Last checked: ${DateTime.tryParse(lastCheck)?.toLocal().toString() ?? lastCheck}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadDashboardData(); // Refresh the dashboard data
            },
            child: const Text('Refresh Dashboard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Database Partitioning Help'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpSection(
                  'Partitioning Strategy Overview',
                  'TraqTrace uses a Base Table Partitioning strategy optimized for JPA inheritance. This approach ensures efficient data management while maintaining compatibility with our object-relational mapping framework.',
                  Icons.info,
                  Colors.blue,
                ),
                const SizedBox(height: 16),

                _buildHelpSection(
                  'Why Only EPCIS Events Are Partitioned?',
                  'Only the main epcis_events table is partitioned because:\n\n'
                      '• Child tables (object_events, aggregation_events, transaction_events, transformation_events) inherit from epcis_events\n'
                      '• JPA inheritance mapping requires the base table to handle partitioning\n'
                      '• All event data flows through epcis_events, making it the optimal partition point\n'
                      '• This reduces complexity while maximizing performance benefits',
                  Icons.table_chart,
                  Colors.green,
                ),
                const SizedBox(height: 16),

                _buildHelpSection(
                  'Event Data Storage',
                  'Event data is stored as follows:\n\n'
                      '• Object Events: Data stored in epcis_events partitions, accessed via object_events view\n'
                      '• Aggregation Events: Data stored in epcis_events partitions, accessed via aggregation_events view\n'
                      '• Transaction Events: Data stored in epcis_events partitions, accessed via transaction_events view\n'
                      '• Transformation Events: Data stored in epcis_events partitions, accessed via transformation_events view\n\n'
                      'This inheritance-based approach ensures all event types benefit from partitioning automatically.',
                  Icons.storage,
                  Colors.purple,
                ),
                const SizedBox(height: 16),

                _buildHelpSection(
                  'Why GLN, GTIN, SSCC, SGTIN Are Not Partitioned?',
                  'Master data tables (GLN, GTIN, SSCC, SGTIN) are not partitioned because:\n\n'
                      '• These are reference/lookup tables with relatively static data\n'
                      '• They have smaller data volumes compared to event tables\n'
                      '• Frequent joins require these tables to be readily accessible\n'
                      '• Partitioning would add complexity without significant performance benefits\n'
                      '• Master data changes infrequently, so time-based partitioning is unnecessary',
                  Icons.category,
                  Colors.orange,
                ),
                const SizedBox(height: 16),

                _buildHelpSection(
                  'Maintenance Tab Functionality',
                  'The Maintenance tab provides essential partition management tools:\n\n'
                      '• Create Future Partitions: Pre-creates partitions for next 3 months to avoid runtime delays\n'
                      '• Update Statistics: Refreshes partition metadata and size calculations\n'
                      '• Archive Old Partitions: Moves partitions older than 12 months to archive status\n'
                      '• Health Check: Performs comprehensive analysis of partition health and performance\n\n'
                      'Regular maintenance ensures optimal database performance and prevents partition-related issues.',
                  Icons.build,
                  Colors.red,
                ),
                const SizedBox(height: 16),

                _buildHelpSection(
                  'Partition Naming Convention',
                  'Partitions follow a consistent naming pattern:\n\n'
                      '• Format: table_name_yYYYY_mMM\n'
                      '• Example: epcis_events_y2025_m07 (July 2025)\n'
                      '• Each partition contains one month of data\n'
                      '• Automatic routing based on event timestamp\n'
                      '• Enables efficient query pruning and maintenance operations',
                  Icons.label,
                  Colors.teal,
                ),
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

  Widget _buildHelpSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
