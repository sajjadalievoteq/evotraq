import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';

import '../../../../../../core/consts/app_consts.dart';

/// Placeholder column for [Gs1FormShimmerLayer] — approximates GLN detail sections.
class GlnDetailFormSkeleton extends StatelessWidget {
  const GlnDetailFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    Widget row3() {
      return Row(
        children: [
          Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
          const SizedBox(width: 8),
          Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
          const SizedBox(width: 8),
          Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      const SizedBox(height: Constants.spacing),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        row3(),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),
        GtinSkeletonExtensionTile(color: c),
        GtinSkeletonExtensionTile(color: c),
        const SizedBox(height: 24),
        GtinSkeletonPrimaryButton(color: c),
        const SizedBox(height: 24),
      ],
    );
  }
}
