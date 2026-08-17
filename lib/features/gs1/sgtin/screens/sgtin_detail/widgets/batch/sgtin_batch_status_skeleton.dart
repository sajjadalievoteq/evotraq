import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class SgtinBatchStatusSkeleton extends StatelessWidget {
  const SgtinBatchStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppShimmer.defaultBaseColor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeletonBox(width: 20, height: 20, radius: 10, color: muted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonBox(
                    width: 220,
                    height: 14,
                    radius: 4,
                    color: muted,
                  ),
                  const SizedBox(height: 8),
                  AppSkeletonBox(
                    width: 140,
                    height: 12,
                    radius: 4,
                    color: muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
