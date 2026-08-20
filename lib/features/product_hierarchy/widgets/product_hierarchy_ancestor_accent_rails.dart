import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';

/// Vertical accent rails drawn to the left of nested hierarchy group content.
class ProductHierarchyAncestorAccentRails extends StatelessWidget {
  const ProductHierarchyAncestorAccentRails({
    super.key,
    required this.railCount,
    required this.child,
    this.accentWidth = defaultAccentWidth,
    this.gap = defaultGap,
  });

  static const double defaultAccentWidth = 3;
  static const double defaultGap = TraqSpacing.xs;

  final int railCount;
  final Widget child;
  final double accentWidth;
  final double gap;

  static double railsWidth(
    int railCount, {
    double accentWidth = defaultAccentWidth,
    double gap = defaultGap,
  }) {
    if (railCount <= 0) return 0;
    return railCount * accentWidth + (railCount - 1) * gap;
  }

  @override
  Widget build(BuildContext context) {
    if (railCount <= 0) return child;
    final c = context.colors;
    return CustomPaint(
      painter: ProductHierarchyAncestorAccentRailPainter(
        railCount: railCount,
        accentWidth: accentWidth,
        gap: gap,
        accentFor: (g) => productHierarchyAccentForDepth(c, g),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: railsWidth(railCount, accentWidth: accentWidth, gap: gap),
        ),
        child: child,
      ),
    );
  }
}

class ProductHierarchyAncestorAccentRailPainter extends CustomPainter {
  ProductHierarchyAncestorAccentRailPainter({
    required this.railCount,
    required this.accentWidth,
    required this.gap,
    required this.accentFor,
  });

  final int railCount;
  final double accentWidth;
  final double gap;
  final Color Function(int groupDepth) accentFor;

  @override
  void paint(Canvas canvas, Size size) {
    var x = 0.0;
    for (var g = 0; g < railCount; g++) {
      final paint = Paint()..color = accentFor(g);
      canvas.drawRect(Rect.fromLTWH(x, 0, accentWidth, size.height), paint);
      x += accentWidth + gap;
    }
  }

  @override
  bool shouldRepaint(
    covariant ProductHierarchyAncestorAccentRailPainter oldDelegate,
  ) {
    return oldDelegate.railCount != railCount ||
        oldDelegate.accentWidth != accentWidth ||
        oldDelegate.gap != gap;
  }
}
