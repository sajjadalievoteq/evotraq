import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/skeleton/object_event_skeleton_group_card.dart';

class ObjectEventDetailSkeleton extends StatelessWidget {
  const ObjectEventDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final border = Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: 0.45,
        );

    Widget group({
      required double titleWidth,
      required List<double> fieldHeights,
      double fieldSpacing = 12,
    }) {
      return ObjectEventSkeletonGroupCard(
        borderColor: border,
        baseColor: baseColor,
        titleWidth: titleWidth,
        fieldHeights: fieldHeights,
        fieldSpacing: fieldSpacing,
      );
    }

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            group(
              titleWidth: 180,
              fieldHeights: const [56, 40, 40, 40, 40, 40],
              fieldSpacing: 16,
            ),
            const SizedBox(height: 12),
            group(
              titleWidth: 160,
              fieldHeights: const [24, 24, 24, 24],
            ),
            const SizedBox(height: 12),
            group(
              titleWidth: 170,
              fieldHeights: const [56, 56],
            ),
            const SizedBox(height: 12),
            group(
              titleWidth: 150,
              fieldHeights: const [40, 40, 40, 56],
            ),
            const SizedBox(height: 12),
            group(
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
