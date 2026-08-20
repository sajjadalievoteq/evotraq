import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/inbound_category_tile_skeleton.dart';

/// Grid-shaped loading placeholder that mirrors [InboundApiCatalog]'s category
/// card grid (`maxCrossAxisExtent: 300`, `mainAxisExtent: 165`).
class InboundCatalogLoadingSkeleton extends StatelessWidget {
  const InboundCatalogLoadingSkeleton({super.key, this.tileCount = 5});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeletonBox(
          width: 160,
          height: 22,
          radius: 4,
          color: c.surfaceMuted,
        ),
        const SizedBox(height: TraqSpacing.sm),
        AppSkeletonBox(
          width: double.infinity,
          height: 14,
          radius: 4,
          color: c.surfaceMuted,
        ),
        const SizedBox(height: TraqSpacing.xs),
        AppSkeletonBox(
          width: 280,
          height: 14,
          radius: 4,
          color: c.surfaceMuted,
        ),
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
          itemBuilder: (context, index) =>
              InboundCategoryTileSkeleton(colors: c),
        ),
      ],
    );
  }
}
