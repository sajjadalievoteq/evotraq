import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_state.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

class StatusRail extends StatelessWidget {
  const StatusRail({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return _WallClockTick(
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
            final zoneText = _statusRailTimeZoneLabel(now);

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
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: healthy
                          ? context.colors.success
                          : context.colors.warning,
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

            final refreshedAt = state.lastDataRefreshAt;
            final version = state.healthStatus?.backendVersion?.trim();
            final subtitle = _homeFreshnessAndVersionLine(
              refreshedAt: refreshedAt,
              now: now,
              backendVersion: version,
            );
            final statusBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _nominalStatusLine(healthy, now),
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

class _WallClockTick extends StatefulWidget {
  const _WallClockTick({required this.builder});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<_WallClockTick> createState() => _WallClockTickState();
}

class _WallClockTickState extends State<_WallClockTick> {
  late final Stream<DateTime> _everySecond;

  @override
  void initState() {
    super.initState();
    _everySecond = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _everySecond,
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        return widget.builder(context, now);
      },
    );
  }
}

String _statusRailTimeZoneLabel(DateTime now) {
  final abbr = DateFormat('z').format(now).trim();
  if (abbr.isNotEmpty) return abbr;
  final zzz = DateFormat('ZZZ').format(now).trim();
  if (zzz.isNotEmpty) return zzz;
  final name = now.timeZoneName.trim();
  if (name.isNotEmpty) return name;
  return _utcOffsetLabel(now.timeZoneOffset);
}

String _utcOffsetLabel(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final total = offset.inMinutes.abs();
  final h = total ~/ 60;
  final m = total % 60;
  return HomeStrings.utcOffsetLabel(
    sign,
    h.toString().padLeft(2, '0'),
    m.toString().padLeft(2, '0'),
  );
}

String? _homeFreshnessAndVersionLine({
  required DateTime? refreshedAt,
  required DateTime now,
  required String? backendVersion,
}) {
  final refresh = refreshedAt;
  final ver = backendVersion?.trim();
  final parts = <String>[];
  if (refresh != null) {
    parts.add(
      HomeStrings.dataRefreshed(_relativeRefreshPhrase(refresh, now)),
    );
  }
  if (ver != null && ver.isNotEmpty) {
    parts.add(_formatBackendVersionLine(ver));
  }
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

String _formatBackendVersionLine(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  final withV = RegExp(r'^[vV](\d|\.)').hasMatch(t) ? t : 'v$t';
  return HomeStrings.servicesVersion(withV);
}

String _relativeRefreshPhrase(DateTime refreshedAt, DateTime now) {
  var diff = now.difference(refreshedAt);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inSeconds < 15) return HomeStrings.relativeJustNow;
  if (diff.inMinutes < 1) return HomeStrings.relativeUnderOneMin;
  if (diff.inMinutes < 60) {
    return HomeStrings.relativeMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return h == 1
        ? HomeStrings.relativeOneHourAgo
        : HomeStrings.relativeHoursAgo(h);
  }
  return DateFormat.yMMMd().add_jm().format(refreshedAt);
}

String _nominalStatusLine(bool healthy, DateTime now) {
  final h = now.hour;
  final greeting = h < 12
      ? HomeStrings.greetingMorning
      : h < 17
          ? HomeStrings.greetingAfternoon
          : HomeStrings.greetingEvening;
  if (!healthy) {
    return HomeStrings.statusNominalDegraded(greeting);
  }
  return HomeStrings.statusNominalHealthy(greeting);
}
