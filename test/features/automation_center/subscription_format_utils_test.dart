import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_format_utils.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';

void main() {
  group('SubscriptionFormatUtils.successRatePercent', () {
    test('formats backend 0–100 percentages without multiplying again', () {
      expect(
        SubscriptionFormatUtils.successRatePercent(
          100,
          delivered: 2,
          failed: 0,
        ),
        '100%',
      );
      expect(
        SubscriptionFormatUtils.successRatePercent(
          50,
          delivered: 1,
          failed: 1,
        ),
        '50%',
      );
    });

    test('shows em dash when there are no delivery attempts', () {
      expect(
        SubscriptionFormatUtils.successRatePercent(
          100,
          delivered: 0,
          failed: 0,
        ),
        '—',
      );
    });

    test('treats 0–1 fractions defensively', () {
      expect(
        SubscriptionFormatUtils.successRatePercent(
          1.0,
          delivered: 2,
          failed: 0,
        ),
        '100%',
      );
    });
  });

  group('WebhookNotification.fromJson', () {
    test('maps backend DTO field names', () {
      final row = WebhookNotification.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'subscriptionId': '22222222-2222-2222-2222-222222222222',
        'webhookUrl': 'ops@example.test',
        'status': 'DELIVERED',
        'attemptCount': 1,
        'deliveryTime': '2026-08-10T07:42:00Z',
        'createdAt': '2026-08-10T07:42:00Z',
        'eventIds': ['33333333-3333-3333-3333-333333333333'],
        'errorMessage': null,
        'responseBody': 'ok',
      });

      expect(row.status, 'DELIVERED');
      expect(row.retryCount, 1);
      expect(row.eventId, '33333333-3333-3333-3333-333333333333');
      expect(row.deliveredAt, isNotNull);
      expect(row.webhookUrl, 'ops@example.test');
    });
  });
}
