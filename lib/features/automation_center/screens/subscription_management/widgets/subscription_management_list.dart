import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card.dart';

class SubscriptionManagementList extends StatelessWidget {
  const SubscriptionManagementList({
    super.key,
    required this.subscriptions,
    required this.selectedFilter,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    required this.onClearFilters,
    required this.onCreate,
  });

  final List<NotificationSubscription> subscriptions;
  final String selectedFilter;
  final bool shrinkWrap;
  final Future<void> Function() onRefresh;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final void Function(NotificationSubscription) onViewDetails;
  final VoidCallback onClearFilters;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final filteredSubscriptions =
        SubscriptionFilterUtils.filterManagement(subscriptions, selectedFilter);

    if (filteredSubscriptions.isEmpty) {
      return SubscriptionManagementEmptyState(
        totalSubscriptions: subscriptions.length,
        selectedFilter: selectedFilter,
        onClearFilters: onClearFilters,
        onCreate: onCreate,
      );
    }

    final cards = <Widget>[
      for (final subscription in filteredSubscriptions)
        Padding(
          padding: const EdgeInsets.only(bottom: TraqSpacing.md),
          child: SubscriptionCard(
            subscription: subscription,
            onEdit: onEdit,
            onDelete: onDelete,
            onPause: onPause,
            onResume: onResume,
            onViewDetails: onViewDetails,
          ),
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
