import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart';

void main() {
  group('ValidatedTextField Widget Tests', () {
    testWidgets('should display validation errors', (
      WidgetTester tester,
    ) async {
      // Controller to manipulate the text
      final controller = TextEditingController();

      // Validation function
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        if (value.length < 3) {
          return 'Must be at least 3 characters';
        }
        return null;
      }

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ValidatedTextField(
                controller: controller,
                validator: validator,
                decoration: const InputDecoration(labelText: 'Test Field'),
                validateOnChange: true,
              ),
            ),
          ),
        ),
      );

      // Initially no validation indicator should be shown
      expect(find.byType(FieldValidationIndicator), findsOneWidget);
      expect(find.text('Field is required'), findsNothing);

      // Enter empty value
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // Should show validation error
      expect(find.text('Field is required'), findsOneWidget);

      // Enter short value
      await tester.enterText(find.byType(TextFormField), 'AB');
      await tester.pump();

      // Should show different validation error
      expect(find.text('Must be at least 3 characters'), findsOneWidget);

      // Enter valid value
      await tester.enterText(find.byType(TextFormField), 'ABC');
      await tester.pump();

      // Should show valid indicator
      expect(find.text('Valid'), findsOneWidget);
    });

    testWidgets('should validate on blur', (WidgetTester tester) async {
      // Controller to manipulate the text
      final controller = TextEditingController();

      // Validation function
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      }

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ValidatedTextField(
                  controller: controller,
                  validator: validator,
                  decoration: const InputDecoration(labelText: 'Test Field'),
                  validateOnChange: false,
                  validateOnBlur: true,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Other Field'),
                ),
              ],
            ),
          ),
        ),
      );

      // Focus the field first so blur can be triggered
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Enter empty value
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // No error should be shown yet (validateOnChange is false)
      expect(find.text('Field is required'), findsNothing);

      // Tap another focusable widget to shift focus (triggering blur)
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Should now show validation error
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('should pass onChanged callback', (WidgetTester tester) async {
      // Controller to manipulate the text
      final controller = TextEditingController();
      String? lastChangedValue;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ValidatedTextField(
                controller: controller,
                onChanged: (value) {
                  lastChangedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Test Value');
      await tester.pump();

      // Callback should be triggered
      expect(lastChangedValue, 'Test Value');
    });
  });
}
