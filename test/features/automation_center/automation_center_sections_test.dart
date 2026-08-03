import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/automation_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

void main() {
  test('uses the canonical route and section ids', () {
    expect(Constants.automationCenterRoute, '/automation');
    expect(AutomationCenterSections.ordered, const [
      'alert-subscriptions',
      'notification-activity',
      'background-jobs',
    ]);
    expect(
      WorkbenchRail.flatten(
        AutomationCenterSections.groups,
      ).map((item) => item.id),
      AutomationCenterSections.ordered,
    );
    expect(
      AutomationCenterSections.location(
        AutomationCenterSections.notificationActivity,
      ),
      '/automation?section=notification-activity',
    );
  });

  test('normalizes unknown sections and keeps admin sections gated', () {
    expect(
      AutomationCenterSections.normalize('unknown'),
      AutomationCenterSections.alertSubscriptions,
    );
    expect(AutomationCenterSections.adminOnly, const {'background-jobs'});

    final nonAdminIds = WorkbenchRail.flatten(
      AutomationCenterSections.groupsFor(isAdmin: false),
    ).map((item) => item.id);
    expect(
      nonAdminIds,
      containsAll([
        AutomationCenterSections.alertSubscriptions,
        AutomationCenterSections.notificationActivity,
      ]),
    );
    expect(
      nonAdminIds,
      isNot(contains(AutomationCenterSections.backgroundJobs)),
    );
  });

  test('screen accepts a deep-linked initial section', () {
    const screen = AutomationCenterScreen(initialSection: 'background-jobs');
    expect(screen.initialSection, 'background-jobs');
  });
}
