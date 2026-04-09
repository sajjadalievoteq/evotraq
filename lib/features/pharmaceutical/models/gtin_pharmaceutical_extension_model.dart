import 'package:equatable/equatable.dart';

/// DEA Schedule enum for controlled substances
enum DeaSchedule {
  scheduleI,
  scheduleII,
  scheduleIII,
  scheduleIV,
  scheduleV,
  none,
}

extension DeaScheduleExtension on DeaSchedule {
  String get value {
    switch (this) {
      case DeaSchedule.scheduleI:
        return 'I';
      case DeaSchedule.scheduleII:
        return 'II';
      case DeaSchedule.scheduleIII:
        return 'III';
      case DeaSchedule.scheduleIV:
        return 'IV';
      case DeaSchedule.scheduleV:
        return 'V';
      case DeaSchedule.none:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case DeaSchedule.scheduleI:
        return 'Schedule I - High abuse potential, no accepted medical use';
      case DeaSchedule.scheduleII:
        return 'Schedule II - High abuse potential, severe dependence';
      case DeaSchedule.scheduleIII:
        return 'Schedule III - Moderate abuse potential';
      case DeaSchedule.scheduleIV:
        return 'Schedule IV - Low abuse potential';
      case DeaSchedule.scheduleV:
        return 'Schedule V - Lowest abuse potential';
      case DeaSchedule.none:
        return 'Not a Controlled Substance';
    }
  }

  static DeaSchedule fromString(String? value) {
    if (value == null || value.isEmpty) return DeaSchedule.none;
    switch (value.toUpperCase()) {
      case 'I':
        return DeaSchedule.scheduleI;
      case 'II':
        return DeaSchedule.scheduleII;
      case 'III':
        return DeaSchedule.scheduleIII;
      case 'IV':
        return DeaSchedule.scheduleIV;
      case 'V':
        return DeaSchedule.scheduleV;
      default:
        return DeaSchedule.none;
    }
  }
}

/// Pregnancy category enum
enum PregnancyCategory {
  categoryA,
  categoryB,
  categoryC,
  categoryD,
  categoryX,
  notClassified,
}

extension PregnancyCategoryExtension on PregnancyCategory {
  String get value {
    switch (this) {
      case PregnancyCategory.categoryA:
        return 'A';
      case PregnancyCategory.categoryB:
        return 'B';
      case PregnancyCategory.categoryC:
        return 'C';
      case PregnancyCategory.categoryD:
        return 'D';
      case PregnancyCategory.categoryX:
        return 'X';
      case PregnancyCategory.notClassified:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case PregnancyCategory.categoryA:
        return 'Category A - Adequate studies show no risk';
      case PregnancyCategory.categoryB:
        return 'Category B - No risk in animal studies';
      case PregnancyCategory.categoryC:
        return 'Category C - Risk cannot be ruled out';
      case PregnancyCategory.categoryD:
        return 'Category D - Positive evidence of risk';
      case PregnancyCategory.categoryX:
        return 'Category X - Contraindicated in pregnancy';
      case PregnancyCategory.notClassified:
        return 'Not Classified';
    }
  }

  static PregnancyCategory fromString(String? value) {
    if (value == null || value.isEmpty) return PregnancyCategory.notClassified;
    switch (value.toUpperCase()) {
      case 'A':
        return PregnancyCategory.categoryA;
      case 'B':
        return PregnancyCategory.categoryB;
      case 'C':
        return PregnancyCategory.categoryC;
      case 'D':
        return PregnancyCategory.categoryD;
      case 'X':
        return PregnancyCategory.categoryX;
      default:
        return PregnancyCategory.notClassified;
    }
  }
}

/// Active ingredient model
class ActiveIngredient extends Equatable {
  final String name;
  final double amount;
  final String unit;

  const ActiveIngredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    return ActiveIngredient(
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [name, amount, unit];
}

/// GTIN Pharmaceutical Extension model
class GTINPharmaceuticalExtension extends Equatable {
  final int? id;
  final int gtinId;
  final String? gtinCode;

  // Drug Identification
  final String? ndcNumber;
  final String? dinNumber;
  final String? eanPharmaCode;

