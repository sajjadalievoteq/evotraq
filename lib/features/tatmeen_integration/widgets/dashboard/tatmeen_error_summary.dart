import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

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
    if (isLoading) return const _ErrorSkeleton();
    if (error != null) return Center(child: FilledButton(onPressed: onRetry, child: const Text('Retry')));
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
                  child: Text(e.message, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              ),
              const SizedBox(width: TraqSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: TraqSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.12),
                  border: Border.all(color: context.colors.error.withValues(alpha: 0.35)),
                  borderRadius: TraqRadius.chip,
                ),
                child: Text('${e.count}', style: context.text.bodySm.copyWith(color: context.colors.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorSkeleton extends StatelessWidget {
  const _ErrorSkeleton();
  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
            child: AppSkeletonBox(height: 20, color: muted),
          ),
        ),
      ),
    );
  }
}
