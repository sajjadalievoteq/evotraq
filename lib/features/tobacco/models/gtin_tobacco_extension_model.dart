import 'package:equatable/equatable.dart';

/// Tobacco product category enum
enum TobaccoProductCategory {
  cigarette,
  cigar,
  cigarillo,
  pipeTobacco,
  smokelessTobacco,
  rollingTobacco,
  heatedTobacco,
  eCigarette,
  waterPipeTobacco,
  other,
}

/// Extension to handle TobaccoProductCategory serialization
extension TobaccoProductCategoryExtension on TobaccoProductCategory {
  String get value {
    switch (this) {
      case TobaccoProductCategory.cigarette:
        return 'CIGARETTE';
      case TobaccoProductCategory.cigar:
        return 'CIGAR';
      case TobaccoProductCategory.cigarillo:
        return 'CIGARILLO';
      case TobaccoProductCategory.pipeTobacco:
        return 'PIPE_TOBACCO';
      case TobaccoProductCategory.smokelessTobacco:
        return 'SMOKELESS_TOBACCO';
      case TobaccoProductCategory.rollingTobacco:
        return 'ROLLING_TOBACCO';
      case TobaccoProductCategory.heatedTobacco:
        return 'HEATED_TOBACCO';
      case TobaccoProductCategory.eCigarette:
        return 'E_CIGARETTE';
      case TobaccoProductCategory.waterPipeTobacco:
        return 'WATER_PIPE_TOBACCO';
      case TobaccoProductCategory.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case TobaccoProductCategory.cigarette:
        return 'Cigarette';
      case TobaccoProductCategory.cigar:
        return 'Cigar';
      case TobaccoProductCategory.cigarillo:
        return 'Cigarillo';
      case TobaccoProductCategory.pipeTobacco:
        return 'Pipe Tobacco';
      case TobaccoProductCategory.smokelessTobacco:
        return 'Smokeless Tobacco';
      case TobaccoProductCategory.rollingTobacco:
        return 'Rolling Tobacco';
      case TobaccoProductCategory.heatedTobacco:
        return 'Heated Tobacco';
      case TobaccoProductCategory.eCigarette:
        return 'E-Cigarette';
      case TobaccoProductCategory.waterPipeTobacco:
        return 'Water Pipe Tobacco';
      case TobaccoProductCategory.other:
        return 'Other';
    }
  }

  static TobaccoProductCategory fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CIGARETTE':
        return TobaccoProductCategory.cigarette;
      case 'CIGAR':
        return TobaccoProductCategory.cigar;
      case 'CIGARILLO':
        return TobaccoProductCategory.cigarillo;
      case 'PIPE_TOBACCO':
        return TobaccoProductCategory.pipeTobacco;
      case 'SMOKELESS_TOBACCO':
        return TobaccoProductCategory.smokelessTobacco;
      case 'ROLLING_TOBACCO':
        return TobaccoProductCategory.rollingTobacco;
      case 'HEATED_TOBACCO':
        return TobaccoProductCategory.heatedTobacco;
      case 'E_CIGARETTE':
        return TobaccoProductCategory.eCigarette;
      case 'WATER_PIPE_TOBACCO':
        return TobaccoProductCategory.waterPipeTobacco;
      default:
        return TobaccoProductCategory.other;
    }
  }
}

/// Tobacco curing method enum
enum TobaccoCuringMethod {
  flueCured,
  airCured,
  fireCured,
  sunCured,
}

extension TobaccoCuringMethodExtension on TobaccoCuringMethod {
  String get value {
    switch (this) {
      case TobaccoCuringMethod.flueCured:
        return 'FLUE_CURED';
      case TobaccoCuringMethod.airCured:
        return 'AIR_CURED';
      case TobaccoCuringMethod.fireCured:
        return 'FIRE_CURED';
      case TobaccoCuringMethod.sunCured:
        return 'SUN_CURED';
    }
  }

  String get displayName {
    switch (this) {
      case TobaccoCuringMethod.flueCured:
        return 'Flue Cured';
      case TobaccoCuringMethod.airCured:
        return 'Air Cured';
      case TobaccoCuringMethod.fireCured:
        return 'Fire Cured';
      case TobaccoCuringMethod.sunCured:
        return 'Sun Cured';
    }
  }

  static TobaccoCuringMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FLUE_CURED':
        return TobaccoCuringMethod.flueCured;
      case 'AIR_CURED':
        return TobaccoCuringMethod.airCured;
      case 'FIRE_CURED':
        return TobaccoCuringMethod.fireCured;
      case 'SUN_CURED':
        return TobaccoCuringMethod.sunCured;
      default:
        return TobaccoCuringMethod.flueCured;
    }
  }
}

