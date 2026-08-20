import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown_skeleton_chart.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown_skeleton_legend.dart';

class TatmeenStatusBreakdownSkeleton extends StatelessWidget {
  const TatmeenStatusBreakdownSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            return Column(
              children: [
                TatmeenStatusBreakdownSkeletonChart(color: muted),
                const SizedBox(height: TraqSpacing.md),
                TatmeenStatusBreakdownSkeletonLegend(color: muted),
              ],
            );
          }
          return Row(
            children: [
              TatmeenStatusBreakdownSkeletonChart(color: muted),
              const SizedBox(width: TraqSpacing.md),
              Expanded(
                child: TatmeenStatusBreakdownSkeletonLegend(color: muted),
              ),
            ],
          );
        },
      ),
    );
  }
}
