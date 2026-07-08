import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_state_row.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_analytics.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

class JourneyCurrentStateSection extends StatelessWidget {
  const JourneyCurrentStateSection({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final last = JourneyAnalytics.lastStep(journey);
    final info = journey.productInfo;

    final location = journey.currentLocation ??
        info?.currentLocationName ??
        last?.locationName ??
        last?.locationGLN;
    final owner = info?.mahName ?? info?.manufacturer ?? last?.locationName;
    final disposition = CbvDisplayUtils.displayDisposition(
      journey.currentDisposition ?? last?.disposition,
      fallback: last?.dispositionLabel ?? '—',
    );
    final businessStep = last != null
        ? JourneyStepStyle.titleFor(last.businessStep)
        : null;
    final currentEvent = last != null
        ? JourneyStepStyle.titleFor(last.businessStep)
        : null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          children: [
            JourneyStateRow(
              icon: AppAssets.iconMapPin,
              label: 'Current Location',
              value: location,
            ),
            JourneyStateRow(
              icon: AppAssets.iconBusiness,
              label: 'Current Owner',
              value: owner,
            ),
            JourneyStateRow(
              icon: AppAssets.iconCheckCircle,
              label: 'Current Disposition',
              value: disposition,
            ),
            JourneyStateRow(
              icon: AppAssets.iconRoute,
              label: 'Current Business Step',
              value: businessStep,
            ),
            JourneyStateRow(
              icon: AppAssets.iconEvent,
              label: 'Current Event',
              value: currentEvent,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}
