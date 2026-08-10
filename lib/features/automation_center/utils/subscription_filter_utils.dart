import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';

/// Shared subscription list filters for notification center and management UIs.
abstract final class SubscriptionFilterUtils {
  static List<NotificationSubscription> filterCenter(
    List<NotificationSubscription> subscriptions,
    String selectedFilter,
  ) {
    switch (selectedFilter) {
      case 'activity':
        return subscriptions.where((sub) {
          final stats = sub.stats;
          if (stats == null) return false;
          return (stats.successfulNotifications) > 0 ||
              (stats.failedNotifications) > 0 ||
              (stats.totalNotifications) > 0;
        }).toList();
      case 'active':
        return subscriptions
            .where((sub) => sub.status.toUpperCase() == 'ACTIVE')
            .toList();
      default:
        return subscriptions;
    }
  }

  static List<NotificationSubscription> filterManagement(
    List<NotificationSubscription> subscriptions,
    String deliveryFilter, {
    String statusFilter = 'all',
  }) {
    // Preserve compatibility with older callers that supplied status as the
    // single positional filter while the UI migrates to two filter dimensions.
    final legacyStatus =
        deliveryFilter == 'active' || deliveryFilter == 'paused';
    final effectiveDelivery = legacyStatus ? 'all' : deliveryFilter;
    final effectiveStatus = legacyStatus && statusFilter == 'all'
        ? deliveryFilter
        : statusFilter;
    return subscriptions.where((sub) {
      final isEmail =
          sub.webhookUrl.contains('@') &&
          !sub.webhookUrl.toLowerCase().startsWith('http');
      final deliveryMatches = switch (effectiveDelivery) {
        'email' => isEmail,
        'webhook' => !isEmail,
        _ => true,
      };
      final statusMatches =
          effectiveStatus == 'all' ||
          sub.status.toUpperCase() == effectiveStatus.toUpperCase();
      return deliveryMatches && statusMatches;
    }).toList();
  }
}
