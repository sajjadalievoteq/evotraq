import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_readiness_checker.dart';

class _MockGlnService extends Mock implements GLNService {}

class _MockSgtinService extends Mock implements SGTINService {}

class _MockSsccService extends Mock implements SSCCService {}

void main() {
  const locationGln = '0614141123452';
  const parentSsccCode = '061414112345678905';
  const parentUri = 'urn:epc:id:sscc:0614141.1234567890';
  const childUri = 'urn:epc:id:sgtin:0614141.107346.2024';
  final now = DateTime.utc(2024, 1, 1);

  late _MockGlnService glnService;
  late _MockSgtinService sgtinService;
  late _MockSsccService ssccService;
  late AggregationPharmaReadinessChecker checker;

  SSCC parentSscc({required LogisticUnitStatus status}) {
    return SSCC(
      ssccCode: parentSsccCode,
      unitType: UnitType.PALLET,
      status: status,
      commissionedAt: now,
      currentBizlocationGln: locationGln,
      currentCustodianGln: locationGln,
      createdAt: now,
      updatedAt: now,
    );
  }

  SGTIN child({required ItemStatus status}) {
    return SGTIN(
      id: '1',
      gtinCode: '00614141107346',
      serialNumber: '2024',
      status: status,
      createdAt: now,
      commissionedAt: now,
    );
  }

  setUp(() {
    glnService = _MockGlnService();
    sgtinService = _MockSgtinService();
    ssccService = _MockSsccService();
    checker = AggregationPharmaReadinessChecker(
      glnService: glnService,
      sgtinService: sgtinService,
      ssccService: ssccService,
    );

    when(
      () => glnService.getGLNByCode(any()),
    ).thenAnswer((_) async => GLN.fromCode(locationGln));
  });

  group('AggregationPharmaReadinessChecker', () {
    test('ADD rejects EXCEPTION children with packing terminology', () async {
      when(
        () => ssccService.getSSCCByCode(any()),
      ).thenAnswer((_) async => parentSscc(status: LogisticUnitStatus.ACTIVE));
      when(
        () => sgtinService.getSGTINBySerialNumber(any()),
      ).thenAnswer((_) async => child(status: ItemStatus.EXCEPTION));

      final issues = await checker.findIssues(
        eventLocationGln: locationGln,
        action: 'ADD',
        parentEpcUri: parentUri,
        childEpcUris: [childUri],
      );

      expect(issues, isNotEmpty);
      expect(
        issues.any((i) => i.toLowerCase().contains('cannot be packed')),
        isTrue,
      );
    });

    test(
      'DELETE allows EXCEPTION child when actively aggregated under parent',
      () async {
        when(() => ssccService.getSSCCByCode(any())).thenAnswer(
          (_) async => parentSscc(status: LogisticUnitStatus.ACTIVE),
        );
        when(() => ssccService.getAggregationLinksByCode(any())).thenAnswer(
          (_) async => [
            SsccAggregationLink(
              parentSsccCode: parentSsccCode,
              childEpc: childUri,
              childKind: 'SGTIN',
              active: true,
            ),
          ],
        );
        when(
          () => sgtinService.getSGTINBySerialNumber(any()),
        ).thenAnswer((_) async => child(status: ItemStatus.EXCEPTION));

        final issues = await checker.findIssues(
          eventLocationGln: locationGln,
          action: 'DELETE',
          parentEpcUri: parentUri,
          childEpcUris: [childUri],
        );

        expect(issues, isEmpty);
        expect(
          issues.join(' ').toLowerCase().contains('cannot be packed'),
          isFalse,
        );
        expect(
          issues.join(' ').toLowerCase().contains('packing location'),
          isFalse,
        );
      },
    );

    test('DELETE rejects child not aggregated under parent', () async {
      when(
        () => ssccService.getSSCCByCode(any()),
      ).thenAnswer((_) async => parentSscc(status: LogisticUnitStatus.ACTIVE));
      when(
        () => ssccService.getAggregationLinksByCode(any()),
      ).thenAnswer((_) async => const <SsccAggregationLink>[]);
      when(
        () => sgtinService.getSGTINBySerialNumber(any()),
      ).thenAnswer((_) async => child(status: ItemStatus.EXCEPTION));

      final issues = await checker.findIssues(
        eventLocationGln: locationGln,
        action: 'DELETE',
        parentEpcUri: parentUri,
        childEpcUris: [childUri],
      );

      expect(issues, isNotEmpty);
      expect(issues.any((i) => i.contains('not currently aggregated')), isTrue);
      expect(
        issues.join(' ').toLowerCase().contains('cannot be packed'),
        isFalse,
      );
      expect(issues.join(' ').toLowerCase().contains('packing'), isFalse);
    });
  });
}
