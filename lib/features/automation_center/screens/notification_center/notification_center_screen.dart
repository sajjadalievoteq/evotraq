import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_connection_status.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_embedded_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_filter_chips.dart';

/// Notification-center filter options (UI labels only; filter logic stays in
/// [SubscriptionFilterUtils.filterCenter]).
const List<SubscriptionFilterOption> kNotificationCenterFilterOptions = [
  SubscriptionFilterOption(label: 'All subscriptions', value: 'all'),
  SubscriptionFilterOption(label: 'With deliveries', value: 'activity'),
  SubscriptionFilterOption(label: 'Active only', value: 'active'),
];

/// Aggregate delivery activity for subscriptions (Automation Center panel).
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

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

  bool _isLive(NotificationState state) {
    return state.notificationLiveEnabled &&
        state.connectionStatus == NotificationConnectionStatus.connected;
  }

  void refresh() {
    context.read<NotificationCubit>().loadSubscriptions(force: true);
  }

  void toggleLive() {
    final cubit = context.read<NotificationCubit>();
    final currentlyLive = cubit.state.notificationLiveEnabled;
    try {
      if (currentlyLive) {
        cubit.disableNotificationLive();
        context.showInfo('Delivery Activity live updates paused');
      } else {
        cubit.enableNotificationLive();
        context.showInfo('Resuming Delivery Activity live updates…');
      }
    } catch (e) {
      context.showError('Connection error: $e');
    }
  }

  void goManageSubscriptions() {
    context.go(AutomationCenterSections.alertSubscriptionsLocation);
  }

  bool get isLive => _isLive(context.read<NotificationCubit>().state);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listenWhen: (prev, next) =>
          prev.connectionStatus != next.connectionStatus ||
          (prev.status != next.status &&
              next.status == NotificationStatus.error),
      listener: (context, state) {
        if (state.status == NotificationStatus.error && state.error != null) {
          context.showError(state.error!);
        }
      },
      builder: (context, state) {
        final c = context.colors;
        return SubscriptionEmbeddedBody(
          description: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Aggregate Delivered / Failed counters per subscription. '
                  'This is not a per-event notification inbox.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: c.textMuted),
                ),
              ),
              const SizedBox(width: TraqSpacing.sm),
              NotificationConnectionIndicator(
                liveEnabled: state.notificationLiveEnabled,
                connectionStatus: state.connectionStatus,
              ),
            ],
          ),
          filterChips: SubscriptionFilterChips(
            options: kNotificationCenterFilterOptions,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) =>
                setState(() => _selectedFilter = filter),
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
      },
    );
  }
}
