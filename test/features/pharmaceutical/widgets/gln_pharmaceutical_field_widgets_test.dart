import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

void main() {
  testWidgets('text field preserves its controller and input limit', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlnPharmaceuticalTextField(
            controller: controller,
            label: 'Registration',
            maxLength: 4,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '123456');
    expect(controller.text, '1234');
    expect(find.text('Registration'), findsOneWidget);
  });

  testWidgets('switch forwards value changes', (tester) async {
    bool? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlnPharmaceuticalSwitch(
            label: 'Cold chain',
            value: false,
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    expect(changedValue, isTrue);
  });

  testWidgets('read-only date field displays the existing date', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlnPharmaceuticalDateField(
            label: 'Expiry',
            value: DateTime(2027, 2, 3),
            onChanged: null,
          ),
        ),
      ),
    );

    expect(find.text('Expiry'), findsOneWidget);
    expect(find.text('2027-02-03'), findsOneWidget);
  });
}
