import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/models/automation_center/inbound_catalog.dart';
import 'package:traqtrace_app/data/services/automation_center/inbound_catalog_service.dart';
import 'package:traqtrace_app/features/automation_center/cubit/inbound_catalog_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/inbound_catalog_state.dart';

class _MockInboundCatalogService extends Mock implements InboundCatalogService {}

void main() {
  late _MockInboundCatalogService service;

  final catalog = InboundCatalog(
    schemaVersion: 1,
    generatedAt: '2026-08-13T00:00:00Z',
    categories: const [
      InboundCatalogCategory(
        id: 'operations',
        title: 'Operations',
        description: 'Ops',
        order: 40,
        endpoints: [],
      ),
    ],
  );

  setUp(() {
    service = _MockInboundCatalogService();
  });

  blocTest<InboundCatalogCubit, InboundCatalogState>(
    'load emits loading then success',
    build: () {
      when(() => service.fetchCatalog()).thenAnswer((_) async => catalog);
      return InboundCatalogCubit(service: service);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.loading,
      ),
      isA<InboundCatalogState>()
          .having((s) => s.status, 'status', InboundCatalogStatus.success)
          .having((s) => s.catalog, 'catalog', catalog),
    ],
  );

  blocTest<InboundCatalogCubit, InboundCatalogState>(
    'load emits loading then error',
    build: () {
      when(() => service.fetchCatalog()).thenThrow(Exception('network'));
      return InboundCatalogCubit(service: service);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.loading,
      ),
      isA<InboundCatalogState>()
          .having((s) => s.status, 'status', InboundCatalogStatus.error)
          .having((s) => s.error, 'error', contains('network')),
    ],
  );

  blocTest<InboundCatalogCubit, InboundCatalogState>(
    'selectCategory uses stable category id',
    build: () {
      when(() => service.fetchCatalog()).thenAnswer((_) async => catalog);
      return InboundCatalogCubit(service: service);
    },
    act: (cubit) async {
      await cubit.load();
      cubit.selectCategory('operations');
    },
    expect: () => [
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.loading,
      ),
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.success,
      ),
      isA<InboundCatalogState>().having(
        (s) => s.selectedCategoryId,
        'selectedCategoryId',
        'operations',
      ),
    ],
  );

  test('downloadPostmanCollection forwards stable category id', () async {
    when(
      () => service.downloadPostmanCollection(categoryId: 'operations'),
    ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
    final cubit = InboundCatalogCubit(service: service);
    final bytes = await cubit.downloadPostmanCollection('operations');
    expect(bytes, [1, 2, 3]);
    verify(
      () => service.downloadPostmanCollection(categoryId: 'operations'),
    ).called(1);
  });

  blocTest<InboundCatalogCubit, InboundCatalogState>(
    'second load without force is a no-op when catalog already loaded',
    build: () {
      when(() => service.fetchCatalog()).thenAnswer((_) async => catalog);
      return InboundCatalogCubit(service: service);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.load();
    },
    expect: () => [
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.loading,
      ),
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => service.fetchCatalog()).called(1);
    },
  );

  blocTest<InboundCatalogCubit, InboundCatalogState>(
    'force reload refetches even after success',
    build: () {
      when(() => service.fetchCatalog()).thenAnswer((_) async => catalog);
      return InboundCatalogCubit(service: service);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.load(force: true);
    },
    expect: () => [
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.loading,
      ),
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.success,
      ),
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.loading,
      ),
      isA<InboundCatalogState>().having(
        (s) => s.status,
        'status',
        InboundCatalogStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => service.fetchCatalog()).called(2);
    },
  );
}
