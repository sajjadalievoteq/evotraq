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

    return SizedBox.expand(
      child: AppShimmer(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserApprovalsHeaderSkeleton(baseColor: baseColor),
              const SizedBox(height: 20),
              for (var i = 0; i < 4; i++) ...[
                UserApprovalTileSkeleton(baseColor: baseColor),
                SizedBox(height: i == 3 ? g : 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
