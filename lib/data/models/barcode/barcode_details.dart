import 'package:flutter/foundation.dart';

enum Gs1BarcodeType {
  sgtin,

  gtin,

  sscc,

  gln,

  unknown,
}

@immutable
class BarcodeDetails {

  final Gs1BarcodeType type;

  final String rawBarcode;

  final String gs1ElementString;

  final bool isValid;

  final String? gtin;

  final String? serial;

  final String? batchLot;

  final String? expiryRaw;

  final DateTime? expiry;

  final String? productionDateRaw;

  final DateTime? productionDate;

  final String? bestBeforeDateRaw;

  final DateTime? bestBeforeDate;

  final String? sscc;

  final String? contentGtin;

  final String? gln;

  final String? countryOfOrigin;

  final Map<String, String> allFields;

  const BarcodeDetails({
    required this.type,
    required this.rawBarcode,
    required this.gs1ElementString,
    required this.isValid,
    this.gtin,
    this.serial,
    this.batchLot,
    this.expiryRaw,
    this.expiry,
    this.productionDateRaw,
    this.productionDate,
    this.bestBeforeDateRaw,
    this.bestBeforeDate,
    this.sscc,
    this.contentGtin,
    this.gln,
    this.countryOfOrigin,
    required this.allFields,
  });

  bool get hasGtin => gtin != null;

  bool get isSgtin => type == Gs1BarcodeType.sgtin;

  bool get isSscc => type == Gs1BarcodeType.sscc;

  bool get isGln => type == Gs1BarcodeType.gln;

  String get summary {
    switch (type) {
      case Gs1BarcodeType.sgtin:
        final buf = StringBuffer('SGTIN — ${gtin ?? '-'}');
        if (serial != null) buf.write(' / S/N: $serial');
        if (batchLot != null) buf.write(' / Lot: $batchLot');
        return buf.toString();
      case Gs1BarcodeType.gtin:
        return 'GTIN — ${gtin ?? '-'}';
      case Gs1BarcodeType.sscc:
        return 'SSCC — ${sscc ?? '-'}';
      case Gs1BarcodeType.gln:
        return 'GLN — ${gln ?? '-'}';
      case Gs1BarcodeType.unknown:
        return 'Unknown barcode';
    }
  }

  String get typeLabel {
    switch (type) {
      case Gs1BarcodeType.sgtin:
        return 'SGTIN';
      case Gs1BarcodeType.gtin:
        return 'GTIN';
      case Gs1BarcodeType.sscc:
        return 'SSCC';
      case Gs1BarcodeType.gln:
        return 'GLN';
      case Gs1BarcodeType.unknown:
        return 'Unknown';
    }
  }

  List<MapEntry<String, String>> get displayRows {
    final rows = <MapEntry<String, String>>[];

    void add(String label, String? value) {
      if (value != null && value.isNotEmpty) {
        rows.add(MapEntry(label, value));
      }
    }

    switch (type) {
      case Gs1BarcodeType.sgtin:
      case Gs1BarcodeType.gtin:
        add('GTIN', gtin);
        add('S/N', serial);
        add('Batch/Lot', batchLot);
        add('Expiry', _formatDate(expiry, expiryRaw));
        add('Production Date', _formatDate(productionDate, productionDateRaw));
        add('Best Before', _formatDate(bestBeforeDate, bestBeforeDateRaw));
        add('Country of Origin', countryOfOrigin);
        add('GLN', gln);
      case Gs1BarcodeType.sscc:
        add('SSCC', sscc);
        add('Content GTIN', contentGtin);
        add('GLN', gln);
      case Gs1BarcodeType.gln:
        add('GLN', gln);
        add('Country of Origin', countryOfOrigin);
      case Gs1BarcodeType.unknown:
        add('Raw', rawBarcode);
    }

    return rows;
  }

  static String? _formatDate(DateTime? dt, String? raw) {
    if (dt != null) {
      return '${dt.year}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    }
    return raw;
  }

  @override
  String toString() => 'BarcodeDetails($summary)';
}
