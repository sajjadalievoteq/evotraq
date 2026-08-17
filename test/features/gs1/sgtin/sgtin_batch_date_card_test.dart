import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_batch_date_card.dart';

void main() {
  testWidgets('create registration fields live on Batch & Date Information', (
    tester,
  ) async {
    final quantity = TextEditingController();
    final lot = TextEditingController(text: 'LOT-42');
    addTearDown(quantity.dispose);
    addTearDown(lot.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        home: Scaffold(
          body: SgtinBatchDateCard(
            borderColor: Colors.grey,
            isCreating: true,
            expiryDate: DateTime(2027, 1, 1),
            productionDate: DateTime(2026, 1, 1),
            bestBeforeDate: null,
            onPickExpiry: () {},
            onPickProduction: () {},
            onPickBestBefore: () {},
            showRegistrationFields: true,
            quantityController: quantity,
            onRegister: () {},
            batchLotNumberController: lot,
          ),
        ),
      ),
    );

    expect(find.text('Batch / Lot Number *'), findsOneWidget);
    expect(find.text('Manufacture Date *'), findsOneWidget);
    expect(find.text('Expiry Date *'), findsOneWidget);
    expect(find.text('Quantity Manufactured'), findsOneWidget);
    expect(find.text('Register Batch'), findsOneWidget);
    expect(find.text('Best Before Date'), findsOneWidget);
  });
}
