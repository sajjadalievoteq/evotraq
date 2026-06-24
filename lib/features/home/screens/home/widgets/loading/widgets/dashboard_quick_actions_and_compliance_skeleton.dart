import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_compliance_skeleton.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_quick_actions_skeleton.dart';

class DashboardQuickActionsAndComplianceSkeleton extends StatelessWidget {
  const DashboardQuickActionsAndComplianceSkeleton({
    super.key,
    required this.layout,
  });

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    if (layout.isTabletUp) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 3, child: DashboardQuickActionsSkeleton()),
          SizedBox(width: layout.isCompact ? 12 : 20),
          const Expanded(flex: 2, child: DashboardComplianceSkeleton()),
        ],
      );
    }
    return Column(
      children: [
        const DashboardQuickActionsSkeleton(),
        SizedBox(height: layout.isCompact ? 16 : 20),
        const DashboardComplianceSkeleton(),
      ],
    );
  }
}
