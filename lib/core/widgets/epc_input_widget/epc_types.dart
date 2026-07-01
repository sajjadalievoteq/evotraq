/// Canonical EPC identifier types supported by [EPCInputWidget].
enum EPCType {
  sgtin,
  sscc,
  gtin,
  unknown,
}

/// Result of parsing a barcode or EPC input string via [parseToEPC].
class EPCParseResult {
  const EPCParseResult({
    required this.type,
    required this.epc,
    required this.raw,
    required this.detectedFormat,
    this.gtin,
    this.serial,
    this.sscc,
  });

  final EPCType type;
  final String epc;
  final String? gtin;
  final String? serial;
  final String? sscc;
  final String raw;
  final String detectedFormat;

  String get typeLabel => switch (type) {
        EPCType.sgtin => 'SGTIN',
        EPCType.sscc => 'SSCC',
        EPCType.gtin => 'GTIN',
        EPCType.unknown => 'Unknown',
      };
}

/// Thrown when [parseToEPC] cannot recognise or validate the input.
class EPCParseException implements Exception {
  EPCParseException(this.message);

  final String message;

  @override
  String toString() => message;
}
