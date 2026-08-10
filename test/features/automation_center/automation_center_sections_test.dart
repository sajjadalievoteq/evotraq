import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/automation_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

void main() {
  test('uses the canonical route and single Notifications rail item', () {
    expect(Constants.automationCenterRoute, '/automation');
    expect(AutomationCenterSections.ordered, const ['notifications']);
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
    expect(
      AutomationCenterSections.location(
        AutomationCenterSections.backgroundJobs,
      ),
      '/automation?section=background-jobs',
    );
  });

  test('uses one rail destination and normalizes internal workspace tabs', () {
    expect(
      AutomationCenterSections.normalize('unknown'),
      AutomationCenterSections.notifications,
    );
    expect(
      AutomationCenterSections.normalizeTab('unknown'),
      AutomationCenterSections.alertSubscriptions,
    );
    expect(
      AutomationCenterSections.normalizeTab('background-jobs', isAdmin: false),
      AutomationCenterSections.alertSubscriptions,
    );
    expect(
      AutomationCenterSections.normalizeTab('background-jobs', isAdmin: true),
      AutomationCenterSections.backgroundJobs,
    );
    expect(AutomationCenterSections.adminOnly, isEmpty);
    expect(AutomationCenterSections.adminOnlyTabs, const {'background-jobs'});

    final nonAdminIds = WorkbenchRail.flatten(
      AutomationCenterSections.groupsFor(isAdmin: false),
    ).map((item) => item.id);
    expect(nonAdminIds, [AutomationCenterSections.notifications]);
    expect(
      AutomationCenterSections.groupsFor(
        isAdmin: false,
      ).every((group) => group.items.isNotEmpty),
      isTrue,
    );
  });

  test('screen accepts a deep-linked initial section', () {
    const screen = AutomationCenterScreen(initialSection: 'background-jobs');
    expect(screen.initialSection, 'background-jobs');
  });
}
