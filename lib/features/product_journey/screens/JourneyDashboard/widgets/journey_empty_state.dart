import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_search_hint_chip.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyEmptyState extends StatelessWidget {
  const JourneyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppEmptyState(
      iconAsset: NavIcons.productJourney,
      title: 'Track Product Journey',
      subtitle:
          'Enter a serial number, SGTIN, or SSCC to view\nthe complete supply chain journey',
      footer: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          JourneySearchHintChip(
            colors: c,
            label: 'Serial Number',
            iconAsset: NavIcons.serialization,
          ),
          JourneySearchHintChip(
            colors: c,
            label: 'SGTIN URI',
            iconAsset: AppAssets.iconLink,
          ),
          JourneySearchHintChip(
            colors: c,
            label: 'SSCC',
            iconAsset: NavIcons.sscc,
          ),
        ],
      ),
    );
  }
}
