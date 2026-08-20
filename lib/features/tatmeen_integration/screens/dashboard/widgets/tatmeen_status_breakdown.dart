import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown_skeleton.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown_legend.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown_pie.dart';

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
    if (isLoading) return const TatmeenStatusBreakdownSkeleton();
    if (error != null) {
      return SubscriptionErrorView(
        title: 'Unable to load status breakdown',
        message: error!,
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      );
    }
    if (breakdown == null || breakdown!.total == 0) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconDashboard,
        title: 'No status data yet',
        subtitle: 'Monthly status breakdown will appear here.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              TatmeenStatusBreakdownPie(breakdown: breakdown!),
              const SizedBox(height: TraqSpacing.md),
              TatmeenStatusBreakdownLegend(breakdown: breakdown!),
            ],
          );
        }
        return Row(
          children: [
            TatmeenStatusBreakdownPie(breakdown: breakdown!),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              child: TatmeenStatusBreakdownLegend(breakdown: breakdown!),
            ),
          ],
        );
      },
    );
  }
}
