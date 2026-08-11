import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_kpi_tile_skeleton.dart';

class JourneyKpiGridSkeleton extends StatelessWidget {
  const JourneyKpiGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: TraqSpacing.sm,
      crossAxisSpacing: TraqSpacing.sm,
      childAspectRatio: 1.55,
      children: List.generate(4, (_) => const JourneyKpiTileSkeleton()),
    );
  }
}
