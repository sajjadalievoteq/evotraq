import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_extension_tile.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_outline_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_skeleton_three_field_row.dart';

class GlnDetailFormSkeleton extends StatelessWidget {
  const GlnDetailFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GlnSkeletonThreeFieldRow(color: c),
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
