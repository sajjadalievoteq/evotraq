import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_types.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

extension PharmaceuticalExtensionActions on PharmaceuticalExtensionWidgetState {
  static List<String> _splitDelimitedGlnsOrCodes(String raw) {
    if (raw.trim().isEmpty) return const [];
    final parts = raw.split(RegExp(r'[\s,;\n]+'));
    return parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  void populateFormFromExtension(GTINPharmaceuticalExtension ext) {
    ndcNumber = ext.ndcNumber ?? '';
    dinNumber = ext.dinNumber ?? '';
    eanPharmaCode = ext.eanPharmaCode ?? '';
    drugClass = ext.drugClass ?? '';
    therapeuticClass = ext.therapeuticClass ?? '';
    pharmacologicalClass = ext.pharmacologicalClass ?? '';
    atcCode = ext.atcCode ?? '';
    isControlledSubstance = ext.isControlledSubstance;
    deaSchedule = ext.deaSchedule;
    controlClass = ext.controlClass ?? '';
    dosageForm = ext.dosageForm ?? '';
    strength = ext.strength ?? '';
    strengthUnit = ext.strengthUnit ?? '';
    routeOfAdministration = ext.routeOfAdministration ?? '';
    storageConditions = ext.storageConditions ?? '';
    minStorageTemp = ext.minStorageTempCelsius?.toString() ?? '';
    maxStorageTemp = ext.maxStorageTempCelsius?.toString() ?? '';
    requiresRefrigeration = ext.requiresRefrigeration;
    requiresFreezing = ext.requiresFreezing;
    lightSensitive = ext.lightSensitive;
    humiditySensitive = ext.humiditySensitive;
    requiresPrescription = ext.requiresPrescription;
    prescriptionType = ext.prescriptionType ?? '';
    fdaApprovalDate = ext.fdaApprovalDate;
    fdaApplicationNumber = ext.fdaApplicationNumber ?? '';
    emaApprovalDate = ext.emaApprovalDate;
    emaProcedureNumber = ext.emaProcedureNumber ?? '';
    blackBoxWarning = ext.blackBoxWarning;
    blackBoxWarningText = ext.blackBoxWarningText ?? '';
    contraindications = ext.contraindications ?? '';
    drugInteractions = ext.drugInteractions ?? '';
    pregnancyCategory = ext.pregnancyCategory;

    regulatedProductName = ext.regulatedProductName ?? '';
    dosageFormTypeCode = ext.dosageFormTypeCode ?? '';
    routeOfAdministrationCode = ext.routeOfAdministrationEdqmCode ?? '';
    mahGln = ext.mahGln ?? '';
    mahName = ext.mahName ?? '';
    mahCountry = ext.mahCountry ?? '';
    licensedAgentGlns = ext.licensedAgentGlns.join(', ');
    additionalAtcCodes = ext.additionalAtcCodes.join(', ');
    maNumber = ext.marketingAuthorizationNumber ?? '';
    maValidFrom = ext.marketingAuthorizationValidFrom;
    maValidTo = ext.marketingAuthorizationValidTo;
    regulatoryStatus = ext.regulatoryStatus ?? '';
    prescriptionStatus =
        (ext.prescriptionStatusCategory != null &&
            ext.prescriptionStatusCategory!.isNotEmpty &&
            PharmaFieldValidators.prescriptionStatusCodes.contains(
              ext.prescriptionStatusCategory,
            ))
        ? ext.prescriptionStatusCategory!
        : 'RX';
    controlledSubstance = ext.specControlledSubstanceIndicator;
    controlledSubstanceSchedule = ext.specControlledSubstanceSchedule ?? '';
    additionalMonitoring = ext.additionalMonitoringIndicator;
    shelfLifeMonths = ext.shelfLifeMonths?.toString() ?? '';
    shelfLifeAfterOpenDays = ext.shelfLifeAfterOpeningDays?.toString() ?? '';
    countryOfManufacture = ext.countryOfManufactureNumeric ?? '';
    packSizeDescription = ext.packSizeDescription ?? '';

    nhmnGermanyPzn = ext.nhmnGermanyPzn ?? '';
    nhmnFranceCip = ext.nhmnFranceCip ?? '';
    nhmnSpainCn = ext.nhmnSpainCn ?? '';
    nhmnBrazilAnvisa = ext.nhmnBrazilAnvisa ?? '';
    nhmnPortugalAim = ext.nhmnPortugalAim ?? '';
    nhmnUsaNdc = ext.nhmnUsaNdc ?? '';
    nhmnItalyAifa = ext.nhmnItalyAifa ?? '';
    localDrugCodeUaeGcc = ext.localDrugCodeUaeGcc ?? '';

    dataCarrierTypeCode = ext.dataCarrierTypeCode ?? '';
    antiTamperingIndicator = ext.antiTamperingIndicator;
    pseudoGtinNtinFlag = ext.pseudoGtinNtinFlag;
    coldChainRequired = ext.coldChainRequired;
    activePotencyAi7004 = ext.activePotencyAi7004?.toString() ?? '';
    inactiveIngredients = ext.inactiveIngredients ?? '';
    activeIngredients = List<ActiveIngredient>.from(ext.activeIngredients);
  }

  bool get hasData {
    bool nz(String s) => s.trim().isNotEmpty;

    final basics =
        nz(ndcNumber) ||
        nz(dinNumber) ||
        nz(eanPharmaCode) ||
        nz(drugClass) ||
        nz(dosageForm) ||
        nz(strength) ||
        nz(therapeuticClass) ||
        nz(pharmacologicalClass) ||
        nz(atcCode);
    if (basics) return true;

    final spec =
        nz(regulatedProductName) ||
        nz(dosageFormTypeCode) ||
        nz(routeOfAdministrationCode) ||
        nz(mahGln) ||
        nz(mahName) ||
        nz(mahCountry) ||
        nz(licensedAgentGlns) ||
        nz(additionalAtcCodes) ||
        nz(maNumber) ||
        nz(regulatoryStatus) ||
        nz(shelfLifeMonths) ||
        nz(shelfLifeAfterOpenDays) ||
        nz(countryOfManufacture) ||
        nz(packSizeDescription) ||
        nz(inactiveIngredients) ||
        nz(fdaApplicationNumber) ||
        nz(emaProcedureNumber) ||
        nz(nhmnGermanyPzn) ||
        nz(nhmnFranceCip) ||
        nz(nhmnSpainCn) ||
        nz(nhmnBrazilAnvisa) ||
        nz(nhmnPortugalAim) ||
        nz(nhmnUsaNdc) ||
        nz(nhmnItalyAifa) ||
        nz(localDrugCodeUaeGcc) ||
        nz(dataCarrierTypeCode) ||
        nz(activePotencyAi7004) ||
        nz(contraindications) ||
        nz(drugInteractions) ||
        nz(blackBoxWarningText) ||
        nz(storageConditions) ||
        nz(strengthUnit) ||
        nz(prescriptionType) ||
        nz(controlClass) ||
        nz(minStorageTemp) ||
        nz(maxStorageTemp);
    if (spec) return true;

    if (activeIngredients.any((r) => nz(r.name))) return true;

    if (fdaApprovalDate != null || emaApprovalDate != null) return true;
    if (maValidFrom != null || maValidTo != null) return true;

    if (coldChainRequired ||
        antiTamperingIndicator ||
        pseudoGtinNtinFlag ||
        !requiresPrescription ||
        isControlledSubstance ||
        deaSchedule != DeaSchedule.none ||
        controlledSubstance ||
        additionalMonitoring ||
        blackBoxWarning ||
        pregnancyCategory != PregnancyCategory.notClassified ||
        requiresFreezing ||
        requiresRefrigeration ||
        lightSensitive ||
        humiditySensitive) {
      return true;
    }

    return false;
  }

  String? validate() {
    return null;
  }

  GTINPharmaceuticalExtension _composeExtension({
    required int gtinId,
    String? gtinCode,
  }) {
    return GTINPharmaceuticalExtension(
      id: extension?.id,
      gtinId: gtinId,
      gtinCode: gtinCode,
      ndcNumber: ndcNumber.trim().isEmpty ? null : ndcNumber.trim(),
      dinNumber: dinNumber.trim().isEmpty ? null : dinNumber.trim(),
      eanPharmaCode: eanPharmaCode.trim().isEmpty
          ? null
          : eanPharmaCode.trim(),
      drugClass: drugClass.trim().isEmpty ? null : drugClass.trim(),
      therapeuticClass: therapeuticClass.trim().isEmpty
          ? null
          : therapeuticClass.trim(),
      pharmacologicalClass: pharmacologicalClass.trim().isEmpty
          ? null
          : pharmacologicalClass.trim(),
      atcCode: atcCode.trim().isEmpty ? null : atcCode.trim(),
      isControlledSubstance: isControlledSubstance,
      deaSchedule: deaSchedule,
      controlClass: controlClass.trim().isEmpty ? null : controlClass.trim(),
      dosageForm: dosageForm.trim().isEmpty ? null : dosageForm.trim(),
      strength: strength.trim().isEmpty ? null : strength.trim(),
      strengthUnit: strengthUnit.trim().isEmpty ? null : strengthUnit.trim(),
      routeOfAdministration: routeOfAdministration.trim().isEmpty
          ? null
          : routeOfAdministration.trim(),
      storageConditions: storageConditions.trim().isEmpty
          ? null
          : storageConditions.trim(),
      minStorageTempCelsius: double.tryParse(minStorageTemp),
      maxStorageTempCelsius: double.tryParse(maxStorageTemp),
      requiresRefrigeration: requiresRefrigeration,
      requiresFreezing: requiresFreezing,
      lightSensitive: lightSensitive,
      humiditySensitive: humiditySensitive,
      requiresPrescription: requiresPrescription,
      prescriptionType: prescriptionType.trim().isEmpty
          ? null
          : prescriptionType.trim(),
      fdaApprovalDate: fdaApprovalDate,
      fdaApplicationNumber: fdaApplicationNumber.trim().isEmpty
          ? null
          : fdaApplicationNumber.trim(),
      emaApprovalDate: emaApprovalDate,
      emaProcedureNumber: emaProcedureNumber.trim().isEmpty
          ? null
          : emaProcedureNumber.trim(),
      activeIngredients: activeIngredients
          .where((i) => i.name.trim().isNotEmpty)
          .toList(growable: false),
      inactiveIngredients: inactiveIngredients.trim().isEmpty
          ? null
          : inactiveIngredients.trim(),
      blackBoxWarning: blackBoxWarning,
      blackBoxWarningText: blackBoxWarningText.trim().isEmpty
          ? null
          : blackBoxWarningText.trim(),
      contraindications: contraindications.trim().isEmpty
          ? null
          : contraindications.trim(),
      drugInteractions: drugInteractions.trim().isEmpty
          ? null
          : drugInteractions.trim(),
      pregnancyCategory: pregnancyCategory,
      regulatedProductName: regulatedProductName.trim().isEmpty
          ? null
          : regulatedProductName.trim(),
      dosageFormTypeCode: dosageFormTypeCode.trim().isEmpty
          ? null
          : dosageFormTypeCode.trim(),
      routeOfAdministrationEdqmCode: routeOfAdministrationCode.trim().isEmpty
          ? null
          : routeOfAdministrationCode.trim(),
      mahGln: mahGln.trim().isEmpty ? null : mahGln.trim(),
      mahName: mahName.trim().isEmpty ? null : mahName.trim(),
      mahCountry: mahCountry.trim().isEmpty ? null : mahCountry.trim(),
      licensedAgentGlns: _splitDelimitedGlnsOrCodes(licensedAgentGlns),
      marketingAuthorizationNumber: maNumber.trim().isEmpty
          ? null
          : maNumber.trim(),
      marketingAuthorizationValidFrom: maValidFrom,
      marketingAuthorizationValidTo: maValidTo,
      regulatoryStatus: regulatoryStatus.trim().isEmpty
          ? null
          : regulatoryStatus.trim(),
      additionalAtcCodes: _splitDelimitedGlnsOrCodes(additionalAtcCodes),
      nhmnGermanyPzn: nhmnGermanyPzn.trim().isEmpty
          ? null
          : nhmnGermanyPzn.trim(),
      nhmnFranceCip: nhmnFranceCip.trim().isEmpty
          ? null
          : nhmnFranceCip.trim(),
      nhmnSpainCn: nhmnSpainCn.trim().isEmpty ? null : nhmnSpainCn.trim(),
      nhmnBrazilAnvisa: nhmnBrazilAnvisa.trim().isEmpty
          ? null
          : nhmnBrazilAnvisa.trim(),
      nhmnPortugalAim: nhmnPortugalAim.trim().isEmpty
          ? null
          : nhmnPortugalAim.trim(),
      nhmnUsaNdc: nhmnUsaNdc.trim().isEmpty ? null : nhmnUsaNdc.trim(),
      nhmnItalyAifa: nhmnItalyAifa.trim().isEmpty
          ? null
          : nhmnItalyAifa.trim(),
      localDrugCodeUaeGcc: localDrugCodeUaeGcc.trim().isEmpty
          ? null
          : localDrugCodeUaeGcc.trim(),
      dataCarrierTypeCode: dataCarrierTypeCode.trim().isEmpty
          ? null
          : dataCarrierTypeCode.trim(),
      antiTamperingIndicator: antiTamperingIndicator,
      pseudoGtinNtinFlag: pseudoGtinNtinFlag,
      coldChainRequired: coldChainRequired,
      prescriptionStatusCategory: prescriptionStatus,
      specControlledSubstanceIndicator: controlledSubstance,
      specControlledSubstanceSchedule:
          controlledSubstanceSchedule.trim().isEmpty
          ? null
          : controlledSubstanceSchedule.trim(),
      additionalMonitoringIndicator: additionalMonitoring,
      shelfLifeMonths: int.tryParse(shelfLifeMonths.trim()),
      shelfLifeAfterOpeningDays: int.tryParse(shelfLifeAfterOpenDays.trim()),
      countryOfManufactureNumeric: countryOfManufacture.trim().isEmpty
          ? null
          : countryOfManufacture.trim(),
      packSizeDescription: packSizeDescription.trim().isEmpty
          ? null
          : packSizeDescription.trim(),
      activePotencyAi7004: double.tryParse(activePotencyAi7004.trim()),
      createdAt: extension?.createdAt,
      updatedAt: extension?.updatedAt,
    );
  }

  GTINPharmaceuticalExtension? buildExtension({int? gtinId, String? gtinCode}) {
    if (!hasData) return null;
    return _composeExtension(
      gtinId: gtinId ?? widget.gtinId ?? 0,
      gtinCode: gtinCode ?? widget.gtinCode,
    );
  }

  void applyRegulatoryAuthorityValues({
    required String localDrugCode,
    required String marketingAuthorizationNumber,
    required String licensedAgentGlns,
    required String regulatedProductName,
  }) {
    localDrugCodeUaeGcc = localDrugCode;
    maNumber = marketingAuthorizationNumber;
    licensedAgentGlns = licensedAgentGlns;
    regulatedProductName = regulatedProductName;
  }
}
