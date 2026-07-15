import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_analytics.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_metric_row.dart';

class JourneyMetricsSection extends StatelessWidget {
  const JourneyMetricsSection({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final longest = JourneyAnalytics.longestTransit(journey);
    final average = JourneyAnalytics.averageTransit(journey);
    final countries = JourneyAnalytics.countryCount(journey);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.lg,
          vertical: TraqSpacing.sm,
        ),
        child: Column(
          children: [
            JourneyMetricRow(
              icon: AppAssets.iconHourglass,
              label: 'Longest Transit',
              value: JourneyFormatters.duration(longest),
            ),
            JourneyMetricRow(
              icon: NavIcons.performanceTests,
              label: 'Average Transit',
              value: JourneyFormatters.duration(average),
            ),
            JourneyMetricRow(
              icon: NavIcons.shipping,
              label: 'Number of Shipments',
              value: '${JourneyAnalytics.shipmentCount(journey)}',
            ),
            JourneyMetricRow(
              icon: NavIcons.aggregationEvents,
              label: 'Number of Aggregations',
              value: '${JourneyAnalytics.aggregationCount(journey)}',
            ),
            JourneyMetricRow(
              icon: AppAssets.iconUsers,
              label: 'Business Partners',
              value: '${JourneyAnalytics.businessPartnerCount(journey)}',
            ),
            JourneyMetricRow(
              icon: AppAssets.iconGlobe,
              label: 'Countries',
              value: countries > 0 ? '$countries' : '—',
            ),
            JourneyMetricRow(
              icon: AppAssets.iconMapPin,
              label: 'Locations',
              value: '${journey.locationsVisited}',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}
