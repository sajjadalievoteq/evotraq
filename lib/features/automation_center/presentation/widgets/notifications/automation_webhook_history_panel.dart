import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/webhook_configuration_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class AutomationWebhookHistoryPanel extends StatelessWidget {
  const AutomationWebhookHistoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkbenchPanelShell(
      title: 'Webhook History',
      slice: WorkbenchSlice(),
      expandBody: true,
      child: WebhookConfigurationScreen(embedded: true),
    );
  }
}
