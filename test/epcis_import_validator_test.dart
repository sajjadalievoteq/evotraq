import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_template.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validator.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String bundledTemplate;

  setUpAll(() async {
    bundledTemplate =
        await rootBundle.loadString(EpcisImportTemplate.assetPath);
  });

  Map<String, dynamic> filledTemplate() {
    final doc = jsonDecode(bundledTemplate) as Map<String, dynamic>;
    doc['creationDate'] = '2026-01-15T10:00:00Z';
    doc['id'] = 'urn:uuid:aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    final events =
        (doc['epcisBody'] as Map)['eventList'] as List<dynamic>;
    final objectEvent = Map<String, dynamic>.from(events[0] as Map);
    objectEvent['eventTime'] = '2026-01-15T10:00:00Z';
    objectEvent['eventTimeZoneOffset'] = '+00:00';
    objectEvent['eventID'] =
        'urn:uuid:11111111-1111-4111-8111-111111111111';
    objectEvent['epcList'] = [
      'https://id.gs1.org/01/00614141073467/21/SERIAL1',
    ];
    objectEvent['ilmd'] = {
      'cbvmda:lotNumber': 'LOT-1',
      'cbvmda:itemExpirationDate': '2027-01-01',
      'cbvmda:manufacturerOfGoods': 'Acme Pharma',
    };
    final agg = Map<String, dynamic>.from(events[1] as Map);
    agg['eventTime'] = '2026-01-15T11:00:00Z';
    agg['eventTimeZoneOffset'] = '+00:00';
    agg['eventID'] = 'urn:uuid:22222222-2222-4222-8222-222222222222';
    agg['parentID'] = 'https://id.gs1.org/00/106141412345678908';
    agg['childEPCs'] = [
      'https://id.gs1.org/01/00614141073467/21/SERIAL1',
    ];
    (doc['epcisBody'] as Map)['eventList'] = [objectEvent, agg];
    return doc;
  }

  group('EpcisImportValidator', () {
    test('bundled template fails content gate on placeholders', () {
      final result = EpcisImportValidator.validate(bundledTemplate);
      expect(result.isValid, isFalse);
      expect(result.forGate(EpcisImportGate.content), isNotEmpty);
      expect(
        result.issues.any((i) => i.reason.contains('REPLACE_WITH_')),
        isTrue,
      );
    });

    test('filled template passes all gates', () {
      final result =
          EpcisImportValidator.validate(jsonEncode(filledTemplate()));
      expect(result.summarize(), result.isValid ? isNotEmpty : result.summarize());
      expect(result.isValid, isTrue, reason: result.summarize());
      expect(result.document, isNotNull);
    });

    test('CSV / plain text rejected at format gate', () {
      final csv = EpcisImportValidator.validate('a,b,c\n1,2,3');
      expect(csv.forGate(EpcisImportGate.format), isNotEmpty);
      expect(csv.issues.first.reason, contains('download the template'));

      final plain = EpcisImportValidator.validate('not json at all');
      expect(plain.forGate(EpcisImportGate.format), isNotEmpty);
    });

    test('arbitrary JSON rejected at format gate', () {
      final result = EpcisImportValidator.validate('{"foo":1}');
      expect(result.isValid, isFalse);
      expect(result.forGate(EpcisImportGate.format), isNotEmpty);
    });

    test('missing required field rejected at schema gate', () {
      final doc = filledTemplate();
      final events =
          (doc['epcisBody'] as Map)['eventList'] as List<dynamic>;
      final objectEvent = Map<String, dynamic>.from(events[0] as Map);
      objectEvent.remove('action');
      (doc['epcisBody'] as Map)['eventList'] = [objectEvent];
      final result = EpcisImportValidator.validate(jsonEncode(doc));
      expect(result.forGate(EpcisImportGate.schema), isNotEmpty);
      expect(
        result.issues.any((i) => i.path.contains('action')),
        isTrue,
      );
    });

    test('wrong event type rejected at schema gate', () {
      final doc = filledTemplate();
      final events =
          (doc['epcisBody'] as Map)['eventList'] as List<dynamic>;
      final objectEvent = Map<String, dynamic>.from(events[0] as Map);
      objectEvent['type'] = 'TransactionEvent';
      (doc['epcisBody'] as Map)['eventList'] = [objectEvent];
      final result = EpcisImportValidator.validate(jsonEncode(doc));
      expect(result.forGate(EpcisImportGate.schema), isNotEmpty);
    });

    test('invalid GTIN check digit rejected at content gate', () {
      final doc = filledTemplate();
      final events =
          (doc['epcisBody'] as Map)['eventList'] as List<dynamic>;
      final objectEvent = Map<String, dynamic>.from(events[0] as Map);
      objectEvent['epcList'] = [
        'https://id.gs1.org/01/00614141073465/21/BADSERIAL',
      ];
      (doc['epcisBody'] as Map)['eventList'] = [objectEvent];
      final result = EpcisImportValidator.validate(jsonEncode(doc));
      expect(result.forGate(EpcisImportGate.content), isNotEmpty);
      expect(
        result.issues.any((i) => i.reason.toLowerCase().contains('check digit')),
        isTrue,
        reason: result.summarize(),
      );
    });

    test('bad ISO date rejected at content gate', () {
      final doc = filledTemplate();
      final events =
          (doc['epcisBody'] as Map)['eventList'] as List<dynamic>;
      final objectEvent = Map<String, dynamic>.from(events[0] as Map);
      objectEvent['eventTime'] = 'not-a-date';
      (doc['epcisBody'] as Map)['eventList'] = [objectEvent];
      final result = EpcisImportValidator.validate(jsonEncode(doc));
      expect(result.forGate(EpcisImportGate.content), isNotEmpty);
    });

    test('unknown extra field rejected at schema gate', () {
      final doc = filledTemplate();
      doc['extraTopLevel'] = true;
      final result = EpcisImportValidator.validate(jsonEncode(doc));
      expect(result.forGate(EpcisImportGate.schema), isNotEmpty);
      expect(
        result.issues.any((i) => i.path.contains('extraTopLevel')),
        isTrue,
      );
    });

    test('template asset is EPCISDocument JSON-LD', () {
      final doc = jsonDecode(bundledTemplate) as Map<String, dynamic>;
      expect(doc['@context'], EpcisImportTemplate.contextUri);
      expect(doc['type'], 'EPCISDocument');
      expect(doc['schemaVersion'], '2.0');
      expect(doc['epcisBody'], isA<Map>());
      final list = (doc['epcisBody'] as Map)['eventList'] as List;
      expect(list.length, 2);
      expect(list[0]['type'], 'ObjectEvent');
      expect(list[1]['type'], 'AggregationEvent');
      expect(list[0].containsKey('action'), isTrue);
      expect(list[0].containsKey('epcList'), isTrue);
      expect(list[1].containsKey('parentID'), isTrue);
    });
  });
}
