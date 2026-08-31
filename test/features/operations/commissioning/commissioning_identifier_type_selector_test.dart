import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_view.dart';

void main() {
  test('commissioning operation view remains constructible', () {
    expect(
      const CommissioningOperationView(),
      isA<CommissioningOperationView>(),
    );
  });

  testWidgets('commissioning fields follow selected identifier type', (
    tester,
  ) async {
    EPCType? selectedType;
    final controllers = List.generate(11, (_) => TextEditingController());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    Widget subject() => MaterialApp(
      home: Scaffold(
        body: CommissioningStep1ProductDetails(
          identifierType: selectedType,
          identifierTypeError: null,
          onIdentifierTypeChanged: (value) => selectedType = value,
          commissioningLocationGLN: null,
          locationError: null,
          onLocationChanged: (_) {},
          pickerCatalog: [
            GLN.fromJson({
              'glnCode': '6295151151105',
              'locationName': 'Commissioning Site',
              'locationStatus': 'active',
              'operatingStatus': 'ACTIVE',
            }),
          ],
          referenceController: controllers[0],
          countryOfOriginController: controllers[1],
          manufacturingOriginController: controllers[2],
          shipmentPermitController: controllers[3],
          productionOrderController: controllers[4],
          productionLineController: controllers[5],
          regulatoryMarketController: controllers[6],
          regulatoryStatusController: controllers[7],
          operatorIdController: controllers[8],
          notesController: controllers[9],
          readPointGlnController: controllers[10],
        ),
      ),
    );

    selectedType = EPCType.sgtin;
    await tester.pumpWidget(subject());
    expect(find.text('Manufacturing Origin *'), findsOneWidget);
    expect(find.text('Shipment / Local Sales Permit *'), findsOneWidget);

    selectedType = EPCType.sscc;
    await tester.pumpWidget(subject());
    expect(find.text('Manufacturing Origin *'), findsNothing);
    expect(find.text('Shipment / Local Sales Permit *'), findsNothing);
    expect(find.text('Read Point GLN (optional)'), findsOneWidget);
  });
}
