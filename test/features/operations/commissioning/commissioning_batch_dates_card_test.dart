import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_batch_dates_card.dart';

void main() {
  testWidgets(
    'commissioning batch card keeps lot entry without Batch Master registration',
    (tester) async {
      final lotController = TextEditingController(text: 'LOT-99');
      addTearDown(lotController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          home: Scaffold(
            body: Form(
              child: CommissioningBatchDatesCard(
                batchLotController: lotController,
                expiryDate: DateTime(2027, 1, 1),
                productionDate: DateTime(2026, 1, 1),
                bestBeforeDate: null,
                onSelectDate: (_) {},
                onClearDate: (_) {},
                requireExpiry: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Batch/Lot Number *'), findsOneWidget);
      expect(find.text('Register Batch'), findsNothing);
      expect(find.text('Looking up batch in Batch Master…'), findsNothing);
      expect(find.text('Batch not found in Batch Master'), findsNothing);
    },
  );
}
