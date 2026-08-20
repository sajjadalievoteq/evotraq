import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/workspace_tabs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/inbound_catalog_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_system_health_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_inbound_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_center_tab_content.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/notification_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/subscription_management_screen.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_panel.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

class NotificationsWorkspace extends StatefulWidget {
  const NotificationsWorkspace({super.key, this.initialSection});

  final String? initialSection;

  @override
  State<NotificationsWorkspace> createState() => NotificationsWorkspaceState();
}

class NotificationsWorkspaceState extends State<NotificationsWorkspace> {
  final _subscriptionsKey = GlobalKey<SubscriptionManagementScreenState>();
  final _activityKey = GlobalKey<NotificationCenterScreenState>();
  final _jobsKey = GlobalKey<JobQueuePanelState>();

  JobQueueCubit? _jobQueueCubit;
  late final InboundCatalogCubit _inboundCatalogCubit;
  late String _selectedTab;
  late String _selectedSection;

  @override
  void initState() {
    super.initState();
    final isAdmin = context.read<AuthCubit>().state.isAdmin;
    _selectedSection = AutomationCenterSections.normalize(
      widget.initialSection,
    );
    _selectedTab = AutomationCenterSections.normalizeTab(
      widget.initialSection,
      isAdmin: isAdmin,
    );
    _inboundCatalogCubit = getIt<InboundCatalogCubit>();
    if (isAdmin) {
      _jobQueueCubit = getIt<JobQueueCubit>()..connectWebSocket();
    }
  }

  @override
  void didUpdateWidget(NotificationsWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isAdmin = context.read<AuthCubit>().state.isAdmin;
    final next = AutomationCenterSections.normalizeTab(
      widget.initialSection,
      isAdmin: isAdmin,
    );
    _selectedSection = AutomationCenterSections.normalize(
      widget.initialSection,
    );
    if (next != _selectedTab) setState(() => _selectedTab = next);
  }

  @override
  void dispose() {
    _inboundCatalogCubit.close();
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
    final tabs = <WorkspaceTab>[
      const WorkspaceTab(
        id: AutomationCenterSections.alertSubscriptions,
        label: 'Subscriptions',
        icon: NavIcons.manageSubscriptions,
      ),
      const WorkspaceTab(
        id: AutomationCenterSections.notificationActivity,
        label: 'Activity',
        icon: NavIcons.notificationCenter,
      ),
      if (isAdmin)
        const WorkspaceTab(
          id: AutomationCenterSections.backgroundJobs,
          label: 'Job Operations',
          icon: NavIcons.jobQueueManagement,
        ),
      const WorkspaceTab(
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
      selectedId: _selectedSection,
      onSelect: (section) => setState(() => _selectedSection = section),
      panelBuilder: (context, section) =>
          section == AutomationCenterSections.inbound
          ? BlocProvider<InboundCatalogCubit>.value(
              value: _inboundCatalogCubit,
              child: const AutomationInboundPanel(),
            )
          : AutomationWorkbenchPanel(
              title: 'Outbound',
              actions: switch (selected) {
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
                    onPressed: () =>
                        _subscriptionsKey.currentState?.showCreate(),
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
                    onPressed: () =>
                        _jobsKey.currentState?.showScheduleJobDialog(),
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
                      context.read<NotificationCubit>().loadSubscriptions(
                        force: true,
                      );
                      _jobQueueCubit?.refresh();
                    },
                    icon: const TraqIcon(AppAssets.iconRefresh),
                  ),
                ],
              },
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
                  WorkspaceTabs(
                    tabs: tabs,
                    selectedId: selected,
                    onSelected: _selectTab,
                  ),
                  Divider(height: 1, color: context.colors.border),
                  const SizedBox(height: TraqSpacing.md),
                  AutomationCenterTabContent(
                    tab: tabs[selectedIndex].id,
                    subscriptions: SubscriptionManagementScreen(
                      key: _subscriptionsKey,
                      onViewAllActivity: () => _selectTab(
                        AutomationCenterSections.notificationActivity,
                      ),
                    ),
                    activity: NotificationCenterScreen(
                      key: _activityKey,
                      onManageSubscriptions: () => _selectTab(
                        AutomationCenterSections.alertSubscriptions,
                      ),
                    ),
                    jobs: JobQueuePanel(
                      key: _jobsKey,
                      embedded: true,
                      cubit: _jobQueueCubit,
                    ),
                    systemHealth: AutomationSystemHealthPanel(
                      jobQueueCubit: _jobQueueCubit,
                      onOpenSubscriptions: () => _selectTab(
                        AutomationCenterSections.alertSubscriptions,
                      ),
                      onOpenActivity: () => _selectTab(
                        AutomationCenterSections.notificationActivity,
                      ),
                      onOpenJobOperations: isAdmin
                          ? () => _selectTab(
                              AutomationCenterSections.backgroundJobs,
                            )
                          : null,
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
}
