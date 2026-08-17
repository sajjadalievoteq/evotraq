import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_master_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_status_skeleton.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: TraqTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('looking-up state uses skeleton loading instead of a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SgtinBatchMasterCard(
          batchLot: 'LOT-42',
          state: SgtinBatchState(status: SgtinBatchLookupStatus.lookingUp),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(SgtinBatchStatusSkeleton), findsOneWidget);
  });

  testWidgets('found state shows Batch Master dates and status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SgtinBatchMasterCard(
          batchLot: 'LOT-42',
          state: SgtinBatchState(
            status: SgtinBatchLookupStatus.found,
            resolvedBatch: const GtinBatch(
              gtinId: 1,
              batchLotNumber: 'LOT-42',
              expiryDate: '2027-01-01',
              manufactureDate: '2026-01-01',
              recallAffected: false,
              batchStatus: 'ACTIVE',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Batch found'), findsOneWidget);
    expect(find.textContaining('Expiry: 2027-01-01'), findsOneWidget);
    expect(find.textContaining('Status: ACTIVE'), findsOneWidget);
  });

  testWidgets('missing batch points to Batch & Date Information', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SgtinBatchMasterCard(
          batchLot: 'LOT-42',
          state: SgtinBatchState(
            status: SgtinBatchLookupStatus.notFound,
            registrationPanelExpanded: false,
          ),
        ),
      ),
    );

    expect(find.text('Batch not found in Batch Master'), findsOneWidget);
    expect(find.textContaining('tap Register Batch'), findsOneWidget);
  });

  testWidgets('idle lot without GTIN asks the user to select a GTIN', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SgtinBatchMasterCard(
          batchLot: 'dfdfdff',
          state: SgtinBatchState(status: SgtinBatchLookupStatus.idle),
        ),
      ),
    );

    expect(find.text('Select a GTIN to look up this batch'), findsOneWidget);
    expect(find.textContaining('Choose a saved GTIN first'), findsOneWidget);
  });
}
