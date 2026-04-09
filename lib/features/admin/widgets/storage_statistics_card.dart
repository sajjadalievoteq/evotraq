import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

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
            
            // Storage overview
            Row(
              children: [
                Expanded(
                  child: _buildStorageMetric(
                    'Total Events',
                    _formatNumber(storage.totalEvents),
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStorageMetric(
                    'Storage Used',
                    '${storage.storageUsedGB.toStringAsFixed(2)} GB',
                    Icons.storage,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStorageMetric(
                    'Partitions',
                    '${storage.partitionDistribution.length}',
                    Icons.view_module,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStorageMetric(
                    'Compression Ratio',
                    '${storage.compressionRatio.toStringAsFixed(1)}:1',
                    Icons.compress,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Event type distribution
            const Text(
              'Event Type Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...storage.eventTypeDistribution.entries.map((entry) => 
              _buildEventTypeRow(entry.key, entry.value)
            ).toList(),
            
            const SizedBox(height: 24),
            
            // Partition distribution
            const Text(
              'Partition Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _buildPartitionChart(),
            ),
            
            const SizedBox(height: 24),
            
            // Archive information
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
            
            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showArchiveDialog(context),
                  icon: const Icon(Icons.archive),
                  label: const Text('Archive Old Events'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCompressionDialog(context),
                  icon: const Icon(Icons.compress),
                  label: const Text('Compress Events'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

  Widget _buildStorageMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeRow(String eventType, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              eventType,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(_getEventTypeColor(eventType)),
            ),
          ),
          const SizedBox(width: 8),
          Text('${percentage.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildPartitionChart() {
    // Simple bar chart for partition distribution
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
                  _formatNumber(entry.value),
                  style: const TextStyle(fontSize: 10),
                ),
                Container(
                  width: 40,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.blue,
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

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'object_event':
        return Colors.blue;
      case 'aggregation_event':
        return Colors.green;
      case 'transaction_event':
        return Colors.orange;
      case 'transformation_event':
        return Colors.purple;
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
              onCompressEvents([]); // Empty list means compress all eligible events
            },
            child: const Text('Compress'),
          ),
        ],
      ),
    );
  }
}
