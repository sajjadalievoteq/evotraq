import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_form_field.dart';

void main() {
  group('ValidatedFormField Widget Tests', () {
    testWidgets('should notify on value change', (WidgetTester tester) async {
      // Build a form field that dispatches notifications
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedFormField(
              animate: false,
              formField: TextFormField(
                onChanged: (value) {
                  ValidationNotification(value).dispatch(tester.element(find.byType(TextFormField)));
                },
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Field is required' : null,
            ),
          ),
        ),
      );
      
      // Enter text to trigger validation
      await tester.enterText(find.byType(TextFormField), '');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification(''));
      await tester.pump();
      
      // Should show error message
      expect(find.text('Field is required'), findsOneWidget);
      
      // Enter valid text
      await tester.enterText(find.byType(TextFormField), 'Valid value');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification('Valid value'));
      await tester.pump();
      
      // Should show valid indicator
      expect(find.text('Valid'), findsOneWidget);
    });
    
    testWidgets('should respect validateOnChange setting', (WidgetTester tester) async {
      final focusNode = FocusNode();
      // Build a form field with validateOnChange=false and another field to take focus
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ValidatedFormField(
                  focusNode: focusNode,
                  animate: false,
                  validateOnChange: false,
                  formField: TextFormField(
                    focusNode: focusNode,
                    onChanged: (value) {
                      ValidationNotification(value).dispatch(tester.element(find.byType(TextFormField)));
                    },
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Field is required' : null,
                ),
                const TextField(key: Key('other_field')),
              ],
            ),
          ),
        ),
      );
      
      // Focus the field
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      // Enter empty text
      await tester.enterText(find.byType(TextFormField), '');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification(''));
      await tester.pump();
      
      // Should not show error message yet
      expect(find.text('Field is required'), findsNothing);
      
      // Force focus change to trigger blur validation
      focusNode.unfocus();
      await tester.pump();
      
      // Now should show validation error
      expect(find.text('Field is required'), findsOneWidget);
    });
    
    testWidgets('should display help text', (WidgetTester tester) async {
      // Build a form field with help text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedFormField(
              formField: const TextField(),
              validator: (value) => null,
              helpText: 'This is help text',
              initiallyValidated: false,
            ),
          ),
        ),
      );
      
      // Should show help text
      expect(find.text('This is help text'), findsOneWidget);
    });
    
    testWidgets('should respect initiallyValidated setting', (WidgetTester tester) async {
      // Build a form field with initiallyValidated=true and a passing validator
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedFormField(
              animate: false,
              formField: const TextField(),
              validator: (value) => null, // Always valid
              initiallyValidated: true,
            ),
          ),
        ),
      );

      // Should show valid indicator immediately
      await tester.pump();
      expect(find.text('Valid'), findsOneWidget);
    });
  });
}
