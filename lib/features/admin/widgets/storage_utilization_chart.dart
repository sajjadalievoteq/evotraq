import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_metric_card.dart';
import 'package:traqtrace_app/features/admin/widgets/storage_utilization_legend_item.dart';
import 'package:traqtrace_app/features/admin/utils/admin_event_visualization_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

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
                SizedBox(
                  width: 220,
                  child: _StoragePieChart(storageStats: storageStats),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StorageLegend(storageStats: storageStats),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StorageMetrics(storageStats: storageStats),
          ],
        ),
      ),
    );
  }

}

class _StoragePieChart extends StatelessWidget {
  const _StoragePieChart({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: PieChartPainter(
          eventTypeDistribution: storageStats.eventTypeDistribution,
          brightness: Theme.of(context).brightness,
        ),
        size: const Size(200, 200),
      ),
    );
  }
}

class _StorageLegend extends StatelessWidget {
  const _StorageLegend({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
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
          return StorageUtilizationLegendItem(
            entry.key,
            entry.value,
            AdminEventVisualizationUtils.eventTypeColor(entry.key, context: context),
          );
        }).toList(),
      ],
    );
  }
}

class _StorageMetrics extends StatelessWidget {
  const _StorageMetrics({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StorageUtilizationMetricCard(
                'Total Storage',
                '${storageStats.totalStorageCapacityGB.toStringAsFixed(0)} GB',
                NavIcons.databasePartitioning,
                AppColorMapper.chartColor(context, 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StorageUtilizationMetricCard(
                'Compression',
                '${storageStats.compressionRatio.toStringAsFixed(1)}:1',
                AppAssets.iconCompress,
                AppColorMapper.chartColor(context, 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StorageUtilizationMetricCard(
                'Partitions',
                storageStats.partitionDistribution.length.toString(),
                NavIcons.masterData,
                AppColorMapper.chartColor(context, 2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StorageUtilizationMetricCard(
                'Avg Size',
                '${storageStats.averagePartitionSize.toStringAsFixed(1)} MB',
                AppAssets.iconFolder,
                AppColorMapper.chartColor(context, 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PartitionDistribution(storageStats: storageStats),
      ],
    );
  }
}

class _PartitionDistribution extends StatelessWidget {
  const _PartitionDistribution({required this.storageStats});
  final StorageStatistics storageStats;

  @override
  Widget build(BuildContext context) {
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
        SizedBox(
          height: 100,
          child: CustomPaint(
            painter: PartitionBarChartPainter(
              partitionDistribution: storageStats.partitionDistribution,
              brightness: Theme.of(context).brightness,
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
                    color: AdminEventVisualizationUtils.partitionColor(
                      entry.key,
                      context: context,
                    ),
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
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> eventTypeDistribution;
  final Brightness brightness;

  PieChartPainter({
    required this.eventTypeDistribution,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (eventTypeDistribution.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * (3.14159 / 180);

    final paint = Paint()..style = PaintingStyle.fill;

    for (final entry in eventTypeDistribution.entries) {
      final sweepAngle = (entry.value / 100) * 2 * 3.14159;

      paint.color = AppColorMapper.eventType(
        entry.key,
        scheme: AppEventColorScheme.admin,
        brightness: brightness,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

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

    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.4, centerPaint);

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PartitionBarChartPainter extends CustomPainter {
  final Map<String, int> partitionDistribution;
  final Brightness brightness;

  PartitionBarChartPainter({
    required this.partitionDistribution,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (partitionDistribution.isEmpty) return;

    final maxValue =
        partitionDistribution.values.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / partitionDistribution.length * 0.8;
    final barSpacing = size.width / partitionDistribution.length * 0.2;
    final palette = brightness == Brightness.dark
        ? OperationPalette.dark
        : OperationPalette.light;

    final paint = Paint()..style = PaintingStyle.fill;
    final colors = palette.chartSeries;

    int index = 0;
    for (final entry in partitionDistribution.entries) {
      final barHeight = (entry.value / maxValue) * (size.height - 20);
      final x = index * (barWidth + barSpacing) + barSpacing / 2;
      final y = size.height - barHeight - 10;

      paint.color = colors[entry.key.hashCode.abs() % colors.length];

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
