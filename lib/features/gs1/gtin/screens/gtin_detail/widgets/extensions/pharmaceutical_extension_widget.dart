import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_grouped_body.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

part 'pharmaceutical_extension_actions.dart';

class PharmaceuticalExtensionWidget extends StatefulWidget {
  final int? gtinId;
  final String? gtinCode;
  final bool isEditing;
  final String? targetMarketCountry;
  final Function(GTINPharmaceuticalExtension?)? onSaved;
  final GTINPharmaceuticalExtension? initialExtension;

  final bool deferInitialExtensionFetch;

  final bool extensionFetchResolved;

  const PharmaceuticalExtensionWidget({
    Key? key,
    this.gtinId,
    this.gtinCode,
    this.isEditing = false,
    this.targetMarketCountry,
    this.onSaved,
    this.initialExtension,
    this.deferInitialExtensionFetch = false,
    this.extensionFetchResolved = true,
  }) : super(key: key);

  @override
  State<PharmaceuticalExtensionWidget> createState() =>
      PharmaceuticalExtensionWidgetState();
}

class PharmaceuticalExtensionWidgetState
    extends State<PharmaceuticalExtensionWidget> {
  GTINPharmaceuticalExtension? _extension;
  bool _isLoading = true;

  String _ndcNumber = '';
  String _dinNumber = '';
  String _eanPharmaCode = '';

  String _drugClass = '';
  String _therapeuticClass = '';
  String _pharmacologicalClass = '';
  String _atcCode = '';

  bool _isControlledSubstance = false;
  DeaSchedule _deaSchedule = DeaSchedule.none;
  String _controlClass = '';

  String _dosageForm = '';
  String _strength = '';
  String _strengthUnit = '';
  String _routeOfAdministration = '';
  List<ActiveIngredient> _activeIngredients = [];
  String _inactiveIngredients = '';

  String _storageConditions = '';
  String _minStorageTemp = '';
  String _maxStorageTemp = '';
  bool _requiresRefrigeration = false;
  bool _requiresFreezing = false;
  bool _lightSensitive = false;
  bool _humiditySensitive = false;

  bool _requiresPrescription = true;
  String _prescriptionType = '';

  DateTime? _fdaApprovalDate;
  String _fdaApplicationNumber = '';
  DateTime? _emaApprovalDate;
  String _emaProcedureNumber = '';

  bool _blackBoxWarning = false;
  String _blackBoxWarningText = '';
  String _contraindications = '';
  String _drugInteractions = '';
  PregnancyCategory _pregnancyCategory = PregnancyCategory.notClassified;

  String _regulatedProductName = '';
  String _dosageFormTypeCode = '';
  String _routeOfAdministrationCode = '';

  String _mahGln = '';
  String _mahName = '';
  String _mahCountry = '';
  String _licensedAgentGlns = '';
  String _additionalAtcCodes = '';

  String _maNumber = '';
  DateTime? _maValidFrom;
  DateTime? _maValidTo;

  String _regulatoryStatus = '';

  String _prescriptionStatus = 'RX';
  bool _controlledSubstance = false;
  String _controlledSubstanceSchedule = '';
  bool _additionalMonitoring = false;

  String _shelfLifeMonths = '';
  String _shelfLifeAfterOpenDays = '';

  String _countryOfManufacture = '';
  String _packSizeDescription = '';

  String _nhmnGermanyPzn = '';
  String _nhmnFranceCip = '';
  String _nhmnSpainCn = '';
  String _nhmnBrazilAnvisa = '';
  String _nhmnPortugalAim = '';
  String _nhmnUsaNdc = '';
  String _nhmnItalyAifa = '';
  String _localDrugCodeUaeGcc = '';

  String _dataCarrierTypeCode = '';
  bool _antiTamperingIndicator = false;
  bool _pseudoGtinNtinFlag = false;
  bool _coldChainRequired = false;

  String _activePotencyAi7004 = '';
  @override
  void initState() {
    super.initState();
    if (widget.initialExtension != null) {
      _populateFormFromExtension(widget.initialExtension!);
      _extension = widget.initialExtension;
      _isLoading = false;
    } else {
      _isLoading =
          widget.deferInitialExtensionFetch && !widget.extensionFetchResolved;
    }
  }

  @override
  void didUpdateWidget(covariant PharmaceuticalExtensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deferInitialExtensionFetch) {
      if (!widget.extensionFetchResolved && oldWidget.extensionFetchResolved) {
        _applyState(() => _isLoading = true);
      }
      if (widget.extensionFetchResolved && !oldWidget.extensionFetchResolved) {
        _applyState(() {
          _isLoading = false;
          if (widget.initialExtension != null) {
            _populateFormFromExtension(widget.initialExtension!);
            _extension = widget.initialExtension;
          }
        });
      }
    }
    if (widget.initialExtension != oldWidget.initialExtension) {
      final next = widget.initialExtension;
      if (next != null) {
        _populateFormFromExtension(next);
        _applyState(() {
          _extension = next;
          _isLoading = false;
        });
      }
    }
  }

  void _applyState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmaceuticalMode = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      isPharmaceuticalMode = settings.isPharmaceuticalMode;
    } catch (e) {
      return const SizedBox.shrink();
    }

    if (!isPharmaceuticalMode) {
      return const SizedBox.shrink();
    }

    return PharmaceuticalExtensionGroupedBody(
      isEditing: widget.isEditing,
      isLoading: _isLoading,
      initialNdcNumber: _ndcNumber,
      initialDinNumber: _dinNumber,
      initialEanPharmaCode: _eanPharmaCode,
      initialDrugClass: _drugClass,
      initialTherapeuticClass: _therapeuticClass,
      initialPharmacologicalClass: _pharmacologicalClass,
      initialAtcCode: _atcCode,
      initialAdditionalAtcCodes: _additionalAtcCodes,
      initialIsControlledSubstance: _isControlledSubstance,
      initialDeaSchedule: _deaSchedule,
      initialControlClass: _controlClass,
      initialDosageForm: _dosageForm,
      initialStrength: _strength,
      initialStrengthUnit: _strengthUnit,
      initialRouteOfAdministration: _routeOfAdministration,
      initialActiveIngredients: _activeIngredients,
      initialInactiveIngredients: _inactiveIngredients,
      initialStorageConditions: _storageConditions,
      initialMinStorageTemp: _minStorageTemp,
      initialMaxStorageTemp: _maxStorageTemp,
      initialRequiresRefrigeration: _requiresRefrigeration,
      initialRequiresFreezing: _requiresFreezing,
      initialLightSensitive: _lightSensitive,
      initialHumiditySensitive: _humiditySensitive,
      initialColdChainRequired: _coldChainRequired,
      initialRequiresPrescription: _requiresPrescription,
      initialPrescriptionType: _prescriptionType,
      initialFdaApplicationNumber: _fdaApplicationNumber,
      initialFdaApprovalDate: _fdaApprovalDate,
      initialEmaProcedureNumber: _emaProcedureNumber,
      initialEmaApprovalDate: _emaApprovalDate,
      initialBlackBoxWarning: _blackBoxWarning,
      initialBlackBoxWarningText: _blackBoxWarningText,
      initialPregnancyCategory: _pregnancyCategory,
      initialContraindications: _contraindications,
      initialDrugInteractions: _drugInteractions,
      initialRegulatedProductName: _regulatedProductName,
      initialDosageFormTypeCode: _dosageFormTypeCode,
      initialRouteOfAdministrationCode: _routeOfAdministrationCode,
      initialMahGln: _mahGln,
      initialMahName: _mahName,
      initialMahCountry: _mahCountry,
      initialLicensedAgentGlns: _licensedAgentGlns,
      initialMaNumber: _maNumber,
      initialMaValidFrom: _maValidFrom,
      initialMaValidTo: _maValidTo,
      initialRegulatoryStatus: _regulatoryStatus,
      initialPrescriptionStatus: _prescriptionStatus,
      initialControlledSubstance: _controlledSubstance,
      initialControlledSubstanceSchedule: _controlledSubstanceSchedule,
      initialAdditionalMonitoring: _additionalMonitoring,
      initialShelfLifeMonths: _shelfLifeMonths,
      initialShelfLifeAfterOpenDays: _shelfLifeAfterOpenDays,
      initialCountryOfManufacture: _countryOfManufacture,
      initialPackSizeDescription: _packSizeDescription,
      initialActivePotencyAi7004: _activePotencyAi7004,
      initialNhmnGermanyPzn: _nhmnGermanyPzn,
      initialNhmnFranceCip: _nhmnFranceCip,
      initialNhmnSpainCn: _nhmnSpainCn,
      initialNhmnBrazilAnvisa: _nhmnBrazilAnvisa,
      initialNhmnPortugalAim: _nhmnPortugalAim,
      initialNhmnUsaNdc: _nhmnUsaNdc,
      initialNhmnItalyAifa: _nhmnItalyAifa,
      initialLocalDrugCodeUaeGcc: _localDrugCodeUaeGcc,
      initialDataCarrierTypeCode: _dataCarrierTypeCode,
      initialAntiTamperingIndicator: _antiTamperingIndicator,
      initialPseudoGtinNtinFlag: _pseudoGtinNtinFlag,
      onDrugIdentificationChanged:
          ({required ndcNumber, required dinNumber, required eanPharmaCode}) {
            _ndcNumber = ndcNumber;
            _dinNumber = dinNumber;
            _eanPharmaCode = eanPharmaCode;
          },
      onDrugClassificationChanged:
          ({
            required drugClass,
            required therapeuticClass,
            required pharmacologicalClass,
            required atcCode,
            required additionalAtcCodes,
          }) {
            _drugClass = drugClass;
            _therapeuticClass = therapeuticClass;
            _pharmacologicalClass = pharmacologicalClass;
            _atcCode = atcCode;
            _additionalAtcCodes = additionalAtcCodes;
          },
      onControlledSubstanceChanged:
          ({
            required isControlledSubstance,
            required deaSchedule,
            required controlClass,
          }) {
            _isControlledSubstance = isControlledSubstance;
            _deaSchedule = deaSchedule;
            _controlClass = controlClass;
          },
      onDosageRouteCompositionChanged:
          ({
            required dosageForm,
            required strength,
            required strengthUnit,
            required routeOfAdministration,
            required activeIngredients,
            required inactiveIngredients,
          }) {
            _dosageForm = dosageForm;
            _strength = strength;
            _strengthUnit = strengthUnit;
            _routeOfAdministration = routeOfAdministration;
            _activeIngredients = activeIngredients;
            _inactiveIngredients = inactiveIngredients;
          },
      onStorageHandlingChanged:
          ({
            required storageConditions,
            required minStorageTemp,
            required maxStorageTemp,
            required requiresRefrigeration,
            required requiresFreezing,
            required lightSensitive,
            required humiditySensitive,
            required coldChainRequired,
          }) {
            _storageConditions = storageConditions;
            _minStorageTemp = minStorageTemp;
            _maxStorageTemp = maxStorageTemp;
            _requiresRefrigeration = requiresRefrigeration;
            _requiresFreezing = requiresFreezing;
            _lightSensitive = lightSensitive;
            _humiditySensitive = humiditySensitive;
            _coldChainRequired = coldChainRequired;
          },
      onPrescriptionRequirementsChanged:
          ({required requiresPrescription, required prescriptionType}) {
            _requiresPrescription = requiresPrescription;
            _prescriptionType = prescriptionType;
          },
      onRegulatoryApprovalsChanged:
          ({
            required fdaApplicationNumber,
            required fdaApprovalDate,
            required emaProcedureNumber,
            required emaApprovalDate,
          }) {
            _fdaApplicationNumber = fdaApplicationNumber;
            _fdaApprovalDate = fdaApprovalDate;
            _emaProcedureNumber = emaProcedureNumber;
            _emaApprovalDate = emaApprovalDate;
          },
      onWarningsPrecautionsChanged:
          ({
            required blackBoxWarning,
            required blackBoxWarningText,
            required pregnancyCategory,
            required contraindications,
            required drugInteractions,
          }) {
            _blackBoxWarning = blackBoxWarning;
            _blackBoxWarningText = blackBoxWarningText;
            _pregnancyCategory = pregnancyCategory;
            _contraindications = contraindications;
            _drugInteractions = drugInteractions;
          },
      onTechProductCodedChanged:
          ({
            required regulatedProductName,
            required dosageFormTypeCode,
            required routeOfAdministrationCode,
          }) {
            _regulatedProductName = regulatedProductName;
            _dosageFormTypeCode = dosageFormTypeCode;
            _routeOfAdministrationCode = routeOfAdministrationCode;
          },
      onTechMahAuthorizationChanged:
          ({
            required mahGln,
            required mahName,
            required mahCountry,
            required licensedAgentGlns,
            required maNumber,
            required maValidFrom,
            required maValidTo,
            required regulatoryStatus,
          }) {
            _mahGln = mahGln;
            _mahName = mahName;
            _mahCountry = mahCountry;
            _licensedAgentGlns = licensedAgentGlns;
            _maNumber = maNumber;
            _maValidFrom = maValidFrom;
            _maValidTo = maValidTo;
            _regulatoryStatus = regulatoryStatus;
          },
      onTechDispensingLifecycleChanged:
          ({
            required prescriptionStatus,
            required controlledSubstance,
            required controlledSubstanceSchedule,
            required additionalMonitoring,
            required shelfLifeMonths,
            required shelfLifeAfterOpenDays,
            required countryOfManufacture,
            required packSizeDescription,
            required activePotencyAi7004,
          }) {
            _prescriptionStatus = prescriptionStatus;
            _controlledSubstance = controlledSubstance;
            _controlledSubstanceSchedule = controlledSubstanceSchedule;
            _additionalMonitoring = additionalMonitoring;
            _shelfLifeMonths = shelfLifeMonths;
            _shelfLifeAfterOpenDays = shelfLifeAfterOpenDays;
            _countryOfManufacture = countryOfManufacture;
            _packSizeDescription = packSizeDescription;
            _activePotencyAi7004 = activePotencyAi7004;
          },
      onNationalIdentifiersChanged:
          ({
            required nhmnGermanyPzn,
            required nhmnFranceCip,
            required nhmnSpainCn,
            required nhmnBrazilAnvisa,
            required nhmnPortugalAim,
            required nhmnUsaNdc,
            required nhmnItalyAifa,
            required localDrugCodeUaeGcc,
          }) {
            _nhmnGermanyPzn = nhmnGermanyPzn;
            _nhmnFranceCip = nhmnFranceCip;
            _nhmnSpainCn = nhmnSpainCn;
            _nhmnBrazilAnvisa = nhmnBrazilAnvisa;
            _nhmnPortugalAim = nhmnPortugalAim;
            _nhmnUsaNdc = nhmnUsaNdc;
            _nhmnItalyAifa = nhmnItalyAifa;
            _localDrugCodeUaeGcc = localDrugCodeUaeGcc;
          },
      onDataCarrierIntegrityChanged:
          ({required dataCarrierTypeCode, required antiTamperingIndicator}) {
            _dataCarrierTypeCode = dataCarrierTypeCode;
            _antiTamperingIndicator = antiTamperingIndicator;
          },
    );
  }
}
