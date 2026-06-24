import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/home_section_layout_utils.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_epcis_event_stream_skeleton.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_throughput_chart_skeleton.dart';

class DashboardThroughputAndEventsSkeleton extends StatelessWidget {
  const DashboardThroughputAndEventsSkeleton({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = HomeSectionLayoutUtils.throughputAndEventsPairHeight(c.maxWidth);
        if (layout.isTabletUp) {
          return SizedBox(
            height: h,
            child: Row(
              children: [
                const Expanded(flex: 3, child: DashboardThroughputChartSkeleton()),
                SizedBox(width: layout.isCompact ? 12 : 20),
                const Expanded(flex: 2, child: DashboardEpcisEventStreamSkeleton()),
              ],
            ),
          );
        }
        return Column(
          children: [
            SizedBox(height: h, child: const DashboardThroughputChartSkeleton()),
            SizedBox(height: layout.isCompact ? 16 : 20),
            SizedBox(height: h, child: const DashboardEpcisEventStreamSkeleton()),
          ],
        );
      },
    );
  }
}
