import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/skeleton/sscc_skeleton_group_card.dart';

class SsccSectionLoadingSkeleton extends StatelessWidget {
  const SsccSectionLoadingSkeleton({
    super.key,
    this.title = 'Loading',
    this.fieldCount = 2,
  });

  final String title;
  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: 0.45,
        );

    return AppShimmer(
      child: SsccSkeletonGroupCard(
        borderColor: border,
        titleWidth: title.length * 8.0 + 40,
        fieldHeights: List<double>.generate(
          fieldCount,
          (i) => i == 0 ? 48 : 56,
        ),
      ),
    );
  }
}
