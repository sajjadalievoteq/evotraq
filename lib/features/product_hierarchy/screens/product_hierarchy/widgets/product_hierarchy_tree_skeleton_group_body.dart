import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
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
    final colors = context.colors;
    final frame = BorderSide(color: colors.borderStrong);
    final body = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceMuted.withValues(alpha: 0.55),
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
