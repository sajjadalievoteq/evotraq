import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// Normalizes raw scanner input through the shared GS1 barcode pipeline.
abstract final class Gs1ScanPipeline {
  Gs1ScanPipeline._();

  static ScanResult processScan(String rawBarcode) {
    final trimmed = rawBarcode.trim();
    if (trimmed.isEmpty) {
      return ScanResult.error(data: rawBarcode, error: 'Empty barcode data');
    }

    final details = extractBarcodeDetails(trimmed);
    final barcodeType = switch (details.type) {
      Gs1BarcodeType.sscc => 'SSCC',
      Gs1BarcodeType.sgtin => 'SGTIN',
      Gs1BarcodeType.gtin => 'GTIN',
      Gs1BarcodeType.gln => 'GLN',
      Gs1BarcodeType.unknown => null,
    };

    if (barcodeType == null &&
        !details.isValid &&
        !SsccFormat.isValidSscc(trimmed.replaceAll(RegExp(r'\D'), ''))) {
      return ScanResult.error(
        data: trimmed,
        error: 'Unrecognized GS1 barcode format',
      );
    }

    return ScanResult.success(
      data: trimmed,
      barcodeType: barcodeType ?? 'UNKNOWN',
      metadata: {
        'gs1Type': details.type.name,
        'gtin': details.gtin,
        'serial': details.serial,
        'sscc': details.sscc,
        'gln': details.gln,
        'isValidParse': details.isValid,
      },
    );
  }
}
