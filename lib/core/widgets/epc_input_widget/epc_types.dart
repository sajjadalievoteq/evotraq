enum EPCType {
  sgtin,
  sscc,
  gtin,
  unknown,
}

class EPCParseResult {
  const EPCParseResult({
    required this.type,
    required this.epc,
    required this.raw,
    required this.detectedFormat,
    this.gtin,
    this.serial,
    this.sscc,
    this.gcpLength,
    this.companyPrefix,
  });

  final EPCType type;
  final String epc;
  final String? gtin;
  final String? serial;
  final String? sscc;
  final int? gcpLength;
  final String? companyPrefix;
  final String raw;
  final String detectedFormat;

  String get typeLabel => switch (type) {
        EPCType.sgtin => 'SGTIN',
        EPCType.sscc => 'SSCC',
        EPCType.gtin => 'GTIN',
        EPCType.unknown => 'Unknown',
      };
}

class EPCParseException implements Exception {
  EPCParseException(this.message);

  final String message;

  @override
  String toString() => message;
}
