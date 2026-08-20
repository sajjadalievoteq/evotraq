import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_types.dart';

extension GtinPharmaceuticalCopyWith on GTINPharmaceuticalExtension {
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
      isControlledSubstance:
          isControlledSubstance ?? this.isControlledSubstance,
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
      regulatedProductName: regulatedProductName ?? this.regulatedProductName,
      dosageFormTypeCode: dosageFormTypeCode ?? this.dosageFormTypeCode,
      routeOfAdministrationEdqmCode:
          routeOfAdministrationEdqmCode ?? this.routeOfAdministrationEdqmCode,
      mahGln: mahGln ?? this.mahGln,
      mahName: mahName ?? this.mahName,
      mahCountry: mahCountry ?? this.mahCountry,
      licensedAgentGlns: licensedAgentGlns ?? this.licensedAgentGlns,
      marketingAuthorizationNumber:
          marketingAuthorizationNumber ?? this.marketingAuthorizationNumber,
      marketingAuthorizationValidFrom:
          marketingAuthorizationValidFrom ??
          this.marketingAuthorizationValidFrom,
      marketingAuthorizationValidTo:
          marketingAuthorizationValidTo ?? this.marketingAuthorizationValidTo,
      regulatoryStatus: regulatoryStatus ?? this.regulatoryStatus,
      additionalAtcCodes: additionalAtcCodes ?? this.additionalAtcCodes,
      nhmnGermanyPzn: nhmnGermanyPzn ?? this.nhmnGermanyPzn,
      nhmnFranceCip: nhmnFranceCip ?? this.nhmnFranceCip,
      nhmnSpainCn: nhmnSpainCn ?? this.nhmnSpainCn,
      nhmnBrazilAnvisa: nhmnBrazilAnvisa ?? this.nhmnBrazilAnvisa,
      nhmnPortugalAim: nhmnPortugalAim ?? this.nhmnPortugalAim,
      nhmnUsaNdc: nhmnUsaNdc ?? this.nhmnUsaNdc,
      nhmnItalyAifa: nhmnItalyAifa ?? this.nhmnItalyAifa,
      localDrugCodeUaeGcc: localDrugCodeUaeGcc ?? this.localDrugCodeUaeGcc,
      dataCarrierTypeCode: dataCarrierTypeCode ?? this.dataCarrierTypeCode,
      antiTamperingIndicator:
          antiTamperingIndicator ?? this.antiTamperingIndicator,
      pseudoGtinNtinFlag: pseudoGtinNtinFlag ?? this.pseudoGtinNtinFlag,
      coldChainRequired: coldChainRequired ?? this.coldChainRequired,
      prescriptionStatusCategory:
          prescriptionStatusCategory ?? this.prescriptionStatusCategory,
      specControlledSubstanceIndicator:
          specControlledSubstanceIndicator ??
          this.specControlledSubstanceIndicator,
      specControlledSubstanceSchedule:
          specControlledSubstanceSchedule ??
          this.specControlledSubstanceSchedule,
      additionalMonitoringIndicator:
          additionalMonitoringIndicator ?? this.additionalMonitoringIndicator,
      shelfLifeMonths: shelfLifeMonths ?? this.shelfLifeMonths,
      shelfLifeAfterOpeningDays:
          shelfLifeAfterOpeningDays ?? this.shelfLifeAfterOpeningDays,
      countryOfManufactureNumeric:
          countryOfManufactureNumeric ?? this.countryOfManufactureNumeric,
      packSizeDescription: packSizeDescription ?? this.packSizeDescription,
      activePotencyAi7004: activePotencyAi7004 ?? this.activePotencyAi7004,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasStorageRequirements =>
      requiresRefrigeration ||
      requiresFreezing ||
      lightSensitive ||
      humiditySensitive ||
      minStorageTempCelsius != null ||
      maxStorageTempCelsius != null;

  String get storageRequirementsSummary {
    List<String> requirements = [];
    if (requiresFreezing) requirements.add('Frozen');
    if (requiresRefrigeration) requirements.add('Refrigerated');
    if (lightSensitive) requirements.add('Light Protected');
    if (humiditySensitive) requirements.add('Humidity Controlled');
    if (minStorageTempCelsius != null && maxStorageTempCelsius != null) {
      requirements.add(
        '${minStorageTempCelsius}°C - ${maxStorageTempCelsius}°C',
      );
    }
    return requirements.isEmpty ? 'Room Temperature' : requirements.join(', ');
  }
}
