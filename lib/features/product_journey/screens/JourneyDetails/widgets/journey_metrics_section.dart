import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_metric_row.dart';

class _JourneyMetrics {
  final Duration? longest;
  final Duration? average;
  final int shipments;
  final int aggregations;
  final int businessPartners;
  final int countries;

  const _JourneyMetrics({
    required this.longest,
    required this.average,
    required this.shipments,
    required this.aggregations,
    required this.businessPartners,
    required this.countries,
  });

  factory _JourneyMetrics.compute(List<JourneyStep> steps) {
    final durations = <Duration>[];
    final locations = <String>{};
    final countrySet = <String>{};
    int shipments = 0;
    int aggregations = 0;

    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];

      if (i < steps.length - 1) {
        final d = steps[i + 1].eventTime.difference(s.eventTime);
        if (d.inMinutes > 0) durations.add(d);
      }

      if (JourneyEventFilter.shipping.matches(s)) shipments++;
      if (JourneyEventFilter.aggregation.matches(s)) aggregations++;

      final loc = s.locationGLN ?? s.locationName;
      if (loc != null && loc.isNotEmpty) locations.add(loc);

      final address = s.locationAddress;
      if (address != null && address.isNotEmpty) {
        final parts = address.split(',');
        final country = parts.last.trim();
        if (country.isNotEmpty) countrySet.add(country);
      }
    }

    Duration? longest;
    Duration? average;
    if (durations.isNotEmpty) {
      longest = durations.reduce((a, b) => a > b ? a : b);
      final total = durations.fold<int>(0, (sum, d) => sum + d.inMinutes);
      average = Duration(minutes: total ~/ durations.length);
    }

    return _JourneyMetrics(
      longest: longest,
      average: average,
      shipments: shipments,
      aggregations: aggregations,
      businessPartners: locations.length,
      countries: countrySet.length,
    );
  }
}

class JourneyMetricsSection extends StatelessWidget {
  const JourneyMetricsSection({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final m = _JourneyMetrics.compute(journey.steps);

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
              value: JourneyFormatters.duration(m.longest),
            ),
            JourneyMetricRow(
              icon: NavIcons.performanceTests,
              label: 'Average Transit',
              value: JourneyFormatters.duration(m.average),
            ),
            JourneyMetricRow(
              icon: NavIcons.shipping,
              label: 'Number of Shipments',
              value: '${m.shipments}',
            ),
            JourneyMetricRow(
              icon: NavIcons.aggregationEvents,
              label: 'Number of Aggregations',
              value: '${m.aggregations}',
            ),
            JourneyMetricRow(
              icon: AppAssets.iconUsers,
              label: 'Business Partners',
              value: '${m.businessPartners}',
            ),
            JourneyMetricRow(
              icon: AppAssets.iconGlobe,
              label: 'Countries',
              value: m.countries > 0 ? '${m.countries}' : '—',
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