  // Drug Classification
  final String? drugClass;
  final String? therapeuticClass;
  final String? pharmacologicalClass;
  final String? atcCode;

  // Controlled Substance
  final bool isControlledSubstance;
  final DeaSchedule deaSchedule;
  final String? controlClass;

  // Dosage Information
  final String? dosageForm;
  final String? strength;
  final String? strengthUnit;
  final String? routeOfAdministration;

  // Storage Requirements
  final String? storageConditions;
  final double? minStorageTempCelsius;
  final double? maxStorageTempCelsius;
  final bool requiresRefrigeration;
  final bool requiresFreezing;
  final bool lightSensitive;
  final bool humiditySensitive;

  // Prescription Requirements
  final bool requiresPrescription;
  final String? prescriptionType;

  // Regulatory
  final DateTime? fdaApprovalDate;
  final String? fdaApplicationNumber;
  final DateTime? emaApprovalDate;
  final String? emaProcedureNumber;

  // Active Ingredients
  final List<ActiveIngredient> activeIngredients;
  final String? inactiveIngredients;

  // Warnings and Precautions
  final bool blackBoxWarning;
  final String? blackBoxWarningText;
  final String? contraindications;
  final String? drugInteractions;
  final PregnancyCategory pregnancyCategory;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GTINPharmaceuticalExtension({
    this.id,
    required this.gtinId,
    this.gtinCode,
    this.ndcNumber,
    this.dinNumber,
    this.eanPharmaCode,
    this.drugClass,
    this.therapeuticClass,
    this.pharmacologicalClass,
    this.atcCode,
    this.isControlledSubstance = false,
    this.deaSchedule = DeaSchedule.none,
    this.controlClass,
    this.dosageForm,
    this.strength,
    this.strengthUnit,
    this.routeOfAdministration,
    this.storageConditions,
    this.minStorageTempCelsius,
    this.maxStorageTempCelsius,
    this.requiresRefrigeration = false,
    this.requiresFreezing = false,
    this.lightSensitive = false,
    this.humiditySensitive = false,
    this.requiresPrescription = true,
    this.prescriptionType,
    this.fdaApprovalDate,
    this.fdaApplicationNumber,
    this.emaApprovalDate,
    this.emaProcedureNumber,
    this.activeIngredients = const [],
    this.inactiveIngredients,
    this.blackBoxWarning = false,
    this.blackBoxWarningText,
    this.contraindications,
    this.drugInteractions,
    this.pregnancyCategory = PregnancyCategory.notClassified,
    this.createdAt,
    this.updatedAt,
  });

