import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';

void main() {
  NotificationSubscription subscription({
    required String id,
    required String endpoint,
    required String status,
  }) {
    return NotificationSubscription(
      id: id,
      subscriptionName: id,
      webhookUrl: endpoint,
      status: status,
      subscriptionType: 'REALTIME',
      createdAt: DateTime.utc(2026),
    );
  }

  final subscriptions = [
    subscription(
      id: 'active-webhook',
      endpoint: 'https://example.test/events',
      status: 'ACTIVE',
    ),
    subscription(
      id: 'paused-email',
      endpoint: 'ops@example.test',
      status: 'PAUSED',
    ),
    subscription(
      id: 'active-email',
      endpoint: 'alerts@example.test',
      status: 'ACTIVE',
    ),
  ];

  test('combines delivery and status filters', () {
    final filtered = SubscriptionFilterUtils.filterManagement(
      subscriptions,
      'email',
      statusFilter: 'active',
    );

    expect(filtered.map((item) => item.id), ['active-email']);
  });

  test('distinguishes webhook and email endpoints', () {
    final webhooks = SubscriptionFilterUtils.filterManagement(
      subscriptions,
      'webhook',
    );

    expect(webhooks.map((item) => item.id), ['active-webhook']);
  });

  test('keeps legacy single status filter behavior', () {
    final paused = SubscriptionFilterUtils.filterManagement(
      subscriptions,
      'paused',
    );

    expect(paused.map((item) => item.id), ['paused-email']);
  });
}
