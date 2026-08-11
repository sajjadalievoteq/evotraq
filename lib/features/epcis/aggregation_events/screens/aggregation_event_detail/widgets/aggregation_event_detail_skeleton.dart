import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_detail_header_skeleton.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_detail_skeleton_group_card.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_detail_skeleton_field_row.dart';

class AggregationEventDetailSkeleton extends StatelessWidget {
  const AggregationEventDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    final outline = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.45);

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AggregationDetailHeaderSkeleton(),
            const SizedBox(height: 16),
            AggregationDetailSkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AggregationDetailSkeletonFieldRow(
                    base: base,
                    maxWidth: maxWidth,
                    withChip: true,
                  ),
                  for (var i = 0; i < 5; i++)
                    AggregationDetailSkeletonFieldRow(
                      base: base,
                      maxWidth: maxWidth,
                    ),
                ],
              ),
            ),
            AggregationDetailSkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(base, width: maxWidth * 0.4, height: 11),
                        const SizedBox(height: 4),
                        SkeletonBox(base, width: maxWidth, height: 13),
                      ],
                    ),
                  ),
                  SkeletonBox(base, width: 50, height: 11),
                  const SizedBox(height: 6),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SkeletonBox(base, width: 6, height: 6, radius: 3),
                          const SizedBox(width: 8),
                          Expanded(child: SkeletonBox(base, height: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            AggregationDetailSkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AggregationDetailSkeletonFieldRow(
                    base: base,
                    maxWidth: maxWidth,
                  ),
                  AggregationDetailSkeletonFieldRow(
                    base: base,
                    maxWidth: maxWidth,
                  ),
                ],
              ),
            ),
            AggregationDetailSkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AggregationDetailSkeletonFieldRow(
                    base: base,
                    maxWidth: maxWidth,
                  ),
                  AggregationDetailSkeletonFieldRow(
                    base: base,
                    maxWidth: maxWidth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.spacing * 2),
          ],
        ),
      ),
    );
  }
}
