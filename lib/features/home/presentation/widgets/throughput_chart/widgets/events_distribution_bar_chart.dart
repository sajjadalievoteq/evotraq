import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_state.dart';

class EventsDistributionBarChart extends StatelessWidget {
  const EventsDistributionBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      buildWhen: (p, c) => p.stats != c.stats,
      builder: (context, state) {
        final eventCounts = state.stats?.eventsByType ?? {};

        if (eventCounts.isEmpty) {
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No event data available',
                  style: context.text.body.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }

        final t = context.text;
        final muted = context.colors.textMuted;
        final secondary = context.colors.textSecondary;

        final entries = eventCounts.entries.toList();
        final calculatedMaxY =
            entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;
        final maxY = calculatedMaxY > 0 ? calculatedMaxY.toDouble() : 10.0;

        final barColors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
        ];

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;
                final barWidth = isSmallScreen ? 20.0 : 40.0;
                final chartHeight = isSmallScreen ? 220.0 : 300.0;

                return SizedBox(
                  height: chartHeight,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${entries[groupIndex].key}\n${rod.toY.toInt()}',
                              t.mono.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < entries.length) {
                                String label = entries[index].key;
                                if (label.contains(' ')) {
                                  label = label.split(' ').first;
                                }
                                if (isSmallScreen && label.length > 4) {
                                  label = label.substring(0, 3);
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    label,
                                    style: t.bodySm.copyWith(
                                      fontSize: isSmallScreen ? 8 : 10,
                                      color: secondary,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isSmallScreen ? 30 : 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: t.bodySm.copyWith(
                                  fontSize: isSmallScreen ? 8 : 10,
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
                        horizontalInterval: maxY / 5,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: entries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value.toDouble(),
                              color: barColors[index % barColors.length],
                              width: barWidth,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
