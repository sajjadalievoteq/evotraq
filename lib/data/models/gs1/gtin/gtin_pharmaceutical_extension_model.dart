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

/// Active ingredient row (GDSN-style; aligns with pharma technical spec §B).
class ActiveIngredient extends Equatable {
  final String name;
  final double? amount;
  final String? unit;
  /// e.g. ACTIVE (default per GS1 substance role).
  final String substanceRoleCode;
  final int sequence;
  final String? basisOfStrength;

  ActiveIngredient({
    required this.name,
    this.amount,
    this.unit,
    this.substanceRoleCode = 'ACTIVE',
    this.sequence = 0,
    this.basisOfStrength,
  });

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    return ActiveIngredient(
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      substanceRoleCode: json['substanceRoleCode'] as String? ?? 'ACTIVE',
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      basisOfStrength: json['basisOfStrength'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'substanceRoleCode': substanceRoleCode,
      'sequence': sequence,
      'basisOfStrength': basisOfStrength,
    };
  }

  @override
  List<Object?> get props =>
      [name, amount, unit, substanceRoleCode, sequence, basisOfStrength];
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

  // Pharma technical specification (Section 5) — master-data extension
  final String? regulatedProductName;
  final String? dosageFormTypeCode;
  final String? routeOfAdministrationEdqmCode;

  final String? mahGln;
  final String? mahName;
  final String? mahCountry;
  final List<String> licensedAgentGlns;
  final String? marketingAuthorizationNumber;
  final DateTime? marketingAuthorizationValidFrom;
  final DateTime? marketingAuthorizationValidTo;
  final String? regulatoryStatus;

  /// Extra WHO ATC codes beyond [atcCode] (primary).
  final List<String> additionalAtcCodes;

  final String? nhmnGermanyPzn;
  final String? nhmnFranceCip;
  final String? nhmnSpainCn;
  final String? nhmnBrazilAnvisa;
  final String? nhmnPortugalAim;
  final String? nhmnUsaNdc;
  final String? nhmnItalyAifa;
  final String? localDrugCodeUaeGcc;

  final String? dataCarrierTypeCode;
  final bool antiTamperingIndicator;
  final bool pseudoGtinNtinFlag;

  final bool coldChainRequired;

  final String? prescriptionStatusCategory;
  final bool specControlledSubstanceIndicator;
  final String? specControlledSubstanceSchedule;
  final bool additionalMonitoringIndicator;

  final int? shelfLifeMonths;
  final int? shelfLifeAfterOpeningDays;
  final String? countryOfManufactureNumeric;
  final String? packSizeDescription;

