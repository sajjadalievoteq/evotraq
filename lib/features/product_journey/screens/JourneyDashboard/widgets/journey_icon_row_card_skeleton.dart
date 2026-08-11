import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_skeleton_icon_row.dart';

class JourneyIconRowCardSkeleton extends StatelessWidget {
  const JourneyIconRowCardSkeleton({required this.rowCount, super.key});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          children: List.generate(
            rowCount,
            (index) => JourneySkeletonIconRow(last: index == rowCount - 1),
          ),
        ),
      ),
    );
  }
}
