import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

abstract final class AutomationCenterSections {
  static const subscriptions = 'subscriptions';
  static const webhookHistory = 'webhook-history';
  static const statistics = 'statistics';
  static const jobQueue = 'job-queue';
  static const bulkImport = 'bulk-import';
  static const bulkExport = 'bulk-export';
  static const etl = 'etl';

  static const ordered = [
    subscriptions,
    webhookHistory,
    statistics,
    jobQueue,
    bulkImport,
    bulkExport,
    etl,
  ];

  static const adminOnly = {jobQueue, bulkExport, etl};

  static const groups = [
    WorkbenchRailGroup(
      title: 'Notifications',
      items: [
        WorkbenchRailItem(
          id: subscriptions,
          iconAsset: NavIcons.manageSubscriptions,
          label: 'Subscriptions',
        ),
        WorkbenchRailItem(
          id: webhookHistory,
          iconAsset: NavIcons.webhookConfiguration,
          label: 'Webhook History',
        ),
        WorkbenchRailItem(
          id: statistics,
          iconAsset: NavIcons.notificationCenter,
          label: 'Statistics',
        ),
      ],
    ),
    WorkbenchRailGroup(
      title: 'Batch Processing',
      items: [
        WorkbenchRailItem(
          id: jobQueue,
          iconAsset: NavIcons.jobQueueManagement,
          label: 'Job Queue',
        ),
        WorkbenchRailItem(
          id: bulkImport,
          iconAsset: AppAssets.iconUpload,
          label: 'Bulk Import',
        ),
        WorkbenchRailItem(
          id: bulkExport,
          iconAsset: NavIcons.bulkExport,
          label: 'Bulk Export',
        ),
        WorkbenchRailItem(
          id: etl,
          iconAsset: NavIcons.etlManagement,
          label: 'ETL',
        ),
      ],
    ),
  ];

  static String normalize(String? section) {
    return ordered.contains(section) ? section! : subscriptions;
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
