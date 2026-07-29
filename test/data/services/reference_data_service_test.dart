import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/data/services/reference_data_service.dart';

class _MockGtinService extends Mock implements GTINService {}

class _MockSgtinService extends Mock implements SGTINService {}

class _MockSsccService extends Mock implements SSCCService {}

class _MockGlnService extends Mock implements GLNService {}

void main() {
  late _MockGlnService glnService;
  late ReferenceDataService service;

  setUp(() {
    glnService = _MockGlnService();
    service = ReferenceDataService(
      gtinService: _MockGtinService(),
      sgtinService: _MockSgtinService(),
      ssccService: _MockSsccService(),
      glnService: glnService,
    );
  });

  test('shares the cached in-flight GLN future', () async {
    const code = '0614141000005';
    final gln = GLN.fromCode(code);
    when(() => glnService.getGLNByCode(code)).thenAnswer((_) async => gln);

    final first = service.resolveGln(code);
    final second = service.resolveGln(code);

    expect(identical(first, second), isTrue);
    expect(await first, gln);
    verify(() => glnService.getGLNByCode(code)).called(1);
  });

  test('caches null after a failed GLN lookup', () async {
    const code = '0614141000005';
    when(() => glnService.getGLNByCode(code)).thenThrow(Exception('offline'));

    expect(await service.resolveGln(code), isNull);
    expect(await service.resolveGln(code), isNull);
    verify(() => glnService.getGLNByCode(code)).called(1);
  });

  test('evicts the least recently used GLN entry at the cache limit', () async {
    when(() => glnService.getGLNByCode(any())).thenAnswer(
      (invocation) async =>
          GLN.fromCode(invocation.positionalArguments[0] as String),
    );

    for (var i = 0; i < 256; i++) {
      await service.resolveGln(i.toString().padLeft(13, '0'));
    }

    await service.resolveGln('9999999999999');
    await service.resolveGln('0000000000000');

    verify(() => glnService.getGLNByCode('0000000000000')).called(2);
    verify(() => glnService.getGLNByCode('9999999999999')).called(1);
  });
}
