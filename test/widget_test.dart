import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/splash/native_splash_colors.dart';

void main() {
  testWidgets('startup safety background matches native splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ColoredBox(color: NativeSplashColors.lightBackground),
      ),
    );

    final splashBackground = find.byWidgetPredicate(
      (widget) =>
          widget is ColoredBox &&
          widget.color == NativeSplashColors.lightBackground,
    );
    expect(splashBackground, findsOneWidget);
    final box = tester.widget<ColoredBox>(splashBackground);
    expect(box.color, NativeSplashColors.lightBackground);
  });
}
