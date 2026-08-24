import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_master_row.dart';

class SubscriptionMasterList extends StatelessWidget {
  const SubscriptionMasterList({
    required this.subscriptions,
    required this.selectedId,
    required this.onSelected,
    this.shrinkWrap = false,
  });

  final List<NotificationSubscription> subscriptions;
  final String selectedId;
  final ValueChanged<NotificationSubscription> onSelected;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    // A shrink-wrapped ListView is a viewport and cannot report intrinsic dimensions. The
    // embedded desktop master/detail layout uses IntrinsicHeight so both panes remain equal
    // height; use ordinary box children in that mode while preserving the exact row spacing.
    if (shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < subscriptions.length; index++) ...[
            if (index > 0) const SizedBox(height: TraqSpacing.sm),
            _buildRow(subscriptions[index]),
          ],
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: subscriptions.length,
      separatorBuilder: (_, _) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (context, index) => _buildRow(subscriptions[index]),
    );
  }

  Widget _buildRow(NotificationSubscription subscription) {
    return SubscriptionMasterRow(
      subscription: subscription,
      selected: subscription.id == selectedId,
      onTap: () => onSelected(subscription),
    );
  }
}
