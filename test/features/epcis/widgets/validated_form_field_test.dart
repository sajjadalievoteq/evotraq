import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validated_form_field.dart';

void main() {
  group('ValidatedFormField Widget Tests', () {
    testWidgets('should notify on value change', (WidgetTester tester) async {
      
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
      
      
      await tester.enterText(find.byType(TextFormField), '');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification(''));
      await tester.pump();
      
      
      expect(find.text('Field is required'), findsOneWidget);
      
      
      await tester.enterText(find.byType(TextFormField), 'Valid value');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification('Valid value'));
      await tester.pump();
      
      
      expect(find.text('Valid'), findsOneWidget);
    });
    
    testWidgets('should respect validateOnChange setting', (WidgetTester tester) async {
      final focusNode = FocusNode();
      
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
      
      
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      
      await tester.enterText(find.byType(TextFormField), '');
      tester.element(find.byType(TextFormField)).dispatchNotification(ValidationNotification(''));
      await tester.pump();
      
      
      expect(find.text('Field is required'), findsNothing);
      
      
      focusNode.unfocus();
      await tester.pump();
      
      
      expect(find.text('Field is required'), findsOneWidget);
    });
    
    testWidgets('should display help text', (WidgetTester tester) async {
      
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
      
      
      expect(find.text('This is help text'), findsOneWidget);
    });
    
    testWidgets('should respect initiallyValidated setting', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedFormField(
              animate: false,
              formField: const TextField(),
              validator: (value) => null, 
              initiallyValidated: true,
            ),
          ),
        ),
      );

      
      await tester.pump();
      expect(find.text('Valid'), findsOneWidget);
    });
  });
}
