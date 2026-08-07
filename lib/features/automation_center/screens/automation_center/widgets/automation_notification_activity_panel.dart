import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/notification_center_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';

class AutomationNotificationActivityPanel extends StatefulWidget {
  const AutomationNotificationActivityPanel({super.key});

  @override
  State<AutomationNotificationActivityPanel> createState() =>
      _AutomationNotificationActivityPanelState();
}

class _AutomationNotificationActivityPanelState
    extends State<AutomationNotificationActivityPanel> {
  final _screenKey = GlobalKey<NotificationCenterScreenState>();

  static const _instructions = WorkbenchInstructions(
    summary:
        'Review aggregate delivery activity — matched, delivered, and failed '
        'counts per subscription.',
    useCase:
        'Use to monitor whether alerts are reaching endpoints successfully, '
        'not as a per-event inbox.',
    audience: 'Operators',
    steps: [
      'Filter to subscriptions with deliveries or active status.',
      'Toggle Live to pause or resume Delivery Activity updates (does not '
          'affect Background Jobs or Home).',
      'Open a subscription to inspect details.',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (prev, next) =>
          prev.connectionStatus != next.connectionStatus ||
          prev.notificationLiveEnabled != next.notificationLiveEnabled ||
          prev.subscriptions != next.subscriptions,
      builder: (context, state) {
        final live = state.notificationLiveEnabled &&
            state.connectionStatus == NotificationConnectionStatus.connected;
        final connecting = state.notificationLiveEnabled &&
            state.connectionStatus == NotificationConnectionStatus.connecting;
        return AutomationWorkbenchPanel(
          title: 'Delivery Activity',
          instructions: _instructions,
          fillBody: true,
          actions: [
            IconButton(
              tooltip: !state.notificationLiveEnabled
                  ? 'Resume Delivery Activity live updates'
                  : connecting
                      ? 'Connecting…'
                      : live
                          ? 'Pause Delivery Activity live updates'
                          : 'Retry Delivery Activity live updates',
              onPressed: () => _screenKey.currentState?.toggleLive(),
              icon: TraqIcon(
                live || connecting
                    ? AppAssets.iconWifi
                    : AppAssets.iconWifiOff,
                color: live
                    ? AppColorMapper.successColor(context)
                    : connecting
                        ? AppColorMapper.warningColor(context)
                        : AppColorMapper.errorColor(context),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => _screenKey.currentState?.refresh(),
              icon: TraqIcon(AppAssets.iconRefresh),
            ),
            FilledButton.icon(
              onPressed: () =>
                  _screenKey.currentState?.goManageSubscriptions(),
              icon: TraqIcon(AppAssets.iconPlus, size: 14),
              label: const Text('Add Subscription'),
            ),
          ],
          child: NotificationCenterScreen(
            key: _screenKey,
          ),
        );
      },
    );
  }
}
