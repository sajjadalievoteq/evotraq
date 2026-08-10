import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_event_row.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
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
    final loading =
        state.deliveryActivityLoading && state.deliveryActivity.isEmpty;
    if (loading ||
        (state.status == NotificationStatus.initial &&
            state.subscriptions.isEmpty)) {
      return SubscriptionLoadingSkeleton(
        shrinkWrap: shrinkWrap,
        itemCount: 4,
        shape: SubscriptionSkeletonShape.activityCard,
      );
    }

    if (state.deliveryActivityError != null && state.deliveryActivity.isEmpty) {
      return SubscriptionErrorView(
        title: 'Error loading delivery events',
        message: state.deliveryActivityError ?? 'Unknown error',
        onRetry: onRefresh,
      );
    }

    final nameById = {
      for (final sub in state.subscriptions) sub.id: sub.subscriptionName,
    };
    final filtered = state.deliveryActivity.where((event) {
      return DeliveryActivityOutcome.fromStatus(
        event.status,
      ).matchesFilter(selectedFilter);
    }).toList();

    final hasCounters = state.subscriptions.any((sub) {
      final stats = sub.stats;
      if (stats == null) return false;
      return stats.successfulNotifications > 0 ||
          stats.failedNotifications > 0 ||
          stats.totalNotifications > 0;
    });

    if (filtered.isEmpty) {
      return _EmptyDeliveryFeed(
        hasAnyEvents: state.deliveryActivity.isNotEmpty,
        hasCounters: hasCounters,
        selectedFilter: selectedFilter,
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }

    // Each delivery event renders as its own theme-matching tile
    // (DeliveryActivityEventRow now wraps itself in a TraqCard), so this is
    // just a spaced list rather than one bordered box with divider rows.
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (context, index) {
        final event = filtered[index];
        return DeliveryActivityEventRow(
          notification: event,
          subscriptionName: nameById[event.subscriptionId],
        );
      },
    );
  }
}

class _EmptyDeliveryFeed extends StatelessWidget {
  const _EmptyDeliveryFeed({
    required this.hasAnyEvents,
    required this.hasCounters,
    required this.selectedFilter,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });

  final bool hasAnyEvents;
  final bool hasCounters;
  final String selectedFilter;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    if (hasAnyEvents) {
      return SubscriptionEmptyState(
        totalSubscriptions: 1,
        selectedFilter: selectedFilter,
        title: 'No matching delivery events',
        subtitle: 'Try another status filter.',
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }

    final subtitle = hasCounters
        ? 'Matched / Delivered counters can be non-zero while this feed is '
              'empty — counters update even when no durable history row was '
              'stored (older deliveries, or retention cleanup). New deliveries '
              'after history persistence will appear here.'
        : 'When email or webhook deliveries run, each attempt shows up here.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubscriptionEmptyState(
          totalSubscriptions: 0,
          selectedFilter: 'all',
          title: 'No delivery events yet',
          subtitle: subtitle,
          primaryActionLabel: 'Manage Subscriptions',
          onClearFilters: onClearFilters,
          onPrimaryAction: onPrimaryAction,
        ),
      ],
    );
  }
}
