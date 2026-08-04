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
    String selectedFilter,
  ) {
    switch (selectedFilter) {
      case 'email':
        return subscriptions
            .where(
              (sub) =>
                  sub.subscriptionType.toLowerCase().contains('email') ||
                  sub.webhookUrl.contains('@'),
            )
            .toList();
      case 'active':
        return subscriptions.where((sub) => sub.status == 'ACTIVE').toList();
      case 'paused':
        return subscriptions.where((sub) => sub.status == 'PAUSED').toList();
      default:
        return subscriptions;
    }
  }
}
