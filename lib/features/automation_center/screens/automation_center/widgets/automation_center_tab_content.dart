import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';

class AutomationCenterTabContent extends StatelessWidget {
  const AutomationCenterTabContent({
    required this.tab,
    required this.subscriptions,
    required this.activity,
    required this.jobs,
    required this.systemHealth,
    super.key,
  });

  final String tab;
  final Widget subscriptions;
  final Widget activity;
  final Widget jobs;
  final Widget systemHealth;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      AutomationCenterSections.alertSubscriptions => subscriptions,
      AutomationCenterSections.notificationActivity => activity,
      AutomationCenterSections.backgroundJobs => jobs,
      _ => systemHealth,
    };
  }
}
