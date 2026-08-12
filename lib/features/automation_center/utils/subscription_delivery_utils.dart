import 'package:traqtrace_app/core/config/app_assets.dart';

/// Helpers for deriving delivery channel display from a subscription endpoint.
abstract final class SubscriptionDeliveryUtils {
  static bool isEmailEndpoint(String webhookUrl) {
    return webhookUrl.contains('@') && !webhookUrl.startsWith('http');
  }

  static String labelForEndpoint(String webhookUrl) {
    return isEmailEndpoint(webhookUrl) ? 'Email' : 'API';
  }

  static String iconForEndpoint(String webhookUrl) {
    return isEmailEndpoint(webhookUrl)
        ? AppAssets.iconMail
        : AppAssets.iconLink;
  }
}
