import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_formatters.dart';

class JourneyStatsBar extends StatelessWidget {
  const JourneyStatsBar({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(


      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(c, AppAssets.iconCalendar, '${journey.totalSteps}', 'Events',
                c.secondary),
            _item(c, AppAssets.iconMapPin, '${journey.locationsVisited}',
                'Locations', c.identifierGln),
            _item(
              c,
              AppAssets.iconTimer,
              JourneyFormatters.duration(journey.journeyDuration),
              'Duration',
              c.warning,
            ),
            _item(
              c,
              AppAssets.iconCheckCircle,
              journey.currentDisposition ?? 'Active',
              'Status',
              c.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    TraqColors c,
    String iconAsset,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: c.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
