import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_filter_skeleton.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_tile_skeleton.dart';

class UserManagementLoadingView extends StatelessWidget {
  const UserManagementLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final gutter = context.gutter;
    return SizedBox.expand(
      child: AppShimmer(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserManagementFilterSkeleton(baseColor: baseColor),
              const SizedBox(height: 20),
              for (var i = 0; i < 6; i++) ...[
                UserManagementTileSkeleton(baseColor: baseColor),
                SizedBox(height: i == 5 ? gutter : 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
