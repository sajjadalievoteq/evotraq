import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_state.dart';

/// Commissioning throughput bar chart — 24 h (real data) with 1H/7D placeholders.
class ThroughputDummyBarChart extends StatefulWidget {
  const ThroughputDummyBarChart({super.key});

  @override
  State<ThroughputDummyBarChart> createState() => _ThroughputDummyBarChartState();
}

class _ThroughputDummyBarChartState extends State<ThroughputDummyBarChart> {
  int _rangeIndex = 1; // 0 = 1H, 1 = 24H, 2 = 7D

  /// Returns a "nice" y-axis interval that produces ~4 gridlines for [maxY].
  static double _niceInterval(double maxY) {
    if (maxY <= 0) return 10;
    const steps = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000];
    final target = maxY / 4;
    for (final s in steps) {
      if (s >= target) return s.toDouble();
    }
    return ((maxY / 4) / 1000).ceilToDouble() * 1000;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.stats != c.stats || p.throughputLoading != c.throughputLoading,
      builder: (context, state) {
        final buckets   = state.stats?.throughputBuckets ?? {};
        final realTotal = state.stats?.throughputTotal   ?? 0;

        // Compute bars and axis labels for the selected range
        final List<double> bars;
        final int barCount;
        final List<String> barLabels;
        if (_rangeIndex == 0) {
          // 1H: single bucket (hourIndex 0 = most-recent hour)
          barCount = 1;
          bars = [(buckets[0] ?? 0).toDouble()];
          barLabels = [HomeStrings.chartNow];
        } else if (_rangeIndex == 2) {
          // 7D: aggregate 168 hourly buckets into 7 daily totals
          barCount = 7;
          bars = List.generate(7, (day) {
            var sum = 0;
            for (var h = 0; h < 24; h++) {
              sum += buckets[day * 24 + h] ?? 0;
            }
            return sum.toDouble();
          });
          barLabels = List.generate(7, (i) {
            final daysAgo = 6 - i;
            if (daysAgo == 0) return 'Today';
            return DateFormat('EEE')
                .format(DateTime.now().subtract(Duration(days: daysAgo)));
          });
        } else {
          // 24H (default): 24 hourly buckets.
          // Bucket i: i=0 is the oldest hour (23h ago), i=23 is the current hour.
          // Label each bar with the actual clock hour (0-23) it represents.
          final nowHour = DateTime.now().hour;
          barCount = 24;
          bars = List.generate(24, (i) => (buckets[i] ?? 0).toDouble());
          barLabels = List.generate(24, (i) => '${(nowHour - 23 + i + 24) % 24}');
        }

        final allZero = bars.every((v) => v == 0);
        final maxVal = allZero ? 0.0 : bars.reduce((a, b) => a > b ? a : b);
        final maxY = _niceInterval(maxVal) * ((maxVal / _niceInterval(maxVal)).ceil()).toDouble();
        final leftInterval = _niceInterval(maxVal == 0 ? 10 : maxVal);
        final totalLabel = NumberFormat.decimalPattern().format(realTotal);

        final t        = context.text;
        final muted    = context.colors.textMuted;
        final secondary= context.colors.textSecondary;
        final greyBar  = context.colors.textMuted.withValues(alpha: 0.45);
        final greenBar = context.colors.success;

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
              onChanged: (i) {
                setState(() => _rangeIndex = i);
                final hours = const [1, 24, 168][i];
                context.read<HomeCubit>().loadThroughput(hours);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.throughputLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;
              final fallbackH = isSmall ? 200.0 : 240.0;
              final maxH = constraints.maxHeight;
              final chartHeight =
                  maxH.isFinite && maxH > 0 ? maxH : fallbackH;
              final groupsSpace = barCount > 1 ? 4.0 : 0.0;
              final innerW = constraints.maxWidth;
              final rawBarW = barCount == 1
                  ? innerW * 0.4
                  : (innerW - (barCount - 1) * groupsSpace) / barCount;
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
                            final idx = value.toInt();
                            if (idx < 0 || idx >= barCount) {
                              return const SizedBox.shrink();
                            }
                            final label = barLabels[idx];
                            if (label.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            // For 24H: skip odd-numbered labels on narrow charts
                            if (_rangeIndex == 1 && isSmall && idx % 2 != 0) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: t.bodySm.copyWith(
                                  fontSize: isSmall ? 9 : 10,
                                  color: secondary,
                                  fontWeight: idx == barCount - 1
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
                          reservedSize: isSmall ? 36 : 42,
                          interval: leftInterval,
                          getTitlesWidget: (value, meta) {
                            final q = value / leftInterval;
                            final onTick = (q - q.round()).abs() < 1e-6;
                            if (!onTick) return const SizedBox.shrink();
                            final v = (q.round() * leftInterval).round();
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
                      horizontalInterval: leftInterval,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: context.colors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < barCount; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: bars[i],
                              color: i == barCount - 1 ? greenBar : greyBar,
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
      },
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
                      ? c.primary
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
                            ? Colors.white
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
