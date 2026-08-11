import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/widgets/skeleton/object_event_skeleton_group_card.dart';

class ObjectEventDetailSkeleton extends StatelessWidget {
  const ObjectEventDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final border = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.45);

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ObjectEventSkeletonGroupCard(
              borderColor: border,
              baseColor: baseColor,
              titleWidth: 180,
              fieldHeights: const [56, 40, 40, 40, 40, 40],
              fieldSpacing: 16,
            ),
            const SizedBox(height: 12),
            ObjectEventSkeletonGroupCard(
              borderColor: border,
              baseColor: baseColor,
              titleWidth: 160,
              fieldHeights: const [24, 24, 24, 24],
            ),
            const SizedBox(height: 12),
            ObjectEventSkeletonGroupCard(
              borderColor: border,
              baseColor: baseColor,
              titleWidth: 170,
              fieldHeights: const [56, 56],
            ),
            const SizedBox(height: 12),
            ObjectEventSkeletonGroupCard(
              borderColor: border,
              baseColor: baseColor,
              titleWidth: 150,
              fieldHeights: const [40, 40, 40, 56],
            ),
            const SizedBox(height: 12),
            ObjectEventSkeletonGroupCard(
              borderColor: border,
              baseColor: baseColor,
              titleWidth: 200,
              fieldHeights: const [24, 24, 24],
            ),
            const SizedBox(height: Constants.spacing * 2),
          ],
        ),
      ),
    );
  }
}
