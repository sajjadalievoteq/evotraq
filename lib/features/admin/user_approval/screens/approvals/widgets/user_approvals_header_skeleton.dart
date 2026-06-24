import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_skeleton_box.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserApprovalSkeletonBox(
              color: baseColor,
              width: 250,
              height: 28,
              radius: r,
            ),
            const SizedBox(height: 10),
            UserApprovalSkeletonBox(
              color: baseColor,
              width: 420,
              height: 16,
              radius: r,
            ),
            const SizedBox(height: 8),
            UserApprovalSkeletonBox(
              color: baseColor,
              width: 340,
              height: 16,
              radius: r,
            ),
            const SizedBox(height: Constants.spacing),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final search = UserApprovalSkeletonBox(
                  color: baseColor,
                  width: double.infinity,
                  height: 50,
                  radius: r,
                );
                final refresh = UserApprovalSkeletonBox(
                  color: baseColor,
                  width: 50,
                  height: 50,
                  radius: r,
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
