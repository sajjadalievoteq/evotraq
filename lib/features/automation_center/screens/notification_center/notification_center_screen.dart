import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_connection_status.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_embedded_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_standalone_scaffold.dart';

/// Notification-center filter options (UI labels only; filter logic stays in
/// [SubscriptionFilterUtils.filterCenter]).
const List<SubscriptionFilterOption> kNotificationCenterFilterOptions = [
  SubscriptionFilterOption(label: 'All subscriptions', value: 'all'),
  SubscriptionFilterOption(label: 'With deliveries', value: 'activity'),
  SubscriptionFilterOption(label: 'Active only', value: 'active'),
];

/// Aggregate delivery activity for subscriptions (not a per-event inbox).
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  NotificationCenterScreenState createState() =>
      NotificationCenterScreenState();
}

class NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadSubscriptions();
  }

  @override
  void dispose() {
    final cubit = context.read<NotificationCubit>();
    if (cubit.isWebSocketConnected) {
      cubit.disconnectWebSocket();
    }
    super.dispose();
  }

  bool _isLive(NotificationState state) {
    return state.status == NotificationStatus.webSocketConnected ||
        context.read<NotificationCubit>().isWebSocketConnected;
  }

  void refresh() {
    context.read<NotificationCubit>().loadSubscriptions(force: true);
  }

  void toggleLive() {
    final live = _isLive(context.read<NotificationCubit>().state);
    _toggleWebSocketConnection(live);
  }

  void goManageSubscriptions() {
    context.go('/notifications/subscriptions');
  }

  bool get isLive => _isLive(context.read<NotificationCubit>().state);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listenWhen: (prev, next) =>
          prev.status != next.status &&
          (next.status == NotificationStatus.webSocketConnected ||
              next.status == NotificationStatus.webSocketDisconnected ||
              next.status == NotificationStatus.error),
      listener: (context, state) {
        if (state.status == NotificationStatus.error && state.error != null) {
          context.showError(state.error!);
        }
      },
      builder: (context, state) {
        final live = _isLive(state);
        if (widget.embedded) {
          return _buildEmbedded(context, state, live);
        }
        return _buildStandalone(context, state, live);
      },
    );
  }

  Widget _buildEmbedded(
    BuildContext context,
    NotificationState state,
    bool live,
  ) {
    final c = context.colors;
    return SubscriptionEmbeddedBody(
      description: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Aggregate Delivered / Failed counters per subscription. '
              'This is not a per-event notification inbox.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textMuted,
                  ),
            ),
          ),
          const SizedBox(width: TraqSpacing.sm),
          NotificationConnectionStatus(live: live),
        ],
      ),
      filterChips: SubscriptionFilterChips(
        options: kNotificationCenterFilterOptions,
        selectedFilter: _selectedFilter,
        onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
      ),
      body: NotificationCenterBody(
        state: state,
        selectedFilter: _selectedFilter,
        shrinkWrap: true,
        onRefresh: refresh,
        onClearFilters: () => setState(() => _selectedFilter = 'all'),
        onPrimaryAction: goManageSubscriptions,
      ),
    );
  }

  Widget _buildStandalone(
    BuildContext context,
    NotificationState state,
    bool live,
  ) {
    final c = context.colors;
    return SubscriptionStandaloneScaffold(
      title: 'Delivery Activity',
      actions: [
        IconButton(
          icon: TraqIcon(
            live ? AppAssets.iconWifi : AppAssets.iconWifiOff,
            color: live
                ? AppColorMapper.successColor(context)
                : AppColorMapper.errorColor(context),
          ),
          onPressed: () => _toggleWebSocketConnection(live),
          tooltip: live
              ? 'Connected to real-time updates'
              : 'Disconnected',
        ),
        IconButton(
          icon: TraqIcon(AppAssets.iconSettings),
          onPressed: goManageSubscriptions,
          tooltip: 'Manage Subscriptions',
        ),
        IconButton(
          icon: TraqIcon(AppAssets.iconRefresh),
          onPressed: refresh,
          tooltip: 'Refresh',
        ),
      ],
      header: Column(
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: c.textPrimary,
                              ),
                    ),
                    const SizedBox(height: TraqSpacing.sm),
                    Text(
                      'Aggregate Delivered / Failed counters per '
                      'subscription. This is not a per-event '
                      'notification inbox.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: c.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TraqSpacing.sm),
              NotificationConnectionStatus(live: live),
            ],
          ),
          const SizedBox(height: TraqSpacing.lg),
          SubscriptionFilterChips(
            options: kNotificationCenterFilterOptions,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) =>
                setState(() => _selectedFilter = filter),
          ),
        ],
      ),
      body: NotificationCenterBody(
        state: state,
        selectedFilter: _selectedFilter,
        shrinkWrap: false,
        onRefresh: refresh,
        onClearFilters: () => setState(() => _selectedFilter = 'all'),
        onPrimaryAction: goManageSubscriptions,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goManageSubscriptions,
        icon: TraqIcon(AppAssets.iconPlus),
        label: const Text('Add Subscription'),
      ),
    );
  }

  void _toggleWebSocketConnection(bool currentlyLive) {
    final cubit = context.read<NotificationCubit>();
    try {
      if (currentlyLive) {
        cubit.disconnectWebSocket();
        context.showInfo('Disconnected from real-time updates');
      } else {
        cubit.connectWebSocket();
        context.showInfo('Connecting to real-time updates…');
      }
    } catch (e) {
      context.showError('Connection error: $e');
    }
  }
}
