import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_connection_status.dart';

class NotificationCenterStandaloneScaffold extends StatelessWidget {
  const NotificationCenterStandaloneScaffold({
    super.key,
    required this.state,
    required this.live,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onToggleLive,
    required this.onManageSubscriptions,
    required this.onRefresh,
    required this.onClearFilters,
  });

  final NotificationState state;
  final bool live;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onToggleLive;
  final VoidCallback onManageSubscriptions;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Activity'),
        actions: [
          IconButton(
            icon: TraqIcon(
              live ? AppAssets.iconWifi : AppAssets.iconWifiOff,
              color: live
                  ? AppColorMapper.successColor(context)
                  : AppColorMapper.errorColor(context),
            ),
            onPressed: onToggleLive,
            tooltip: live
                ? 'Connected to real-time updates'
                : 'Disconnected',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconSettings),
            onPressed: onManageSubscriptions,
            tooltip: 'Manage Subscriptions',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: TraqSpacing.surfacePad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery activity',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: c.textPrimary,
                                ),
                          ),
                          const SizedBox(height: TraqSpacing.sm),
                          Text(
                            'Aggregate Delivered / Failed counters per '
                            'subscription. This is not a per-event '
                            'notification inbox.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TraqSpacing.sm),
                    NotificationConnectionStatus(live: live),
                  ],
                ),
                const SizedBox(height: TraqSpacing.lg),
                NotificationCenterFilterChips(
                  selectedFilter: selectedFilter,
                  onFilterSelected: onFilterSelected,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: NotificationCenterBody(
              state: state,
              selectedFilter: selectedFilter,
              shrinkWrap: false,
              onRefresh: onRefresh,
              onClearFilters: onClearFilters,
              onPrimaryAction: onManageSubscriptions,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onManageSubscriptions,
        icon: TraqIcon(AppAssets.iconPlus),
        label: const Text('Add Subscription'),
      ),
    );
  }
}
