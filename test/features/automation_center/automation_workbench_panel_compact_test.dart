import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';

void main() {
  testWidgets(
    'compact panel keeps title on one line and stacks actions',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          home: Scaffold(
            body: AutomationWorkbenchPanel(
              title: 'Outbound',
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.info)),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Refresh'),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('New Subscription'),
                ),
              ],
              child: const Text(
                'Manage subscriptions, monitor deliveries, and track '
                'notification system health.',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);

      final title = tester.widget<Text>(find.text('Outbound'));
      expect(title.maxLines, 2);

      final size = tester.getSize(find.text('Outbound'));
      expect(size.height, lessThan(48));
      expect(tester.getTopLeft(find.text('Outbound')).dy, lessThan(
        tester.getTopLeft(find.text('Refresh')).dy,
      ));
    },
  );
}
