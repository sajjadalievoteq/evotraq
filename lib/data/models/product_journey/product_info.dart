/// Product information extracted from ILMD or master data.
class ProductInfo {
  const ProductInfo({
    this.gtin,
    this.description,
    this.batchLotNumber,
    this.manufacturingDate,
    this.expiryDate,
    this.bestBeforeDate,
    this.manufacturer,
  });

  final String? gtin;
  final String? description;
  final String? batchLotNumber;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final String? manufacturer;

  factory ProductInfo.fromILMD(Map<String, dynamic>? ilmd) {
    if (ilmd == null) return const ProductInfo();

    return ProductInfo(
      gtin: ilmd['gtin'] as String?,
      description: ilmd['itemDescription'] as String?,
      batchLotNumber: ilmd['lotNumber'] as String?,
      manufacturingDate: ilmd['manufacturingDate'] != null
          ? _parseDate(ilmd['manufacturingDate'])
          : null,
      expiryDate: ilmd['itemExpirationDate'] != null
          ? _parseDate(ilmd['itemExpirationDate'])
          : null,
      bestBeforeDate: ilmd['bestBeforeDate'] != null
          ? _parseDate(ilmd['bestBeforeDate'])
          : null,
    );
  }

  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    final dateStr = dateValue.toString();
    try {
      if (dateStr.length == 10 && dateStr.contains('-')) {
        return DateTime.parse('${dateStr}T00:00:00Z');
      }
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
