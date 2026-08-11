part of 'pharmaceutical_extension_widget.dart';

extension PharmaceuticalExtensionActions on PharmaceuticalExtensionWidgetState {
  static List<String> _splitDelimitedGlnsOrCodes(String raw) {
    if (raw.trim().isEmpty) return const [];
    final parts = raw.split(RegExp(r'[\s,;\n]+'));
    return parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  void _populateFormFromExtension(GTINPharmaceuticalExtension ext) {
    _ndcNumber = ext.ndcNumber ?? '';
    _dinNumber = ext.dinNumber ?? '';
    _eanPharmaCode = ext.eanPharmaCode ?? '';
    _drugClass = ext.drugClass ?? '';
    _therapeuticClass = ext.therapeuticClass ?? '';
    _pharmacologicalClass = ext.pharmacologicalClass ?? '';
    _atcCode = ext.atcCode ?? '';
    _isControlledSubstance = ext.isControlledSubstance;
    _deaSchedule = ext.deaSchedule;
    _controlClass = ext.controlClass ?? '';
    _dosageForm = ext.dosageForm ?? '';
    _strength = ext.strength ?? '';
    _strengthUnit = ext.strengthUnit ?? '';
    _routeOfAdministration = ext.routeOfAdministration ?? '';
    _storageConditions = ext.storageConditions ?? '';
    _minStorageTemp = ext.minStorageTempCelsius?.toString() ?? '';
    _maxStorageTemp = ext.maxStorageTempCelsius?.toString() ?? '';
    _requiresRefrigeration = ext.requiresRefrigeration;
    _requiresFreezing = ext.requiresFreezing;
    _lightSensitive = ext.lightSensitive;
    _humiditySensitive = ext.humiditySensitive;
    _requiresPrescription = ext.requiresPrescription;
    _prescriptionType = ext.prescriptionType ?? '';
    _fdaApprovalDate = ext.fdaApprovalDate;
    _fdaApplicationNumber = ext.fdaApplicationNumber ?? '';
    _emaApprovalDate = ext.emaApprovalDate;
    _emaProcedureNumber = ext.emaProcedureNumber ?? '';
    _blackBoxWarning = ext.blackBoxWarning;
    _blackBoxWarningText = ext.blackBoxWarningText ?? '';
    _contraindications = ext.contraindications ?? '';
    _drugInteractions = ext.drugInteractions ?? '';
    _pregnancyCategory = ext.pregnancyCategory;

    _regulatedProductName = ext.regulatedProductName ?? '';
    _dosageFormTypeCode = ext.dosageFormTypeCode ?? '';
    _routeOfAdministrationCode = ext.routeOfAdministrationEdqmCode ?? '';
    _mahGln = ext.mahGln ?? '';
    _mahName = ext.mahName ?? '';
    _mahCountry = ext.mahCountry ?? '';
    _licensedAgentGlns = ext.licensedAgentGlns.join(', ');
    _additionalAtcCodes = ext.additionalAtcCodes.join(', ');
    _maNumber = ext.marketingAuthorizationNumber ?? '';
    _maValidFrom = ext.marketingAuthorizationValidFrom;
    _maValidTo = ext.marketingAuthorizationValidTo;
    _regulatoryStatus = ext.regulatoryStatus ?? '';
    _prescriptionStatus =
        (ext.prescriptionStatusCategory != null &&
            ext.prescriptionStatusCategory!.isNotEmpty &&
            PharmaFieldValidators.prescriptionStatusCodes.contains(
              ext.prescriptionStatusCategory,
            ))
        ? ext.prescriptionStatusCategory!
        : 'RX';
    _controlledSubstance = ext.specControlledSubstanceIndicator;
    _controlledSubstanceSchedule = ext.specControlledSubstanceSchedule ?? '';
    _additionalMonitoring = ext.additionalMonitoringIndicator;
    _shelfLifeMonths = ext.shelfLifeMonths?.toString() ?? '';
    _shelfLifeAfterOpenDays = ext.shelfLifeAfterOpeningDays?.toString() ?? '';
    _countryOfManufacture = ext.countryOfManufactureNumeric ?? '';
    _packSizeDescription = ext.packSizeDescription ?? '';

    _nhmnGermanyPzn = ext.nhmnGermanyPzn ?? '';
    _nhmnFranceCip = ext.nhmnFranceCip ?? '';
    _nhmnSpainCn = ext.nhmnSpainCn ?? '';
    _nhmnBrazilAnvisa = ext.nhmnBrazilAnvisa ?? '';
    _nhmnPortugalAim = ext.nhmnPortugalAim ?? '';
    _nhmnUsaNdc = ext.nhmnUsaNdc ?? '';
    _nhmnItalyAifa = ext.nhmnItalyAifa ?? '';
    _localDrugCodeUaeGcc = ext.localDrugCodeUaeGcc ?? '';

    _dataCarrierTypeCode = ext.dataCarrierTypeCode ?? '';
    _antiTamperingIndicator = ext.antiTamperingIndicator;
    _pseudoGtinNtinFlag = ext.pseudoGtinNtinFlag;
    _coldChainRequired = ext.coldChainRequired;
    _activePotencyAi7004 = ext.activePotencyAi7004?.toString() ?? '';
    _inactiveIngredients = ext.inactiveIngredients ?? '';
    _activeIngredients = List<ActiveIngredient>.from(ext.activeIngredients);
  }

  bool get hasData {
    bool nz(String s) => s.trim().isNotEmpty;

    final basics =
        nz(_ndcNumber) ||
        nz(_dinNumber) ||
        nz(_eanPharmaCode) ||
        nz(_drugClass) ||
        nz(_dosageForm) ||
        nz(_strength) ||
        nz(_therapeuticClass) ||
        nz(_pharmacologicalClass) ||
        nz(_atcCode);
    if (basics) return true;

    final spec =
        nz(_regulatedProductName) ||
        nz(_dosageFormTypeCode) ||
        nz(_routeOfAdministrationCode) ||
        nz(_mahGln) ||
        nz(_mahName) ||
        nz(_mahCountry) ||
        nz(_licensedAgentGlns) ||
        nz(_additionalAtcCodes) ||
        nz(_maNumber) ||
        nz(_regulatoryStatus) ||
        nz(_shelfLifeMonths) ||
        nz(_shelfLifeAfterOpenDays) ||
        nz(_countryOfManufacture) ||
        nz(_packSizeDescription) ||
        nz(_inactiveIngredients) ||
        nz(_fdaApplicationNumber) ||
        nz(_emaProcedureNumber) ||
        nz(_nhmnGermanyPzn) ||
        nz(_nhmnFranceCip) ||
        nz(_nhmnSpainCn) ||
        nz(_nhmnBrazilAnvisa) ||
        nz(_nhmnPortugalAim) ||
        nz(_nhmnUsaNdc) ||
        nz(_nhmnItalyAifa) ||
        nz(_localDrugCodeUaeGcc) ||
        nz(_dataCarrierTypeCode) ||
        nz(_activePotencyAi7004) ||
        nz(_contraindications) ||
        nz(_drugInteractions) ||
        nz(_blackBoxWarningText) ||
        nz(_storageConditions) ||
        nz(_strengthUnit) ||
        nz(_prescriptionType) ||
        nz(_controlClass) ||
        nz(_minStorageTemp) ||
        nz(_maxStorageTemp);
    if (spec) return true;

    if (_activeIngredients.any((r) => nz(r.name))) return true;

    if (_fdaApprovalDate != null || _emaApprovalDate != null) return true;
    if (_maValidFrom != null || _maValidTo != null) return true;

    if (_coldChainRequired ||
        _antiTamperingIndicator ||
        _pseudoGtinNtinFlag ||
        !_requiresPrescription ||
        _isControlledSubstance ||
        _deaSchedule != DeaSchedule.none ||
        _controlledSubstance ||
        _additionalMonitoring ||
        _blackBoxWarning ||
        _pregnancyCategory != PregnancyCategory.notClassified ||
        _requiresFreezing ||
        _requiresRefrigeration ||
        _lightSensitive ||
        _humiditySensitive) {
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
      id: _extension?.id,
      gtinId: gtinId,
      gtinCode: gtinCode,
      ndcNumber: _ndcNumber.trim().isEmpty ? null : _ndcNumber.trim(),
      dinNumber: _dinNumber.trim().isEmpty ? null : _dinNumber.trim(),
      eanPharmaCode: _eanPharmaCode.trim().isEmpty
          ? null
          : _eanPharmaCode.trim(),
      drugClass: _drugClass.trim().isEmpty ? null : _drugClass.trim(),
      therapeuticClass: _therapeuticClass.trim().isEmpty
          ? null
          : _therapeuticClass.trim(),
      pharmacologicalClass: _pharmacologicalClass.trim().isEmpty
          ? null
          : _pharmacologicalClass.trim(),
      atcCode: _atcCode.trim().isEmpty ? null : _atcCode.trim(),
      isControlledSubstance: _isControlledSubstance,
      deaSchedule: _deaSchedule,
      controlClass: _controlClass.trim().isEmpty ? null : _controlClass.trim(),
      dosageForm: _dosageForm.trim().isEmpty ? null : _dosageForm.trim(),
      strength: _strength.trim().isEmpty ? null : _strength.trim(),
      strengthUnit: _strengthUnit.trim().isEmpty ? null : _strengthUnit.trim(),
      routeOfAdministration: _routeOfAdministration.trim().isEmpty
          ? null
          : _routeOfAdministration.trim(),
      storageConditions: _storageConditions.trim().isEmpty
          ? null
          : _storageConditions.trim(),
      minStorageTempCelsius: double.tryParse(_minStorageTemp),
      maxStorageTempCelsius: double.tryParse(_maxStorageTemp),
      requiresRefrigeration: _requiresRefrigeration,
      requiresFreezing: _requiresFreezing,
      lightSensitive: _lightSensitive,
      humiditySensitive: _humiditySensitive,
      requiresPrescription: _requiresPrescription,
      prescriptionType: _prescriptionType.trim().isEmpty
          ? null
          : _prescriptionType.trim(),
      fdaApprovalDate: _fdaApprovalDate,
      fdaApplicationNumber: _fdaApplicationNumber.trim().isEmpty
          ? null
          : _fdaApplicationNumber.trim(),
      emaApprovalDate: _emaApprovalDate,
      emaProcedureNumber: _emaProcedureNumber.trim().isEmpty
          ? null
          : _emaProcedureNumber.trim(),
      activeIngredients: _activeIngredients
          .where((i) => i.name.trim().isNotEmpty)
          .toList(growable: false),
      inactiveIngredients: _inactiveIngredients.trim().isEmpty
          ? null
          : _inactiveIngredients.trim(),
      blackBoxWarning: _blackBoxWarning,
      blackBoxWarningText: _blackBoxWarningText.trim().isEmpty
          ? null
          : _blackBoxWarningText.trim(),
      contraindications: _contraindications.trim().isEmpty
          ? null
          : _contraindications.trim(),
      drugInteractions: _drugInteractions.trim().isEmpty
          ? null
          : _drugInteractions.trim(),
      pregnancyCategory: _pregnancyCategory,
      regulatedProductName: _regulatedProductName.trim().isEmpty
          ? null
          : _regulatedProductName.trim(),
      dosageFormTypeCode: _dosageFormTypeCode.trim().isEmpty
          ? null
          : _dosageFormTypeCode.trim(),
      routeOfAdministrationEdqmCode: _routeOfAdministrationCode.trim().isEmpty
          ? null
          : _routeOfAdministrationCode.trim(),
      mahGln: _mahGln.trim().isEmpty ? null : _mahGln.trim(),
      mahName: _mahName.trim().isEmpty ? null : _mahName.trim(),
      mahCountry: _mahCountry.trim().isEmpty ? null : _mahCountry.trim(),
      licensedAgentGlns: _splitDelimitedGlnsOrCodes(_licensedAgentGlns),
      marketingAuthorizationNumber: _maNumber.trim().isEmpty
          ? null
          : _maNumber.trim(),
      marketingAuthorizationValidFrom: _maValidFrom,
      marketingAuthorizationValidTo: _maValidTo,
      regulatoryStatus: _regulatoryStatus.trim().isEmpty
          ? null
          : _regulatoryStatus.trim(),
      additionalAtcCodes: _splitDelimitedGlnsOrCodes(_additionalAtcCodes),
      nhmnGermanyPzn: _nhmnGermanyPzn.trim().isEmpty
          ? null
          : _nhmnGermanyPzn.trim(),
      nhmnFranceCip: _nhmnFranceCip.trim().isEmpty
          ? null
          : _nhmnFranceCip.trim(),
      nhmnSpainCn: _nhmnSpainCn.trim().isEmpty ? null : _nhmnSpainCn.trim(),
      nhmnBrazilAnvisa: _nhmnBrazilAnvisa.trim().isEmpty
          ? null
          : _nhmnBrazilAnvisa.trim(),
      nhmnPortugalAim: _nhmnPortugalAim.trim().isEmpty
          ? null
          : _nhmnPortugalAim.trim(),
      nhmnUsaNdc: _nhmnUsaNdc.trim().isEmpty ? null : _nhmnUsaNdc.trim(),
      nhmnItalyAifa: _nhmnItalyAifa.trim().isEmpty
          ? null
          : _nhmnItalyAifa.trim(),
      localDrugCodeUaeGcc: _localDrugCodeUaeGcc.trim().isEmpty
          ? null
          : _localDrugCodeUaeGcc.trim(),
      dataCarrierTypeCode: _dataCarrierTypeCode.trim().isEmpty
          ? null
          : _dataCarrierTypeCode.trim(),
      antiTamperingIndicator: _antiTamperingIndicator,
      pseudoGtinNtinFlag: _pseudoGtinNtinFlag,
      coldChainRequired: _coldChainRequired,
      prescriptionStatusCategory: _prescriptionStatus,
      specControlledSubstanceIndicator: _controlledSubstance,
      specControlledSubstanceSchedule:
          _controlledSubstanceSchedule.trim().isEmpty
          ? null
          : _controlledSubstanceSchedule.trim(),
      additionalMonitoringIndicator: _additionalMonitoring,
      shelfLifeMonths: int.tryParse(_shelfLifeMonths.trim()),
      shelfLifeAfterOpeningDays: int.tryParse(_shelfLifeAfterOpenDays.trim()),
      countryOfManufactureNumeric: _countryOfManufacture.trim().isEmpty
          ? null
          : _countryOfManufacture.trim(),
      packSizeDescription: _packSizeDescription.trim().isEmpty
          ? null
          : _packSizeDescription.trim(),
      activePotencyAi7004: double.tryParse(_activePotencyAi7004.trim()),
      createdAt: _extension?.createdAt,
      updatedAt: _extension?.updatedAt,
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
    _localDrugCodeUaeGcc = localDrugCode;
    _maNumber = marketingAuthorizationNumber;
    _licensedAgentGlns = licensedAgentGlns;
    _regulatedProductName = regulatedProductName;
  }
}
