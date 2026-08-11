import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_icon_row_card_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_kpi_grid_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_product_summary_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_sidebar_skeleton_section.dart';

class JourneySidebarSkeleton extends StatelessWidget {
  const JourneySidebarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top - 20,
          context.padding.top,
          0,
        ),
        physics: const NeverScrollableScrollPhysics(),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JourneySidebarSkeletonSection(child: JourneyKpiGridSkeleton()),
            SizedBox(height: TraqSpacing.lg),
            JourneySidebarSkeletonSection(
              child: JourneyProductSummarySkeleton(),
            ),
            SizedBox(height: TraqSpacing.lg),
            JourneySidebarSkeletonSection(
              child: JourneyIconRowCardSkeleton(rowCount: 4),
            ),
            SizedBox(height: TraqSpacing.lg),
            JourneySidebarSkeletonSection(
              child: JourneyIconRowCardSkeleton(rowCount: 3),
            ),
            SizedBox(height: TraqSpacing.lg),
            SizedBox(height: TraqSpacing.xl),
          ],
        ),
      ),
    );
  }
}
