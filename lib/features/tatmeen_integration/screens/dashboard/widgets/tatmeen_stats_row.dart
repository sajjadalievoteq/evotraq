import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_stat_card.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_stats_skeleton.dart';

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
    if (isLoading || stats == null) return const TatmeenStatsSkeleton();
    final s = stats!;
    return Wrap(
      spacing: TraqSpacing.md,
      runSpacing: TraqSpacing.md,
      alignment: WrapAlignment.spaceBetween,
      children: [
        TatmeenStatCard(
          label: 'Total Synced',
          value: NumberFormat.decimalPattern().format(s.totalSynced),
          iconAsset: AppAssets.iconDatabase,
          color: context.colors.textMuted,
          trend: s.failedTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.all),
        ),
        TatmeenStatCard(
          label: 'Successful',
          value: NumberFormat.decimalPattern().format(s.successfulThisMonth),
          iconAsset: AppAssets.iconCheckCircle,
          color: context.colors.success,
          trend: s.successfulTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.successful),
        ),
        TatmeenStatCard(
          label: 'Failed',
          value: NumberFormat.decimalPattern().format(s.failedThisMonth),
          iconAsset: AppAssets.iconXCircle,
          color: context.colors.error,
          trend: s.failedTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.failed),
        ),
        TatmeenStatCard(
          label: 'Pending',
          value: NumberFormat.decimalPattern().format(s.pendingInQueue),
          iconAsset: AppAssets.iconPending,
          color: context.colors.warning,
          trend: s.pendingTrendPct,
          onTap: onSelectStatus == null
              ? null
              : () => onSelectStatus!(TatmeenRecordsStatusFilter.pending),
        ),
      ],
    );
  }
}
