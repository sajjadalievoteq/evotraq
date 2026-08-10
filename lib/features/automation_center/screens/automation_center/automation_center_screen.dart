import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_background_jobs_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_alert_subscriptions_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/lazy_indexed_stack.dart';
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

  Widget _panelFor(String sectionId) {
    switch (sectionId) {
      case AutomationCenterSections.alertSubscriptions:
        return const KeyedSubtree(
          key: ValueKey(AutomationCenterSections.alertSubscriptions),
          child: AutomationAlertSubscriptionsPanel(),
        );
      case AutomationCenterSections.backgroundJobs:
        return const KeyedSubtree(
          key: ValueKey(AutomationCenterSections.backgroundJobs),
          child: AutomationBackgroundJobsPanel(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    final visibleSections = AutomationCenterSections.orderedFor(
      isAdmin: isAdmin,
    );
    // Non-admins deep-linked to Background Jobs are redirected by the router;
    // fall back to the first visible section if needed.
    final selected = visibleSections.contains(_selectedSection)
        ? _selectedSection
        : visibleSections.first;
    final index = AutomationCenterSections.indexOf(selected, isAdmin: isAdmin);

    return Title(
      title: 'Automation Center',
      color: Colors.white,
      child: WorkbenchScaffold(
        title: 'Automation Center',
        groups: AutomationCenterSections.groupsFor(isAdmin: isAdmin),
        selectedId: selected,
        onSelect: _selectSection,
        panelBuilder: (context, selectedId) {
          return LazyIndexedStack(
            index: index,
            children: [
              for (final sectionId in visibleSections) _panelFor(sectionId),
            ],
          );
        },
      ),
    );
  }
}
