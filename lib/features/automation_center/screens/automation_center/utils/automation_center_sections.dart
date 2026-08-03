import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

abstract final class AutomationCenterSections {
  static const alertSubscriptions = 'alert-subscriptions';
  static const notificationActivity = 'notification-activity';
  static const backgroundJobs = 'background-jobs';

  static const ordered = [
    alertSubscriptions,
    notificationActivity,
    backgroundJobs,
  ];

  static const adminOnly = {backgroundJobs};

  static const groups = [
    WorkbenchRailGroup(
      title: 'Notifications',
      items: [
        WorkbenchRailItem(
          id: alertSubscriptions,
          iconAsset: NavIcons.manageSubscriptions,
          label: 'Alert Subscriptions',
        ),
        WorkbenchRailItem(
          id: notificationActivity,
          iconAsset: NavIcons.notificationCenter,
          label: 'Notification Activity',
        ),
      ],
    ),
    WorkbenchRailGroup(
      title: 'Data Operations',
      items: [
        WorkbenchRailItem(
          id: backgroundJobs,
          iconAsset: NavIcons.jobQueueManagement,
          label: 'Background Jobs',
        ),
      ],
    ),
  ];

  static String normalize(String? section) {
    return ordered.contains(section) ? section! : alertSubscriptions;
  }

  static int indexOf(String section) => ordered.indexOf(normalize(section));

  static String location(String section) {
    return '${Constants.automationCenterRoute}?section=${normalize(section)}';
  }

  static List<WorkbenchRailGroup> groupsFor({required bool isAdmin}) {
    if (isAdmin) return groups;
    return [
      groups.first,
      WorkbenchRailGroup(
        title: groups.last.title,
        items: groups.last.items
            .where((item) => !adminOnly.contains(item.id))
            .toList(growable: false),
      ),
    ];
  }
}
