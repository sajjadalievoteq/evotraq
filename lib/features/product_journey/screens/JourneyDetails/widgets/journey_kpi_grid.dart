import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_kpi_tile.dart';

class JourneyKpiGrid extends StatelessWidget {
  const JourneyKpiGrid({super.key, required this.journey});

  final ProductJourney journey;

  static const double _tabletBreakpoint = 600.0;
  static const double _tileTargetHeight = 88.0;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      JourneyKpiTile(
        icon: AppAssets.iconCalendar,
        value: '${journey.totalSteps}',
        label: 'Events',
        color: context.colors.secondary,
      ),
      JourneyKpiTile(
        icon: AppAssets.iconMapPin,
        value: '${journey.locationsVisited}',
        label: 'Locations',
        color: context.colors.identifierGln,
      ),
      JourneyKpiTile(
        icon: NavIcons.performanceTests,
        value: JourneyFormatters.duration(journey.journeyDuration),
        label: 'Duration',
        color: context.colors.warning,
      ),
      JourneyKpiTile(
        icon: AppAssets.iconCheckCircle,
        value: CbvDisplayUtils.displayDisposition(
          journey.currentDisposition,
          fallback: 'Active',
        ),
        label: 'Status',
        color: context.colors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isTablet = width >= _tabletBreakpoint;

        final columns = isTablet ? 4 : 2;
        final spacing = isTablet ? TraqSpacing.md : TraqSpacing.sm;

        final totalSpacing = spacing * (columns - 1);
        final tileWidth = (width - totalSpacing) / columns;
        final aspectRatio =
            (tileWidth / _tileTargetHeight).clamp(1.1, 3.0);

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
          children: tiles,
        );
      },
    );
  }
}
