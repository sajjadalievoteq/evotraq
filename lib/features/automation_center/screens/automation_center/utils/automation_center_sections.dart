import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

/// Automation Center rail + internal Notifications workspace tab ids.
///
/// The left rail exposes a single destination ([notifications]). Workspace
/// tabs ([alertSubscriptions], [notificationActivity], [backgroundJobs],
/// [systemHealth]) are selected via `?section=` and never appear as rail items.
abstract final class AutomationCenterSections {
  static const notifications = 'notifications';
  static const alertSubscriptions = 'alert-subscriptions';
  static const notificationActivity = 'notification-activity';
  static const backgroundJobs = 'background-jobs';
  static const systemHealth = 'system-health';

  /// Left-rail destinations only.
  static const ordered = [notifications];

  /// Tabs that require admin (not rail items — gated inside the workspace).
  static const adminOnlyTabs = {backgroundJobs};

  /// Rail has no admin-only items.
  static const adminOnly = <String>{};

  static const groups = [
    WorkbenchRailGroup(
      title: 'Notifications',
      items: [
        WorkbenchRailItem(
          id: notifications,
          iconAsset: NavIcons.manageSubscriptions,
          label: 'Alerts & Subscriptions',
        ),
      ],
    ),
  ];

  /// Rail selection always resolves to the Notifications workspace.
  static String normalize(String? section) => notifications;

  /// Maps deep-link / query `section` values to an internal workspace tab.
  static String normalizeTab(String? section, {bool isAdmin = true}) {
    final tab = switch (section) {
      notificationActivity || 'activity' => notificationActivity,
      backgroundJobs || 'jobs' => backgroundJobs,
      systemHealth || 'health' => systemHealth,
      notifications || alertSubscriptions || 'subscriptions' || null =>
        alertSubscriptions,
      _ => alertSubscriptions,
    };
    if (!isAdmin && adminOnlyTabs.contains(tab)) {
      return alertSubscriptions;
    }
    return tab;
  }

  /// Sections visible for the current role (excludes admin-only for non-admins).
  static List<String> orderedFor({required bool isAdmin}) {
    return ordered
        .where((id) => isAdmin || !adminOnly.contains(id))
        .toList(growable: false);
  }

  static int indexOf(String section, {required bool isAdmin}) {
    final visible = orderedFor(isAdmin: isAdmin);
    final normalized = normalize(section);
    final index = visible.indexOf(normalized);
    return index < 0 ? 0 : index;
  }

  /// Deep link into the Notifications workspace (optionally a specific tab).
  static String location(String section) {
    final tab = normalizeTab(section);
    return '${Constants.automationCenterRoute}?section=$tab';
  }

  /// Deep link back to Alert Subscriptions (and subscription details return).
  static String get alertSubscriptionsLocation => location(alertSubscriptions);

  static List<WorkbenchRailGroup> groupsFor({required bool isAdmin}) {
    if (isAdmin) return groups;
    return groups
        .map(
          (group) => WorkbenchRailGroup(
            title: group.title,
            items: group.items
                .where((item) => !adminOnly.contains(item.id))
                .toList(growable: false),
          ),
        )
        .where((group) => group.items.isNotEmpty)
        .toList(growable: false);
  }
}
