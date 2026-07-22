import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';


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
            const _CardBlock(height: 140),
            const SizedBox(height: TraqSpacing.lg),
            const _Label(),
            const SizedBox(height: TraqSpacing.sm),
            Row(
              children: const [
                Expanded(child: _CardBlock(height: 72)),
                SizedBox(width: TraqSpacing.sm),
                Expanded(child: _CardBlock(height: 72)),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            Row(
              children: const [
                Expanded(child: _CardBlock(height: 72)),
                SizedBox(width: TraqSpacing.sm),
                Expanded(child: _CardBlock(height: 72)),
              ],
            ),
            const SizedBox(height: TraqSpacing.lg),
            const _Label(),
            const SizedBox(height: TraqSpacing.sm),
            const _CardBlock(height: 64),
            const SizedBox(height: TraqSpacing.lg),
            const _Label(),
            const SizedBox(height: TraqSpacing.sm),
            const _CardBlock(height: 160),
            const SizedBox(height: TraqSpacing.lg),
            const _Label(),
            const SizedBox(height: TraqSpacing.sm),
            const _CardBlock(height: 100),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: AppSkeletonBox(width: 100, height: 10, radius: 4),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      width: double.infinity,
      height: height,
      radius: 8,
    );
  }
}
