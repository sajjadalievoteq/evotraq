import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/ndc_gtin_converter.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';

void main() {
  group('Gs1DateUtils', () {
    test('parses YYMMDD and day 00 as end of month', () {
      expect(Gs1DateUtils.parseYymmdd('251231'), DateTime(2025, 12, 31));
      expect(Gs1DateUtils.parseYymmdd('250200'), DateTime(2025, 2, 28));
      expect(Gs1DateUtils.parseYymmdd('240200'), DateTime(2024, 2, 29));
      expect(Gs1DateUtils.toIsoDate('251231'), '2025-12-31');
      expect(Gs1DateUtils.validateYymmdd('250231'), isNotNull);
      expect(Gs1DateUtils.validateYymmdd('251231'), isNull);
    });
  });

  group('CheckDigitUtils extended keys', () {
    test('GTIN-13 and SSCC round-trip check digit', () {
      // Classic GS1 example GTIN-13: 4006381333931
      expect(CheckDigitUtils.validateGtin('4006381333931'), isNull);
      expect(CheckDigitUtils.isValidMod10('4006381333931'), isTrue);
      final body = '400638133393';
      expect(CheckDigitUtils.calculateMod10String(body), '1');
    });

    test('rejects bad check digit', () {
      expect(CheckDigitUtils.validateGtin('4006381333932'), isNotNull);
    });
  });

  group('NdcGtinConverter', () {
    test('5-4-2 11-digit NDC → GTIN-14 with valid check digit', () {
      final gtin = NdcGtinConverter.ndcToGtin14('12345678901', format: '5-4-2');
      expect(gtin, isNotNull);
      expect(gtin!.length, 14);
      expect(gtin.startsWith('003'), isTrue);
      expect(CheckDigitUtils.validateGtin(gtin), isNull);
      final back = NdcGtinConverter.gtin14ToNdc11(gtin);
      expect(back, isNotNull);
    });
  });

  group('Gs1ToolKind deep-link aliases', () {
    test('legacy ids map to tools and modes', () {
      String? mode;
      expect(
        Gs1ToolKindX.fromId('checkdigit', onMode: (m) => mode = m),
        Gs1ToolKind.validate,
      );
      expect(mode, 'check-digit');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('epc', onMode: (m) => mode = m),
        Gs1ToolKind.convert,
      );
      expect(mode, 'epc');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('digitallink', onMode: (m) => mode = m),
        Gs1ToolKind.convert,
      );
      expect(mode, 'digital-link');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('batch', onMode: (m) => mode = m),
        Gs1ToolKind.validate,
      );
      expect(mode, 'batch');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('pharma-datamatrix', onMode: (m) => mode = m),
        Gs1ToolKind.barcode,
      );
      expect(mode, 'pharma');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('cheat-sheet', onMode: (m) => mode = m),
        Gs1ToolKind.aiElement,
      );
      expect(mode, 'table');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('element-string', onMode: (m) => mode = m),
        Gs1ToolKind.aiElement,
      );
      expect(mode, 'convert');

      mode = null;
      expect(
        Gs1ToolKindX.fromId('schema-validation', onMode: (m) => mode = m),
        Gs1ToolKind.serializeConvert,
      );
      expect(mode, 'validate');
    });

    test('rail has seven identifier tools + one serialization tool', () {
      expect(Gs1ToolKindX.toolKinds.length, 7);
      expect(Gs1ToolKindX.serializationKinds.length, 1);
      expect(
        Gs1ToolKindX.serializationKinds,
        isNot(contains(Gs1ToolKind.serializeExport)),
      );
      expect(
        Gs1ToolKindX.serializationKinds,
        isNot(contains(Gs1ToolKind.serializeImport)),
      );
    });
  });
}
