import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';

enum DeliveryActivityOutcome {
  delivered,
  failed,
  pending,
  other;

  static DeliveryActivityOutcome fromStatus(String status) {
    final s = status.toUpperCase();
    if (s.contains('FAIL') || s.contains('ERROR')) {
      return DeliveryActivityOutcome.failed;
    }
    if (s.contains('SUCCESS') ||
        s.contains('DELIVER') ||
        s == 'SENT' ||
        s == 'OK') {
      return DeliveryActivityOutcome.delivered;
    }
    if (s.contains('PENDING') || s.contains('RETRY')) {
      return DeliveryActivityOutcome.pending;
    }
    return DeliveryActivityOutcome.other;
  }

  String get icon => switch (this) {
    DeliveryActivityOutcome.failed => AppAssets.iconXCircle,
    DeliveryActivityOutcome.delivered => AppAssets.iconCheckCircle,
    DeliveryActivityOutcome.pending => AppAssets.iconClock,
    DeliveryActivityOutcome.other => AppAssets.iconNotification,
  };

  Color color(BuildContext context) => switch (this) {
    DeliveryActivityOutcome.failed => AppColorMapper.errorColor(context),
    DeliveryActivityOutcome.delivered => AppColorMapper.successColor(context),
    DeliveryActivityOutcome.pending => AppColorMapper.warningColor(context),
    DeliveryActivityOutcome.other => AppColorMapper.infoColor(context),
  };

  bool matchesFilter(String filter) => switch (filter) {
    'delivered' => this == DeliveryActivityOutcome.delivered,
    'failed' => this == DeliveryActivityOutcome.failed,
    'pending' => this == DeliveryActivityOutcome.pending,
    _ => true,
  };
}

/// One durable delivery attempt from `webhook_notifications`, rendered as a
/// theme-matching tile: a bordered [TraqCard] with a tinted circular status
/// icon (same tint/color language as [SubscriptionStatusChip] and the job
/// queue's status badges), the subscription name as a [SubscriptionMetaChip]
/// (the same chip used on subscription cards), and — for failures — the
/// error message in its own tinted banner instead of plain red text.
///
/// [dense] renders a compact single-row variant instead, for contexts with
/// less room (e.g. an embedded recent-activity feed).
class DeliveryActivityEventRow extends StatelessWidget {
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
    return isEmail ? 'Email' : 'Webhook';
  }

  static String _title(DeliveryActivityOutcome outcome, String channel) =>
      switch (outcome) {
        DeliveryActivityOutcome.failed => '$channel delivery failed',
        DeliveryActivityOutcome.delivered => '$channel delivered',
        DeliveryActivityOutcome.pending => '$channel pending',
        DeliveryActivityOutcome.other => 'Subscription event',
      };

  @override
  Widget build(BuildContext context) {
    final outcome = DeliveryActivityOutcome.fromStatus(notification.status);
    final channel = _channel(notification);
    final title = _title(outcome, channel);
    final when = notification.deliveredAt ?? notification.createdAt;
    final time = DateFormat.MMMd().add_jm().format(when.toLocal());
    final color = outcome.color(context);

    if (dense) {
      return _DenseRow(
        notification: notification,
        subscriptionName: subscriptionName,
        outcome: outcome,
        title: title,
        time: time,
        color: color,
      );
    }

    final c = context.colors;
    return TraqCard(
      padding: TraqSpacing.surfacePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(icon: outcome.icon, color: color),
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
                          style: context.text.cap.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (subscriptionName != null &&
                        subscriptionName!.isNotEmpty) ...[
                      const SizedBox(height: TraqSpacing.xs),
                      SubscriptionMetaChip(
                        label: subscriptionName!,
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
              child: _ErrorBanner(message: notification.errorMessage!),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.icon, required this.color});

  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Center(child: TraqIcon(icon, size: 16, color: color)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = AppColorMapper.errorColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: TraqRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(AppAssets.iconAlert, size: 12, color: color),
          const SizedBox(width: TraqSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: context.text.cap.copyWith(color: color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DenseRow extends StatelessWidget {
  const _DenseRow({
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
