import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

void main() {
  testWidgets('EPCInputWidget shows manual entry only when scanner unavailable',
      (tester) async {
    EPCParseResult? added;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EPCInputWidget(
            label: 'Item Barcode',
            scannerAvailable: false,
            allowedTypes: const [EPCType.sgtin, EPCType.sscc],
            onItemAdded: (result) => added = result,
          ),
        ),
      ),
    );

    expect(find.text('Camera / Scanner'), findsNothing);
    expect(find.text('Manual'), findsNothing);
    expect(find.text('Item Barcode'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'urn:epc:id:sgtin:0629200.008002.SN123',
    );
    await tester.pump();

    await tester.tap(find.text('Add Item'));
    await tester.pump();

    expect(added, isNotNull);
    expect(added!.type, EPCType.sgtin);
    expect(added!.epc, 'https://id.gs1.org/01/00629200080027/21/SN123');
  });

  testWidgets('EPCInputWidget shows type badge after valid manual input',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EPCInputWidget(
            onItemAdded: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'urn:epc:id:sscc:0629200.108002700000001',
    );
    await tester.pump();

    expect(find.text('SSCC detected'), findsOneWidget);
  });
}
