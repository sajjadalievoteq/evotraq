import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

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
          _getChartTitle(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Remove Expanded and use a fixed height container instead
        SizedBox(
          height: 200, // Fixed height for chart area
          child: _buildChart(),
        ),
        const SizedBox(height: 4),
        _buildLegend(),
      ],
    );
  }

  String _getChartTitle() {
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

  Widget _buildChart() {
    if (metrics.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: LineChartPainter(
            metrics: metrics,
            chartType: chartType,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }

  Widget _buildLegend() {
    return SizedBox(
      height: 20, // Fixed height for legend
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Object', Colors.blue),
          _buildLegendItem('Aggregation', Colors.green),
          _buildLegendItem('Transaction', Colors.red),
          _buildLegendItem('Transform', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<PerformanceMetrics> metrics;
  final String chartType;

  LineChartPainter({
    required this.metrics,
    required this.chartType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    // Calculate bounds
    final double maxY = _getMaxValue();
    final double minY = _getMinValue();
    final double rangeY = maxY - minY;

    if (rangeY == 0) return;

    // Draw grid lines
    _drawGrid(canvas, size);

    // Draw axes
    _drawAxes(canvas, size);

    // Draw data lines
    _drawDataLines(canvas, size, paint, pointPaint, minY, rangeY);

    // Draw labels
    _drawLabels(canvas, size, minY, maxY);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Vertical grid lines
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

    // Y-axis
    canvas.drawLine(
      const Offset(40, 0),
      Offset(40, size.height - 30),
      axisPaint,
    );

    // X-axis
    canvas.drawLine(
      Offset(40, size.height - 30),
      Offset(size.width - 20, size.height - 30),
      axisPaint,
    );
  }

  void _drawDataLines(Canvas canvas, Size size, Paint paint, Paint pointPaint,
      double minY, double rangeY) {
    final colors = [Colors.blue, Colors.green, Colors.red, Colors.purple];
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
        final y = size.height - 30 - (size.height - 30) * (series[i] - minY) / rangeY;

        if (isFirst) {
          path.moveTo(x, y);
          isFirst = false;
        } else {
          path.lineTo(x, y);
        }

        // Draw point
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double minY, double maxY) {
    final textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 10,
    );

    // Y-axis labels
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
          metrics.map((m) => m.eventTypeMetrics['OBJECT']?.averageProcessingTime ?? 0.0).toList(),
          metrics.map((m) => m.eventTypeMetrics['AGGREGATION']?.averageProcessingTime ?? 0.0).toList(),
          metrics.map((m) => m.eventTypeMetrics['TRANSACTION']?.averageProcessingTime ?? 0.0).toList(),
          metrics.map((m) => m.eventTypeMetrics['TRANSFORMATION']?.averageProcessingTime ?? 0.0).toList(),
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
