import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';

class _MockGLNService extends Mock implements GLNService {}

GLN _summary({
  required String code,
  required String name,
  bool active = true,
  String? city,
  String? contact,
}) {
  return GLN.fromJson({
    'glnCode': code,
    'locationName': name,
    'city': city ?? 'Dubai',
    'stateProvince': 'DU',
    'contactName': contact,
    'locationStatus': active ? 'active' : 'inactive',
    'operatingStatus': active ? 'ACTIVE' : 'INACTIVE',
  });
}

void main() {
  late _MockGLNService glnService;
  late GlnPickerCatalog catalog;

  setUp(() {
    glnService = _MockGLNService();
    catalog = GlnPickerCatalog(glnService: glnService);
  });

  test('loads picker summaries and exposes active filter', () async {
    when(() => glnService.fetchPickerSummaries()).thenAnswer(
      (_) async => [
        _summary(code: '0614141000003', name: 'Plant A'),
        _summary(code: '0614141000010', name: 'Plant B', active: false),
      ],
    );

    final items = await catalog.ensureLoaded();

    expect(items, hasLength(2));
    expect(catalog.activeItems, hasLength(1));
    expect(catalog.activeItems.single.glnCode, '0614141000003');
    expect(catalog.usedSummaryEndpoint, isTrue);
    verify(() => glnService.fetchPickerSummaries()).called(1);
    verifyNever(() => glnService.fetchAllGLNs());
  });

  test('falls back to full list when summaries endpoint is missing', () async {
    when(() => glnService.fetchPickerSummaries()).thenThrow(
      ApiException(statusCode: 404, message: 'missing'),
    );
    when(() => glnService.fetchAllGLNs()).thenAnswer(
      (_) async => [_summary(code: '0614141000003', name: 'Plant A')],
    );

    final items = await catalog.ensureLoaded();

    expect(items, hasLength(1));
    expect(catalog.usedSummaryEndpoint, isFalse);
    verify(() => glnService.fetchAllGLNs()).called(1);
  });

  test('coalesces concurrent ensureLoaded calls', () async {
    when(() => glnService.fetchPickerSummaries()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return [_summary(code: '0614141000003', name: 'Plant A')];
    });

    final results = await Future.wait([
      catalog.ensureLoaded(),
      catalog.ensureLoaded(),
      catalog.ensureLoaded(),
    ]);

    expect(results.every((r) => r.length == 1), isTrue);
    verify(() => glnService.fetchPickerSummaries()).called(1);
  });

  test('clear drops cache for logout', () async {
    when(() => glnService.fetchPickerSummaries()).thenAnswer(
      (_) async => [_summary(code: '0614141000003', name: 'Plant A')],
    );
    await catalog.ensureLoaded();
    expect(catalog.isLoaded, isTrue);

    catalog.clear();

    expect(catalog.isLoaded, isFalse);
    expect(catalog.items, isEmpty);
  });

  test('search fields used by picker remain populated from summaries', () async {
    when(() => glnService.fetchPickerSummaries()).thenAnswer(
      (_) async => [
        _summary(
          code: '0614141000003',
          name: 'Warehouse North',
          contact: 'Alice',
          city: 'Abu Dhabi',
        ),
      ],
    );

    final gln = (await catalog.ensureLoaded()).single;
    expect(gln.glnCode, '0614141000003');
    expect(gln.locationName, 'Warehouse North');
    expect(gln.contactName, 'Alice');
    expect(gln.city, 'Abu Dhabi');
    expect(gln.stateProvince, 'DU');
    expect(gln.active, isTrue);
  });
}
