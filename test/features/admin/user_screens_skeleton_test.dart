import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approvals_loading_view.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/widgets/user_management_loading_view.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(412, 915)}) {
    return MaterialApp(
      theme: TraqTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Align(alignment: Alignment.topCenter, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('user management skeleton lays out on compact width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const UserManagementLoadingView()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(UserManagementLoadingView), findsOneWidget);
  });

  testWidgets('user approvals skeleton lays out on compact width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const UserApprovalsLoadingView()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(UserApprovalsLoadingView), findsOneWidget);
  });

  testWidgets('user management skeleton lays out on desktop width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(const UserManagementLoadingView(), size: const Size(1280, 800)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
