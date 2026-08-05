import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_subscription_card.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_list_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';

class NotificationCenterBody extends StatelessWidget {
  const NotificationCenterBody({
    super.key,
    required this.state,
    required this.selectedFilter,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });

  final NotificationState state;
  final String selectedFilter;
  final bool shrinkWrap;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    if (state.status == NotificationStatus.initial ||
        (state.status == NotificationStatus.loading &&
            state.subscriptions.isEmpty)) {
      return SubscriptionLoadingSkeleton(
        shrinkWrap: shrinkWrap,
        itemCount: 3,
        shape: SubscriptionSkeletonShape.activityCard,
      );
    }
    if (state.status == NotificationStatus.error &&
        state.subscriptions.isEmpty) {
      return SubscriptionErrorView(
        title: 'Error loading delivery activity',
        message: state.error ?? 'Unknown error',
        onRetry: onRefresh,
      );
    }
    return _FilteredActivityCards(
      subscriptions: state.subscriptions,
      selectedFilter: selectedFilter,
      shrinkWrap: shrinkWrap,
      onRefresh: () async => onRefresh(),
      onClearFilters: onClearFilters,
      onPrimaryAction: onPrimaryAction,
    );
  }
}

class _FilteredActivityCards extends StatelessWidget {
  const _FilteredActivityCards({
    required this.subscriptions,
    required this.selectedFilter,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });

  final List<NotificationSubscription> subscriptions;
  final String selectedFilter;
  final bool shrinkWrap;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final filtered =
        SubscriptionFilterUtils.filterCenter(subscriptions, selectedFilter);

    return SubscriptionListView(
      cards: [
        for (final sub in filtered)
          NotificationCenterSubscriptionCard(subscription: sub),
      ],
      emptyState: SubscriptionEmptyState(
        totalSubscriptions: subscriptions.length,
        selectedFilter: selectedFilter,
        title: 'No matching subscriptions',
        subtitle: 'Create alert subscriptions to track delivery activity.',
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      ),
      shrinkWrap: shrinkWrap,
      onRefresh: onRefresh,
    );
  }
}