  /// Batch-level potency hint (GS1 AI 7004 context); optional master-data note.
  final double? activePotencyAi7004;

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
    this.regulatedProductName,
    this.dosageFormTypeCode,
    this.routeOfAdministrationEdqmCode,
    this.mahGln,
    this.mahName,
    this.mahCountry,
    this.licensedAgentGlns = const [],
    this.marketingAuthorizationNumber,
    this.marketingAuthorizationValidFrom,
    this.marketingAuthorizationValidTo,
    this.regulatoryStatus,
    this.additionalAtcCodes = const [],
    this.nhmnGermanyPzn,
    this.nhmnFranceCip,
    this.nhmnSpainCn,
    this.nhmnBrazilAnvisa,
    this.nhmnPortugalAim,
    this.nhmnUsaNdc,
    this.nhmnItalyAifa,
    this.localDrugCodeUaeGcc,
    this.dataCarrierTypeCode,
    this.antiTamperingIndicator = false,
    this.pseudoGtinNtinFlag = false,
    this.coldChainRequired = false,
    this.prescriptionStatusCategory,
    this.specControlledSubstanceIndicator = false,
    this.specControlledSubstanceSchedule,
    this.additionalMonitoringIndicator = false,
    this.shelfLifeMonths,
    this.shelfLifeAfterOpeningDays,
    this.countryOfManufactureNumeric,
    this.packSizeDescription,
    this.activePotencyAi7004,
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
          ? DateTime.tryParse(json['fdaApprovalDate'].toString())
          : null,
      fdaApplicationNumber: json['fdaApplicationNumber'],
      emaApprovalDate: json['emaApprovalDate'] != null
          ? DateTime.tryParse(json['emaApprovalDate'].toString())
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
      regulatedProductName: json['regulatedProductName'] as String?,
      dosageFormTypeCode: json['dosageFormTypeCode'] as String?,
      routeOfAdministrationEdqmCode:
          json['routeOfAdministrationEdqmCode'] as String?,
      mahGln: json['mahGln'] as String?,
      mahName: json['mahName'] as String?,
      mahCountry: json['mahCountry'] as String?,
      licensedAgentGlns: _stringList(json['licensedAgentGlns']),
      marketingAuthorizationNumber:
          json['marketingAuthorizationNumber'] as String?,
      marketingAuthorizationValidFrom:
          json['marketingAuthorizationValidFrom'] != null
              ? DateTime.tryParse(json['marketingAuthorizationValidFrom'].toString())
              : null,
      marketingAuthorizationValidTo:
          json['marketingAuthorizationValidTo'] != null
              ? DateTime.tryParse(json['marketingAuthorizationValidTo'].toString())
              : null,
      regulatoryStatus: json['regulatoryStatus'] as String?,
      additionalAtcCodes: _stringList(json['additionalAtcCodes']),
      nhmnGermanyPzn: json['nhmnGermanyPzn'] as String?,
      nhmnFranceCip: json['nhmnFranceCip'] as String?,
      nhmnSpainCn: json['nhmnSpainCn'] as String?,
      nhmnBrazilAnvisa: json['nhmnBrazilAnvisa'] as String?,
      nhmnPortugalAim: json['nhmnPortugalAim'] as String?,
      nhmnUsaNdc: json['nhmnUsaNdc'] as String?,
      nhmnItalyAifa: json['nhmnItalyAifa'] as String?,
      localDrugCodeUaeGcc: json['localDrugCodeUaeGcc'] as String?,
      dataCarrierTypeCode: json['dataCarrierTypeCode'] as String?,
      antiTamperingIndicator: json['antiTamperingIndicator'] ?? false,
      pseudoGtinNtinFlag: json['pseudoGtinNtinFlag'] ?? false,
      coldChainRequired: json['coldChainRequired'] ?? false,
      prescriptionStatusCategory: json['prescriptionStatusCategory'] as String?,
      specControlledSubstanceIndicator:
          json['specControlledSubstanceIndicator'] ?? false,
      specControlledSubstanceSchedule:
          json['specControlledSubstanceSchedule'] as String?,
      additionalMonitoringIndicator:
          json['additionalMonitoringIndicator'] ?? false,
      shelfLifeMonths: (json['shelfLifeMonths'] as num?)?.toInt(),
      shelfLifeAfterOpeningDays:
          (json['shelfLifeAfterOpeningDays'] as num?)?.toInt(),
      countryOfManufactureNumeric:
          json['countryOfManufactureNumeric'] as String?,
      packSizeDescription: json['packSizeDescription'] as String?,
      activePotencyAi7004: (json['activePotencyAi7004'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
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
      'regulatedProductName': regulatedProductName,
      'dosageFormTypeCode': dosageFormTypeCode,
      'routeOfAdministrationEdqmCode': routeOfAdministrationEdqmCode,
      'mahGln': mahGln,
      'mahName': mahName,
      'mahCountry': mahCountry,
      'licensedAgentGlns': licensedAgentGlns,
      'marketingAuthorizationNumber': marketingAuthorizationNumber,
      'marketingAuthorizationValidFrom':
          marketingAuthorizationValidFrom?.toIso8601String().split('T').first,
      'marketingAuthorizationValidTo':
          marketingAuthorizationValidTo?.toIso8601String().split('T').first,
      'regulatoryStatus': regulatoryStatus,
      'additionalAtcCodes': additionalAtcCodes,
      'nhmnGermanyPzn': nhmnGermanyPzn,
      'nhmnFranceCip': nhmnFranceCip,
      'nhmnSpainCn': nhmnSpainCn,
      'nhmnBrazilAnvisa': nhmnBrazilAnvisa,
      'nhmnPortugalAim': nhmnPortugalAim,
      'nhmnUsaNdc': nhmnUsaNdc,
      'nhmnItalyAifa': nhmnItalyAifa,
      'localDrugCodeUaeGcc': localDrugCodeUaeGcc,
      'dataCarrierTypeCode': dataCarrierTypeCode,
      'antiTamperingIndicator': antiTamperingIndicator,
      'pseudoGtinNtinFlag': pseudoGtinNtinFlag,
      'coldChainRequired': coldChainRequired,
      'prescriptionStatusCategory': prescriptionStatusCategory,
      'specControlledSubstanceIndicator': specControlledSubstanceIndicator,
      'specControlledSubstanceSchedule': specControlledSubstanceSchedule,
      'additionalMonitoringIndicator': additionalMonitoringIndicator,
      'shelfLifeMonths': shelfLifeMonths,
      'shelfLifeAfterOpeningDays': shelfLifeAfterOpeningDays,
      'countryOfManufactureNumeric': countryOfManufactureNumeric,
      'packSizeDescription': packSizeDescription,
      'activePotencyAi7004': activePotencyAi7004,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
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
    String? regulatedProductName,
    String? dosageFormTypeCode,
    String? routeOfAdministrationEdqmCode,
    String? mahGln,
    String? mahName,
    String? mahCountry,
    List<String>? licensedAgentGlns,
    String? marketingAuthorizationNumber,
    DateTime? marketingAuthorizationValidFrom,
    DateTime? marketingAuthorizationValidTo,
    String? regulatoryStatus,
    List<String>? additionalAtcCodes,
    String? nhmnGermanyPzn,
    String? nhmnFranceCip,
    String? nhmnSpainCn,
    String? nhmnBrazilAnvisa,
    String? nhmnPortugalAim,
    String? nhmnUsaNdc,
    String? nhmnItalyAifa,
    String? localDrugCodeUaeGcc,
    String? dataCarrierTypeCode,
    bool? antiTamperingIndicator,
    bool? pseudoGtinNtinFlag,
    bool? coldChainRequired,
    String? prescriptionStatusCategory,
    bool? specControlledSubstanceIndicator,
    String? specControlledSubstanceSchedule,
    bool? additionalMonitoringIndicator,
    int? shelfLifeMonths,
    int? shelfLifeAfterOpeningDays,
    String? countryOfManufactureNumeric,
    String? packSizeDescription,
    double? activePotencyAi7004,
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
      regulatedProductName:
          regulatedProductName ?? this.regulatedProductName,
      dosageFormTypeCode: dosageFormTypeCode ?? this.dosageFormTypeCode,
      routeOfAdministrationEdqmCode:
          routeOfAdministrationEdqmCode ?? this.routeOfAdministrationEdqmCode,
      mahGln: mahGln ?? this.mahGln,
      mahName: mahName ?? this.mahName,
      mahCountry: mahCountry ?? this.mahCountry,
      licensedAgentGlns: licensedAgentGlns ?? this.licensedAgentGlns,
      marketingAuthorizationNumber:
          marketingAuthorizationNumber ?? this.marketingAuthorizationNumber,
      marketingAuthorizationValidFrom: marketingAuthorizationValidFrom ??
          this.marketingAuthorizationValidFrom,
      marketingAuthorizationValidTo: marketingAuthorizationValidTo ??
          this.marketingAuthorizationValidTo,
      regulatoryStatus: regulatoryStatus ?? this.regulatoryStatus,
      additionalAtcCodes: additionalAtcCodes ?? this.additionalAtcCodes,
      nhmnGermanyPzn: nhmnGermanyPzn ?? this.nhmnGermanyPzn,
      nhmnFranceCip: nhmnFranceCip ?? this.nhmnFranceCip,
      nhmnSpainCn: nhmnSpainCn ?? this.nhmnSpainCn,
      nhmnBrazilAnvisa: nhmnBrazilAnvisa ?? this.nhmnBrazilAnvisa,
      nhmnPortugalAim: nhmnPortugalAim ?? this.nhmnPortugalAim,
      nhmnUsaNdc: nhmnUsaNdc ?? this.nhmnUsaNdc,
      nhmnItalyAifa: nhmnItalyAifa ?? this.nhmnItalyAifa,
      localDrugCodeUaeGcc:
          localDrugCodeUaeGcc ?? this.localDrugCodeUaeGcc,
      dataCarrierTypeCode: dataCarrierTypeCode ?? this.dataCarrierTypeCode,
      antiTamperingIndicator:
          antiTamperingIndicator ?? this.antiTamperingIndicator,
      pseudoGtinNtinFlag: pseudoGtinNtinFlag ?? this.pseudoGtinNtinFlag,
      coldChainRequired: coldChainRequired ?? this.coldChainRequired,
      prescriptionStatusCategory:
          prescriptionStatusCategory ?? this.prescriptionStatusCategory,
      specControlledSubstanceIndicator: specControlledSubstanceIndicator ??
          this.specControlledSubstanceIndicator,
      specControlledSubstanceSchedule: specControlledSubstanceSchedule ??
          this.specControlledSubstanceSchedule,
      additionalMonitoringIndicator: additionalMonitoringIndicator ??
          this.additionalMonitoringIndicator,
      shelfLifeMonths: shelfLifeMonths ?? this.shelfLifeMonths,
      shelfLifeAfterOpeningDays:
          shelfLifeAfterOpeningDays ?? this.shelfLifeAfterOpeningDays,
      countryOfManufactureNumeric:
          countryOfManufactureNumeric ?? this.countryOfManufactureNumeric,
      packSizeDescription: packSizeDescription ?? this.packSizeDescription,
      activePotencyAi7004:
          activePotencyAi7004 ?? this.activePotencyAi7004,
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
        regulatedProductName,
        dosageFormTypeCode,
        routeOfAdministrationEdqmCode,
        mahGln,
        mahName,
        mahCountry,
        licensedAgentGlns,
        marketingAuthorizationNumber,
        marketingAuthorizationValidFrom,
        marketingAuthorizationValidTo,
        regulatoryStatus,
        additionalAtcCodes,
        nhmnGermanyPzn,
        nhmnFranceCip,
        nhmnSpainCn,
        nhmnBrazilAnvisa,
        nhmnPortugalAim,
        nhmnUsaNdc,
        nhmnItalyAifa,
        localDrugCodeUaeGcc,
        dataCarrierTypeCode,
        antiTamperingIndicator,
        pseudoGtinNtinFlag,
        coldChainRequired,
        prescriptionStatusCategory,
        specControlledSubstanceIndicator,
        specControlledSubstanceSchedule,
        additionalMonitoringIndicator,
        shelfLifeMonths,
        shelfLifeAfterOpeningDays,
        countryOfManufactureNumeric,
        packSizeDescription,
        activePotencyAi7004,
        createdAt,
        updatedAt,
      ];
}
