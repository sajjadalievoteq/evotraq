import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

abstract final class AutomationCenterSections {
  static const alertSubscriptions = 'alert-subscriptions';
  static const notificationActivity = 'notification-activity';
  static const backgroundJobs = 'background-jobs';

  static const ordered = [alertSubscriptions, backgroundJobs];

  static const adminOnly = {backgroundJobs};

  static const groups = [
    WorkbenchRailGroup(
      title: 'Notifications',
      items: [
        WorkbenchRailItem(
          id: alertSubscriptions,
          iconAsset: NavIcons.manageSubscriptions,
          label: 'Subscriptions',
        ),
      ],
    ),
    WorkbenchRailGroup(
      title: 'Operations',
      items: [
        WorkbenchRailItem(
          id: backgroundJobs,
          iconAsset: NavIcons.jobQueueManagement,
          label: 'Job Operations',
        ),
      ],
    ),
  ];

  static String normalize(String? section) {
    if (section == notificationActivity) return alertSubscriptions;
    return ordered.contains(section) ? section! : alertSubscriptions;
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

  static String location(String section) {
    return '${Constants.automationCenterRoute}?section=${normalize(section)}';
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
