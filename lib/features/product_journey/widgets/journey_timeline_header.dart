import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_analytics.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_timeline_header_utils.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_header_chip.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_header_stat.dart';

class JourneyTimelineHeader extends StatelessWidget {
  const JourneyTimelineHeader({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final typeColor =
        JourneyStepStyle.typeColor(context, journey.identifierType);
    final status = CbvDisplayUtils.displayDisposition(
      journey.currentDisposition,
      fallback: 'Active',
    );
    final dateRange = JourneyTimelineHeaderUtils.dateRange(journey);
    final orgCount = JourneyAnalytics.organizationCount(journey);

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.lg,
          vertical: TraqSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(TraqRadius.lg),
          border: Border.all(color: c.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Text(
              'Journey',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(width: TraqSpacing.md),
            JourneyHeaderChip(
              label: journey.identifierType.toUpperCase(),
              color: typeColor,
            ),
            const SizedBox(width: TraqSpacing.sm),
            JourneyHeaderChip(label: status, color: c.success),
            const SizedBox(width: TraqSpacing.lg),
            Expanded(
              child: Wrap(
                spacing: TraqSpacing.lg,
                runSpacing: TraqSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (dateRange != null)
                    JourneyHeaderStat(
                      icon: AppAssets.iconCalendar,
                      value: dateRange,
                    ),
                  JourneyHeaderStat(
                    icon: NavIcons.epcisEvents,
                    value: '${journey.totalSteps} Events',
                  ),
                  JourneyHeaderStat(
                    icon: NavIcons.performanceTests,
                    value: JourneyTimelineHeaderUtils.durationLabel(journey),
                  ),
                  JourneyHeaderStat(
                    icon: AppAssets.iconUsers,
                    value:
                        '$orgCount ${orgCount == 1 ? 'Organization' : 'Organizations'}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
