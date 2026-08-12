import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_body.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_delivery_utils.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_action_menu.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_config_row.dart';

class SubscriptionDetailPane extends StatelessWidget {
  const SubscriptionDetailPane({
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    this.onViewAllActivity,
  });

  final NotificationSubscription subscription;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final VoidCallback onViewDetails;
  final VoidCallback? onViewAllActivity;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final created = DateFormat.yMMMd().format(subscription.createdAt.toLocal());
    final deliveryLabel = SubscriptionDeliveryUtils.labelForEndpoint(
      subscription.webhookUrl,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TraqIcon(
                        SubscriptionDeliveryUtils.iconForEndpoint(
                          subscription.webhookUrl,
                        ),
                        size: 22,
                        color: c.primary,
                      ),
                      const SizedBox(width: TraqSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subscription.subscriptionName,
                                    style: context.text.h3.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SubscriptionStatusChip(
                                  status: subscription.status,
                                ),
                                SubscriptionActionMenu(
                                  subscription: subscription,
                                  onEdit: () => onEdit(subscription),
                                  onPause: () => onPause(subscription),
                                  onResume: () => onResume(subscription),
                                  onDelete: () => onDelete(subscription),
                                ),
                              ],
                            ),
                            const SizedBox(height: TraqSpacing.xs),
                            Text(
                              "$deliveryLabel: ${subscription.webhookUrl}",
                              style: context.text.bodySm.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                            Text(
                              'Created: $created',
                              style: context.text.bodySm.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.lg),
                  SubscriptionConfigRow(
                    label: 'Delivery',
                    value: deliveryLabel,
                  ),
                  SubscriptionConfigRow(
                    label: 'Type',
                    value: subscription.subscriptionType,
                  ),
                  SubscriptionConfigRow(
                    label: 'Format',
                    value: subscription.notificationFormat ?? '—',
                  ),
                  const SizedBox(height: TraqSpacing.lg),
                  Text(
                    'Delivery metrics and per-event history live on the '
                    'Activity tab.',
                    style: context.text.bodySm.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            FilledButton(
              onPressed: onViewDetails,
              child: const Text('Open full details'),
            ),
          ],
        ),
      ),
    );
  }
}
