import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/key_metrics/key_metrics_section.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/operations_header/operations_header.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/quick_actions_and_compliance_row.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/status_rail/status_rail.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/throughput_and_events_row.dart';

class HomeScrollBody extends StatelessWidget {
  const HomeScrollBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtils.gutter(context),
            ResponsiveUtils.gutter(context) * 0.5,
            ResponsiveUtils.gutter(context),
            32,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationsHeader(layout: layout),
                SizedBox(height: layout.isCompact ? 16 : 24),
                StatusRail(layout: layout),
                SizedBox(height: layout.isCompact ? 18 : 26),
                KeyMetricsSection(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                ThroughputAndEventsRow(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                QuickActionsAndComplianceRow(layout: layout),
              ],
            ),
          ),
        );
      },
    );
  }
}
