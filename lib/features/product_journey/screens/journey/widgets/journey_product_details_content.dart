import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_step_style.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_product_info_card.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_stats_bar.dart';

class JourneyProductDetailsContent extends StatelessWidget {
  const JourneyProductDetailsContent({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (journey.productInfo != null) ...[
          JourneyProductInfoCard(productInfo: journey.productInfo!),
          const SizedBox(height: 8),
        ],
        JourneyStatsBar(journey: journey),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TraqIcon(AppAssets.iconSgtin, size: 15, color: c.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Identifier',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: JourneyStepStyle.typeColor(
                          context,
                          journey.identifierType,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        journey.identifierType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: JourneyStepStyle.typeColor(
                            context,
                            journey.identifierType,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  journey.identifier,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: c.textMuted,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
                if (journey.currentLocation != null) ...[
                  const SizedBox(height: 10),
                  _metaRow(
                    context,
                    AppAssets.iconGln,
                    'Location',
                    journey.currentLocation!,
                    c.identifierGln,
                  ),
                ],
                if (journey.currentDisposition != null) ...[
                  const SizedBox(height: 5),
                  _metaRow(
                    context,
                    AppAssets.iconCheckCircle,
                    'Disposition',
                    journey.currentDisposition!,
                    c.success,
                  ),
                ],
                if (journey.firstEventTime != null) ...[
                  const SizedBox(height: 5),
                  _metaRow(
                    context,
                    AppAssets.iconClock,
                    'First event',
                    JourneyFormatters.shortDate(journey.firstEventTime!),
                    c.textMuted,
                  ),
                ],
                if (journey.lastEventTime != null) ...[
                  const SizedBox(height: 5),
                  _metaRow(
                    context,
                    AppAssets.iconClock,
                    'Last event',
                    JourneyFormatters.shortDate(journey.lastEventTime!),
                    c.warning,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaRow(
    BuildContext context,
    String icon,
    String label,
    String value,
    Color color,
  ) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TraqIcon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
