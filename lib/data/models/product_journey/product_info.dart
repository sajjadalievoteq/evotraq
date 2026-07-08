class ProductInfo {
  const ProductInfo({
    this.gtin,
    this.description,
    this.batchLotNumber,
    this.manufacturingDate,
    this.expiryDate,
    this.bestBeforeDate,
    this.manufacturer,
    this.identifierType,
    this.status,
    this.currentLocationGLN,
    this.currentLocationName,
    this.serialNumber,
    this.tradeItemDescription,
    this.functionalName,
    this.manufacturerGLN,
    this.packagingLevel,
    this.packagingType,
    this.regulatoryMarket,
    this.dosageForm,
    this.strength,
    this.strengthUnit,
    this.routeOfAdministration,
    this.atcCode,
    this.mahName,
    this.mahGLN,
    this.regulatedProductName,
    this.ndcNumber,
    this.sscc,
    this.unitType,
    this.containerType,
    this.parentSSCC,
    this.itemCount,
    this.containedGtin,
    this.containedBatch,
    this.containedExpiry,
    this.childSgtins,
    this.childSsccs,
    this.purchaseOrderNumber,
    this.ginc,
  });

  final String? gtin;
  final String? description;
  final String? batchLotNumber;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final String? manufacturer;
  final String? identifierType;
  final String? status;
  final String? currentLocationGLN;
  final String? currentLocationName;
  final String? serialNumber;
  final String? tradeItemDescription;
  final String? functionalName;
  final String? manufacturerGLN;
  final String? packagingLevel;
  final String? packagingType;
  final String? regulatoryMarket;
  final String? dosageForm;
  final String? strength;
  final String? strengthUnit;
  final String? routeOfAdministration;
  final String? atcCode;
  final String? mahName;
  final String? mahGLN;
  final String? regulatedProductName;
  final String? ndcNumber;
  final String? sscc;
  final String? unitType;
  final String? containerType;
  final String? parentSSCC;
  final int? itemCount;
  final String? containedGtin;
  final String? containedBatch;
  final DateTime? containedExpiry;
  final List<String>? childSgtins;
  final List<String>? childSsccs;
  final String? purchaseOrderNumber;
  final String? ginc;

  bool get isSscc => identifierType == 'SSCC';
  bool get isSgtin => identifierType == 'SGTIN';

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

  factory ProductInfo.fromResolvedJson(Map<String, dynamic> json) {
    DateTime? d(dynamic v) => v != null ? DateTime.tryParse(v.toString()) : null;
    List<String>? list(dynamic v) =>
        v != null ? List<String>.from(v as List) : null;

    final p = json['product'] as Map<String, dynamic>?;
    final c = json['container'] as Map<String, dynamic>?;

    return ProductInfo(
      identifierType: json['identifierType'] as String?,
      description: json['displayName'] as String?,
      status: json['status'] as String?,
      currentLocationGLN: json['currentLocationGLN'] as String?,
      currentLocationName: json['currentLocationName'] as String?,
      gtin: p?['gtin'] as String?,
      serialNumber: p?['serialNumber'] as String?,
      batchLotNumber: p?['batchLotNumber'] as String?,
      expiryDate: d(p?['expiryDate']),
      manufacturingDate: d(p?['manufacturingDate']),
      regulatoryMarket: p?['regulatoryMarket'] as String?,
      tradeItemDescription: p?['tradeItemDescription'] as String?,
      functionalName: p?['functionalName'] as String?,
      manufacturer: p?['manufacturer'] as String?,
      manufacturerGLN: p?['manufacturerGLN'] as String?,
      packagingLevel: p?['packagingLevel'] as String?,
      packagingType: p?['packagingType'] as String?,
      dosageForm: p?['dosageForm'] as String?,
      strength: p?['strength'] as String?,
      strengthUnit: p?['strengthUnit'] as String?,
      routeOfAdministration: p?['routeOfAdministration'] as String?,
      atcCode: p?['atcCode'] as String?,
      mahName: p?['mahName'] as String?,
      mahGLN: p?['mahGLN'] as String?,
      regulatedProductName: p?['regulatedProductName'] as String?,
      ndcNumber: p?['ndcNumber'] as String?,
      sscc: c?['sscc'] as String?,
      unitType: c?['unitType'] as String?,
      containerType: c?['containerType'] as String?,
      parentSSCC: c?['parentSSCC'] as String?,
      itemCount: c?['itemCount'] as int?,
      containedGtin: c?['containedGtin'] as String?,
      containedBatch: c?['containedBatch'] as String?,
      containedExpiry: d(c?['containedExpiry']),
      childSgtins: list(c?['childSgtins']),
      childSsccs: list(c?['childSsccs']),
      purchaseOrderNumber: c?['purchaseOrderNumber'] as String?,
      ginc: c?['ginc'] as String?,
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
