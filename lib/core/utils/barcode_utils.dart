import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';

export 'package:traqtrace_app/data/models/barcode/barcode_details.dart';

BarcodeDetails extractBarcodeDetails(String rawBarcode) {
  final parsed = Gs1Parser.parseBarcode(rawBarcode);

  final bool isValid = parsed['valid'] == true;
  final String gs1String =
      (parsed['gs1ElementString'] as String?) ?? rawBarcode;

  final rawMap = parsed['parsedData'];
  final Map<String, String> allFields = rawMap is Map
      ? Map<String, String>.fromEntries(
          rawMap.entries
              .map((e) => MapEntry(e.key.toString(), e.value.toString())),
        )
      : const {};

  final String? gtin        = parsed['GTIN']         as String?;
  final String? serial      = parsed['SERIAL']       as String?;
  final String? sscc        = parsed['SSCC']         as String?;
  final String? batchLot    = parsed['BATCH']        as String?;
  final String? contentGtin = parsed['CONTENT_GTIN'] as String?;
  final String? gln         = parsed['GLN']          as String?;
  final String? expiryRaw   = parsed['EXPIRY']       as String?;

  final String? prodDateRaw     = allFields['11'];
  final String? bestBeforeRaw   = allFields['15'];
  final String? countryOfOrigin = allFields['422'];

  final Gs1BarcodeType type;
  if (sscc != null && sscc.isNotEmpty) {
    type = Gs1BarcodeType.sscc;
  } else if (gtin != null && serial != null) {
    type = Gs1BarcodeType.sgtin;
  } else if (gtin != null) {
    type = Gs1BarcodeType.gtin;
  } else if (gln != null && gln.isNotEmpty) {
    type = Gs1BarcodeType.gln;
  } else {
    type = Gs1BarcodeType.unknown;
  }

  debugPrint('[extractBarcodeDetails] type=$type  raw=$rawBarcode');

  return BarcodeDetails(
    type: type,
    rawBarcode: rawBarcode,
    gs1ElementString: gs1String,
    isValid: isValid,
    gtin: gtin,
    serial: serial,
    batchLot: batchLot,
    expiryRaw: expiryRaw,
    expiry: _parseGs1Date(expiryRaw),
    productionDateRaw: prodDateRaw,
    productionDate: _parseGs1Date(prodDateRaw),
    bestBeforeDateRaw: bestBeforeRaw,
    bestBeforeDate: _parseGs1Date(bestBeforeRaw),
    sscc: sscc,
    contentGtin: contentGtin,
    gln: gln,
    countryOfOrigin: countryOfOrigin,
    allFields: allFields,
  );
}

DateTime? _parseGs1Date(String? yymmdd) {
  if (yymmdd == null || yymmdd.length != 6) return null;
  try {
    final year  = int.parse('20${yymmdd.substring(0, 2)}');
    final month = int.parse(yymmdd.substring(2, 4));
    final day   = int.parse(yymmdd.substring(4, 6));

    if (month < 1 || month > 12) return null;

    if (day == 0) {
      return DateTime(year, month + 1, 0);
    }
    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}
