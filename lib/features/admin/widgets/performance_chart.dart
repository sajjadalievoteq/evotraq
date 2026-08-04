import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/performance_chart_legend_item.dart';

class PerformanceChart extends StatelessWidget {
  final List<PerformanceMetrics> metrics;
  final String chartType;

  const PerformanceChart({
    super.key,
    required this.metrics,
    this.chartType = 'response_time',
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const Center(
        child: Text('No performance data available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _chartTitle(chartType),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: LineChartPainter(
                  metrics: metrics,
                  chartType: chartType,
                  brightness: Theme.of(context).brightness,
                ),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PerformanceChartLegendItem(
                'Object',
                AppColorMapper.eventTypeColor(
                  context,
                  'Object',
                  scheme: AppEventColorScheme.admin,
                ),
              ),
              PerformanceChartLegendItem(
                'Aggregation',
                AppColorMapper.eventTypeColor(
                  context,
                  'Aggregation',
                  scheme: AppEventColorScheme.admin,
                ),
              ),
              PerformanceChartLegendItem(
                'Transaction',
                AppColorMapper.eventTypeColor(
                  context,
                  'Transaction',
                  scheme: AppEventColorScheme.admin,
                ),
              ),
              PerformanceChartLegendItem(
                'Transform',
                AppColorMapper.eventTypeColor(
                  context,
                  'Transformation',
                  scheme: AppEventColorScheme.admin,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _chartTitle(String chartType) {
    switch (chartType) {
      case 'response_time':
        return 'Average Response Time Trends';
      case 'throughput':
        return 'Event Processing Throughput';
      case 'errors':
        return 'Error Rate Analysis';
      case 'success_rate':
        return 'Success Rate Trends';
      default:
        return 'Performance Metrics';
    }
  }
}

class LineChartPainter extends CustomPainter {
  final List<PerformanceMetrics> metrics;
  final String chartType;
  final Brightness brightness;

  LineChartPainter({
    required this.metrics,
    required this.chartType,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()..style = PaintingStyle.fill;

    final double maxY = _getMaxValue();
    final double minY = _getMinValue();
    final double rangeY = maxY - minY;

    if (rangeY == 0) return;

    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawDataLines(canvas, size, paint, pointPaint, minY, rangeY);
    _drawLabels(canvas, size, minY, maxY);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= 10; i++) {
      final x = 40 + (size.width - 60) * i / 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 30),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    canvas.drawLine(
      const Offset(40, 0),
      Offset(40, size.height - 30),
      axisPaint,
    );

    canvas.drawLine(
      Offset(40, size.height - 30),
      Offset(size.width - 20, size.height - 30),
      axisPaint,
    );
  }

  void _drawDataLines(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint pointPaint,
    double minY,
    double rangeY,
  ) {
    final p = brightness == Brightness.dark
        ? OperationPalette.dark
        : OperationPalette.light;
    final colors = [
      p.eventObject,
      p.eventAggregation,
      p.eventTransactionAdmin,
      p.eventTransformation,
    ];
    final dataPoints = _getDataPoints();

    for (int seriesIndex = 0; seriesIndex < dataPoints.length; seriesIndex++) {
      final series = dataPoints[seriesIndex];
      if (series.isEmpty) continue;

      paint.color = colors[seriesIndex % colors.length];
      pointPaint.color = paint.color;

      final path = Path();
      bool isFirst = true;

      for (int i = 0; i < series.length; i++) {
        final x = 40 + (size.width - 60) * i / (series.length - 1);
        final y = size.height -
            30 -
            (size.height - 30) * (series[i] - minY) / rangeY;

        if (isFirst) {
          path.moveTo(x, y);
          isFirst = false;
        } else {
          path.lineTo(x, y);
        }

        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double minY, double maxY) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
    );

    for (int i = 0; i <= 5; i++) {
      final value = minY + (maxY - minY) * i / 5;
      final y = size.height - 30 - (size.height - 30) * i / 5;

      final textSpan = TextSpan(
        text: value.toStringAsFixed(1),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
  }

  List<List<double>> _getDataPoints() {
    switch (chartType) {
      case 'response_time':
        return [
          metrics
              .map((m) =>
                  m.eventTypeMetrics['OBJECT']?.averageProcessingTime ?? 0.0)
              .toList(),
          metrics
              .map((m) =>
                  m.eventTypeMetrics['AGGREGATION']?.averageProcessingTime ??
                  0.0)
              .toList(),
          metrics
              .map((m) =>
                  m.eventTypeMetrics['TRANSACTION']?.averageProcessingTime ??
                  0.0)
              .toList(),
          metrics
              .map((m) =>
                  m.eventTypeMetrics['TRANSFORMATION']?.averageProcessingTime ??
                  0.0)
              .toList(),
        ];
      case 'throughput':
        return [
          metrics.map((m) => m.eventsPerSecond).toList(),
        ];
      case 'errors':
        return [
          metrics.map((m) => m.errorRate).toList(),
        ];
      case 'success_rate':
        return [
          metrics.map((m) => m.successRate).toList(),
        ];
      default:
        return [];
    }
  }

  double _getMaxValue() {
    final dataPoints = _getDataPoints();
    double max = 0;
    for (final series in dataPoints) {
      for (final value in series) {
        if (value > max) max = value;
      }
    }
    return max;
  }

  double _getMinValue() {
    final dataPoints = _getDataPoints();
    double min = double.infinity;
    for (final series in dataPoints) {
      for (final value in series) {
        if (value < min) min = value;
      }
    }
    return min == double.infinity ? 0 : min;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
