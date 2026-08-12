import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_detail_row.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_header_card.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_section.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_stat_tile.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_stats_grid.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_format_utils.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_query_filter_utils.dart';

class SubscriptionDetailsBody extends StatelessWidget {
  const SubscriptionDetailsBody({
    super.key,
    required this.subscription,
    this.stats,
    this.embedded = false,
  });

  final NotificationSubscription subscription;
  final NotificationStats? stats;

  /// When true, omit outer scroll padding (host provides panel chrome).
  final bool embedded;

  static const Map<String, String> _frequencyLabels = {
    'IMMEDIATE': 'as soon as the batch job next runs (~15 min poll)',
    'HOURLY': 'about once an hour',
    'DAILY': 'about once a day',
    'WEEKLY': 'about once a week',
    'MONTHLY': 'about once a month',
  };

  static String _cadenceLabel(
    String subscriptionType,
    String? notificationFrequency,
  ) {
    switch (subscriptionType) {
      case 'REALTIME':
        return 'Fires immediately when a matching event is captured';
      case 'BATCH':
      case 'SCHEDULED':
        final freqLabel = notificationFrequency != null
            ? _frequencyLabels[notificationFrequency]
            : null;
        return freqLabel != null
            ? 'Events are queued and delivered $freqLabel'
            : 'Delivered by the scheduled batch job when it next runs';
      default:
        return subscriptionType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryParameters = subscription.queryParameters;
    final eventTypeLabels = SubscriptionQueryFilterUtils.eventTypeLabels(
      queryParameters,
    );
    final operationTypeLabels =
        SubscriptionQueryFilterUtils.operationTypeLabels(queryParameters);
    // Legacy-only: subscriptions created before the Operations selector may
    // still have raw CBV business-step/disposition filters stored.
    final bizStep = SubscriptionQueryFilterUtils.businessStep(queryParameters);
    final disposition = SubscriptionQueryFilterUtils.disposition(
      queryParameters,
    );
    final readPoint = SubscriptionQueryFilterUtils.readPoint(queryParameters);
    final epcPattern = SubscriptionQueryFilterUtils.epcPattern(queryParameters);
    final hasFilters = SubscriptionQueryFilterUtils.hasAnyFilter(
      queryParameters,
    );
    final isEmailDelivery = subscription.webhookUrl.contains('@');

    final totalValue = stats?.totalNotifications.toString() ?? '—';
    final deliveredValue = stats?.successfulNotifications.toString() ?? '—';
    final failedValue = stats?.failedNotifications.toString() ?? '—';
    final successRateValue = stats != null
        ? SubscriptionFormatUtils.successRatePercent(
            stats!.successRate,
            fractionDigits: 1,
            delivered: stats!.successfulNotifications,
            failed: stats!.failedNotifications,
          )
        : '—';
    final avgDeliveryValue = stats != null
        ? SubscriptionFormatUtils.averageDeliveryLabel(stats!.avgDeliveryTime)
        : '—';
    final lastNotificationValue = stats?.lastNotificationSent != null
        ? DisplayDateUtils.dmyHm(stats!.lastNotificationSent!)
        : 'None';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubscriptionDetailsHeaderCard(subscription: subscription),
        const SizedBox(height: TraqSpacing.lg),

        SubscriptionDetailsSection(
          title: 'Delivery',
          children: [
            SubscriptionDetailRow(
              label: isEmailDelivery ? 'Email' : 'API URL',
              value: subscription.webhookUrl.isNotEmpty
                  ? subscription.webhookUrl
                  : 'Not configured',
              monospace: !isEmailDelivery,
              copyable: subscription.webhookUrl.isNotEmpty,
            ),
            SubscriptionDetailRow(
              label: 'Notification Format',
              value: subscription.notificationFormat ?? 'Default',
            ),
          ],
        ),
        const SizedBox(height: TraqSpacing.lg),

        SubscriptionDetailsSection(
          title: 'Event Filtering',
          children: hasFilters
              ? [
                  if (eventTypeLabels.isNotEmpty)
                    SubscriptionDetailRow(
                      label: 'Event Types',
                      value: eventTypeLabels.join(', '),
                    ),
                  SubscriptionDetailRow(
                    label: 'Operations',
                    value: operationTypeLabels.isNotEmpty
                        ? operationTypeLabels.join(', ')
                        : 'Any',
                  ),
                  if (bizStep != null)
                    SubscriptionDetailRow(
                      label: 'Business Step',
                      value: bizStep,
                    ),
                  if (disposition != null)
                    SubscriptionDetailRow(
                      label: 'Disposition',
                      value: disposition,
                    ),
                  SubscriptionDetailRow(
                    label: 'Read Point (GLN)',
                    value: readPoint ?? 'Any',
                    monospace: readPoint != null,
                  ),
                  SubscriptionDetailRow(
                    label: 'EPC Pattern',
                    value: epcPattern ?? 'Any',
                    monospace: epcPattern != null,
                  ),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.all(TraqSpacing.md),
                    child: Text(
                      'No filters configured — this subscription matches '
                      'every EPCIS event.',
                      style: context.text.bodySm.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                ],
        ),
        const SizedBox(height: TraqSpacing.lg),

        SubscriptionDetailsSection(
          title: 'Delivery Statistics',
          children: [
            Padding(
              padding: const EdgeInsets.all(TraqSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubscriptionStatsGrid(
                    tiles: [
                      SubscriptionDetailsStatTile(
                        label: 'Total Matched',
                        value: totalValue,
                        iconAsset: AppAssets.iconList,
                      ),
                      SubscriptionDetailsStatTile(
                        label: 'Delivered',
                        value: deliveredValue,
                        iconAsset: AppAssets.iconCheckCircle,
                        tone: SubscriptionStatTone.success,
                      ),
                      SubscriptionDetailsStatTile(
                        label: 'Failed',
                        value: failedValue,
                        iconAsset: AppAssets.iconXCircle,
                        tone: SubscriptionStatTone.error,
                      ),
                      SubscriptionDetailsStatTile(
                        label: 'Success Rate',
                        value: successRateValue,
                        iconAsset: AppAssets.iconBarChart,
                        tone: SubscriptionStatTone.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  SubscriptionDetailRow(
                    label: 'Last Notification',
                    value: lastNotificationValue,
                  ),
                  SubscriptionDetailRow(
                    label: 'Avg Delivery Time',
                    value: avgDeliveryValue,
                  ),
                  if ((subscription.subscriptionType == 'BATCH' ||
                          subscription.subscriptionType == 'SCHEDULED') &&
                      (stats?.totalNotifications ?? 0) > 0 &&
                      (stats?.successfulNotifications ?? 0) == 0 &&
                      (stats?.failedNotifications ?? 0) == 0) ...[
                    const SizedBox(height: TraqSpacing.sm),
                    Text(
                      "Matched events are queued for this subscription's"
                      'cadence and have not been delivered yet — Delivered/'
                      'Failed will update once the batch is processed.',
                      style: context.text.bodySm.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: TraqSpacing.lg),

        SubscriptionDetailsSection(
          title: 'Timing',
          children: [
            SubscriptionDetailRow(
              label: 'Created',
              value: DisplayDateUtils.dmyHm(subscription.createdAt),
            ),
            SubscriptionDetailRow(
              label: 'Last Modified',
              value: subscription.updatedAt != null
                  ? DisplayDateUtils.dmyHm(subscription.updatedAt!)
                  : 'Never',
            ),
            SubscriptionDetailRow(
              label: 'Delivery Cadence',
              value: _cadenceLabel(
                subscription.subscriptionType,
                subscription.notificationFrequency,
              ),
            ),
          ],
        ),
      ],
    );

    if (embedded) {
      return SingleChildScrollView(child: content);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: content,
    );
  }
}
