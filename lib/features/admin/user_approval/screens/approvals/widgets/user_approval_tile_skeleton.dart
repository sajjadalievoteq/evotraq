import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_skeleton_box.dart';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserApprovalSkeletonBox(
                  color: baseColor,
                  width: 160,
                  height: 18,
                  radius: r,
                ),
                const SizedBox(height: 6),
                UserApprovalSkeletonBox(
                  color: baseColor,
                  width: 120,
                  height: 14,
                  radius: r,
                ),
                const SizedBox(height: 4),
                UserApprovalSkeletonBox(
                  color: baseColor,
                  width: double.infinity,
                  height: 14,
                  radius: r,
                ),
              ],
            );

            final buttons = Column(
              children: [
                UserApprovalSkeletonBox(
                  color: baseColor,
                  width: double.infinity,
                  height: 40,
                  radius: btnRadius,
                ),
                const SizedBox(height: Constants.spacing),
                UserApprovalSkeletonBox(
                  color: baseColor,
                  width: double.infinity,
                  height: 40,
                  radius: btnRadius,
                ),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserApprovalSkeletonBox(
                      color: baseColor,
                      width: 40,
                      height: 40,
                      radius: 999,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 16),
                UserApprovalSkeletonBox(
                  color: baseColor,
                  width: 180,
                  height: 13,
                  radius: r,
                ),
                const SizedBox(height: 16),
                if (compact)
                  buttons
                else
                  Row(
                    children: [
                      Expanded(
                        child: UserApprovalSkeletonBox(
                          color: baseColor,
                          width: double.infinity,
                          height: 40,
                          radius: btnRadius,
                        ),
                      ),
                      const SizedBox(width: Constants.spacing),
                      Expanded(
                        child: UserApprovalSkeletonBox(
                          color: baseColor,
                          width: double.infinity,
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
