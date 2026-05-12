import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_state.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/key_metrics/widgets/dashboard_stat_card.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

class KeyMetricsGrid extends StatelessWidget {
  const KeyMetricsGrid({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
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
            'GTIN',
            stats?.gtinCount.toString() ?? '0',
            AppAssets.iconGtin,
            context.colors.identifierGtin,
            () => context.go(Constants.gs1GtinsRoute),
          ),
          (
            'GLN',
            stats?.glnCount.toString() ?? '0',
            AppAssets.iconGln,
            context.colors.identifierGln,
            () => context.go(Constants.gs1GlnsRoute),
          ),
          (
            'SGTIN',
            stats?.sgtinCount.toString() ?? '0',
            AppAssets.iconSgtin,
            context.colors.identifierSgtin,
            () => context.go(Constants.gs1SgtinsRoute),
          ),
          (
            'SSCC',
            stats?.ssccCount.toString() ?? '0',
            AppAssets.iconSscc,
            context.colors.identifierSscc,
            () => context.go(Constants.gs1SsccsRoute),
          ),
          (
            'OBJECT EVENTS',
            (eventCounts['Object'] ?? 0).toString(),
            AppAssets.iconEvent,
            context.colors.identifierEvent,
            () => context.go(Constants.epcisObjectEventsRoute),
          ),
          (
            'AGGREGATION EVENTS',
            (eventCounts['Aggregation'] ?? 0).toString(),
            AppAssets.iconAggregate,
            context.colors.secondary,
            () => context.go(Constants.epcisAggregationEventsRoute),
          ),
          (
            'TRANSACTION EVENTS',
            (eventCounts['Transaction'] ?? 0).toString(),
            AppAssets.iconShipment,
            context.colors.warning,
            () => context.go(Constants.epcisTransactionEventsRoute),
          ),
          (
            'TRANSFORMATION EVENTS',
            (eventCounts['Transformation'] ?? 0).toString(),
            AppAssets.iconTransform,
            context.colors.primaryMuted,
            () => context.go(Constants.epcisTransformationEventsRoute),
          ),
          (
            'TOTAL EVENTS',
            stats?.totalEvents.toString() ?? '0',
            AppAssets.iconDashboard,
            context.colors.textMuted,
            () => context.go(Constants.epcisEventsRoute),
          ),
        ];

        const gap = 12.0;
        final minTileWidth = layout.isCompact ? 188.0 : 200.0;
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
