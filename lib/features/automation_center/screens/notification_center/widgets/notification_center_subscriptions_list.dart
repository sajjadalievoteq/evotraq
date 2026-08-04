import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_subscription_card.dart';

class NotificationCenterSubscriptionsList extends StatelessWidget {
  const NotificationCenterSubscriptionsList({
    super.key,
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

    if (filtered.isEmpty) {
      return NotificationCenterEmptyState(
        totalSubscriptions: subscriptions.length,
        selectedFilter: selectedFilter,
        onClearFilters: onClearFilters,
        onPrimaryAction: onPrimaryAction,
      );
    }

    final cards = <Widget>[
      for (final sub in filtered)
        Padding(
          padding: const EdgeInsets.only(bottom: TraqSpacing.md),
          child: NotificationCenterSubscriptionCard(subscription: sub),
        ),
    ];

    if (shrinkWrap) {
      // Embedded in a bounded panel body: scroll within the available height
      // (padding comes from the surrounding card).
      return ListView(
        padding: EdgeInsets.zero,
        children: cards,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: TraqSpacing.surfacePad,
        children: cards,
      ),
    );
  }
}
