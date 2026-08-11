import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';

enum DeliveryActivityOutcome {
  delivered,
  failed,
  pending,
  other;

  static DeliveryActivityOutcome fromStatus(String status) {
    final s = status.toUpperCase();
    if (s.contains('FAIL') || s.contains('ERROR')) {
      return DeliveryActivityOutcome.failed;
    }
    if (s.contains('SUCCESS') ||
        s.contains('DELIVER') ||
        s == 'SENT' ||
        s == 'OK') {
      return DeliveryActivityOutcome.delivered;
    }
    if (s.contains('PENDING') || s.contains('RETRY')) {
      return DeliveryActivityOutcome.pending;
    }
    return DeliveryActivityOutcome.other;
  }

  String get icon => switch (this) {
    DeliveryActivityOutcome.failed => AppAssets.iconXCircle,
    DeliveryActivityOutcome.delivered => AppAssets.iconCheckCircle,
    DeliveryActivityOutcome.pending => AppAssets.iconClock,
    DeliveryActivityOutcome.other => AppAssets.iconNotification,
  };

  Color color(BuildContext context) => switch (this) {
    DeliveryActivityOutcome.failed => AppColorMapper.errorColor(context),
    DeliveryActivityOutcome.delivered => AppColorMapper.successColor(context),
    DeliveryActivityOutcome.pending => AppColorMapper.warningColor(context),
    DeliveryActivityOutcome.other => AppColorMapper.infoColor(context),
  };

  bool matchesFilter(String filter) => switch (filter) {
    'delivered' => this == DeliveryActivityOutcome.delivered,
    'failed' => this == DeliveryActivityOutcome.failed,
    'pending' => this == DeliveryActivityOutcome.pending,
    _ => true,
  };
}
