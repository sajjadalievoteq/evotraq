import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/splash/screens/splash_screen.dart';

void main() {
  testWidgets('TraqTrace app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        darkTheme: TraqTheme.dark(),
        home: const SplashScreen(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump();
  });
}
