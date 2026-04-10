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
              formField: TextField(
                onChanged: (value) {
                  ValidationNotification(value).dispatch(tester.element(find.byType(TextField)));
                },
              ),
              validator: (value) => value!.isEmpty ? 'Field is required' : null,
            ),
          ),
        ),
      );
      
      // Enter text to trigger validation
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      
      // Should show error message
      expect(find.text('Field is required'), findsOneWidget);
      
      // Enter valid text
      await tester.enterText(find.byType(TextField), 'Valid value');
      await tester.pump();
      
      // Should show valid indicator
      expect(find.text('Valid'), findsOneWidget);
    });
    
    testWidgets('should respect validateOnChange setting', (WidgetTester tester) async {
      // Build a form field with validateOnChange=false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedFormField(
              validateOnChange: false,
              formField: TextField(
                onChanged: (value) {
                  ValidationNotification(value).dispatch(tester.element(find.byType(TextField)));
                },
              ),
              validator: (value) => value!.isEmpty ? 'Field is required' : null,
            ),
          ),
        ),
      );
      
      // Enter empty text
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      
      // Should not show error message yet
      expect(find.text('Field is required'), findsNothing);
      
      // Force focus change to trigger blur validation
      await tester.tap(find.byType(Scaffold));
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
              formField: const TextField(),
              validator: (value) => null, // Always valid
              initiallyValidated: true,
            ),
          ),
        ),
      );

      // Should show valid indicator immediately
      expect(find.text('Valid'), findsOneWidget);
    });
  });
}
