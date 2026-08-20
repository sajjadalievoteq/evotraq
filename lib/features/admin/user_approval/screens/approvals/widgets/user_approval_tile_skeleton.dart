import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class UserApprovalTileSkeleton extends StatelessWidget {
  const UserApprovalTileSkeleton({super.key, required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();
    final btnRadius = TraqRadius.md.x.toDouble();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            final info = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBox(
                    baseColor,
                    width: 160,
                    height: 18,
                    radius: r,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBox(
                    baseColor,
                    width: 120,
                    height: 14,
                    radius: r,
                  ),
                ),
                const SizedBox(height: 4),
                SkeletonBox(baseColor, height: 14, radius: r),
              ],
            );

            final stackedButtons = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonBox(baseColor, height: 40, radius: btnRadius),
                const SizedBox(height: Constants.spacing),
                SkeletonBox(baseColor, height: 40, radius: btnRadius),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(baseColor, width: 40, height: 40, radius: 999),
                    const SizedBox(width: 16),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 16),
                SkeletonBox(baseColor, width: 180, height: 13, radius: r),
                const SizedBox(height: 16),
                if (compact)
                  stackedButtons
                else
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonBox(
                          baseColor,
                          height: 40,
                          radius: btnRadius,
                        ),
                      ),
                      const SizedBox(width: Constants.spacing),
                      Expanded(
                        child: SkeletonBox(
                          baseColor,
                          height: 40,
                          radius: btnRadius,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
