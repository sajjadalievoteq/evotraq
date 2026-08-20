import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class UserApprovalsHeaderSkeleton extends StatelessWidget {
  const UserApprovalsHeaderSkeleton({super.key, required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();

    return Card(
      elevation: 1,
      child: Padding(
        padding: Constants.sectionPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final isCompact = maxWidth < 600;
            final titleWidth = (maxWidth * 0.55).clamp(140.0, 250.0);
            final subtitleWidth = maxWidth;

            final search = SkeletonBox(
              baseColor,
              width: isCompact ? maxWidth : null,
              height: 50,
              radius: r,
            );
            final refresh = SkeletonBox(
              baseColor,
              width: 50,
              height: 50,
              radius: r,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  baseColor,
                  width: titleWidth,
                  height: 28,
                  radius: r,
                ),
                const SizedBox(height: 8),
                SkeletonBox(
                  baseColor,
                  width: subtitleWidth,
                  height: 16,
                  radius: r,
                ),
                const SizedBox(height: Constants.spacing),
                if (isCompact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      const SizedBox(height: Constants.spacing),
                      Align(alignment: Alignment.centerRight, child: refresh),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: Constants.spacing),
                      refresh,
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
