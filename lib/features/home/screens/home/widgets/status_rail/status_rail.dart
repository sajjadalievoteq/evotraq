import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/status_rail_formatters.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/wall_clock_tick.dart';

class StatusRail extends StatelessWidget {
  const StatusRail({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return WallClockTick(
      builder: (context, now) {
        return BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (p, c) =>
              p.healthStatus != c.healthStatus ||
              p.stats != c.stats ||
              p.status != c.status ||
              p.lastDataRefreshAt != c.lastDataRefreshAt,
          builder: (context, state) {
            final health = state.healthStatus;
            final healthy = health?.backendHealthy == true &&
                health?.databaseHealthy == true &&
                health?.cacheHealthy == true;

            final timeText = DateFormat('HH:mm').format(now);
            final zoneText = statusRailTimeZoneLabel(now);

            final clock = Column(
              crossAxisAlignment:layout.isTabletUp? CrossAxisAlignment.end:CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  zoneText,
                  style: context.text.bodySm.copyWith(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: context.text.bodySm.copyWith(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );

            final healthChip = Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  HomeStrings.statusRailSystem,
                  style: context.text.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    fontSize: 11,
                    color: context.colors.textPrimary.withOpacity(0.8),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TraqIcon(AppAssets.iconCircle, color: healthy
                          ? context.colors.success
                          : context.colors.warning, size: 10),
                    const SizedBox(width: 6),
                    Text(
                      healthy
                          ? HomeStrings.statusRailHealthy
                          : HomeStrings.statusRailDegraded,
                      style: context.text.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        fontSize: 14,
                        color: healthy
                            ? context.colors.success
                            : context.colors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            );

            final refreshedAt = state.lastDataRefreshAt;
            final version = state.healthStatus?.backendVersion?.trim();
            final subtitle = homeFreshnessAndVersionLine(
              refreshedAt: refreshedAt,
              now: now,
              backendVersion: version,
            );
            final statusBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nominalStatusLine(healthy, now),
                  style: context.text.h3.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: context.text.bodySm.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            );

            if (layout.isTabletUp) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.gutter(context),
                    vertical: ResponsiveUtils.gutter(context) * 0.5,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: statusBlock),
                      clock,
                      const SizedBox(width: 20),
                      healthChip,
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.gutter(context),
                  vertical: ResponsiveUtils.gutter(context) * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    statusBlock,
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        clock,
                        healthChip,
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