  factory GTINPharmaceuticalExtension.fromJson(Map<String, dynamic> json) {
    return GTINPharmaceuticalExtension(
      id: json['id'],
      gtinId: json['gtinId'] ?? 0,
      gtinCode: json['gtinCode'],
      ndcNumber: json['ndcNumber'],
      dinNumber: json['dinNumber'],
      eanPharmaCode: json['eanPharmaCode'],
      drugClass: json['drugClass'],
      therapeuticClass: json['therapeuticClass'],
      pharmacologicalClass: json['pharmacologicalClass'],
      atcCode: json['atcCode'],
      isControlledSubstance: json['isControlledSubstance'] ?? false,
      deaSchedule: DeaScheduleExtension.fromString(json['deaSchedule']),
      controlClass: json['controlClass'],
      dosageForm: json['dosageForm'],
      strength: json['strength'],
      strengthUnit: json['strengthUnit'],
      routeOfAdministration: json['routeOfAdministration'],
      storageConditions: json['storageConditions'],
      minStorageTempCelsius: (json['minStorageTempCelsius'] as num?)?.toDouble(),
      maxStorageTempCelsius: (json['maxStorageTempCelsius'] as num?)?.toDouble(),
      requiresRefrigeration: json['requiresRefrigeration'] ?? false,
      requiresFreezing: json['requiresFreezing'] ?? false,
      lightSensitive: json['lightSensitive'] ?? false,
      humiditySensitive: json['humiditySensitive'] ?? false,
      requiresPrescription: json['requiresPrescription'] ?? true,
      prescriptionType: json['prescriptionType'],
      fdaApprovalDate: json['fdaApprovalDate'] != null
          ? DateTime.tryParse(json['fdaApprovalDate'])
          : null,
      fdaApplicationNumber: json['fdaApplicationNumber'],
      emaApprovalDate: json['emaApprovalDate'] != null
          ? DateTime.tryParse(json['emaApprovalDate'])
          : null,
      emaProcedureNumber: json['emaProcedureNumber'],
      activeIngredients: (json['activeIngredients'] as List<dynamic>?)
              ?.map((e) => ActiveIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      inactiveIngredients: json['inactiveIngredients'],
      blackBoxWarning: json['blackBoxWarning'] ?? false,
      blackBoxWarningText: json['blackBoxWarningText'],
      contraindications: json['contraindications'],
      drugInteractions: json['drugInteractions'],
      pregnancyCategory:
          PregnancyCategoryExtension.fromString(json['pregnancyCategory']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gtinId': gtinId,
      'gtinCode': gtinCode,
      'ndcNumber': ndcNumber,
      'dinNumber': dinNumber,
      'eanPharmaCode': eanPharmaCode,
      'drugClass': drugClass,
      'therapeuticClass': therapeuticClass,
      'pharmacologicalClass': pharmacologicalClass,
      'atcCode': atcCode,
      'isControlledSubstance': isControlledSubstance,
      'deaSchedule': deaSchedule.value,
      'controlClass': controlClass,
      'dosageForm': dosageForm,
      'strength': strength,
      'strengthUnit': strengthUnit,
      'routeOfAdministration': routeOfAdministration,
      'storageConditions': storageConditions,
      'minStorageTempCelsius': minStorageTempCelsius,
      'maxStorageTempCelsius': maxStorageTempCelsius,
      'requiresRefrigeration': requiresRefrigeration,
      'requiresFreezing': requiresFreezing,
      'lightSensitive': lightSensitive,
      'humiditySensitive': humiditySensitive,
      'requiresPrescription': requiresPrescription,
      'prescriptionType': prescriptionType,
      'fdaApprovalDate': fdaApprovalDate?.toIso8601String().split('T').first,
      'fdaApplicationNumber': fdaApplicationNumber,
      'emaApprovalDate': emaApprovalDate?.toIso8601String().split('T').first,
      'emaProcedureNumber': emaProcedureNumber,
      'activeIngredients':
          activeIngredients.map((e) => e.toJson()).toList(),
      'inactiveIngredients': inactiveIngredients,
      'blackBoxWarning': blackBoxWarning,
      'blackBoxWarningText': blackBoxWarningText,
      'contraindications': contraindications,
      'drugInteractions': drugInteractions,
      'pregnancyCategory': pregnancyCategory.value,
    };
  }

  GTINPharmaceuticalExtension copyWith({
    int? id,
    int? gtinId,
    String? gtinCode,
    String? ndcNumber,
    String? dinNumber,
    String? eanPharmaCode,
    String? drugClass,
    String? therapeuticClass,
    String? pharmacologicalClass,
    String? atcCode,
    bool? isControlledSubstance,
    DeaSchedule? deaSchedule,
    String? controlClass,
    String? dosageForm,
    String? strength,
    String? strengthUnit,
    String? routeOfAdministration,
    String? storageConditions,
    double? minStorageTempCelsius,
    double? maxStorageTempCelsius,
    bool? requiresRefrigeration,
    bool? requiresFreezing,
    bool? lightSensitive,
    bool? humiditySensitive,
    bool? requiresPrescription,
    String? prescriptionType,
    DateTime? fdaApprovalDate,
    String? fdaApplicationNumber,
    DateTime? emaApprovalDate,
    String? emaProcedureNumber,
    List<ActiveIngredient>? activeIngredients,
    String? inactiveIngredients,
    bool? blackBoxWarning,
    String? blackBoxWarningText,
    String? contraindications,
    String? drugInteractions,
    PregnancyCategory? pregnancyCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GTINPharmaceuticalExtension(
      id: id ?? this.id,
      gtinId: gtinId ?? this.gtinId,
      gtinCode: gtinCode ?? this.gtinCode,
      ndcNumber: ndcNumber ?? this.ndcNumber,
      dinNumber: dinNumber ?? this.dinNumber,
      eanPharmaCode: eanPharmaCode ?? this.eanPharmaCode,
      drugClass: drugClass ?? this.drugClass,
      therapeuticClass: therapeuticClass ?? this.therapeuticClass,
      pharmacologicalClass: pharmacologicalClass ?? this.pharmacologicalClass,
      atcCode: atcCode ?? this.atcCode,
      isControlledSubstance: isControlledSubstance ?? this.isControlledSubstance,
      deaSchedule: deaSchedule ?? this.deaSchedule,
      controlClass: controlClass ?? this.controlClass,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      routeOfAdministration:
          routeOfAdministration ?? this.routeOfAdministration,
      storageConditions: storageConditions ?? this.storageConditions,
      minStorageTempCelsius:
          minStorageTempCelsius ?? this.minStorageTempCelsius,
      maxStorageTempCelsius:
          maxStorageTempCelsius ?? this.maxStorageTempCelsius,
      requiresRefrigeration:
          requiresRefrigeration ?? this.requiresRefrigeration,
      requiresFreezing: requiresFreezing ?? this.requiresFreezing,
      lightSensitive: lightSensitive ?? this.lightSensitive,
      humiditySensitive: humiditySensitive ?? this.humiditySensitive,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      fdaApprovalDate: fdaApprovalDate ?? this.fdaApprovalDate,
      fdaApplicationNumber: fdaApplicationNumber ?? this.fdaApplicationNumber,
      emaApprovalDate: emaApprovalDate ?? this.emaApprovalDate,
      emaProcedureNumber: emaProcedureNumber ?? this.emaProcedureNumber,
      activeIngredients: activeIngredients ?? this.activeIngredients,
      inactiveIngredients: inactiveIngredients ?? this.inactiveIngredients,
      blackBoxWarning: blackBoxWarning ?? this.blackBoxWarning,
      blackBoxWarningText: blackBoxWarningText ?? this.blackBoxWarningText,
      contraindications: contraindications ?? this.contraindications,
      drugInteractions: drugInteractions ?? this.drugInteractions,
      pregnancyCategory: pregnancyCategory ?? this.pregnancyCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if extension has special storage requirements
  bool get hasStorageRequirements =>
      requiresRefrigeration ||
      requiresFreezing ||
      lightSensitive ||
      humiditySensitive ||
      minStorageTempCelsius != null ||
      maxStorageTempCelsius != null;

  /// Get storage requirements summary
  String get storageRequirementsSummary {
    List<String> requirements = [];
    if (requiresFreezing) requirements.add('Frozen');
    if (requiresRefrigeration) requirements.add('Refrigerated');
    if (lightSensitive) requirements.add('Light Protected');
    if (humiditySensitive) requirements.add('Humidity Controlled');
    if (minStorageTempCelsius != null && maxStorageTempCelsius != null) {
      requirements.add('${minStorageTempCelsius}°C - ${maxStorageTempCelsius}°C');
    }
    return requirements.isEmpty ? 'Room Temperature' : requirements.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        gtinId,
        gtinCode,
        ndcNumber,
        dinNumber,
        eanPharmaCode,
        drugClass,
        therapeuticClass,
        pharmacologicalClass,
        atcCode,
        isControlledSubstance,
        deaSchedule,
        controlClass,
        dosageForm,
        strength,
        strengthUnit,
        routeOfAdministration,
        storageConditions,
        minStorageTempCelsius,
        maxStorageTempCelsius,
        requiresRefrigeration,
        requiresFreezing,
        lightSensitive,
        humiditySensitive,
        requiresPrescription,
        prescriptionType,
        fdaApprovalDate,
        fdaApplicationNumber,
        emaApprovalDate,
        emaProcedureNumber,
        activeIngredients,
        inactiveIngredients,
        blackBoxWarning,
        blackBoxWarningText,
        contraindications,
        drugInteractions,
        pregnancyCategory,
      ];
}
