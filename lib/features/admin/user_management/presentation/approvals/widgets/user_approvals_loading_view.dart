import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../users/widgets/user_management_constants.dart';

class UserApprovalsLoadingView extends StatelessWidget {
  const UserApprovalsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    const tileMaxExtent = 240.0;
    final g = context.gutter;

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UserApprovalsHeaderSkeleton(baseColor: baseColor),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(g),
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: tileMaxExtent,
                mainAxisSpacing: g,
                crossAxisSpacing: g,
                childAspectRatio: 1,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _UserApprovalCardSkeleton(baseColor: baseColor);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserApprovalsHeaderSkeleton extends StatelessWidget {
  const _UserApprovalsHeaderSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();
    return Card(
      elevation: 1,
      child: Padding(
        padding: Constants.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeletonBox(baseColor, width: 250, height: 28, radius: r),
            const SizedBox(height: 10),
            _skeletonBox(baseColor, width: 420, height: 16, radius: r),
            const SizedBox(height: 8),
            _skeletonBox(baseColor, width: 340, height: 16, radius: r),
            const SizedBox(height: Constants.spacing),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;

                final search = _skeletonBox(
                  baseColor,
                  width: double.infinity,
                  height: 50,
                  radius: TraqRadius.md.x.toDouble(),
                );
                final refresh = _skeletonBox(
                  baseColor,
                  width: 50,
                  height: 50,
                  radius: TraqRadius.md.x.toDouble(),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      const SizedBox(height: Constants.spacing),
                      Align(alignment: Alignment.centerRight, child: refresh),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: Constants.spacing),
                    refresh,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserApprovalCardSkeleton extends StatelessWidget {
  const _UserApprovalCardSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _skeletonBox(baseColor, width: 36, height: 36, radius: 999),
                const SizedBox(width: 10),
                Expanded(
                  child: _skeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 18,
                    radius: r,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _skeletonBox(baseColor, width: double.infinity, height: 14, radius: r),
            const SizedBox(height: 8),
            _skeletonBox(baseColor, width: 180, height: 14, radius: r),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _skeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 36,
                    radius: TraqRadius.md.x.toDouble(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _skeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 36,
                    radius: TraqRadius.md.x.toDouble(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _skeletonBox(
  Color color, {
  required double width,
  required double height,
  double radius = 12,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
