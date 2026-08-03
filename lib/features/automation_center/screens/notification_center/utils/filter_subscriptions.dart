import 'package:traqtrace_app/data/models/notifications/notification_subscription.dart';

List<NotificationSubscription> filterCenterSubscriptions(
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
