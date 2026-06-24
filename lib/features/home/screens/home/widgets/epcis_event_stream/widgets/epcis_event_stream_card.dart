import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/utils/home_navigation.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/epcis_event_stream/widgets/dashboard_recent_event_tile.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class EpcisEventStreamCard extends StatelessWidget {
  const EpcisEventStreamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.recentEvents != c.recentEvents,
      builder: (context, state) {
        final recentEvents = state.recentEvents;
        final borderColor = context.colors.border.withValues(alpha: 0.6);
        final isTabletUp = context.layout.isTabletUp;

        Widget? eventList;
        if (recentEvents != null && recentEvents.isNotEmpty) {
          final listView = ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: !isTabletUp,
            physics: isTabletUp
                ? const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  )
                : const NeverScrollableScrollPhysics(),
            itemCount: recentEvents.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
            itemBuilder: (context, i) =>
                DashboardRecentEventTile(event: recentEvents[i]),
          );
          eventList = isTabletUp ? Expanded(child: listView) : listView;
        }

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(Constants.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: isTabletUp ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        HomeStrings.epcisStreamTitle,
                        style: context.text.h3.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        HomeStrings.epcisStreamLive,
                        style: context.text.cap.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.colors.success,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: HomeStrings.epcisStreamOpenFiltersTooltip,
                      icon: SvgPicture.asset(
                        AppAssets.iconFilter,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => context.go(HomeNavigation.epcisEvents),
                    ),
                    TextButton(
                      onPressed: () => context.go(HomeNavigation.epcisEvents),
                      child: Text(
                        HomeStrings.epcisStreamViewAll,
                        style: context.text.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 1, color: borderColor),
                if (eventList != null) eventList,
              ],
            ),
          ),
        );
      },
    );
  }
}
