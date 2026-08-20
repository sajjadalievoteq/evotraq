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
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.zero,
      itemCount: subscriptions.length,
      separatorBuilder: (_, _) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        return SubscriptionMasterRow(
          subscription: sub,
          selected: sub.id == selectedId,
          onTap: () => onSelected(sub),
        );
      },
    );
  }
}
