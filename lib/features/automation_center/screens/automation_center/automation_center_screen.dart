import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_system_health_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/notification_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/subscription_management_screen.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/lazy_indexed_stack.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

class AutomationCenterScreen extends StatelessWidget {
  const AutomationCenterScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  Widget build(BuildContext context) {
    return NotificationsShell(
      child: _NotificationsWorkspace(initialSection: initialSection),
    );
  }
}

class _NotificationsWorkspace extends StatefulWidget {
  const _NotificationsWorkspace({this.initialSection});

  final String? initialSection;

  @override
  State<_NotificationsWorkspace> createState() =>
      _NotificationsWorkspaceState();
}

class _NotificationsWorkspaceState extends State<_NotificationsWorkspace> {
  final _subscriptionsKey = GlobalKey<SubscriptionManagementScreenState>();
  final _activityKey = GlobalKey<NotificationCenterScreenState>();
  final _jobsKey = GlobalKey<JobQueuePanelState>();

  JobQueueCubit? _jobQueueCubit;
  late String _selectedTab;

  @override
  void initState() {
    super.initState();
    final isAdmin = context.read<AuthCubit>().state.isAdmin;
    _selectedTab = AutomationCenterSections.normalizeTab(
      widget.initialSection,
      isAdmin: isAdmin,
    );
    if (isAdmin) {
      _jobQueueCubit = getIt<JobQueueCubit>()..connectWebSocket();
    }
  }

  @override
  void didUpdateWidget(_NotificationsWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isAdmin = context.read<AuthCubit>().state.isAdmin;
    final next = AutomationCenterSections.normalizeTab(
      widget.initialSection,
      isAdmin: isAdmin,
    );
    if (next != _selectedTab) setState(() => _selectedTab = next);
  }

  @override
  void dispose() {
    _jobQueueCubit?.close();
    super.dispose();
  }

