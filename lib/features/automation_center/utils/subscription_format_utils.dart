import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';

abstract final class SubscriptionFormatUtils {
  static List<Map<String, String>> availableFormats(String deliveryMethod) {
    if (deliveryMethod == 'EMAIL') {
      return NotificationConstants.notificationFormats
          .where(
            (format) =>
                format['value'] == 'SUMMARY' || format['value'] == 'EMAIL_HTML',
          )
          .toList();
    }
    return NotificationConstants.notificationFormats
        .where((format) => format['value'] != 'EMAIL_HTML')
        .toList();
  }
}
