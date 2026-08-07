import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
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
    final showHealth = context.isAdmin;
    return WallClockTick(
      builder: (context, now) {
        return BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (p, c) =>
              p.healthStatus != c.healthStatus ||
              p.stats != c.stats ||
              p.status != c.status ||
              p.lastDataRefreshAt != c.lastDataRefreshAt ||
              p.liveUpdatesConnected != c.liveUpdatesConnected,
          builder: (context, state) {
            final health = state.healthStatus;
            final healthy =
                health?.backendHealthy == true &&
                health?.databaseHealthy == true &&
                health?.cacheHealthy == true;

            final timeText = DateFormat('HH:mm').format(now);
            final zoneText = statusRailTimeZoneLabel(now);

            final clock = Column(
              crossAxisAlignment: layout.isTabletUp
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
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
                    TraqIcon(
                      AppAssets.iconCircle,
                      color: healthy
                          ? context.colors.success
                          : context.colors.warning,
                      size: 10,
                    ),
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

            final version = state.healthStatus?.backendVersion?.trim();
            final servicesVersion = homeServicesVersion(
              backendVersion: version,
            );
            final statusBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  showHealth
                      ? nominalStatusLine(healthy, now)
                      : greetingOnlyStatusLine(now),
                  style: context.text.h3.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                _LiveUpdatesIndicator(
                  isLive: state.liveUpdatesConnected,
                  servicesVersion: servicesVersion,
                ),
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
                      if (showHealth) ...[
                        const SizedBox(width: 20),
                        healthChip,
                      ],
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
                      children: [clock, if (showHealth) healthChip],
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

class _LiveUpdatesIndicator extends StatelessWidget {
  const _LiveUpdatesIndicator({
    required this.isLive,
    required this.servicesVersion,
  });

  final bool isLive;
  final String? servicesVersion;

  @override
  Widget build(BuildContext context) {
    final statusColor = isLive
        ? context.colors.success
        : context.colors.textMuted;

    return Semantics(
      container: true,
      liveRegion: true,
      label: isLive
          ? HomeStrings.liveDashboardUpdatesSemantics
          : HomeStrings.dashboardUpdatesNotLiveSemantics,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: isLive
                    ? [
                        BoxShadow(
                          color: statusColor.withOpacity(0.32),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 14,
              color: statusColor.withOpacity(0.30),
            ),
            const SizedBox(width: 8),

            Text(
              isLive
                  ? HomeStrings.liveDashboardUpdates
                  : HomeStrings.dashboardUpdatesNotLive,
              style: context.text.body.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (servicesVersion != null) ...[
              const SizedBox(width: 8),
              Text(
                servicesVersion!,
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
