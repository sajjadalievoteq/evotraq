import 'package:flutter/foundation.dart';

/// The type of GS1 identifier found in the barcode.
enum Gs1BarcodeType {
  /// GTIN + serial number (AI 01 + AI 21). The primary pharma barcode type.
  sgtin,

  /// GTIN only — no serial number (AI 01 without AI 21).
  gtin,

  /// Serial Shipping Container Code (AI 00). Used on outer cases/pallets.
  sscc,

  /// Global Location Number (AI 414). Identifies a physical location.
  gln,

  /// Barcode could not be decoded into a recognised GS1 type.
  unknown,
}

/// Strongly-typed result of decoding a GS1 barcode.
///
/// Obtain via [extractBarcodeDetails] from `package:traqtrace_app/core/utils/barcode_utils.dart`.
@immutable
class BarcodeDetails {
  // ── Core ─────────────────────────────────────────────────────────────

  /// Detected barcode type.
  final Gs1BarcodeType type;

  /// The original string as scanned.
  final String rawBarcode;

  /// Normalised GS1 element string with AIs in parentheses,
  /// e.g. `(01)12345678901234(17)260101(10)LOT1(21)SN001`.
  final String gs1ElementString;

  /// Whether the parser could successfully decode the barcode.
  final bool isValid;

  // ── SGTIN / GTIN fields (AI 01 family) ───────────────────────────────

  /// 14-digit GTIN (AI 01). Present for [Gs1BarcodeType.sgtin] and
  /// [Gs1BarcodeType.gtin].
  final String? gtin;

  /// Serial number (AI 21). Present for [Gs1BarcodeType.sgtin].
  final String? serial;

  /// Batch / lot number (AI 10).
  final String? batchLot;

  /// Raw expiry date string in YYMMDD format (AI 17).
  final String? expiryRaw;

  /// Parsed expiry date. Day `00` in the barcode means the last day of
  /// the month (GS1 spec §7.12).
  final DateTime? expiry;

  /// Raw production / manufacture date in YYMMDD format (AI 11).
  final String? productionDateRaw;

  /// Parsed production date.
  final DateTime? productionDate;

  /// Raw best-before date in YYMMDD format (AI 15).
  final String? bestBeforeDateRaw;

  /// Parsed best-before date.
  final DateTime? bestBeforeDate;

  // ── SSCC fields (AI 00) ───────────────────────────────────────────────

  /// 18-digit SSCC (AI 00). Present for [Gs1BarcodeType.sscc].
  final String? sscc;

  /// Content GTIN within an SSCC (AI 02), if encoded.
  final String? contentGtin;

  // ── Other standard GS1 AIs ────────────────────────────────────────────

  /// Global Location Number (AI 414).
  final String? gln;

  /// ISO 3166-1 alpha-3 country of origin (AI 422).
  final String? countryOfOrigin;

  /// Every raw AI→value pair decoded from the barcode.
  /// Keys are the AI code strings (`'01'`, `'10'`, `'21'`, etc.).
  final Map<String, String> allFields;

  // ─────────────────────────────────────────────────────────────────────

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

  // ── Convenience getters ───────────────────────────────────────────────

  /// `true` when the barcode carries a GTIN (either SGTIN or class-level GTIN).
  bool get hasGtin => gtin != null;

  /// `true` when the barcode is a fully serialised SGTIN.
  bool get isSgtin => type == Gs1BarcodeType.sgtin;

  /// `true` when the barcode is an SSCC.
  bool get isSscc => type == Gs1BarcodeType.sscc;

  /// `true` when the barcode is a GLN.
  bool get isGln => type == Gs1BarcodeType.gln;

  /// One-line summary suitable for display in lists / tooltips.
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

  /// Display-ready label for a type chip.
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

  /// All non-null detail rows as label→value pairs, in display order.
  /// Drop straight into a `ListView` or `Column`.
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
