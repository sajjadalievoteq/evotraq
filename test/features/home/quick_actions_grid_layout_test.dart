import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/widgets/dashboard_quick_action_card.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/widgets/quick_actions_grid.dart';

/// Number of tiles rendered in the first row, i.e. the resolved column count.
int _columnsInFirstRow(WidgetTester tester) {
  final cards = find.byType(DashboardQuickActionCard);
  final tops = tester
      .widgetList(cards)
      .toList()
      .asMap()
      .keys
      .map((i) => tester.getTopLeft(cards.at(i)))
      .toList();
  final firstRowTop = tops
      .map((offset) => offset.dy)
      .reduce((a, b) => a < b ? a : b);
  return tops.where((offset) => offset.dy == firstRowTop).length;
}

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TraqTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: width, child: const QuickActionsGrid()),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('fills wide rows with more than three columns', (tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Content width of a 1024px browser window minus the dashboard gutters.
    await _pumpAtWidth(tester, 965);
    expect(_columnsInFirstRow(tester), 5);
  });

  testWidgets('scales columns down on narrower widths', (tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpAtWidth(tester, 700);
    expect(_columnsInFirstRow(tester), 3);

    await _pumpAtWidth(tester, 360);
    expect(_columnsInFirstRow(tester), 2);
  });

  testWidgets('keeps tile height capped and compact when wide', (tester) async {
    tester.view.physicalSize = const Size(4000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpAtWidth(tester, 1900);

    final size = tester.getSize(find.byType(DashboardQuickActionCard).first);
    expect(size.height, lessThanOrEqualTo(92.0));
    expect(size.width, greaterThan(size.height));
  });
}
