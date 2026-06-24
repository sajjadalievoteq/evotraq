import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_key_metrics_section_skeleton.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_operations_header_skeleton.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_quick_actions_and_compliance_skeleton.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_status_rail_skeleton.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_throughput_and_events_skeleton.dart';

class DashboardLoader extends StatelessWidget {
  const DashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: AppLayoutBuilder(
        builder: (context, layout) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.gutter(context),
              ResponsiveUtils.gutter(context) * 0.5,
              ResponsiveUtils.gutter(context),
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardOperationsHeaderSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 16 : 24),
                DashboardStatusRailSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 18 : 26),
                DashboardKeyMetricsSectionSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                DashboardThroughputAndEventsSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                DashboardQuickActionsAndComplianceSkeleton(layout: layout),
              ],
            ),
          );
        },
      ),
    );
  }
}
