import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_dashboard/widgets/journey_skeleton_label_value_rows.dart';

class JourneyProductSummarySkeleton extends StatelessWidget {
  const JourneyProductSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                AppSkeletonBox(width: 18, height: 18, radius: 4),
                SizedBox(width: TraqSpacing.sm),
                Expanded(child: AppSkeletonBox(height: 14)),
                SizedBox(width: TraqSpacing.sm),
                AppSkeletonBox(width: 44, height: 20, radius: 10),
              ],
            ),
            SizedBox(height: TraqSpacing.md),
            AppSkeletonBox(width: 56, height: 10),
            SizedBox(height: 4),
            AppSkeletonBox(height: 12),
            Divider(height: TraqSpacing.xl),
            JourneySkeletonLabelValueRows(count: 4),
          ],
        ),
      ),
    );
  }
}
