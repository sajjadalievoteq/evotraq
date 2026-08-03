import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_background_jobs_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_alert_subscriptions_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_notification_activity_panel.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

class AutomationCenterScreen extends StatelessWidget {
  const AutomationCenterScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  Widget build(BuildContext context) {
    return NotificationsShell(
      child: _AutomationCenterView(initialSection: initialSection),
    );
  }
}

class _AutomationCenterView extends StatefulWidget {
  const _AutomationCenterView({this.initialSection});

  final String? initialSection;

  @override
  State<_AutomationCenterView> createState() => _AutomationCenterViewState();
}

class _AutomationCenterViewState extends State<_AutomationCenterView> {
  late String _selectedSection;

  @override
  void initState() {
    super.initState();
    _selectedSection = AutomationCenterSections.normalize(
      widget.initialSection,
    );
  }

  @override
  void didUpdateWidget(_AutomationCenterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = AutomationCenterSections.normalize(widget.initialSection);
    if (next != _selectedSection) {
      setState(() => _selectedSection = next);
    }
  }

  void _selectSection(String section) {
    final next = AutomationCenterSections.normalize(section);
    if (next == _selectedSection) return;
    setState(() => _selectedSection = next);
    context.go(AutomationCenterSections.location(next));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    return Title(
      title: 'Automation Center',
      color: Colors.white,
      child: WorkbenchScaffold(
        title: 'Automation Center',
        groups: AutomationCenterSections.groupsFor(isAdmin: isAdmin),
        selectedId: _selectedSection,
        onSelect: _selectSection,
        panelBuilder: (context, selectedId) {
          return IndexedStack(
            index: AutomationCenterSections.indexOf(selectedId),
            children: [
              const KeyedSubtree(
                key: ValueKey(AutomationCenterSections.alertSubscriptions),
                child: AutomationAlertSubscriptionsPanel(),
              ),
              const KeyedSubtree(
                key: ValueKey(AutomationCenterSections.notificationActivity),
                child: AutomationNotificationActivityPanel(),
              ),
                if (isAdmin)
                const KeyedSubtree(
                  key: ValueKey(AutomationCenterSections.backgroundJobs),
                  child: AutomationBackgroundJobsPanel(),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}
