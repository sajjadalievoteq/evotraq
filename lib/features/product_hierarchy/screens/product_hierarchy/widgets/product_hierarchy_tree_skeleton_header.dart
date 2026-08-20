import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/product_hierarchy/widgets/product_hierarchy_ancestor_accent_rails.dart';

class ProductHierarchyTreeSkeletonHeader extends StatelessWidget {
  const ProductHierarchyTreeSkeletonHeader({
    super.key,
    required this.isGroupHeader,
    required this.railCount,
  });
  final bool isGroupHeader;
  final int railCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final frame = BorderSide(color: colors.borderStrong);
    final row = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: isGroupHeader ? BorderRadius.zero : TraqRadius.card,
        border: isGroupHeader
            ? Border(top: frame, right: frame)
            : Border.all(color: colors.border),
      ),
      child: const Row(
        children: [
          AppSkeletonBox(width: 22, height: 22, radius: 4),
          SizedBox(width: 5),
          AppSkeletonBox(width: 36, height: 14, radius: 4),
          SizedBox(width: 5),
          AppSkeletonBox(width: 20, height: 20, radius: 6),
          SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: AppSkeletonBox(
              width: double.infinity,
              height: 14,
              radius: 4,
            ),
          ),
          SizedBox(width: TraqSpacing.sm),
          AppSkeletonBox(width: 28, height: 18, radius: 10),
          SizedBox(width: 4),
          AppSkeletonBox(width: 28, height: 28, radius: 6),
        ],
      ),
    );
    final framed = isGroupHeader
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceMuted.withValues(alpha: 0.55),
            ),
            child: row,
          )
        : row;
    return ProductHierarchyAncestorAccentRails(
      railCount: railCount,
      child: framed,
    );
  }
}
