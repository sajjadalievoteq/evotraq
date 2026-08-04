import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/subscription_management_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';

class AutomationAlertSubscriptionsPanel extends StatefulWidget {
  const AutomationAlertSubscriptionsPanel({super.key});

  @override
  State<AutomationAlertSubscriptionsPanel> createState() =>
      _AutomationAlertSubscriptionsPanelState();
}

class _AutomationAlertSubscriptionsPanelState
    extends State<AutomationAlertSubscriptionsPanel> {
  final _screenKey = GlobalKey<SubscriptionManagementScreenState>();

  static const _instructions = WorkbenchInstructions(
    summary:
        'Create and manage alert subscriptions that deliver EPCIS event matches '
        'by webhook or email.',
    useCase:
        'Use when you need real-time or batched notifications for events that '
        'match business step, disposition, location, or EPC filters.',
    audience: 'Operators / Integrators',
    steps: [
      'Create a subscription and choose Webhook or Email delivery.',
      'Optionally narrow matches with event type, bizStep, disposition, GLN, or EPC pattern.',
      'Pause, resume, or edit from the list; open a row for details.',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AutomationWorkbenchPanel(
      title: 'Alert Subscriptions',
      instructions: _instructions,
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
          label: const Text('Create'),
        ),
      ],
      child: SubscriptionManagementScreen(
        key: _screenKey,
        embedded: true,
      ),
    );
  }
}
