import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';

Widget _host(Widget child) => MaterialApp(
  theme: TraqTheme.light(),
  home: Scaffold(
    body: DefaultTextHeightBehavior(
      textHeightBehavior: TraqText.heightBehavior,
      child: child,
    ),
  ),
);

void main() {
  Future<void> setMobileView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Edit Profile label fits inside CustomElevatedButton', (
    tester,
  ) async {
    await setMobileView(tester);
    await tester.pumpWidget(
      _host(
        CustomElevatedButton(
          fontSize: 14,
          label: 'Edit Profile',
          onPressed: () {},
        ),
      ),
    );

    final textRect = tester.getRect(find.text('Edit Profile'));
    final buttonRect = tester.getRect(find.byType(FilledButton));

    expect(textRect.height, greaterThanOrEqualTo(14));
    expect(textRect.top, greaterThanOrEqualTo(buttonRect.top));
    expect(textRect.bottom, lessThanOrEqualTo(buttonRect.bottom));
  });

  testWidgets('AuthActionButton label fits inside the fixed-height button', (
    tester,
  ) async {
    await setMobileView(tester);
    await tester.pumpWidget(
      _host(AuthActionButton(label: 'Sign in', onPressed: () {})),
    );

    final textRect = tester.getRect(find.text('Sign in'));
    final buttonRect = tester.getRect(find.byType(FilledButton));

    expect(textRect.height, greaterThanOrEqualTo(16));
    expect(textRect.top, greaterThanOrEqualTo(buttonRect.top));
    expect(textRect.bottom, lessThanOrEqualTo(buttonRect.bottom));
  });
}
