import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/throughput_chart_utils.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/widgets/throughput_range_toggle.dart';

class ThroughputDummyBarChart extends StatefulWidget {
  const ThroughputDummyBarChart({super.key});

  @override
  State<ThroughputDummyBarChart> createState() => _ThroughputDummyBarChartState();
}

class _ThroughputDummyBarChartState extends State<ThroughputDummyBarChart> {
  int _rangeIndex = 1;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.stats != c.stats || p.throughputLoading != c.throughputLoading,
      builder: (context, state) {
        final buckets   = state.stats?.throughputBuckets ?? {};
        final realTotal = state.stats?.throughputTotal   ?? 0;

        final List<double> bars;
        final int barCount;
        final List<String> barLabels;
        if (_rangeIndex == 0) {
          barCount = 1;
          bars = [(buckets[0] ?? 0).toDouble()];
          barLabels = [HomeStrings.chartNow];
        } else if (_rangeIndex == 2) {
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
          final nowHour = DateTime.now().hour;
          barCount = 24;
          bars = List.generate(24, (i) => (buckets[i] ?? 0).toDouble());
          barLabels = List.generate(24, (i) => '${(nowHour - 23 + i + 24) % 24}');
        }

        final allZero = bars.every((v) => v == 0);
        final maxVal = allZero ? 0.0 : bars.reduce((a, b) => a > b ? a : b);
        final maxY = ThroughputChartUtils.niceInterval(maxVal) *
            ((maxVal / ThroughputChartUtils.niceInterval(maxVal)).ceil())
                .toDouble();
        final leftInterval =
            ThroughputChartUtils.niceInterval(maxVal == 0 ? 10 : maxVal);
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
            ThroughputRangeToggle(
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
                            final label = _rangeIndex == 1
                                ? '${barLabels[idx]}:00'
                                : barLabels[idx];
                            if (label.isEmpty) {
                              return const SizedBox.shrink();
                            }
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
