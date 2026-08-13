import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/batch_delivery_event_row.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_event_row.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/empty_delivery_feed.dart';
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
        hasAnyEvents: state.deliveryActivity.isNotEmpty,
        hasCounters: hasCounters,
        selectedFilter: selectedFilter,
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      children: [
        if (state.failedBatches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
            child: Text(
              'Awaiting Manual Retry',
              style: context.text.bodySm.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...state.failedBatches.map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
              child: BatchDeliveryEventRow(
                batch: batch,
                subscriptionName: nameById[batch.subscriptionId],
              ),
            ),
          ),
          if (filtered.isNotEmpty) const Divider(height: TraqSpacing.lg),
        ],
        ...filtered.asMap().entries.map((entry) {
          final event = entry.value;
          final isLast = entry.key == filtered.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : TraqSpacing.sm),
            child: DeliveryActivityEventRow(
              notification: event,
              subscriptionName: nameById[event.subscriptionId],
            ),
          );
        }),
      ],
    );
  }
}
