import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';
import 'package:traqtrace_app/features/product_hierarchy/widgets/product_hierarchy_ancestor_accent_rails.dart';

class ProductHierarchyGroupChrome extends StatelessWidget {
  const ProductHierarchyGroupChrome({
    super.key,
    required this.depth,
    required this.inGroupBody,
    required this.isExpandedHeader,
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  final int depth;
  final bool inGroupBody;
  final bool isExpandedHeader;
  final bool isFirst;
  final bool isLast;
  final Widget child;

  static const double _accentWidth =
      ProductHierarchyAncestorAccentRails.defaultAccentWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final frame = BorderSide(color: c.borderStrong);

    final railCount = inGroupBody
        ? depth
        : (isExpandedHeader && depth > 0 ? depth : 0);

    Widget framed = child;

    if (isExpandedHeader) {
      framed = DecoratedBox(
        decoration: BoxDecoration(
          color: inGroupBody ? c.surfaceMuted.withValues(alpha: 0.55) : null,
          border: Border(
            top: frame,
            left: railCount > 0 ? BorderSide.none : frame,
            right: frame,
          ),
        ),
        child: child,
      );
    } else if (inGroupBody && depth > 0) {
      framed = DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceMuted.withValues(alpha: 0.55),
          border: Border(
            top: isFirst ? frame : BorderSide.none,
            right: frame,
            bottom: isLast
                ? BorderSide(
                    color: productHierarchyAccentForDepth(c, depth - 1),
                    width: _accentWidth,
                  )
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            TraqSpacing.sm,
            isFirst ? TraqSpacing.sm : TraqSpacing.xs,
            TraqSpacing.sm,
            TraqSpacing.sm,
          ),
          child: child,
        ),
      );
    }

    return ProductHierarchyAncestorAccentRails(
      railCount: railCount,
      child: framed,
    );
  }
}
