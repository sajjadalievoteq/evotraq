import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';

/// Placeholder column for [Gs1FormShimmerLayer] — approximates GTIN detail length.
class GtinDetailFormSkeleton extends StatelessWidget {
  const GtinDetailFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        GtinSkeletonOutlineField(color: c, height: 76),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
            const SizedBox(width: 8),
            Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
            const SizedBox(width: 8),
            Expanded(child: GtinSkeletonOutlineField(color: c, height: 36)),
          ],
        ),
        const SizedBox(height: 32),
        for (var i = 0; i < 14; i++) ...[
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 24),
        ],
        GtinSkeletonExtensionTile(color: c),
        GtinSkeletonExtensionTile(color: c),
        GtinSkeletonExtensionTile(color: c),
        const SizedBox(height: 32),
        GtinSkeletonPrimaryButton(color: c),
        const SizedBox(height: 24),
      ],
    );
  }
}
