import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_validated_text_field.dart';

void main() {
  testWidgets('validated field forwards its named validation error', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? reportedField;
    String? reportedError;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: TransformationEventValidatedTextField(
              controller: controller,
              label: 'Transformation ID',
              fieldName: 'transformationId',
              validator: (_) => 'Required',
              onFieldError: (field, error) {
                reportedField = field;
                reportedError = error;
              },
            ),
          ),
        ),
      ),
    );

    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isFalse);
    expect(reportedField, 'transformationId');
    expect(reportedError, 'Required');
  });

  testWidgets('dropdown formats underscore-separated option labels', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'in_transit');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransformationEventDropdownField(
            controller: controller,
            label: 'Disposition',
            options: const ['in_transit'],
          ),
        ),
      ),
    );

    expect(find.text('In Transit'), findsOneWidget);
  });
}
