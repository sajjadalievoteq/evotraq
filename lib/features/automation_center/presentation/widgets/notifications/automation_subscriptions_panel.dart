import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/subscription_management_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class AutomationSubscriptionsPanel extends StatelessWidget {
  const AutomationSubscriptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkbenchPanelShell(
      title: 'Subscriptions',
      slice: WorkbenchSlice(),
      expandBody: true,
      child: SubscriptionManagementScreen(embedded: true),
    );
  }
}
