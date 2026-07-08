class ProductSearchResult {
  const ProductSearchResult({
    required this.identifier,
    required this.displayName,
    required this.type,
    this.gtin,
    this.serialNumber,
    this.description,
  });

  final String identifier;
  final String displayName;
  final String type;
  final String? gtin;
  final String? serialNumber;
  final String? description;

  factory ProductSearchResult.fromBackendJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      identifier: json['identifier']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      gtin: json['gtin']?.toString(),
      serialNumber: json['serialNumber']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
