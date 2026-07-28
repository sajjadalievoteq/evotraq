import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_skeleton_parts.dart';

/// Loading placeholder for the hierarchy tree (right panel).
///
/// Mirrors [ProductHierarchyNodeTile] + [ProductHierarchyGroupChrome]:
/// bordered expandable headers, muted group bodies with accent rails, and
/// borderless leaf rows with a status subtitle.
class ProductHierarchyTreeSkeleton extends StatelessWidget {
  const ProductHierarchyTreeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppShimmer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          TraqSpacing.lg,
        ),
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProductHierarchyTreeSkeletonHeader(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  ProductHierarchyTreeSkeletonGroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      ProductHierarchyTreeSkeletonLeafRow(),
                      ProductHierarchyTreeSkeletonLeafRow(),
                    ],
                  ),
                  const ProductHierarchyTreeSkeletonHeader(
                    isGroupHeader: true,
                    railCount: 1,
                  ),
                  ProductHierarchyTreeSkeletonGroupBody(
                    railCount: 2,
                    bottomAccent: productHierarchyAccentForDepth(c, 1),
                    children: const [
                      ProductHierarchyTreeSkeletonLeafRow(),
                      ProductHierarchyTreeSkeletonLeafRow(),
                      ProductHierarchyTreeSkeletonLeafRow(),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  const ProductHierarchyTreeSkeletonHeader(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  ProductHierarchyTreeSkeletonGroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      ProductHierarchyTreeSkeletonLeafRow(),
                      ProductHierarchyTreeSkeletonLeafRow(),
                    ],
                  ),
                  const ProductHierarchyTreeSkeletonHeader(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  ProductHierarchyTreeSkeletonGroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      ProductHierarchyTreeSkeletonLeafRow(),
                      ProductHierarchyTreeSkeletonLeafRow(),
                    ],
                  ),
                  const ProductHierarchyTreeSkeletonHeader(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  ProductHierarchyTreeSkeletonGroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      ProductHierarchyTreeSkeletonLeafRow(),
                      ProductHierarchyTreeSkeletonLeafRow(),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
