import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/pharma_service.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';

class MockPharmaService extends Mock implements PharmaService {}

void main() {
  late MockPharmaService pharma;
  late SgtinBatchCubit cubit;

  const lot = 'LOT-1';
  const gtinCode = '01234567890128';
  final existing = GtinBatch(
    id: 9,
    gtinId: 1,
    gtinCode: gtinCode,
    batchLotNumber: lot,
    expiryDate: '2027-01-01',
    manufactureDate: '2026-01-01',
    recallAffected: false,
    batchStatus: 'ACTIVE',
  );

  setUpAll(() {
    registerFallbackValue(existing);
    registerFallbackValue(0);
  });

  setUp(() {
    pharma = MockPharmaService();
    cubit = SgtinBatchCubit(pharmaService: pharma);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('lookup does not start without a persisted GTIN', () {
    cubit.onBatchLotInputChanged(lot);
    verifyNever(() => pharma.tryGetBatchByLot(any(), any()));
    expect(cubit.state.status, SgtinBatchLookupStatus.idle);
    expect(cubit.state.lookupBatchLot, lot);
  });

  test('changing GTIN clears the previous resolved batch', () async {
    when(
      () => pharma.tryGetBatchByLot(1, lot),
    ).thenAnswer((_) async => existing);
    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
    await cubit.lookupBatch(gtinId: 1, gtinCode: gtinCode, batchLot: lot);
    expect(cubit.state.resolvedBatch, existing);

    cubit.onGtinChanged(gtinId: 2, gtinCode: '01234567890135');
    expect(cubit.state.resolvedBatch, isNull);
    expect(cubit.state.status, SgtinBatchLookupStatus.idle);
    expect(cubit.state.gtinId, 2);
  });

  test('stale lookup results cannot overwrite the current selection', () async {
    when(() => pharma.tryGetBatchByLot(1, 'LOT-OLD')).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return existing.copyWith(batchLotNumber: 'LOT-OLD');
    });
    when(
      () => pharma.tryGetBatchByLot(1, 'LOT-NEW'),
    ).thenAnswer((_) async => null);

    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
    final stale = cubit.lookupBatch(
      gtinId: 1,
      gtinCode: gtinCode,
      batchLot: 'LOT-OLD',
    );
    await cubit.lookupBatch(gtinId: 1, gtinCode: gtinCode, batchLot: 'LOT-NEW');
    await stale;

    expect(cubit.state.lookupBatchLot, 'LOT-NEW');
    expect(cubit.state.status, SgtinBatchLookupStatus.notFound);
    expect(cubit.state.resolvedBatch, isNull);
  });

  blocTest<SgtinBatchCubit, SgtinBatchState>(
    'existing batch renders as found',
    build: () {
      when(
        () => pharma.tryGetBatchByLot(1, lot),
      ).thenAnswer((_) async => existing);
      return SgtinBatchCubit(pharmaService: pharma);
    },
    act: (c) async {
      c.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
      await c.lookupBatch(gtinId: 1, gtinCode: gtinCode, batchLot: lot);
    },
    expect: () => [
      isA<SgtinBatchState>().having((s) => s.gtinId, 'gtinId', 1),
      isA<SgtinBatchState>().having(
        (s) => s.status,
        'status',
        SgtinBatchLookupStatus.lookingUp,
      ),
      isA<SgtinBatchState>().having(
        (s) => s.status,
        'status',
        SgtinBatchLookupStatus.found,
      ),
    ],
  );

  test('missing batch exposes registration controls', () async {
    when(() => pharma.tryGetBatchByLot(1, lot)).thenAnswer((_) async => null);
    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
    await cubit.lookupBatch(gtinId: 1, gtinCode: gtinCode, batchLot: lot);
    expect(cubit.state.status, SgtinBatchLookupStatus.notFound);
    expect(cubit.state.registrationPanelExpanded, isTrue);
    expect(cubit.state.canSubmitSgtin, isFalse);
  });

  test('invalid dates block registration', () async {
    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
    final ok = await cubit.registerBatch(
      batchLot: lot,
      manufactureDate: DateTime(2027, 1, 1),
      expiryDate: DateTime(2026, 1, 1),
    );
    expect(ok, isFalse);
    verifyNever(() => pharma.createBatch(any(), any()));
    expect(cubit.state.canSubmitSgtin, isFalse);
  });

  test('successful registration enables SGTIN submission', () async {
    when(
      () => pharma.createBatch(any(), any()),
    ).thenAnswer((_) async => existing);
    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
    final ok = await cubit.registerBatch(
      batchLot: lot,
      manufactureDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2027, 1, 1),
    );
    expect(ok, isTrue);
    expect(cubit.state.status, SgtinBatchLookupStatus.registered);
    expect(cubit.state.canSubmitSgtin, isTrue);
    expect(cubit.state.resolvedBatch, existing);
  });

  test('failed registration blocks SGTIN creation', () async {
    when(
      () => pharma.createBatch(any(), any()),
    ).thenThrow(ApiException(statusCode: 400, message: 'Invalid batch'));
    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);
    final ok = await cubit.registerBatch(
      batchLot: lot,
      manufactureDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2027, 1, 1),
    );
    expect(ok, isFalse);
    expect(cubit.state.status, SgtinBatchLookupStatus.notFound);
    expect(cubit.state.canSubmitSgtin, isFalse);
  });

  test('double tap does not create duplicate batches', () async {
    when(() => pharma.createBatch(any(), any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return existing;
    });
    cubit.onGtinChanged(gtinId: 1, gtinCode: gtinCode);

    final first = cubit.registerBatch(
      batchLot: lot,
      manufactureDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2027, 1, 1),
    );
    await Future<void>.delayed(Duration.zero);
    final second = await cubit.registerBatch(
      batchLot: lot,
      manufactureDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2027, 1, 1),
    );
    expect(second, isFalse);
    expect(await first, isTrue);
    verify(() => pharma.createBatch(any(), any())).called(1);
  });
}
