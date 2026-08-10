import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/subscription_management_screen.dart';

class AutomationAlertSubscriptionsPanel extends StatefulWidget {
  const AutomationAlertSubscriptionsPanel({super.key});

  @override
  State<AutomationAlertSubscriptionsPanel> createState() =>
      _AutomationAlertSubscriptionsPanelState();
}

class _AutomationAlertSubscriptionsPanelState
    extends State<AutomationAlertSubscriptionsPanel> {
  final _screenKey = GlobalKey<SubscriptionManagementScreenState>();

  @override
  Widget build(BuildContext context) {
    return AutomationWorkbenchPanel(
      title: 'Subscriptions',
      fillBody: true,
      actions: [
        IconButton(
          tooltip: 'Help',
          onPressed: () => _screenKey.currentState?.showHelp(),
          icon: TraqIcon(AppAssets.iconInfo),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _screenKey.currentState?.refresh(),
          icon: TraqIcon(AppAssets.iconRefresh),
        ),
        FilledButton.icon(
          onPressed: () => _screenKey.currentState?.showCreate(),
          icon: TraqIcon(AppAssets.iconPlus, size: 14),
          label: const Text('New Subscription'),
        ),
      ],
      child: SubscriptionManagementScreen(key: _screenKey),
    );
  }
}
