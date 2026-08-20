import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_skeleton_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_skeleton_label.dart';

class ProductHierarchySidebarSkeleton extends StatelessWidget {
  const ProductHierarchySidebarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          15,
          context.padding.top,
          0,
        ),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProductHierarchySidebarSkeletonCard(height: 140),
            const SizedBox(height: TraqSpacing.lg),
            const ProductHierarchySidebarSkeletonLabel(),
            const SizedBox(height: TraqSpacing.sm),
            Row(
              children: const [
                Expanded(
                  child: ProductHierarchySidebarSkeletonCard(height: 72),
                ),
                SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: ProductHierarchySidebarSkeletonCard(height: 72),
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            Row(
              children: const [
                Expanded(
                  child: ProductHierarchySidebarSkeletonCard(height: 72),
                ),
                SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: ProductHierarchySidebarSkeletonCard(height: 72),
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.lg),
            const ProductHierarchySidebarSkeletonLabel(),
            const SizedBox(height: TraqSpacing.sm),
            const ProductHierarchySidebarSkeletonCard(height: 64),
            const SizedBox(height: TraqSpacing.lg),
            const ProductHierarchySidebarSkeletonLabel(),
            const SizedBox(height: TraqSpacing.sm),
            const ProductHierarchySidebarSkeletonCard(height: 160),
            const SizedBox(height: TraqSpacing.lg),
            const ProductHierarchySidebarSkeletonLabel(),
            const SizedBox(height: TraqSpacing.sm),
            const ProductHierarchySidebarSkeletonCard(height: 100),
          ],
        ),
      ),
    );
  }
}
