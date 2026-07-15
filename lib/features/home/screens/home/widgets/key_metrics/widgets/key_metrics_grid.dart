import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/utils/home_navigation.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/key_metrics/widgets/dashboard_stat_card.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class KeyMetricsGrid extends StatelessWidget {
  const KeyMetricsGrid({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.stats != c.stats,
      builder: (context, state) {
        final stats = state.stats;
        final eventCounts = stats?.eventsByType ?? {};

        final items = <
            (
              String title,
              String value,
              String iconAsset,
              Color iconTint,
              VoidCallback onTap,
            )>[
          (
            HomeStrings.metricGtin,
            stats?.gtinCount.toString() ?? '0',
            NavIcons.gtin,
            context.colors.identifierGtin,
            () => context.go(HomeNavigation.gs1Gtins),
          ),
          (
            HomeStrings.metricGln,
            stats?.glnCount.toString() ?? '0',
            NavIcons.gln,
            context.colors.identifierGln,
            () => context.go(HomeNavigation.gs1Glns),
          ),
          (
            HomeStrings.metricSgtin,
            stats?.sgtinCount.toString() ?? '0',
            NavIcons.sgtin,
            context.colors.identifierSgtin,
            () => context.go(HomeNavigation.gs1Sgtins),
          ),
          (
            HomeStrings.metricSscc,
            stats?.ssccCount.toString() ?? '0',
            NavIcons.sscc,
            context.colors.identifierSscc,
            () => context.go(HomeNavigation.gs1Ssccs),
          ),
          (
            HomeStrings.metricObjectEvents,
            (eventCounts['Object'] ?? 0).toString(),
            NavIcons.objectEvents,
            context.colors.identifierEvent,
            () => context.go(HomeNavigation.epcisObjectEvents),
          ),
          (
            HomeStrings.metricAggregationEvents,
            (eventCounts['Aggregation'] ?? 0).toString(),
            NavIcons.aggregationEvents,
            context.colors.secondary,
            () => context.go(HomeNavigation.epcisAggregationEvents),
          ),
          (
            HomeStrings.metricTransactionEvents,
            (eventCounts['Transaction'] ?? 0).toString(),
            NavIcons.epcisEvents,
            context.colors.warning,
            () => context.go(HomeNavigation.epcisTransactionEvents),
          ),
          (
            HomeStrings.metricTransformationEvents,
            (eventCounts['Transformation'] ?? 0).toString(),
            NavIcons.conversion,
            context.colors.primaryMuted,
            () => context.go(HomeNavigation.epcisTransformationEvents),
          ),
          (
            HomeStrings.metricTotalEvents,
            stats?.totalEvents.toString() ?? '0',
            NavIcons.allEvents,
            context.colors.textMuted,
            () => context.go(HomeNavigation.epcisEvents),
          ),
        ];

        const gap = 12.0;
        final minTileWidth = layout.isCompact ? 158.0 : 200.0;
        const maxCols = 7;

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            var cols = ((maxW + gap) / (minTileWidth + gap)).floor();
            if (cols < 1) cols = 1;
            if (cols > maxCols) cols = maxCols;
            final tileW = (maxW - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final e in items)
                  SizedBox(
                    width: tileW,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, c) {
                            return SizedBox(
                              width: c.maxWidth,
                              height: c.maxHeight,
                              child: DashboardStatCard(
                                title: e.$1,
                                value: e.$2,
                                iconAsset: e.$3,
                                color: e.$4,
                                dense: true,
                                valueTextColor: context.colors.textPrimary,
                                labelTextColor: context.colors.textSecondary,
                                width: c.maxWidth,
                                onTap: e.$5,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
