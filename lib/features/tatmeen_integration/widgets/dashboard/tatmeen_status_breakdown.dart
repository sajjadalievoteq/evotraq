import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

class TatmeenStatusBreakdownChart extends StatelessWidget {
  const TatmeenStatusBreakdownChart({
    super.key,
    required this.breakdown,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final TatmeenStatusBreakdown? breakdown;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _BreakdownSkeleton();
    if (error != null) {
      return Center(child: FilledButton(onPressed: onRetry, child: const Text('Retry')));
    }
    if (breakdown == null || breakdown!.total == 0) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconDashboard,
        title: 'No status data yet',
        subtitle: 'Monthly status breakdown will appear here.',
      );
    }
    final b = breakdown!;
    final sections = [
      ('Successful', b.successful, context.colors.success),
      ('Failed', b.failed, context.colors.error),
      ('Pending', b.pending, context.colors.warning),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final chart = SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                  sections: sections
                      .map(
                        (s) => PieChartSectionData(
                          value: s.$2.toDouble(),
                          color: s.$3,
                          radius: 26,
                          showTitle: false,
                        ),
                      )
                      .toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${b.total}', style: context.text.h2.copyWith(fontWeight: FontWeight.w700)),
                  Text('This month', style: context.text.bodySm.copyWith(color: context.colors.textMuted)),
                ],
              ),
            ],
          ),
        );
        final legend = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections.map((s) {
            final pct = b.total == 0 ? 0 : (s.$2 / b.total * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: s.$3, shape: BoxShape.circle)),
                  const SizedBox(width: TraqSpacing.xs),
                  Expanded(child: Text(s.$1, style: context.text.bodySm)),
                  Text('${pct.toStringAsFixed(1)}%', style: context.text.bodySm.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }).toList(),
        );
        if (compact) return Column(children: [chart, const SizedBox(height: TraqSpacing.md), legend]);
        return Row(children: [chart, const SizedBox(width: TraqSpacing.md), Expanded(child: legend)]);
      },
    );
  }
}

class _BreakdownSkeleton extends StatelessWidget {
  const _BreakdownSkeleton();
  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(child: AppSkeletonBox(height: 220, color: muted));
  }
}
