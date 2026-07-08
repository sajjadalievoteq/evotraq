import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_current_state_section.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_kpi_grid.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_metrics_section.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_panel_section.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_product_summary_section.dart';

/// Composes journey detail sections (sidebar / bottom-sheet content).
class JourneyDetailsScreen extends StatelessWidget {
  const JourneyDetailsScreen({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    return JourneyDetailsContent(journey: journey);
  }
}

class JourneyDetailsContent extends StatelessWidget {
  const JourneyDetailsContent({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JourneyPanelSection(
          title: 'Journey Summary',
          child: JourneyKpiGrid(journey: journey),
        ),
        const SizedBox(height: TraqSpacing.lg),
        JourneyPanelSection(
          title: 'Product Summary',
          child: JourneyProductSummarySection(journey: journey),
        ),
        const SizedBox(height: TraqSpacing.lg),
        JourneyPanelSection(
          title: 'Current State',
          child: JourneyCurrentStateSection(journey: journey),
        ),
        const SizedBox(height: TraqSpacing.lg),
        JourneyPanelSection(
          title: 'Journey Metrics',
          child: JourneyMetricsSection(journey: journey),
        ),
        SizedBox(height: context.padding.top),
      ],
    );
  }
}
