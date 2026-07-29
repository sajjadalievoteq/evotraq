import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/automation_center/presentation/screen/automation_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/presentation/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

void main() {
  test('uses the canonical route and section ids', () {
    expect(Constants.automationCenterRoute, '/automation');
    expect(AutomationCenterSections.ordered, const [
      'subscriptions',
      'webhook-history',
      'statistics',
      'job-queue',
      'bulk-import',
      'bulk-export',
      'etl',
    ]);
    expect(
      WorkbenchRail.flatten(
        AutomationCenterSections.groups,
      ).map((item) => item.id),
      AutomationCenterSections.ordered,
    );
    expect(
      AutomationCenterSections.location(
        AutomationCenterSections.webhookHistory,
      ),
      '/automation?section=webhook-history',
    );
  });

  test('normalizes unknown sections and keeps admin sections gated', () {
    expect(
      AutomationCenterSections.normalize('unknown'),
      AutomationCenterSections.subscriptions,
    );
    expect(AutomationCenterSections.adminOnly, const {
      'job-queue',
      'bulk-export',
      'etl',
    });

    final nonAdminIds = WorkbenchRail.flatten(
      AutomationCenterSections.groupsFor(isAdmin: false),
    ).map((item) => item.id);
    expect(
      nonAdminIds,
      containsAll([
        AutomationCenterSections.subscriptions,
        AutomationCenterSections.webhookHistory,
        AutomationCenterSections.statistics,
        AutomationCenterSections.bulkImport,
      ]),
    );
    expect(nonAdminIds, isNot(contains(AutomationCenterSections.jobQueue)));
  });

  test('screen accepts a deep-linked initial section', () {
    const screen = AutomationCenterScreen(initialSection: 'etl');
    expect(screen.initialSection, 'etl');
  });
}
