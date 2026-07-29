import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_ai_table.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_element_string_builder.dart';
import 'package:traqtrace_app/core/utils/gs1/ndc_gtin_converter.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

void main() {
  setUp(() {
    Gs1AiTable.seedForTest(Gs1AiTable.embeddedSeed);
  });

  group('Gs1DateUtils', () {
    test('day 00 is end of month and leap years', () {
      expect(Gs1DateUtils.parseYymmdd('250200'), DateTime(2025, 2, 28));
      expect(Gs1DateUtils.parseYymmdd('240200'), DateTime(2024, 2, 29));
      expect(Gs1DateUtils.toIsoDate('251231'), '2025-12-31');
      expect(Gs1DateUtils.formatYymmdd(DateTime(2025, 12, 31)), '251231');
      expect(Gs1DateUtils.validateYymmdd('250231'), isNotNull);
    });
  });

  group('Gs1AiTable SSOT for parser', () {
    test('fixed lengths match legacy AI+value totals', () {
      expect(Gs1AiTable.fixedAiPlusValueLength('01'), 16);
      expect(Gs1AiTable.fixedAiPlusValueLength('00'), 20);
      expect(Gs1AiTable.fixedAiPlusValueLength('17'), 8);
      expect(Gs1AiTable.isFixedLength('21'), isFalse);
      expect(Gs1AiTable.titleFor('01'), 'GTIN');
    });

    test('parser human titles come from Gs1AiTable', () {
      final result = GS1BarcodeParser.parseGS1Barcode(
        '(01)18902411114026(17)210228(10)AFG8007A(21)0SIATXTA39607034P',
      );
      expect(result['valid'], isTrue);
      expect(result['GTIN'], '18902411114026');
      expect(result['BATCH'], 'AFG8007A');
      expect(result['EXPIRY_FORMATTED'], '2021-02-28');
    });

    test('pharma element string builder order 01/21/17/10', () {
      final built = Gs1ElementStringBuilder.build({
        '01': '18902411114026',
        '21': 'ABC',
        '17': '251231',
        '10': 'LOT1',
      });
      expect(built.human, '(01)18902411114026(21)ABC(17)251231(10)LOT1');
    });
  });

  group('CheckDigitUtils extended keys', () {
    test('GSRN / GDTI / GRAI mod-10', () {
      // Build valid bodies then append computed check digit
      const gsrnBody = '06141411234567890'; // 17 digits
      final gsrn = '$gsrnBody${CheckDigitUtils.calculateMod10String(gsrnBody)}';
      expect(CheckDigitUtils.validateGsrn(gsrn), isNull);

      const gdtiBody = '061414112345'; // 12
      final gdti = '$gdtiBody${CheckDigitUtils.calculateMod10String(gdtiBody)}';
      expect(CheckDigitUtils.validateGdti(gdti), isNull);

      const graiBody = '0614141123456'; // 13
      final grai = '$graiBody${CheckDigitUtils.calculateMod10String(graiBody)}';
      expect(CheckDigitUtils.validateGrai(grai), isNull);

      expect(CheckDigitUtils.validateGrai('${graiBody}0'), isNotNull);
      expect(CheckDigitUtils.validateGiai('ASSET-1'), isNull);
      expect(CheckDigitUtils.validateCpid('CPID-99'), isNull);
    });
  });

  group('GTIN packaging check digit', () {
    test('GTIN-13 body → GTIN-14 with indicator', () {
      // Classic: 4006381333931 → body 400638133393 → pad to 13 with indicator 0
      const gtin13 = '4006381333931';
      expect(CheckDigitUtils.validateGtin(gtin13), isNull);
      final body12 = gtin13.substring(0, 12);
      final body13 = '0$body12';
      final gtin14 = '$body13${CheckDigitUtils.calculateMod10String(body13)}';
      expect(gtin14.length, 14);
      expect(CheckDigitUtils.validateGtin(gtin14), isNull);
      expect(gtin14[0], '0');
    });
  });

  group('SSCC builder check digit', () {
    test('extension + gcp + serial → valid SSCC-18', () {
      const ext = '0';
      const gcp = '0614141'; // 7
      const serial = '123456789'; // 9 → 1+7+9=17
      final body = '$ext$gcp$serial';
      expect(body.length, 17);
      final full = '$body${CheckDigitUtils.calculateMod10String(body)}';
      expect(CheckDigitUtils.validateSscc(full), isNull);
    });
  });

  group('Digital Link ⇄ element string', () {
    test('element string with 01+21 converts to Digital Link', () {
      const es = '(01)09506000134352(21)ABC123';
      final uri = EPCURIConverter.convertToEPCUri(es);
      expect(uri, isNotNull);
      expect(uri!, contains('01'));
      final gtin = EPCURIConverter.extractGTINFromEPCUri(uri);
      final serial = EPCURIConverter.extractSerialFromEPCUri(uri);
      expect(gtin, isNotNull);
      expect(serial, 'ABC123');
    });
  });

  group('NDC ↔ GTIN', () {
    test('both directions', () {
      final gtin = NdcGtinConverter.ndcToGtin14('12345678901', format: '5-4-2');
      expect(gtin, isNotNull);
      expect(CheckDigitUtils.validateGtin(gtin), isNull);
      final back = NdcGtinConverter.gtin14ToNdc11(gtin);
      expect(back, isNotNull);
      expect(back!.length, 11);

      final from10 = NdcGtinConverter.ndcToGtin14('1234567890', format: '5-4-1');
      expect(from10, isNotNull);
      expect(CheckDigitUtils.validateGtin(from10), isNull);
    });
  });
}
