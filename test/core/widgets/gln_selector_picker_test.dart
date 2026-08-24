import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

GLN _gln(String code, String name, {String? contact}) {
  return GLN.fromJson({
    'glnCode': code,
    'locationName': name,
    'city': 'Dubai',
    'stateProvince': 'DU',
    'contactName': contact,
    'locationStatus': 'active',
    'operatingStatus': 'ACTIVE',
  });
}

void main() {
  testWidgets('GLNSelector filters and selects from provided picker catalog',
      (tester) async {
    GLN? selected;
    final catalog = [
      _gln('0614141000003', 'Plant Alpha', contact: 'Alice'),
      _gln('0614141000010', 'Warehouse Beta', contact: 'Bob'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GLNSelector(
            label: 'Location',
            pickerCatalog: catalog,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.textContaining('Plant Alpha'), findsWidgets);
    expect(find.textContaining('Warehouse Beta'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), 'warehouse');
    await tester.pumpAndSettle();

    expect(find.textContaining('Warehouse Beta'), findsWidgets);
    expect(find.textContaining('Plant Alpha'), findsNothing);

    await tester.tap(find.textContaining('Warehouse Beta').first);
    await tester.pumpAndSettle();

    expect(selected?.glnCode, '0614141000010');
    expect(selected?.locationName, 'Warehouse Beta');
  });
}
