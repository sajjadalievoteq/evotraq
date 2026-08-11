import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/gtin_packed_into_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_label_value_row.dart';

void main() {
  testWidgets('supply chain rows preserve labels and values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Gs1LabelValueRow(
                label: 'Current Location',
                value: 'Warehouse A',
                monospace: false,
              ),
              GtinPackedIntoRow(epc: 'not-a-routable-epc'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Current Location'), findsOneWidget);
    expect(find.text('Warehouse A'), findsOneWidget);
    expect(find.text('Packed Into'), findsOneWidget);
    expect(find.text('not-a-routable-epc'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
