import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/models/partition_models.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../data/services/database_partitioning_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/keep_alive_tab_view.dart';





class _OverviewData {
  final PartitionStatistics statistics;
  final Map<String, dynamic> health;

  const _OverviewData(this.statistics, this.health);
}

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

  
  
  
  final Set<int> _loadedTabs = {};

  
  
  LoadState<_OverviewData> _overviewState = const LoadState.loading();

  
  
  LoadState<List<PartitionMetadata>> _metadataState = const LoadState.loading();

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ensureTabLoaded(_tabController.index);
      }
    });

    _partitioningService = DatabasePartitioningService(
      dioService: getIt<DioService>(),
    );

    _ensureTabLoaded(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  
  
  
  
  
  
  void _ensureTabLoaded(int index) {
    if (_loadedTabs.contains(index)) return;
    _loadedTabs.add(index);

    switch (index) {
      case 0:
        _loadOverview();
        break;
      case 1:
        _loadOverview();
        _loadMetadata();
        break;
      default:
        break;
    }
  }

  Future<void> _loadOverview({bool force = false}) async {
    if (!force && _overviewState.isSuccess) return;

    setState(() {
      _overviewState = const LoadState.loading();
    });

    try {
      final overview = await _partitioningService.getDashboardOverview();
      final statsJson = overview['statistics'];
      final healthJson = overview['health'];

      if (!mounted) return;

      if (statsJson == null) {
        setState(() {
          _overviewState = const LoadState.empty();
        });
        return;
      }

      final statistics = PartitionStatistics.fromJson(
        (statsJson as Map).cast<String, dynamic>(),
      );
      final health = healthJson != null
          ? (healthJson as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      setState(() {
        _overviewState = LoadState.success(_OverviewData(statistics, health));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _overviewState = LoadState.error(e.toString());
      });
    }
  }

  Future<void> _loadMetadata({bool force = false}) async {
    if (!force && _metadataState.isSuccess) return;

    setState(() {
      _metadataState = const LoadState.loading();
    });

    try {
      final metadata = await _partitioningService.getPartitionMetadata();

      if (!mounted) return;
      setState(() {
        _metadataState =
            metadata.isEmpty ? const LoadState.empty() : LoadState.success(metadata);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metadataState = LoadState.error(e.toString());
      });
    }
  }

  
  
  
  Future<void> _refreshLoadedTabs() async {
    final futures = <Future<void>>[];

    if (_loadedTabs.contains(0) || _loadedTabs.contains(1)) {
      futures.add(_loadOverview(force: true));
    }
    if (_loadedTabs.contains(1)) {
      futures.add(_loadMetadata(force: true));
    }

    await Future.wait(futures);
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
            Tab(text: 'Overview', icon: TraqIcon(NavIcons.dashboard)),
            Tab(text: 'Partitions', icon: TraqIcon(AppAssets.iconTable)),
            Tab(text: 'Archive', icon: TraqIcon(AppAssets.iconDownload)),
            Tab(text: 'Maintenance', icon: TraqIcon(AppAssets.iconSettings)),
          ],
        ),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: _showHelpDialog,
            tooltip: 'Help & Information',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _refreshLoadedTabs,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(child: _buildOverviewTab()),
          KeepAliveTabView(child: _buildPartitionsTab()),
          KeepAliveTabView(child: _buildArchiveTab()),
          KeepAliveTabView(child: _buildMaintenanceTab()),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return LoadStateView<_OverviewData>(
      state: _overviewState,
      onRetry: () => _loadOverview(force: true),
      builder: (context, data) => _buildOverviewContent(data.statistics, data.health),
    );
  }

  Widget _buildOverviewContent(
    PartitionStatistics statistics,
    Map<String, dynamic> health,
  ) {
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

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Partitions',
                  statistics.totalPartitions.toString(),
                  AppAssets.iconTable,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Partitions',
                  statistics.activePartitions.toString(),
                  AppAssets.iconCheckCircle,
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
                  statistics.archivedPartitions.toString(),
                  AppAssets.iconArchive,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Size',
                  '${(statistics.totalSizeGb != null && statistics.totalSizeGb! > 0) ? statistics.totalSizeGb!.toStringAsFixed(6) : (statistics.totalSizeMb != null ? (statistics.totalSizeMb! / 1024).toStringAsFixed(6) : '0.000000')} GB',
                  NavIcons.databasePartitioning,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildHealthStatusCard(health),
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

          LoadStateView<_OverviewData>(
            state: _overviewState,
            onRetry: () => _loadOverview(force: true),
            builder: (context, data) => _buildPartitionSummaryCard(data.statistics),
          ),
          const SizedBox(height: 20),

          LoadStateView<List<PartitionMetadata>>(
            state: _metadataState,
            onRetry: () => _loadMetadata(force: true),
            emptyWidget: const Center(child: Text('No partition data available')),
            builder: (context, metadata) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metadata.length,
              itemBuilder: (context, index) {
                final partition = metadata[index];
                return _buildPartitionCard(partition);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartitionSummaryCard(PartitionStatistics statistics) {
    return Card(
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
              'Total Records (in partitions): ${statistics.totalRecords}',
            ),
            Text('Total Size Bytes: ${statistics.totalSizeBytes}'),
            Text(
              'Total Size MB: ${statistics.totalSizeMb?.toStringAsFixed(2) ?? 'null'}',
            ),
            Text(
              'Total Size GB: ${statistics.totalSizeGb?.toStringAsFixed(6) ?? 'null'}',
            ),
            Text(
              'Average Partition Size: ${statistics.averagePartitionSizeMb?.toStringAsFixed(2) ?? 'N/A'} MB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconDownload, size: 64, color: Colors.grey),
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
    String iconAsset,
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
                TraqIcon(iconAsset, color: color),
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

  Widget _buildHealthStatusCard(Map<String, dynamic> healthStatus) {
    final status = healthStatus['overall_status'] ?? 'UNKNOWN';
    Color statusColor;
    String statusIconAsset;

    switch (status) {
      case 'HEALTHY':
        statusColor = Colors.green;
        statusIconAsset = AppAssets.iconCheckCircle;
        break;
      case 'WARNING':
        statusColor = Colors.orange;
        statusIconAsset = AppAssets.iconAlert;
        break;
      case 'CRITICAL':
        statusColor = Colors.red;
        statusIconAsset = AppAssets.iconXCircle;
        break;
      default:
        statusColor = Colors.grey;
        statusIconAsset = NavIcons.helpSupport;
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
                TraqIcon(statusIconAsset, color: statusColor),
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
            if (healthStatus['issues'] != null &&
                (healthStatus['issues'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${(healthStatus['issues'] as List).length} issue(s) found',
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
          AppAssets.iconPlus,
          () => _performMaintenance('CREATE_FUTURE'),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceButton(
          'Update Statistics',
          'Refresh partition statistics',
          AppAssets.iconRefresh,
          () => _performMaintenance('UPDATE_STATS'),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceButton(
          'Archive Old Partitions',
          'Archive partitions older than 12 months',
          AppAssets.iconArchive,
          () => _performMaintenance('ARCHIVE_OLD'),
        ),
        const SizedBox(height: 12),
        _buildMaintenanceButton(
          'Health Check',
          'Perform comprehensive health check',
          AppAssets.iconSecurity,
          () => _performMaintenance('HEALTH_CHECK'),
        ),
      ],
    );
  }

  Widget _buildMaintenanceButton(
    String title,
    String subtitle,
    String iconAsset,
    VoidCallback onPressed,
  ) {
    return Card(
      child: ListTile(
        leading: TraqIcon(iconAsset, color: Theme.of(context).primaryColor),
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
          Navigator.of(context).pop();
          _showHealthCheckResults(healthData);
          return;
      }

      Navigator.of(context).pop();

      context.showSuccess('Maintenance operation completed successfully');

      _refreshLoadedTabs();
    } catch (e) {
      Navigator.of(context).pop();

      context.showError('Maintenance failed: $e');
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
    String statusIconAsset;

    switch (status) {
      case 'HEALTHY':
        statusColor = Colors.green;
        statusIconAsset = AppAssets.iconCheckCircle;
        break;
      case 'WARNING':
        statusColor = Colors.orange;
        statusIconAsset = AppAssets.iconAlert;
        break;
      case 'CRITICAL':
        statusColor = Colors.red;
        statusIconAsset = AppAssets.iconXCircle;
        break;
      default:
        statusColor = Colors.grey;
        statusIconAsset = NavIcons.helpSupport;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(statusIconAsset, color: statusColor),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      TraqIcon(statusIconAsset, color: statusColor, size: 20),
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
                                  TraqIcon(AppAssets.iconAlert,
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
                                  const TraqIcon(AppAssets.iconLightbulb, color: Colors.blue, size: 16),
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
                        TraqIcon(AppAssets.iconCheck, color: Colors.green, size: 20),
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
              _refreshLoadedTabs();
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
            TraqIcon(AppAssets.iconInfo, color: Colors.blue),
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
                  AppAssets.iconInfo,
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
                  AppAssets.iconTable,
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
                  NavIcons.databasePartitioning,
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
                  AppAssets.iconCategory,
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
                  NavIcons.systemTools,
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
                  AppAssets.iconTag,
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
    String iconAsset,
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
                TraqIcon(iconAsset, color: color, size: 20),
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
