import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/widgets/field_validation_indicator.dart';

void main() {
  group('FieldValidationIndicator Widget Tests', () {
    testWidgets('should show nothing when not validated', (WidgetTester tester) async {
      // Build widget without validation
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: false,
            ),
          ),
        ),
      );
      
      // Should be empty
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Valid'), findsNothing);
      expect(find.text('Invalid'), findsNothing);
    });
    
    testWidgets('should show help text when available', (WidgetTester tester) async {
      // Build widget with help text
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: false,
              helpText: 'Enter a valid value',
            ),
          ),
        ),
      );
      
      // Should show help text
      expect(find.text('Enter a valid value'), findsOneWidget);
    });
    
    testWidgets('should show valid indicator when valid', (WidgetTester tester) async {
      // Build widget with valid state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: true,
              isValid: true,
            ),
          ),
        ),
      );
      
      // Should show valid indicator
      expect(find.text('Valid'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
    
    testWidgets('should show error message when invalid', (WidgetTester tester) async {
      // Build widget with invalid state and error message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: true,
              isValid: false,
              errorMessage: 'This field is required',
            ),
          ),
        ),
      );
      
      // Should show error message
      expect(find.text('This field is required'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
    
    testWidgets('should show invalid indicator when no error message', (WidgetTester tester) async {
      // Build widget with invalid state but no error message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FieldValidationIndicator(
              wasValidated: true,
              isValid: false,
              errorMessage: null,
            ),
          ),
        ),
      );
      
      // Should show invalid indicator
      expect(find.text('Invalid'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
