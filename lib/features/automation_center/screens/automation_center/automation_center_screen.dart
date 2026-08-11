import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/notifications_workspace.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';

class AutomationCenterScreen extends StatelessWidget {
  const AutomationCenterScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  Widget build(BuildContext context) {
    return NotificationsShell(
      child: NotificationsWorkspace(initialSection: initialSection),
    );
  }
}
