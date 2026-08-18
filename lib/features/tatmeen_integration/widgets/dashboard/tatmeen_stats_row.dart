import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

class TatmeenStatsRow extends StatelessWidget {
  const TatmeenStatsRow({super.key, required this.stats, required this.isLoading});

  final TatmeenDashboardStats? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading || stats == null) return const _StatsSkeleton();
    final s = stats!;
    return Wrap(

      spacing: TraqSpacing.md,
      runSpacing: TraqSpacing.md,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _item(context, 'Total Synced', NumberFormat.decimalPattern().format(s.totalSynced), AppAssets.iconDatabase, context.colors.textMuted,trend: s.failedTrendPct),
        _item(context, 'Successful', NumberFormat.decimalPattern().format(s.successfulThisMonth), AppAssets.iconCheckCircle, context.colors.success, trend: s.successfulTrendPct),
        _item(context, 'Failed', NumberFormat.decimalPattern().format(s.failedThisMonth), AppAssets.iconXCircle, context.colors.error, trend: s.failedTrendPct),
        _item(context, 'Pending', NumberFormat.decimalPattern().format(s.pendingInQueue), AppAssets.iconPending, context.colors.warning, trend: s.pendingTrendPct),
      ],
    );
  }

  Widget _item(BuildContext context, String label, String value, String iconAsset, Color color, {double? trend}) {
    final width = (MediaQuery.sizeOf(context).width >= 1200)
        ? (MediaQuery.sizeOf(context).width - 520) / 4
        : (MediaQuery.sizeOf(context).width >= 760 ? (MediaQuery.sizeOf(context).width - 460) / 2 : double.infinity);
    return SizedBox(
      width: width,
      child: TraqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(iconAsset, size: 18, color: color),
                const SizedBox(width: TraqSpacing.xs),
                Expanded(child: Text(label, style: context.text.bodySm.copyWith(color: context.colors.textMuted))),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            Text(value, style: context.text.h2.copyWith(fontWeight: FontWeight.w700)),
            if (trend != null) ...[
              const SizedBox(height: TraqSpacing.xs),
              Text(
                '${trend >= 0 ? '↑' : '↓'} ${trend.abs().toStringAsFixed(1)}% vs last month',
                style: context.text.bodySm.copyWith(color: trend >= 0 ? context.colors.success : context.colors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Wrap(
        spacing: TraqSpacing.md,
        runSpacing: TraqSpacing.md,
        children: List.generate(
          4,
          (_) => SizedBox(
            width: 220,
            child: TraqCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonBox(width: 120, height: 14, color: base),
                  const SizedBox(height: TraqSpacing.sm),
                  AppSkeletonBox(width: 96, height: 28, color: base),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
