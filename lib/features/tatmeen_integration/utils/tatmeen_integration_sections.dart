import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';
import 'package:traqtrace_app/features/tatmeen_integration/data/tatmeen_dummy_sync_data.dart';

abstract final class TatmeenIntegrationSections {
  static const dashboard = 'dashboard';
  static const configurations = 'configurations';
  static const failedQueue = 'failed-queue';
  static const syncLogs = 'sync-logs';

  static const ordered = [dashboard, configurations, failedQueue, syncLogs];

  static List<WorkbenchRailGroup> groups({int? failedQueueCount}) => [
    WorkbenchRailGroup(
      title: 'Tatmeen Settings',
      items: [
        WorkbenchRailItem(
          id: dashboard,
          iconAsset: NavIcons.dashboard,
          label: 'Dashboard',
        ),
        WorkbenchRailItem(
          id: configurations,
          iconAsset: NavIcons.systemTools,
          label: 'Configurations',
        ),
      ],
    ),
  ];

  static String normalize(String? section) {
    if (section == null || section.trim().isEmpty) return dashboard;
    return switch (section) {
      dashboard => dashboard,
      configurations ||
      'integration' ||
      'credentials' ||
      'notifications' => configurations,
      failedQueue => failedQueue,
      syncLogs => syncLogs,
      _ => dashboard,
    };
  }

  static int indexOf(String? section) {
    final index = ordered.indexOf(normalize(section));
    return index < 0 ? 0 : index;
  }

  static String panelTitle(String? section) {
    return switch (normalize(section)) {
      dashboard => 'Dashboard',
      configurations => 'Configurations',
      failedQueue => 'Failed Queue',
      syncLogs => 'Sync Logs',
      _ => 'Tatmeen Integration',
    };
  }
}
