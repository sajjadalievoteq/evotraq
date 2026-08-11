import 'package:equatable/equatable.dart';

import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_types.dart';
export 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_types.dart';

part 'gtin_pharmaceutical_copy_with.dart';

double? _jsonDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

int? _jsonInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

class GTINPharmaceuticalExtension extends Equatable {
  final int? id;
  final int gtinId;
  final String? gtinCode;

  final String? ndcNumber;
  final String? dinNumber;
  final String? eanPharmaCode;

  final String? drugClass;
  final String? therapeuticClass;
  final String? pharmacologicalClass;
  final String? atcCode;

  final bool isControlledSubstance;
  final DeaSchedule deaSchedule;
  final String? controlClass;

  final String? dosageForm;
  final String? strength;
  final String? strengthUnit;
  final String? routeOfAdministration;

  final String? storageConditions;
  final double? minStorageTempCelsius;
  final double? maxStorageTempCelsius;
  final bool requiresRefrigeration;
  final bool requiresFreezing;
  final bool lightSensitive;
  final bool humiditySensitive;

  final bool requiresPrescription;
  final String? prescriptionType;

  final DateTime? fdaApprovalDate;
  final String? fdaApplicationNumber;
  final DateTime? emaApprovalDate;
  final String? emaProcedureNumber;

  final List<ActiveIngredient> activeIngredients;
  final String? inactiveIngredients;

  final bool blackBoxWarning;
  final String? blackBoxWarningText;
  final String? contraindications;
  final String? drugInteractions;
  final PregnancyCategory pregnancyCategory;

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

  final double? activePotencyAi7004;

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
      id: _jsonInt(json['id']),
      gtinId: _jsonInt(json['gtinId']) ?? 0,
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
      minStorageTempCelsius: _jsonDouble(json['minStorageTempCelsius']),
      maxStorageTempCelsius: _jsonDouble(json['maxStorageTempCelsius']),
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
      activeIngredients:
          (json['activeIngredients'] as List<dynamic>?)
              ?.map((e) => ActiveIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      inactiveIngredients: json['inactiveIngredients'],
      blackBoxWarning: json['blackBoxWarning'] ?? false,
      blackBoxWarningText: json['blackBoxWarningText'],
      contraindications: json['contraindications'],
      drugInteractions: json['drugInteractions'],
      pregnancyCategory: PregnancyCategoryExtension.fromString(
        json['pregnancyCategory'],
      ),
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
          ? DateTime.tryParse(
              json['marketingAuthorizationValidFrom'].toString(),
            )
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
      shelfLifeMonths: _jsonInt(json['shelfLifeMonths']),
      shelfLifeAfterOpeningDays: _jsonInt(json['shelfLifeAfterOpeningDays']),
      countryOfManufactureNumeric:
          json['countryOfManufactureNumeric'] as String?,
      packSizeDescription: json['packSizeDescription'] as String?,
      activePotencyAi7004: _jsonDouble(json['activePotencyAi7004']),
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
      'activeIngredients': activeIngredients.map((e) => e.toJson()).toList(),
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
      'marketingAuthorizationValidFrom': marketingAuthorizationValidFrom
          ?.toIso8601String()
          .split('T')
          .first,
      'marketingAuthorizationValidTo': marketingAuthorizationValidTo
          ?.toIso8601String()
          .split('T')
          .first,
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
