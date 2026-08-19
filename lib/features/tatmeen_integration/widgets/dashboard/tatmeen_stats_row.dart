import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';

class TatmeenStatsRow extends StatelessWidget {
  const TatmeenStatsRow({
    super.key,
    required this.stats,
    required this.isLoading,
    this.onSelectStatus,
  });

  final TatmeenDashboardStats? stats;
  final bool isLoading;
  final ValueChanged<TatmeenRecordsStatusFilter>? onSelectStatus;

  @override
  Widget build(BuildContext context) {
    if (isLoading || stats == null) return const _StatsSkeleton();
    final s = stats!;
    return Wrap(
      spacing: TraqSpacing.md,
      runSpacing: TraqSpacing.md,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _item(
          context,
          'Total Synced',
          NumberFormat.decimalPattern().format(s.totalSynced),
          AppAssets.iconDatabase,
          context.colors.textMuted,
          trend: s.failedTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.all),
        ),
        _item(
          context,
          'Successful',
          NumberFormat.decimalPattern().format(s.successfulThisMonth),
          AppAssets.iconCheckCircle,
          context.colors.success,
          trend: s.successfulTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.successful),
        ),
        _item(
          context,
          'Failed',
          NumberFormat.decimalPattern().format(s.failedThisMonth),
          AppAssets.iconXCircle,
          context.colors.error,
          trend: s.failedTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.failed),
        ),
        _item(
          context,
          'Pending',
          NumberFormat.decimalPattern().format(s.pendingInQueue),
          AppAssets.iconPending,
          context.colors.warning,
          trend: s.pendingTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.pending),
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    String value,
    String iconAsset,
    Color color, {
    double? trend,
    VoidCallback? onTap,
  }) {
    final width = _tatmeenKpiCardWidth(context);
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: TraqRadius.card,
        child: TraqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(iconAsset, size: 18, color: color),
                const SizedBox(width: TraqSpacing.xs),
                Expanded(child: Text(label, style: context.text.bodySm.copyWith(color: context.colors.textMuted))),
                if (onTap != null)
                  TraqIcon(
                    AppAssets.iconChevronR,
                    size: 14,
                    color: context.colors.textMuted,
                  ),
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
      ),
    );
  }
}

double _tatmeenKpiCardWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1200) return (width - 520) / 4;
  if (width >= 760) return (width - 460) / 2;
  return double.infinity;
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    final width = _tatmeenKpiCardWidth(context);
    return AppShimmer(
      child: Wrap(
        spacing: TraqSpacing.md,
        runSpacing: TraqSpacing.md,
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(
          4,
          (_) => SizedBox(
            width: width,
            child: TraqCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppSkeletonBox(
                        width: 18,
                        height: 18,
                        radius: 9,
                        color: base,
                      ),
                      const SizedBox(width: TraqSpacing.xs),
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.6,
                          child: AppSkeletonBox(height: 14, color: base),
                        ),
                      ),
                      AppSkeletonBox(
                        width: 14,
                        height: 14,
                        radius: 4,
                        color: base,
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  AppSkeletonBox(width: 96, height: 28, color: base),
                  const SizedBox(height: TraqSpacing.xs),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.4,
                    child: AppSkeletonBox(height: 12, color: base),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
