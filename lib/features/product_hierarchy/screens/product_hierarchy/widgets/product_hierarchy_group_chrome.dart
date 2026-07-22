import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';


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

  static const double _accentWidth = 3;
  static const double _railGap = TraqSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final frame = BorderSide(color: c.borderStrong);

    
    final railCount = inGroupBody ? depth : (isExpandedHeader && depth > 0 ? depth : 0);

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

    if (railCount <= 0) return framed;

    return CustomPaint(
      painter: _AncestorAccentRailPainter(
        railCount: railCount,
        accentWidth: _accentWidth,
        gap: _railGap,
        accentFor: (g) => productHierarchyAccentForDepth(c, g),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: _railsWidth(railCount)),
        child: framed,
      ),
    );
  }

  static double _railsWidth(int railCount) {
    if (railCount <= 0) return 0;
    return railCount * _accentWidth + (railCount - 1) * _railGap;
  }
}

class _AncestorAccentRailPainter extends CustomPainter {
  _AncestorAccentRailPainter({
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
  bool shouldRepaint(covariant _AncestorAccentRailPainter oldDelegate) {
    return oldDelegate.railCount != railCount ||
        oldDelegate.accentWidth != accentWidth ||
        oldDelegate.gap != gap;
  }
}
