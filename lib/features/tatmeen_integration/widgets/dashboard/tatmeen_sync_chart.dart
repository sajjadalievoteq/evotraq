import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';

class TatmeenSyncChart extends StatelessWidget {
  const TatmeenSyncChart({
    super.key,
    required this.data,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final List<TatmeenChartPoint> data;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  static const _yInterval = 100.0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _ChartSkeleton();
    if (error != null) {
      return SubscriptionErrorView(
        title: 'Unable to load chart',
        message: error!,
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      );
    }
    if (data.isEmpty) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconBarChart,
        title: 'No sync activity yet',
        subtitle: 'Sync activity will appear once Tatmeen traffic starts.',
      );
    }

    var peak = 0.0;
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      final successful = data[i].successful.toDouble();
      final failed = data[i].failed.toDouble();
      if (successful > peak) peak = successful;
      if (failed > peak) peak = failed;
      bars.add(
        BarChartGroupData(
          x: i,
          barsSpace: 3,
          barRods: [
            BarChartRodData(
              toY: successful,
              width: 5,
              color: context.colors.success,
            ),
            BarChartRodData(
              toY: failed,
              width: 5,
              color: context.colors.error,
            ),
          ],
        ),
      );
    }

    final maxY = ((peak / _yInterval).ceil() * _yInterval).clamp(
      _yInterval,
      double.infinity,
    );
    const dateTickCount = 6;
    final lastIndex = data.length - 1;
    final dateLabelIndexes = <int>{
      if (data.length == 1)
        0
      else
        for (var k = 0; k < dateTickCount; k++)
          ((k * lastIndex) / (dateTickCount - 1)).round(),
    };
    final colors = context.colors;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final tooltipStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: colors.onPrimary,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TraqSpacing.sm,
              TraqSpacing.xs,
              TraqSpacing.lg,
              TraqSpacing.xs,
            ),
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _yInterval,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: _yInterval,
                      minIncluded: true,
                      maxIncluded: false,
                      getTitlesWidget: (value, meta) {
                        if ((value % _yInterval).abs() > 0.01) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.round().toString(),
                          maxLines: 1,
                          softWrap: false,
                          style: labelStyle,
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      maxIncluded: false,
                      getTitlesWidget: (value, meta) {
                        final i = value.round();
                        if (!dateLabelIndexes.contains(i)) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i == lastIndex ? TraqSpacing.md : 0,
                          ),
                          child: Text(
                            DateFormat('MMM d').format(data[i].date),
                            style: labelStyle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < 0 || groupIndex >= data.length) {
                        return null;
                      }
                      final point = data[groupIndex];
                      final label = rodIndex == 0 ? 'Successful' : 'Failed';
                      return BarTooltipItem(
                        '${DateFormat('MMM d').format(point.date)}\n$label: ${rod.toY.toInt()}',
                        tooltipStyle,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: TraqSpacing.sm),
        Row(
          children: [
            _LegendDot(label: 'Successful', color: colors.success),
            const SizedBox(width: TraqSpacing.md),
            _LegendDot(label: 'Failed', color: colors.error),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: TraqSpacing.xs),
        Text(label, style: context.text.bodySm),
      ],
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();
  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: SizedBox.expand(
        child: AppSkeletonBox(height: double.infinity, color: muted),
      ),
    );
  }
}
