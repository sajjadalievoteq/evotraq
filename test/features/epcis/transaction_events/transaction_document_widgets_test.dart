import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/utils/transaction_document_type_formatter.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/transaction_document_screen.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_document/widgets/transaction_document_dropdown_field.dart';

void main() {
  test('transaction document screen remains constructible', () {
    expect(const TransactionDocumentScreen(), isA<TransactionDocumentScreen>());
  });

  test('document type formatter preserves the existing CBV labels', () {
    expect(
      TransactionDocumentTypeFormatter.displayName(
        'urn:epcglobal:cbv:btt:desadv',
      ),
      'Despatch Advice',
    );
    expect(TransactionDocumentTypeFormatter.displayName('custom'), 'custom');
  });

  testWidgets(
    'document dropdown writes the selected option to its controller',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionDocumentDropdownField(
              controller: controller,
              options: const ['urn:epcglobal:cbv:btt:inv'],
              hint: 'Select Document Type',
              formatDocumentTypes: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invoice').last);
      await tester.pumpAndSettle();

      expect(controller.text, 'urn:epcglobal:cbv:btt:inv');
    },
  );
}
