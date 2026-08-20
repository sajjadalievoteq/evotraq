import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';

import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_error_summary_skeleton.dart';

class TatmeenErrorSummary extends StatelessWidget {
  const TatmeenErrorSummary({
    super.key,
    required this.items,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final List<TatmeenErrorSummaryItem> items;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const TatmeenErrorSummarySkeleton();
    if (error != null) {
      return SubscriptionErrorView(
        title: 'Unable to load error summary',
        message: error!,
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      );
    }
    if (items.isEmpty) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconCheckCircle,
        title: 'No errors recorded',
      );
    }
    return Column(
      children: items.take(5).map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: e.message,
                  child: Text(
                    e.message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: TraqSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TraqSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.12),
                  border: Border.all(
                    color: context.colors.error.withValues(alpha: 0.35),
                  ),
                  borderRadius: TraqRadius.chip,
                ),
                child: Text(
                  '${e.count}',
                  style: context.text.bodySm.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
