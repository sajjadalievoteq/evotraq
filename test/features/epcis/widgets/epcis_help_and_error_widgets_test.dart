import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/help_widgets/object_event_help_item.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/help_widgets/object_event_help_required_field.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_validation_demo/widgets/transaction_event_validation_section_header.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/widgets/help_widgets/transaction_document_help_section.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_events_help_section.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_form_field_help.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_scenario_help.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_simple_error.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_structured_error.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('simple validation error preserves its message', (tester) async {
    await tester.pumpWidget(
      _host(const ValidationSimpleError(message: 'Invalid EPC')),
    );

    expect(find.text('Invalid EPC'), findsOneWidget);
  });

  testWidgets('structured validation error preserves field fallbacks', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const ValidationStructuredError(errorMap: <String, dynamic>{})),
    );

    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('Invalid value'), findsOneWidget);
  });

  testWidgets('form field help renders all supplied content', (tester) async {
    await tester.pumpWidget(
      _host(
        const TransformationFormFieldHelp(
          fieldName: 'Business Step',
          description: 'Business process description',
          example: 'Business step example',
        ),
      ),
    );

    expect(find.text('Business Step'), findsOneWidget);
    expect(find.text('Business process description'), findsOneWidget);
    expect(find.text('Business step example'), findsOneWidget);
  });

  testWidgets('scenario help renders title, process, and business step', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TransformationScenarioHelp(
          title: 'Manufacturing',
          process: 'Inputs to outputs',
          bizStep: 'Business Step: producing',
        ),
      ),
    );

    expect(find.text('Manufacturing'), findsOneWidget);
    expect(find.text('Inputs to outputs'), findsOneWidget);
    expect(find.text('Business Step: producing'), findsOneWidget);
  });

  testWidgets('object-event help item renders supplied content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const ObjectEventHelpItem(
          title: 'active',
          description: 'The object is active.',
        ),
      ),
    );

    expect(find.text('active'), findsOneWidget);
    expect(find.text('The object is active.'), findsOneWidget);
  });

  testWidgets('required-field help renders title and description', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const ObjectEventHelpRequiredField(
          title: 'Action',
          description: 'ADD, OBSERVE, or DELETE.',
        ),
      ),
    );

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('ADD, OBSERVE, or DELETE.'), findsOneWidget);
  });

  testWidgets('transformation help section renders bullet points', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TransformationEventsHelpSection(
          title: 'When to use',
          description: 'Use for manufacturing.',
          bulletPoints: ['Raw materials into products'],
        ),
      ),
    );

    expect(find.text('When to use'), findsOneWidget);
    expect(find.text('Use for manufacturing.'), findsOneWidget);
    expect(find.text('Raw materials into products'), findsOneWidget);
  });

  testWidgets('transaction-document help section renders its content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TransactionDocumentHelpSection(
          title: 'Document type',
          content: 'Commercial invoice',
        ),
      ),
    );

    expect(find.text('Document type'), findsOneWidget);
    expect(find.text('Commercial invoice'), findsOneWidget);
  });

  testWidgets('validation section header renders title and divider', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TransactionEventValidationSectionHeader(
          title: 'Business Context',
        ),
      ),
    );

    expect(find.text('Business Context'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });
}
