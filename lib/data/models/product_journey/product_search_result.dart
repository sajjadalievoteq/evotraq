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
}
