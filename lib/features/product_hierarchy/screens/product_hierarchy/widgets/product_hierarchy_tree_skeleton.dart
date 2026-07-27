import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/utils/product_hierarchy_tree_flatten.dart';

/// Loading placeholder for the hierarchy tree (right panel).
///
/// Mirrors [ProductHierarchyNodeTile] + [ProductHierarchyGroupChrome]:
/// bordered expandable headers, muted group bodies with accent rails, and
/// borderless leaf rows with a status subtitle.
class ProductHierarchyTreeSkeleton extends StatelessWidget {
  const ProductHierarchyTreeSkeleton({super.key});

  static const double _accentWidth = 3;
  static const double _railGap = TraqSpacing.xs;

  static double railsWidth(int railCount) {
    if (railCount <= 0) return 0;
    return railCount * _accentWidth + (railCount - 1) * _railGap;
  }

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
                  // Root SSCC — standalone expandable.
                  const _ExpandableHeaderSkeleton(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  // Direct children of root (leaves).
                  _GroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
                    ],
                  ),
                  // Nested carton header (expanded) with one ancestor rail.
                  const _ExpandableHeaderSkeleton(
                    isGroupHeader: true,
                    railCount: 1,
                  ),
                  // Nested carton leaves.
                  _GroupBody(
                    railCount: 2,
                    bottomAccent: productHierarchyAccentForDepth(c, 1),
                    children: const [
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  // Sibling carton under the same view-root.
                  const _ExpandableHeaderSkeleton(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  _GroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
                    ],
                  ),
                  const _ExpandableHeaderSkeleton(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  _GroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
                    ],
                  ),
                  const _ExpandableHeaderSkeleton(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  _GroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
                    ],
                  ),
                  const _ExpandableHeaderSkeleton(
                    isGroupHeader: false,
                    railCount: 0,
                  ),
                  _GroupBody(
                    railCount: 1,
                    bottomAccent: productHierarchyAccentForDepth(c, 0),
                    children: const [
                      _LeafRowSkeleton(),
                      _LeafRowSkeleton(),
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

class _GroupBody extends StatelessWidget {
  const _GroupBody({
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
            width: ProductHierarchyTreeSkeleton._accentWidth,
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

    return _WithRails(railCount: railCount, child: body);
  }
}

class _WithRails extends StatelessWidget {
  const _WithRails({required this.railCount, required this.child});

  final int railCount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (railCount <= 0) return child;
    final c = context.colors;
    return CustomPaint(
      painter: _AncestorAccentRailPainter(
        railCount: railCount,
        accentWidth: ProductHierarchyTreeSkeleton._accentWidth,
        gap: ProductHierarchyTreeSkeleton._railGap,
        accentFor: (g) => productHierarchyAccentForDepth(c, g),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: ProductHierarchyTreeSkeleton.railsWidth(railCount),
        ),
        child: child,
      ),
    );
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

/// Matches [_ExpandableNodeTile] / group-header chrome.
class _ExpandableHeaderSkeleton extends StatelessWidget {
  const _ExpandableHeaderSkeleton({
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
          // Leading chevron (22×22)
          AppSkeletonBox(width: 22, height: 22, radius: 4),
          SizedBox(width: 5),
          // "SSCC" / "Sgtin"
          AppSkeletonBox(width: 36, height: 14, radius: 4),
          SizedBox(width: 5),
          // Type icon
          AppSkeletonBox(width: 20, height: 20, radius: 6),
          SizedBox(width: TraqSpacing.sm),
          // EPC
          Expanded(
            child: AppSkeletonBox(
              width: double.infinity,
              height: 14,
              radius: 4,
            ),
          ),
          SizedBox(width: TraqSpacing.sm),
          // Child-count badge
          AppSkeletonBox(width: 28, height: 18, radius: 10),
          SizedBox(width: 4),
          // Copy
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

    return _WithRails(railCount: railCount, child: framed);
  }
}

/// Matches [_LeafNodeTile]: type, icon, EPC + status, copy — no card border.
class _LeafRowSkeleton extends StatelessWidget {
  const _LeafRowSkeleton();

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
