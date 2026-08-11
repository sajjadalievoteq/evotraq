import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_outcome.dart';

class DeliveryActivityDenseRow extends StatelessWidget {
  const DeliveryActivityDenseRow({
    required this.notification,
    required this.subscriptionName,
    required this.outcome,
    required this.title,
    required this.time,
    required this.color,
  });

  final WebhookNotification notification;
  final String? subscriptionName;
  final DeliveryActivityOutcome outcome;
  final String title;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(outcome.icon, size: 16, color: color),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subscriptionName != null && subscriptionName!.isNotEmpty)
                  Text(
                    subscriptionName!,
                    style: context.text.cap.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  notification.webhookUrl,
                  style: context.text.cap.copyWith(color: c.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notification.errorMessage != null &&
                    notification.errorMessage!.isNotEmpty)
                  Text(
                    notification.errorMessage!,
                    style: context.text.cap.copyWith(color: color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(time, style: context.text.cap.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}
