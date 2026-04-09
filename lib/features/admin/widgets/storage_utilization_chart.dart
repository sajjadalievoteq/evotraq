import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

class StorageUtilizationChart extends StatelessWidget {
  final StorageStatistics storageStats;

  const StorageUtilizationChart({
    super.key,
    required this.storageStats,
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
              'Storage Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed width for pie chart area
                SizedBox(
                  width: 220, // Fixed width to contain the pie chart
                  child: _buildPieChart(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStorageLegend(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStorageMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: PieChartPainter(
          eventTypeDistribution: storageStats.eventTypeDistribution,
        ),
        size: const Size(200, 200),
      ),
    );
  }

  Widget _buildStorageLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Types',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...storageStats.eventTypeDistribution.entries.map((entry) {
          return _buildLegendItem(
            entry.key,
            entry.value,
            _getEventTypeColor(entry.key),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLegendItem(String eventType, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              eventType,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageMetrics() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Storage',
                '${storageStats.totalStorageCapacityGB.toStringAsFixed(0)} GB',
                Icons.storage,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Compression',
                '${storageStats.compressionRatio.toStringAsFixed(1)}:1',
                Icons.compress,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Partitions',
                storageStats.partitionDistribution.length.toString(),
                Icons.dataset,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Avg Size',
                '${storageStats.averagePartitionSize.toStringAsFixed(1)} MB',
                Icons.folder,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPartitionDistribution(),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
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
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPartitionDistribution() {
    if (storageStats.partitionDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Partition Distribution',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: CustomPaint(
            painter: PartitionBarChartPainter(
              partitionDistribution: storageStats.partitionDistribution,
            ),
            size: const Size(double.infinity, 100),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: storageStats.partitionDistribution.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPartitionColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toUpperCase()) {
      case 'OBJECT':
        return Colors.blue;
      case 'AGGREGATION':
        return Colors.green;
      case 'TRANSACTION':
        return Colors.red;
      case 'TRANSFORMATION':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getPartitionColor(String partition) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[partition.hashCode % colors.length];
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> eventTypeDistribution;

  PieChartPainter({required this.eventTypeDistribution});

  @override
  void paint(Canvas canvas, Size size) {
    if (eventTypeDistribution.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    final paint = Paint()..style = PaintingStyle.fill;

    for (final entry in eventTypeDistribution.entries) {
      final sweepAngle = (entry.value / 100) * 2 * 3.14159;
      
      paint.color = _getEventTypeColor(entry.key);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw white border between segments
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 2;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.4, centerPaint);

    // Draw percentage in center
    final textPainter = _createTextPainter(
      '100%',
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  TextPainter _createTextPainter(String text, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter;
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toUpperCase()) {
      case 'OBJECT':
        return Colors.blue;
      case 'AGGREGATION':
        return Colors.green;
      case 'TRANSACTION':
        return Colors.red;
      case 'TRANSFORMATION':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PartitionBarChartPainter extends CustomPainter {
  final Map<String, int> partitionDistribution;

  PartitionBarChartPainter({required this.partitionDistribution});

  @override
  void paint(Canvas canvas, Size size) {
    if (partitionDistribution.isEmpty) return;

    final maxValue = partitionDistribution.values.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / partitionDistribution.length * 0.8;
    final barSpacing = size.width / partitionDistribution.length * 0.2;

    final paint = Paint()..style = PaintingStyle.fill;

    int index = 0;
    for (final entry in partitionDistribution.entries) {
      final barHeight = (entry.value / maxValue) * (size.height - 20);
      final x = index * (barWidth + barSpacing) + barSpacing / 2;
      final y = size.height - barHeight - 10;

      paint.color = _getPartitionColor(entry.key);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      index++;
    }
  }

  Color _getPartitionColor(String partition) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[partition.hashCode % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