/// GTIN Tobacco Extension model for tobacco-specific product attributes
class GTINTobaccoExtension extends Equatable {
  final int? id;
  final int gtinId;
  final String? gtinCode;
  final TobaccoProductCategory tobaccoCategory;
  final String brandFamily;
  final String? brandVariant;
  final double? nicotineContentMg;
  final double? tarContentMg;
  final double? carbonMonoxideMg;
  final int? unitsPerPack;
  final String? packType;
  final bool? isMenthol;
  final bool? isSlim;
  final bool? isKingSize;
  final String? filterType;
  final int? cigaretteLengthMm;
  final String? countryOfOrigin;
  final String? intendedMarket;
  final double? maxRetailPrice;
  final String? maxRetailPriceCurrency;
  final String? taxCategory;
  final double? exciseTaxRate;
  final TobaccoCuringMethod? curingMethod;
  final String? leafOriginCountries;
  final double? moistureContentPercent;
  final String? qualityGrade;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GTINTobaccoExtension({
    this.id,
    required this.gtinId,
    this.gtinCode,
    required this.tobaccoCategory,
    required this.brandFamily,
    this.brandVariant,
    this.nicotineContentMg,
    this.tarContentMg,
    this.carbonMonoxideMg,
    this.unitsPerPack,
    this.packType,
    this.isMenthol,
    this.isSlim,
    this.isKingSize,
    this.filterType,
    this.cigaretteLengthMm,
    this.countryOfOrigin,
    this.intendedMarket,
    this.maxRetailPrice,
    this.maxRetailPriceCurrency,
    this.taxCategory,
    this.exciseTaxRate,
    this.curingMethod,
    this.leafOriginCountries,
    this.moistureContentPercent,
    this.qualityGrade,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        gtinId,
        gtinCode,
        tobaccoCategory,
        brandFamily,
        brandVariant,
        nicotineContentMg,
        tarContentMg,
        carbonMonoxideMg,
        unitsPerPack,
        packType,
        isMenthol,
        isSlim,
        isKingSize,
        filterType,
        cigaretteLengthMm,
        countryOfOrigin,
        intendedMarket,
        maxRetailPrice,
        maxRetailPriceCurrency,
        taxCategory,
        exciseTaxRate,
        curingMethod,
        leafOriginCountries,
        moistureContentPercent,
        qualityGrade,
        createdAt,
        updatedAt,
      ];

  GTINTobaccoExtension copyWith({
    int? id,
    int? gtinId,
    String? gtinCode,
    TobaccoProductCategory? tobaccoCategory,
    String? brandFamily,
    String? brandVariant,
    double? nicotineContentMg,
    double? tarContentMg,
    double? carbonMonoxideMg,
    int? unitsPerPack,
    String? packType,
    bool? isMenthol,
    bool? isSlim,
    bool? isKingSize,
    String? filterType,
    int? cigaretteLengthMm,
    String? countryOfOrigin,
    String? intendedMarket,
    double? maxRetailPrice,
    String? maxRetailPriceCurrency,
    String? taxCategory,
    double? exciseTaxRate,
    TobaccoCuringMethod? curingMethod,
    String? leafOriginCountries,
    double? moistureContentPercent,
    String? qualityGrade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GTINTobaccoExtension(
      id: id ?? this.id,
      gtinId: gtinId ?? this.gtinId,
      gtinCode: gtinCode ?? this.gtinCode,
      tobaccoCategory: tobaccoCategory ?? this.tobaccoCategory,
      brandFamily: brandFamily ?? this.brandFamily,
      brandVariant: brandVariant ?? this.brandVariant,
      nicotineContentMg: nicotineContentMg ?? this.nicotineContentMg,
      tarContentMg: tarContentMg ?? this.tarContentMg,
      carbonMonoxideMg: carbonMonoxideMg ?? this.carbonMonoxideMg,
      unitsPerPack: unitsPerPack ?? this.unitsPerPack,
      packType: packType ?? this.packType,
      isMenthol: isMenthol ?? this.isMenthol,
      isSlim: isSlim ?? this.isSlim,
      isKingSize: isKingSize ?? this.isKingSize,
      filterType: filterType ?? this.filterType,
      cigaretteLengthMm: cigaretteLengthMm ?? this.cigaretteLengthMm,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      intendedMarket: intendedMarket ?? this.intendedMarket,
      maxRetailPrice: maxRetailPrice ?? this.maxRetailPrice,
      maxRetailPriceCurrency: maxRetailPriceCurrency ?? this.maxRetailPriceCurrency,
      taxCategory: taxCategory ?? this.taxCategory,
      exciseTaxRate: exciseTaxRate ?? this.exciseTaxRate,
      curingMethod: curingMethod ?? this.curingMethod,
      leafOriginCountries: leafOriginCountries ?? this.leafOriginCountries,
      moistureContentPercent: moistureContentPercent ?? this.moistureContentPercent,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'gtinId': gtinId,
      if (gtinCode != null) 'gtinCode': gtinCode,
      'tobaccoCategory': tobaccoCategory.value,
      'brandFamily': brandFamily,
      if (brandVariant != null) 'brandVariant': brandVariant,
      if (nicotineContentMg != null) 'nicotineContentMg': nicotineContentMg,
      if (tarContentMg != null) 'tarContentMg': tarContentMg,
      if (carbonMonoxideMg != null) 'carbonMonoxideMg': carbonMonoxideMg,
      if (unitsPerPack != null) 'unitsPerPack': unitsPerPack,
      if (packType != null) 'packType': packType,
      if (isMenthol != null) 'isMenthol': isMenthol,
      if (isSlim != null) 'isSlim': isSlim,
      if (isKingSize != null) 'isKingSize': isKingSize,
      if (filterType != null) 'filterType': filterType,
      if (cigaretteLengthMm != null) 'cigaretteLengthMm': cigaretteLengthMm,
      if (countryOfOrigin != null) 'countryOfOrigin': countryOfOrigin,
      if (intendedMarket != null) 'intendedMarket': intendedMarket,
      if (maxRetailPrice != null) 'maxRetailPrice': maxRetailPrice,
      if (maxRetailPriceCurrency != null) 'maxRetailPriceCurrency': maxRetailPriceCurrency,
      if (taxCategory != null) 'taxCategory': taxCategory,
      if (exciseTaxRate != null) 'exciseTaxRate': exciseTaxRate,
      if (curingMethod != null) 'curingMethod': curingMethod!.value,
      if (leafOriginCountries != null) 'leafOriginCountries': leafOriginCountries,
      if (moistureContentPercent != null) 'moistureContentPercent': moistureContentPercent,
      if (qualityGrade != null) 'qualityGrade': qualityGrade,
    };
  }

  factory GTINTobaccoExtension.fromJson(Map<String, dynamic> json) {
    return GTINTobaccoExtension(
      id: json['id'] as int?,
      gtinId: json['gtinId'] as int,
      gtinCode: json['gtinCode'] as String?,
      tobaccoCategory: TobaccoProductCategoryExtension.fromString(
          json['tobaccoCategory'] as String? ?? 'CIGARETTE'),
      brandFamily: json['brandFamily'] as String,
      brandVariant: json['brandVariant'] as String?,
      nicotineContentMg: json['nicotineContentMg'] != null
          ? (json['nicotineContentMg'] as num).toDouble()
          : null,
      tarContentMg: json['tarContentMg'] != null
          ? (json['tarContentMg'] as num).toDouble()
          : null,
      carbonMonoxideMg: json['carbonMonoxideMg'] != null
          ? (json['carbonMonoxideMg'] as num).toDouble()
          : null,
      unitsPerPack: json['unitsPerPack'] as int?,
      packType: json['packType'] as String?,
      isMenthol: json['isMenthol'] as bool?,
      isSlim: json['isSlim'] as bool?,
      isKingSize: json['isKingSize'] as bool?,
      filterType: json['filterType'] as String?,
      cigaretteLengthMm: json['cigaretteLengthMm'] as int?,
      countryOfOrigin: json['countryOfOrigin'] as String?,
      intendedMarket: json['intendedMarket'] as String?,
      maxRetailPrice: json['maxRetailPrice'] != null
          ? (json['maxRetailPrice'] as num).toDouble()
          : null,
      maxRetailPriceCurrency: json['maxRetailPriceCurrency'] as String?,
      taxCategory: json['taxCategory'] as String?,
      exciseTaxRate: json['exciseTaxRate'] != null
          ? (json['exciseTaxRate'] as num).toDouble()
          : null,
      curingMethod: json['curingMethod'] != null
          ? TobaccoCuringMethodExtension.fromString(json['curingMethod'] as String)
          : null,
      leafOriginCountries: json['leafOriginCountries'] as String?,
      moistureContentPercent: json['moistureContentPercent'] != null
          ? (json['moistureContentPercent'] as num).toDouble()
          : null,
      qualityGrade: json['qualityGrade'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
