import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_tile_skeleton.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approvals_header_skeleton.dart';

class UserApprovalsLoadingView extends StatelessWidget {
  const UserApprovalsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final g = context.gutter;

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserApprovalsHeaderSkeleton(baseColor: baseColor),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(g),
              physics: const ClampingScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: g),
              itemBuilder: (context, _) =>
                  UserApprovalTileSkeleton(baseColor: baseColor),
            ),
          ),
        ],
      ),
    );
  }
}
