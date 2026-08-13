import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

/// Grid-shaped loading placeholder that mirrors [InboundApiCatalog]'s category
/// card grid (`maxCrossAxisExtent: 300`, `mainAxisExtent: 165`).
class InboundCatalogLoadingSkeleton extends StatelessWidget {
  const InboundCatalogLoadingSkeleton({
    super.key,
    this.tileCount = 5,
  });

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeletonBox(width: 160, height: 22, radius: 4, color: c.surfaceMuted),
        const SizedBox(height: TraqSpacing.sm),
        AppSkeletonBox(
          width: double.infinity,
          height: 14,
          radius: 4,
          color: c.surfaceMuted,
        ),
        const SizedBox(height: TraqSpacing.xs),
        AppSkeletonBox(width: 280, height: 14, radius: 4, color: c.surfaceMuted),
        const SizedBox(height: TraqSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisExtent: 165,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: tileCount,
          itemBuilder: (context, index) => _CategoryTileSkeleton(colors: c),
        ),
      ],
    );
  }
}

class _CategoryTileSkeleton extends StatelessWidget {
  const _CategoryTileSkeleton({required this.colors});

  final TraqColors colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeletonBox(
                  width: 24,
                  height: 24,
                  radius: 6,
                  color: colors.surfaceMuted,
                ),
                const Spacer(),
                AppSkeletonBox(
                  width: 28,
                  height: 28,
                  radius: 999,
                  color: colors.surfaceMuted,
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            AppSkeletonBox(
              width: 120,
              height: 18,
              radius: 4,
              color: colors.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.xs),
            AppSkeletonBox(
              width: double.infinity,
              height: 12,
              radius: 4,
              color: colors.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.xs),
            AppSkeletonBox(
              width: 140,
              height: 12,
              radius: 4,
              color: colors.surfaceMuted,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: AppSkeletonBox(
                width: 132,
                height: 28,
                radius: 8,
                color: colors.surfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
