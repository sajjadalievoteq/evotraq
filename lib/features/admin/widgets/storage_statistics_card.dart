import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_event_type_row.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_stat_metric.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/number_format_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class StorageStatisticsCard extends StatelessWidget {
  final StorageStatistics storage;
  final Function(DateTime) onArchiveEvents;
  final Function(List<String>) onCompressEvents;

  const StorageStatisticsCard({
    super.key,
    required this.storage,
    required this.onArchiveEvents,
    required this.onCompressEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: StorageStatMetric(
                    'Total Events',
                    _formatNumber(storage.totalEvents),
                    NavIcons.epcisEvents,
                    AppColorMapper.chartColor(context, 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StorageStatMetric(
                    'Storage Used',
                    '${storage.storageUsedGB.toStringAsFixed(2)} GB',
                    NavIcons.databasePartitioning,
                    AppColorMapper.chartColor(context, 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StorageStatMetric(
                    'Partitions',
                    '${storage.partitionDistribution.length}',
                    AppAssets.iconGrid,
                    AppColorMapper.chartColor(context, 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StorageStatMetric(
                    'Compression Ratio',
                    '${storage.compressionRatio.toStringAsFixed(1)}:1',
                    AppAssets.iconCompress,
                    AppColorMapper.chartColor(context, 3),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Event Type Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...storage.eventTypeDistribution.entries.map((entry) => 
              StorageEventTypeRow(entry.key, entry.value)
            ).toList(),
            
            const SizedBox(height: 24),
            
            const Text(
              'Partition Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _StoragePartitionChart(storage: storage),
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Archive Information',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Archived Events: ${_formatNumber(storage.archivedEventsCount)}'),
                      Text('Last Archive: ${_formatDate(storage.lastArchiveDate)}'),
                    ],
                  ),
                  Text('Average Partition Size: ${storage.averagePartitionSize.toStringAsFixed(1)} MB'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showArchiveDialog(context),
                  icon: TraqIcon(AppAssets.iconDownload),
                  label: const Text('Archive Old Events'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCompressionDialog(context),
                  icon: const TraqIcon(AppAssets.iconCompress),
                  label: const Text('Compress Events'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorMapper.successColor(context),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return NumberFormatUtils.compactKilo(number);
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Old Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select archive cutoff date:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('6 months ago'),
              onTap: () {
                Navigator.pop(context);
                onArchiveEvents(DateTime.now().subtract(const Duration(days: 180)));
              },
            ),
            ListTile(
              title: const Text('1 year ago'),
              onTap: () {
                Navigator.pop(context);
                onArchiveEvents(DateTime.now().subtract(const Duration(days: 365)));
              },
            ),
            ListTile(
              title: const Text('2 years ago'),
              onTap: () {
                Navigator.pop(context);
                onArchiveEvents(DateTime.now().subtract(const Duration(days: 730)));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCompressionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compress Events'),
        content: const Text('Compress all uncompressed events to save storage space?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onCompressEvents([]);
            },
            child: const Text('Compress'),
          ),
        ],
      ),
    );
  }
}

class _StoragePartitionChart extends StatelessWidget {
  const _StoragePartitionChart({required this.storage});
  final StorageStatistics storage;

  @override
  Widget build(BuildContext context) {
    final maxCount = storage.partitionDistribution.values.isNotEmpty
        ? storage.partitionDistribution.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: storage.partitionDistribution.entries.map((entry) {
          final height = (entry.value / maxCount) * 160;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  NumberFormatUtils.compactKilo(entry.value),
                  style: const TextStyle(fontSize: 10),
                ),
                Container(
                  width: 40,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColorMapper.infoColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 40,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}