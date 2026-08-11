import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_status_card.dart';

void main() {
  testWidgets('looking-up state preserves lot and progress message', (
    tester,
  ) async {
    final quantityController = TextEditingController();
    addTearDown(quantityController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommissioningBatchStatusCard(
            status: CommissioningBatchLookupStatus.lookingUp,
            batchLot: 'LOT-42',
            registrationPanelExpanded: false,
            registrationExpiryDate: null,
            registrationManufactureDate: null,
            registrationQuantityController: quantityController,
            onSelectRegistrationDate: (_) {},
            onClearRegistrationDate: (_) {},
            onRegisterBatch: () {},
            onToggleRegistrationPanel: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Looking up batch in Batch Masterâ€¦'), findsOneWidget);
    expect(find.text('Lot: LOT-42'), findsOneWidget);
  });
}
