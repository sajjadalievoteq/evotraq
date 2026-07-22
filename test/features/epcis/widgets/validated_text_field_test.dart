import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/field_validation_indicator.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validated_form_field.dart';

void main() {
  group('ValidatedTextField Widget Tests', () {
    testWidgets('should display validation errors', (
      WidgetTester tester,
    ) async {
      
      final controller = TextEditingController();

      
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        if (value.length < 3) {
          return 'Must be at least 3 characters';
        }
        return null;
      }

      
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

      
      expect(find.byType(FieldValidationIndicator), findsOneWidget);
      expect(find.text('Field is required'), findsNothing);

      
      await tester.enterText(find.byType(TextFormField), '');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification(''));
      await tester.pumpAndSettle();

      
      expect(find.text('Field is required'), findsOneWidget);

      
      await tester.enterText(find.byType(TextFormField), 'AB');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification('AB'));
      await tester.pumpAndSettle();

      
      expect(find.text('Must be at least 3 characters'), findsOneWidget);

      
      await tester.enterText(find.byType(TextFormField), 'ABC');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification('ABC'));
      await tester.pumpAndSettle();

      
      expect(find.text('Valid'), findsOneWidget);
    });

    testWidgets('should validate on blur', (WidgetTester tester) async {
      
      final controller = TextEditingController();

      
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      }

      
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

      
      await tester.tap(find.widgetWithText(TextFormField, 'Test Field'));
      await tester.pumpAndSettle();

      
      await tester.enterText(find.widgetWithText(TextFormField, 'Test Field'), '');
      await tester.pumpAndSettle();

      
      expect(find.text('Field is required'), findsNothing);

      
      await tester.tap(find.widgetWithText(TextField, 'Other Field'));
      await tester.pumpAndSettle();

      
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('should pass onChanged callback', (WidgetTester tester) async {
      
      final controller = TextEditingController();
      String? lastChangedValue;

      
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

      
      await tester.enterText(find.byType(TextFormField), 'Test Value');
      await tester.pump();

      
      expect(lastChangedValue, 'Test Value');
    });
  });
}
