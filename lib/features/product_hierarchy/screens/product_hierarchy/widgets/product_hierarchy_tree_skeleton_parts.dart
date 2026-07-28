import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/product_hierarchy/widgets/product_hierarchy_ancestor_accent_rails.dart';

class ProductHierarchyTreeSkeletonGroupBody extends StatelessWidget {
  const ProductHierarchyTreeSkeletonGroupBody({
    super.key,
    required this.railCount,
    required this.bottomAccent,
    required this.children,
  });

  final int railCount;
  final Color bottomAccent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final frame = BorderSide(color: c.borderStrong);

    final body = DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceMuted.withValues(alpha: 0.55),
        border: Border(
          top: frame,
          right: frame,
          bottom: BorderSide(
            color: bottomAccent,
            width: ProductHierarchyAncestorAccentRails.defaultAccentWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: TraqSpacing.xs),
              children[i],
            ],
          ],
        ),
      ),
    );

    return ProductHierarchyAncestorAccentRails(
      railCount: railCount,
      child: body,
    );
  }
}

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
    final c = context.colors;
    final radius = isGroupHeader ? BorderRadius.zero : TraqRadius.card;
    final frame = BorderSide(color: c.borderStrong);

    final row = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        border: isGroupHeader
            ? Border(top: frame, right: frame)
            : Border.all(color: c.border),
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
              color: c.surfaceMuted.withValues(alpha: 0.55),
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

class ProductHierarchyTreeSkeletonLeafRow extends StatelessWidget {
  const ProductHierarchyTreeSkeletonLeafRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.sm,
      ),
      child: Row(
        children: [
          AppSkeletonBox(width: 36, height: 14, radius: 4),
          SizedBox(width: TraqSpacing.sm),
          AppSkeletonBox(width: 18, height: 18, radius: 6),
          SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSkeletonBox(
                  width: double.infinity,
                  height: 14,
                  radius: 4,
                ),
                SizedBox(height: 4),
                AppSkeletonBox(width: 96, height: 10, radius: 4),
              ],
            ),
          ),
          SizedBox(width: 4),
          AppSkeletonBox(width: 28, height: 28, radius: 6),
        ],
      ),
    );
  }
}
