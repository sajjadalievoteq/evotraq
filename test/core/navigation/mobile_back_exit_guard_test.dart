import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/navigation/mobile_back/mobile_back_exit_guard.dart';
import 'package:traqtrace_app/core/widgets/snack_bar_interaction_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileBackExitGuard', () {
    testWidgets('first prompt does not exit; second within window does', (
      tester,
    ) async {
      var now = DateTime(2026, 1, 1, 12);
      final guard = MobileBackExitGuard(
        confirmWindow: const Duration(seconds: 2),
        now: () => now,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SnackBarInteractionScope(child: Scaffold(body: SizedBox())),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      expect(guard.registerPrompt(context), isFalse);
      expect(guard.registerPrompt(context), isTrue);
    });

    testWidgets('prompt after window expires requires another confirm', (
      tester,
    ) async {
      var now = DateTime(2026, 1, 1, 12);
      final guard = MobileBackExitGuard(
        confirmWindow: const Duration(seconds: 2),
        now: () => now,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SnackBarInteractionScope(child: Scaffold(body: SizedBox())),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      expect(guard.registerPrompt(context), isFalse);
      now = now.add(const Duration(seconds: 3));
      expect(guard.registerPrompt(context), isFalse);
      expect(guard.registerPrompt(context), isTrue);
    });
  });
}
