import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class AutomationStatisticsPanel extends StatelessWidget {
  const AutomationStatisticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkbenchPanelShell(
      title: 'Statistics',
      slice: WorkbenchSlice(),
      expandBody: true,
      child: NotificationCenterScreen(embedded: true),
    );
  }
}
