import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';

class NotificationConnectionIndicator extends StatelessWidget {
  const NotificationConnectionIndicator({
    super.key,
    required this.liveEnabled,
    required this.connectionStatus,
  });

  final bool liveEnabled;
  final NotificationConnectionStatus connectionStatus;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final String semanticsLabel;
    final String icon;

    if (!liveEnabled) {
      color = context.colors.textMuted;
      label = 'Paused';
      semanticsLabel = 'Delivery Activity live updates paused';
      icon = AppAssets.iconWifiOff;
    } else {
      switch (connectionStatus) {
        case NotificationConnectionStatus.connecting:
          color = AppColorMapper.warningColor(context);
          label = 'Connecting';
          semanticsLabel = 'Connecting to real-time updates';
          icon = AppAssets.iconWifi;
        case NotificationConnectionStatus.connected:
          color = AppColorMapper.successColor(context);
          label = 'Live';
          semanticsLabel = 'Delivery Activity live updates on';
          icon = AppAssets.iconCheckCircle;
        case NotificationConnectionStatus.failed:
          color = AppColorMapper.errorColor(context);
          label = 'Failed';
          semanticsLabel = 'Real-time connection failed';
          icon = AppAssets.iconWifiOff;
        case NotificationConnectionStatus.disconnected:
          color = AppColorMapper.errorColor(context);
          label = 'Offline';
          semanticsLabel = 'Offline from real-time updates';
          icon = AppAssets.iconCircle;
      }
    }

    return Semantics(
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: TraqSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color),
          borderRadius: const BorderRadius.all(TraqRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (connectionStatus == NotificationConnectionStatus.connecting &&
                liveEnabled)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              TraqIcon(icon, size: 14, color: color),
            const SizedBox(width: TraqSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
