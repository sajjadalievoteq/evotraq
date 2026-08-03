import 'package:traqtrace_app/data/models/notifications/notification_subscription.dart';

List<NotificationSubscription> filterManagementSubscriptions(
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
