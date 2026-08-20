import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/batch_delivery_event_row.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_event_row.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_outcome.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/empty_delivery_feed.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_skeleton_shape.dart';

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
        (state.deliveryActivityLoading && state.deliveryActivity.isEmpty) ||
        (state.failedBatchesLoading &&
            state.failedBatches.isEmpty &&
            state.deliveryActivity.isEmpty);
    if (loading ||
        (state.status == NotificationStatus.initial &&
            state.subscriptions.isEmpty)) {
      return SubscriptionLoadingSkeleton(
        shrinkWrap: shrinkWrap,
        itemCount: 4,
        shape: SubscriptionSkeletonShape.activityCard,
      );
    }
    if (state.deliveryActivityError != null &&
        state.deliveryActivity.isEmpty &&
        state.failedBatches.isEmpty) {
      return SubscriptionErrorView(
        title: 'Error loading delivery events',
        message: state.deliveryActivityError ?? 'Unknown error',
        onRetry: onRefresh,
      );
    }
    final nameById = {
      for (final subscription in state.subscriptions)
        subscription.id: subscription.subscriptionName,
    };
    // Server already filters by outcome; keep a local match as a safety net.
    final filtered = state.deliveryActivity
        .where(
          (event) => DeliveryActivityOutcome.fromStatus(
            event.status,
          ).matchesFilter(selectedFilter),
        )
        .toList();
    final hasCounters = state.subscriptions.any((subscription) {
      final stats = subscription.stats;
      return stats != null &&
          (stats.successfulNotifications > 0 ||
              stats.failedNotifications > 0 ||
              stats.totalNotifications > 0);
    });
    if (filtered.isEmpty && state.failedBatches.isEmpty) {
      return EmptyDeliveryFeed(
        hasAnyEvents:
            state.deliveryActivity.isNotEmpty || state.deliveryActivityHasMore,
        hasCounters: hasCounters,
        selectedFilter: selectedFilter,
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }

    // Failed batches used to be pinned above the feed, which made old failures
    // sit on top of newer deliveries. Merge everything into one newest-first
    // timeline, and only include batches when the filter allows failures.
    final showFailedBatches =
        selectedFilter == 'all' || selectedFilter == 'failed';
    final timeline = <({DateTime time, Widget child})>[
      if (showFailedBatches)
        for (final batch in state.failedBatches)
          (
            time: batch.createdAt,
            child: BatchDeliveryEventRow(
              batch: batch,
              subscriptionName: nameById[batch.subscriptionId],
            ),
          ),
      for (final event in filtered)
        (
          time: event.deliveredAt ?? event.createdAt,
          child: DeliveryActivityEventRow(
            notification: event,
            subscriptionName: nameById[event.subscriptionId],
          ),
        ),
    ]..sort((a, b) => b.time.compareTo(a.time));

    if (timeline.isEmpty) {
      return EmptyDeliveryFeed(
        hasAnyEvents:
            state.deliveryActivity.isNotEmpty || state.deliveryActivityHasMore,
        hasCounters: hasCounters,
        selectedFilter: selectedFilter,
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }

    final showLoadMoreFooter =
        state.deliveryActivityHasMore || state.deliveryActivityLoadingMore;
    final itemCount = timeline.length + (showLoadMoreFooter ? 1 : 0);

    final list = ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= timeline.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.md),
            child: Center(
              child: state.deliveryActivityLoadingMore
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == timeline.length - 1 && !showLoadMoreFooter
                ? 0
                : TraqSpacing.sm,
          ),
          child: timeline[index].child,
        );
      },
    );

    if (shrinkWrap) {
      return list;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400 &&
            state.deliveryActivityHasMore &&
            !state.deliveryActivityLoadingMore &&
            !state.deliveryActivityLoading) {
          context.read<NotificationCubit>().loadMoreDeliveryActivity();
        }
        return false;
      },
      child: list,
    );
  }
}
