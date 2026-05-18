import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';

/// Placeholder commissioning throughput (24h bar chart). Replace with API data.
class ThroughputDummyBarChart extends StatefulWidget {
  const ThroughputDummyBarChart({super.key});

  @override
  State<ThroughputDummyBarChart> createState() => _ThroughputDummyBarChartState();
}

class _ThroughputDummyBarChartState extends State<ThroughputDummyBarChart> {
  /// Visual only until API — matches reference toggles.
  int _rangeIndex = 1; // 0 = 1H, 1 = 24H, 2 = 7D

  /// Steady upward trend; last bucket is the “current” hour (highlighted).
  static const List<double> _hourly24 = [
    6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25, 26,
    28, 30, 32, 36,
  ];

  static const int _dummyTotal = 1410;

  String _bottomLabel(int hourIndex) {
    if (hourIndex == 23) return HomeStrings.chartNow;
    switch (hourIndex) {
      case 0:
        return HomeStrings.chartAxis00;
      case 6:
        return HomeStrings.chartAxis06;
      case 12:
        return HomeStrings.chartAxis12;
      case 18:
        return HomeStrings.chartAxis18;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final muted = context.colors.textMuted;
    final secondary = context.colors.textSecondary;
    final greyBar = context.colors.textMuted.withValues(alpha: 0.45);
    final greenBar = context.colors.success;
    final maxY = _hourly24.reduce((a, b) => a > b ? a : b) * 1.12;
    final totalLabel = NumberFormat.decimalPattern().format(_dummyTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalLabel,
                    style: context.text.h1.copyWith(
                      fontSize: 36,
                      height: 1.05,
                      letterSpacing: -0.5,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    HomeStrings.chartUnitsSerialized,
                    style: context.text.bodySm.copyWith(
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),
            _RangeToggle(
              selectedIndex: _rangeIndex,
              onChanged: (i) => setState(() => _rangeIndex = i),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;
              final fallbackH = isSmall ? 200.0 : 240.0;
              final maxH = constraints.maxHeight;
              final chartHeight =
                  maxH.isFinite && maxH > 0 ? maxH : fallbackH;
              const barCount = 24;
              const groupsSpace = 4.0;
              final innerW = constraints.maxWidth;
              final rawBarW =
                  (innerW - (barCount - 1) * groupsSpace) / barCount;
              final barWidth = rawBarW < 1 ? 1.0 : rawBarW;

              return SizedBox(
                height: chartHeight,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    groupsSpace: groupsSpace,
                    maxY: maxY,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final h = value.toInt();
                            if (h < 0 || h >= 24) {
                              return const SizedBox.shrink();
                            }
                            final label = _bottomLabel(h);
                            if (label.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: t.bodySm.copyWith(
                                  fontSize: isSmall ? 9 : 10,
                                  color: secondary,
                                  fontWeight: h == 23
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: isSmall ? 26 : 30,
                          interval: 10,
                          getTitlesWidget: (value, meta) {
                            // Only label exact 10s; rounding alone duplicates (e.g. 39.6 and 40.2 → "40").
                            const step = 10.0;
                            final q = value / step;
                            final onTick = (q - q.round()).abs() < 1e-6;
                            if (!onTick) {
                              return const SizedBox.shrink();
                            }
                            final v = q.round() * 10;
                            if (v < 0 || v > maxY.ceil()) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '$v',
                              style: t.bodySm.copyWith(
                                fontSize: isSmall ? 8 : 10,
                                color: muted,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: context.colors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < 24; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: _hourly24[i],
                              color: i == 23 ? greenBar : greyBar,
                              width: barWidth,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    
      ],
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = HomeStrings.chartRangeLabels;
    final c = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.borderVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selectedIndex == i
                      ? c.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      labels[i],
                      style: context.text.bodySm.copyWith(
                        fontWeight: selectedIndex == i
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == i
                            ? c.textPrimary
                            : c.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
