import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/epcis_event_stream/widgets/dashboard_recent_event_tile.dart';

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
                    
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10,),
                  child: Divider(
                      height: 1, color: borderColor),
                ),
                ?eventList,
              ],
            ),
          ),
        );
      },
    );
  }
}