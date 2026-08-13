import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_error_banner.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_outcome.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/delivery_activity_status_badge.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';

/// Exhausted [NotificationBatch] row for the Activity feed: same card language
/// as [DeliveryActivityEventRow], with a local-loading "Retry now" action.
class BatchDeliveryEventRow extends StatefulWidget {
  const BatchDeliveryEventRow({
    super.key,
    required this.batch,
    this.subscriptionName,
  });

  final NotificationBatch batch;
  final String? subscriptionName;

  @override
  State<BatchDeliveryEventRow> createState() => _BatchDeliveryEventRowState();
}

class _BatchDeliveryEventRowState extends State<BatchDeliveryEventRow> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      await context.read<NotificationCubit>().retryBatch(widget.batch.id);
      if (!mounted) return;
      context.showSuccess('Batch queued for retry');
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.getUserFriendlyMessage()
          : "Couldn't retry this batch. Please try again.";
      context.showError(message);
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final name = widget.subscriptionName ?? batch.subscriptionName;
    final color = DeliveryActivityOutcome.failed.color(context);
    final time = DateFormat.MMMd().add_jm().format(batch.createdAt.toLocal());
    final attempts = batch.deliveryAttempts ?? 0;
    final eventCount = batch.batchSize ?? 0;
    final eventLabel = eventCount == 1 ? '1 event' : '$eventCount events';
    final c = context.colors;

    return TraqCard(
      padding: TraqSpacing.surfacePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeliveryActivityStatusBadge(
                icon: DeliveryActivityOutcome.failed.icon,
                color: color,
              ),
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
                            'Batch delivery failed',
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
                    if (name != null && name.isNotEmpty) ...[
                      const SizedBox(height: TraqSpacing.xs),
                      SubscriptionMetaChip(
                        label: name,
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
              '$eventLabel · $attempts of 3 attempts',
              style: context.text.cap.copyWith(color: c.textMuted),
            ),
          ),
          if (batch.lastError != null && batch.lastError!.isNotEmpty) ...[
            const SizedBox(height: TraqSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: DeliveryActivityErrorBanner(message: batch.lastError!),
            ),
          ],
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
      ),
    );
  }
}
