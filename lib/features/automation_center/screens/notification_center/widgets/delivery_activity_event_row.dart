import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_outcome.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_status_badge.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_error_banner.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_dense_row.dart';

export 'delivery_activity_outcome.dart';

/// One durable delivery attempt from `webhook_notifications`, rendered as a
/// theme-matching tile: a bordered [TraqCard] with a tinted circular status
/// icon (same tint/color language as [SubscriptionStatusChip] and the job
/// queue's status badges), the subscription name as a [SubscriptionMetaChip]
/// (the same chip used on subscription cards), and — for failures — the
/// error message in its own tinted banner instead of plain red text.
///
/// [dense] renders a compact single-row variant instead, for contexts with
/// less room (e.g. an embedded recent-activity feed).

class DeliveryActivityEventRow extends StatefulWidget {
  const DeliveryActivityEventRow({
    super.key,
    required this.notification,
    this.subscriptionName,
    this.dense = false,
  });

  final WebhookNotification notification;
  final String? subscriptionName;
  final bool dense;

  static String _channel(WebhookNotification notification) {
    final isEmail =
        notification.webhookUrl.contains('@') &&
        !notification.webhookUrl.toLowerCase().startsWith('http');
    return isEmail ? 'Email' : 'API';
  }

  static String _title(DeliveryActivityOutcome outcome, String channel) =>
      switch (outcome) {
        DeliveryActivityOutcome.failed => '$channel delivery failed',
        DeliveryActivityOutcome.delivered => '$channel delivered',
        DeliveryActivityOutcome.pending => '$channel pending',
        DeliveryActivityOutcome.other => 'Subscription event',
      };

  @override
  State<DeliveryActivityEventRow> createState() =>
      _DeliveryActivityEventRowState();
}

class _DeliveryActivityEventRowState extends State<DeliveryActivityEventRow> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      await context.read<NotificationCubit>().retryWebhook(
        widget.notification.id,
      );
      if (!mounted) return;
      context.showSuccess(
        widget.notification.isEmail
            ? 'Email queued for retry'
            : 'API delivery queued for retry',
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.getUserFriendlyMessage()
          : "Couldn't retry this delivery. Please try again.";
      context.showError(message);
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final outcome = DeliveryActivityOutcome.fromStatus(notification.status);
    final channel = DeliveryActivityEventRow._channel(notification);
    final title = DeliveryActivityEventRow._title(outcome, channel);
    final when = notification.deliveredAt ?? notification.createdAt;
    final time = DateFormat.MMMd().add_jm().format(when.toLocal());
    final color = outcome.color(context);

    if (widget.dense) {
      return DeliveryActivityDenseRow(
        notification: notification,
        subscriptionName: widget.subscriptionName,
        outcome: outcome,
        title: title,
        time: time,
        color: color,
      );
    }

    final c = context.colors;
    final showRetry = outcome == DeliveryActivityOutcome.failed;
    return TraqCard(
      padding: TraqSpacing.surfacePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeliveryActivityStatusBadge(icon: outcome.icon, color: color),
              const SizedBox(width: TraqSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: context.text.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: TraqSpacing.sm),
                        Text(
                          time,
                          style: context.text.cap.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                    if (widget.subscriptionName != null &&
                        widget.subscriptionName!.isNotEmpty) ...[
                      const SizedBox(height: TraqSpacing.xs),
                      SubscriptionMetaChip(
                        label: widget.subscriptionName!,
                        icon: AppAssets.iconList,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              notification.webhookUrl,
              style: context.text.mono.copyWith(color: c.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (notification.errorMessage != null &&
              notification.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: TraqSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: DeliveryActivityErrorBanner(
                message: notification.errorMessage!,
              ),
            ),
          ],
          if (showRetry) ...[
            const SizedBox(height: TraqSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: _retrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : OutlinedButton(
                      onPressed: _retry,
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: TraqSpacing.md,
                        ),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Retry now'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
