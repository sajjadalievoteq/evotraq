import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

abstract final class AutomationCenterSections {
  static const notifications = 'notifications';
  static const inbound = 'inbound';
  static const alertSubscriptions = 'alert-subscriptions';
  static const notificationActivity = 'notification-activity';
  static const backgroundJobs = 'background-jobs';
  static const systemHealth = 'system-health';

  static const ordered = [notifications, inbound];

  static const adminOnlyTabs = {backgroundJobs};

  static const adminOnly = <String>{};

  static const groups = [
    WorkbenchRailGroup(
      title: 'Integrations',
      items: [
        WorkbenchRailItem(
          id: notifications,
          iconAsset: NavIcons.manageSubscriptions,
          label: 'Outbound',
        ),
        WorkbenchRailItem(
          id: inbound,
          iconAsset: NavIcons.integrationValidation,
          label: 'Inbound',
        ),
      ],
    ),
  ];

  static String normalize(String? section) =>
      section == inbound ? inbound : notifications;

  static String normalizeTab(String? section, {bool isAdmin = true}) {
    final tab = switch (section) {
      notificationActivity || 'activity' => notificationActivity,
      backgroundJobs || 'jobs' => backgroundJobs,
      systemHealth || 'health' => systemHealth,
      notifications ||
      alertSubscriptions ||
      'subscriptions' ||
      null => alertSubscriptions,
      _ => alertSubscriptions,
    };
    if (!isAdmin && adminOnlyTabs.contains(tab)) {
      return alertSubscriptions;
    }
    return tab;
  }

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

  static String location(String section) {
    final tab = normalizeTab(section);
    return '${Constants.automationCenterRoute}?section=$tab';
  }

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