  void _selectTab(String tab) {
    final isAdmin = context.read<AuthCubit>().state.isAdmin;
    final next = AutomationCenterSections.normalizeTab(tab, isAdmin: isAdmin);
    if (next == _selectedTab) return;
    setState(() => _selectedTab = next);
    // Keep workspace navigation local. Replacing the GoRouter page from the
    // same pointer event that selected a tab can leave the outgoing Scaffold's
    // closed drawer in the hit-test tree before its next layout on Flutter web.
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    final tabs = <_WorkspaceTab>[
      const _WorkspaceTab(
        id: AutomationCenterSections.alertSubscriptions,
        label: 'Subscriptions',
        icon: NavIcons.manageSubscriptions,
      ),
      const _WorkspaceTab(
        id: AutomationCenterSections.notificationActivity,
        label: 'Activity',
        icon: NavIcons.notificationCenter,
      ),
      if (isAdmin)
        const _WorkspaceTab(
          id: AutomationCenterSections.backgroundJobs,
          label: 'Job Operations',
          icon: NavIcons.jobQueueManagement,
        ),
      const _WorkspaceTab(
        id: AutomationCenterSections.systemHealth,
        label: 'System Health',
        icon: NavIcons.systemMonitoring,
      ),
    ];
    final selected = tabs.any((tab) => tab.id == _selectedTab)
        ? _selectedTab
        : AutomationCenterSections.alertSubscriptions;
    final selectedIndex = tabs.indexWhere((tab) => tab.id == selected);

    Widget body = WorkbenchScaffold(
      title: 'Automation Center',
      groups: AutomationCenterSections.groupsFor(isAdmin: isAdmin),
      selectedId: AutomationCenterSections.notifications,
      onSelect: (_) =>
          _selectTab(AutomationCenterSections.alertSubscriptions),
      panelBuilder: (context, _) => AutomationWorkbenchPanel(
        title: 'Notifications',
        fillBody: true,
        actions: _actionsFor(context, selected),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage subscriptions, monitor deliveries, and track '
              'notification system health.',
              style: context.text.body.copyWith(
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            _WorkspaceTabs(
              tabs: tabs,
              selectedId: selected,
              onSelected: _selectTab,
            ),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: TraqSpacing.md),
            Expanded(
              child: LazyIndexedStack(
                index: selectedIndex,
                sizing: StackFit.expand,
                children: [
                  for (final tab in tabs) _contentFor(tab.id, isAdmin: isAdmin),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final jobCubit = _jobQueueCubit;
    if (jobCubit != null) {
      body = BlocProvider<JobQueueCubit>.value(value: jobCubit, child: body);
    }

    return Title(title: 'Notifications', color: Colors.white, child: body);
  }

  List<Widget> _actionsFor(BuildContext context, String tab) => switch (tab) {
    AutomationCenterSections.alertSubscriptions => [
      IconButton(
        tooltip: 'Help',
        onPressed: () => _subscriptionsKey.currentState?.showHelp(),
        icon: const TraqIcon(AppAssets.iconInfo),
      ),
      OutlinedButton.icon(
        onPressed: () => _subscriptionsKey.currentState?.refresh(),
        icon: const TraqIcon(AppAssets.iconRefresh, size: 14),
        label: const Text('Refresh'),
      ),
      FilledButton.icon(
        onPressed: () => _subscriptionsKey.currentState?.showCreate(),
        icon: const TraqIcon(AppAssets.iconPlus, size: 14),
        label: const Text('New Subscription'),
      ),
    ],
    AutomationCenterSections.backgroundJobs => [
      OutlinedButton.icon(
        onPressed: () => _jobsKey.currentState?.showControlPanel(),
        icon: const TraqIcon(AppAssets.iconTune, size: 14),
        label: const Text('Queue Controls'),
      ),
      IconButton(
        tooltip: 'Refresh job operations',
        onPressed: () => _jobsKey.currentState?.refreshCurrentTab(),
        icon: const TraqIcon(AppAssets.iconRefresh),
      ),
      FilledButton.icon(
        onPressed: () => _jobsKey.currentState?.showScheduleJobDialog(),
        icon: const TraqIcon(AppAssets.iconClock, size: 14),
        label: const Text('Run Job'),
      ),
    ],
    AutomationCenterSections.notificationActivity => [
      IconButton(
        tooltip: 'Toggle live updates',
        onPressed: () => _activityKey.currentState?.toggleLive(),
        icon: const TraqIcon(AppAssets.iconWifi),
      ),
      IconButton(
        tooltip: 'Refresh activity',
        onPressed: () => _activityKey.currentState?.refresh(),
        icon: const TraqIcon(AppAssets.iconRefresh),
      ),
    ],
    _ => [
      IconButton(
        tooltip: 'Refresh system health',
        onPressed: () {
          context.read<NotificationCubit>().loadSubscriptions(force: true);
          _jobQueueCubit?.refresh();
        },
        icon: const TraqIcon(AppAssets.iconRefresh),
      ),
    ],
  };

  Widget _contentFor(String tab, {required bool isAdmin}) => switch (tab) {
    AutomationCenterSections.alertSubscriptions =>
      SubscriptionManagementScreen(
        key: _subscriptionsKey,
        onViewAllActivity: () =>
            _selectTab(AutomationCenterSections.notificationActivity),
      ),
    AutomationCenterSections.notificationActivity => NotificationCenterScreen(
      key: _activityKey,
      onManageSubscriptions: () =>
          _selectTab(AutomationCenterSections.alertSubscriptions),
    ),
    AutomationCenterSections.backgroundJobs => SingleChildScrollView(
      child: JobQueuePanel(
        key: _jobsKey,
        embedded: true,
        cubit: _jobQueueCubit,
      ),
    ),
    _ => AutomationSystemHealthPanel(
      jobQueueCubit: _jobQueueCubit,
      onOpenSubscriptions: () =>
          _selectTab(AutomationCenterSections.alertSubscriptions),
      onOpenActivity: () =>
          _selectTab(AutomationCenterSections.notificationActivity),
      onOpenJobOperations: isAdmin
          ? () => _selectTab(AutomationCenterSections.backgroundJobs)
          : null,
    ),
  };
}

class _WorkspaceTab {
  const _WorkspaceTab({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final String icon;
}

class _WorkspaceTabs extends StatelessWidget {
  const _WorkspaceTabs({
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<_WorkspaceTab> tabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs)
            Semantics(
              button: true,
              selected: tab.id == selectedId,
              child: InkWell(
                onTap: () => onSelected(tab.id),
                borderRadius: TraqRadius.button,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TraqSpacing.lg,
                    vertical: TraqSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: tab.id == selectedId
                            ? colors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      TraqIcon(
                        tab.icon,
                        size: 16,
                        color: tab.id == selectedId
                            ? colors.primary
                            : colors.textMuted,
                      ),
                      const SizedBox(width: TraqSpacing.sm),
                      Text(
                        tab.label,
                        style: context.text.bodySm.copyWith(
                          color: tab.id == selectedId
                              ? colors.primary
                              : colors.textSecondary,
                          fontWeight: tab.id == selectedId
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
