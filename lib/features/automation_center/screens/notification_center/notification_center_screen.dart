import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_connection_indicator.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_embedded_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_filter_chips.dart';

const List<SubscriptionFilterOption> kDeliveryActivityFilterOptions = [
  SubscriptionFilterOption(label: 'All events', value: 'all'),
  SubscriptionFilterOption(label: 'Delivered', value: 'delivered'),
  SubscriptionFilterOption(label: 'Failed', value: 'failed'),
  SubscriptionFilterOption(label: 'Pending', value: 'pending'),
];

/// Per-event delivery inbox for notification webhooks / emails.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key, this.onManageSubscriptions});

  /// Switches the parent Notifications workspace to the Subscriptions tab.
  final VoidCallback? onManageSubscriptions;

  @override
  NotificationCenterScreenState createState() =>
      NotificationCenterScreenState();
}

class NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationCubit>();
    cubit.loadDeliveryActivity();
    cubit.loadFailedBatches();
  }

  bool _isLive(NotificationState state) {
    return state.notificationLiveEnabled &&
        state.connectionStatus == NotificationConnectionStatus.connected;
  }

  void refresh() {
    final cubit = context.read<NotificationCubit>();
    cubit.loadDeliveryActivity(forceSubscriptions: true);
    cubit.loadFailedBatches();
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
    if (widget.onManageSubscriptions != null) {
      widget.onManageSubscriptions!();
      return;
    }
    context.go(AutomationCenterSections.alertSubscriptionsLocation);
  }

  bool get isLive => _isLive(context.read<NotificationCubit>().state);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listenWhen: (prev, next) =>
          prev.connectionStatus != next.connectionStatus ||
          (prev.deliveryActivityError != next.deliveryActivityError &&
              next.deliveryActivityError != null) ||
          (prev.failedBatchesError != next.failedBatchesError &&
              next.failedBatchesError != null),
      listener: (context, state) {
        if (state.deliveryActivityError != null) {
          context.showError(state.deliveryActivityError!);
        }
        if (state.failedBatchesError != null) {
          context.showError(state.failedBatchesError!);
        }
      },
      builder: (context, state) {
        final c = context.colors;
        return SubscriptionEmbeddedBody(
          expandBody: false,
          description: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Per-event delivery timeline (email & webhook attempts). '
                  'Subscription totals live under Subscriptions.',
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
            options: kDeliveryActivityFilterOptions,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() => _selectedFilter = filter);
              context.read<NotificationCubit>().loadDeliveryActivity(
                outcome: filter,
              );
            },
          ),
          body: NotificationCenterBody(
            state: state,
            selectedFilter: _selectedFilter,
            shrinkWrap: true,
            onRefresh: refresh,
            onClearFilters: () {
              setState(() => _selectedFilter = 'all');
              context.read<NotificationCubit>().loadDeliveryActivity(
                outcome: 'all',
              );
            },
            onPrimaryAction: goManageSubscriptions,
          ),
        );
      },
    );
  }
}
