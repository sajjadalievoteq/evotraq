part of 'database_partitioning_dashboard_screen.dart';

extension DatabasePartitioningActions on _DatabasePartitioningDashboardState {
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
        statusColor = AppColorMapper.successColor(context);
        statusIconAsset = AppAssets.iconCheckCircle;
        break;
      case 'WARNING':
        statusColor = AppColorMapper.warningColor(context);
        statusIconAsset = AppAssets.iconAlert;
        break;
      case 'CRITICAL':
        statusColor = AppColorMapper.errorColor(context);
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
                  Text(
                    'Issues Found:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorMapper.errorColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColorMapper.errorColor(
                        context,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColorMapper.errorColor(
                          context,
                        ).withOpacity(0.3),
                      ),
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
                                  TraqIcon(
                                    AppAssets.iconAlert,
                                    size: 16,
                                    color: AppColorMapper.errorColor(context),
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
                  Text(
                    'Recommendations:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorMapper.infoColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColorMapper.infoColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColorMapper.infoColor(
                          context,
                        ).withOpacity(0.3),
                      ),
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
                                  TraqIcon(
                                    AppAssets.iconLightbulb,
                                    color: AppColorMapper.infoColor(context),
                                    size: 16,
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
                      color: AppColorMapper.successColor(
                        context,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColorMapper.successColor(
                          context,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        TraqIcon(
                          AppAssets.iconCheck,
                          color: AppColorMapper.successColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'All partitions are healthy!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColorMapper.successColor(context),
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
        title: Row(
          children: [
            TraqIcon(
              AppAssets.iconInfo,
              color: AppColorMapper.infoColor(context),
            ),
            const SizedBox(width: 8),
            const Text('Database Partitioning Help'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PartitionHelpSection(
                  'Partitioning Strategy Overview',
                  'TraqTrace uses a Base Table Partitioning strategy optimized for JPA inheritance. This approach ensures efficient data management while maintaining compatibility with our object-relational mapping framework.',
                  AppAssets.iconInfo,
                  AppColorMapper.chartColor(context, 0),
                ),
                const SizedBox(height: 16),

                PartitionHelpSection(
                  'Why Only EPCIS Events Are Partitioned?',
                  'Only the main epcis_events table is partitioned because:\n\n'
                      '• Child tables (object_events, aggregation_events, transaction_events, transformation_events) inherit from epcis_events\n'
                      '• JPA inheritance mapping requires the base table to handle partitioning\n'
                      '• All event data flows through epcis_events, making it the optimal partition point\n'
                      '• This reduces complexity while maximizing performance benefits',
                  AppAssets.iconTable,
                  AppColorMapper.chartColor(context, 1),
                ),
                const SizedBox(height: 16),

                PartitionHelpSection(
                  'Event Data Storage',
                  'Event data is stored as follows:\n\n'
                      '• Object Events: Data stored in epcis_events partitions, accessed via object_events view\n'
                      '• Aggregation Events: Data stored in epcis_events partitions, accessed via aggregation_events view\n'
                      '• Transaction Events: Data stored in epcis_events partitions, accessed via transaction_events view\n'
                      '• Transformation Events: Data stored in epcis_events partitions, accessed via transformation_events view\n\n'
                      'This inheritance-based approach ensures all event types benefit from partitioning automatically.',
                  NavIcons.databasePartitioning,
                  AppColorMapper.chartColor(context, 2),
                ),
                const SizedBox(height: 16),

                PartitionHelpSection(
                  'Why GLN, GTIN, SSCC, SGTIN Are Not Partitioned?',
                  'Master data tables (GLN, GTIN, SSCC, SGTIN) are not partitioned because:\n\n'
                      '• These are reference/lookup tables with relatively static data\n'
                      '• They have smaller data volumes compared to event tables\n'
                      '• Frequent joins require these tables to be readily accessible\n'
                      '• Partitioning would add complexity without significant performance benefits\n'
                      '• Master data changes infrequently, so time-based partitioning is unnecessary',
                  AppAssets.iconCategory,
                  AppColorMapper.chartColor(context, 3),
                ),
                const SizedBox(height: 16),

                PartitionHelpSection(
                  'Maintenance Tab Functionality',
                  'The Maintenance tab provides essential partition management tools:\n\n'
                      '• Create Future Partitions: Pre-creates partitions for next 3 months to avoid runtime delays\n'
                      '• Update Statistics: Refreshes partition metadata and size calculations\n'
                      '• Archive Old Partitions: Moves partitions older than 12 months to archive status\n'
                      '• Health Check: Performs comprehensive analysis of partition health and performance\n\n'
                      'Regular maintenance ensures optimal database performance and prevents partition-related issues.',
                  NavIcons.systemTools,
                  AppColorMapper.chartColor(context, 4),
                ),
                const SizedBox(height: 16),

                PartitionHelpSection(
                  'Partition Naming Convention',
                  'Partitions follow a consistent naming pattern:\n\n'
                      '• Format: table_name_yYYYY_mMM\n'
                      '• Example: epcis_events_y2025_m07 (July 2025)\n'
                      '• Each partition contains one month of data\n'
                      '• Automatic routing based on event timestamp\n'
                      '• Enables efficient query pruning and maintenance operations',
                  AppAssets.iconTag,
                  AppColorMapper.chartColor(context, 5),
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
}
