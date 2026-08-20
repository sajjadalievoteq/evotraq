import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_grouped_body.dart';

import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_actions.dart';

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
  GTINPharmaceuticalExtension? extension;
  bool _isLoading = true;

  String ndcNumber = '';
  String dinNumber = '';
  String eanPharmaCode = '';

  String drugClass = '';
  String therapeuticClass = '';
  String pharmacologicalClass = '';
  String atcCode = '';

  bool isControlledSubstance = false;
  DeaSchedule deaSchedule = DeaSchedule.none;
  String controlClass = '';

  String dosageForm = '';
  String strength = '';
  String strengthUnit = '';
  String routeOfAdministration = '';
  List<ActiveIngredient> activeIngredients = [];
  String inactiveIngredients = '';

  String storageConditions = '';
  String minStorageTemp = '';
  String maxStorageTemp = '';
  bool requiresRefrigeration = false;
  bool requiresFreezing = false;
  bool lightSensitive = false;
  bool humiditySensitive = false;

  bool requiresPrescription = true;
  String prescriptionType = '';

  DateTime? fdaApprovalDate;
  String fdaApplicationNumber = '';
  DateTime? emaApprovalDate;
  String emaProcedureNumber = '';

  bool blackBoxWarning = false;
  String blackBoxWarningText = '';
  String contraindications = '';
  String drugInteractions = '';
  PregnancyCategory pregnancyCategory = PregnancyCategory.notClassified;

  String regulatedProductName = '';
  String dosageFormTypeCode = '';
  String routeOfAdministrationCode = '';

  String mahGln = '';
  String mahName = '';
  String mahCountry = '';
  String licensedAgentGlns = '';
  String additionalAtcCodes = '';

  String maNumber = '';
  DateTime? maValidFrom;
  DateTime? maValidTo;

  String regulatoryStatus = '';

  String prescriptionStatus = 'RX';
  bool controlledSubstance = false;
  String controlledSubstanceSchedule = '';
  bool additionalMonitoring = false;

  String shelfLifeMonths = '';
  String shelfLifeAfterOpenDays = '';

  String countryOfManufacture = '';
  String packSizeDescription = '';

  String nhmnGermanyPzn = '';
  String nhmnFranceCip = '';
  String nhmnSpainCn = '';
  String nhmnBrazilAnvisa = '';
  String nhmnPortugalAim = '';
  String nhmnUsaNdc = '';
  String nhmnItalyAifa = '';
  String localDrugCodeUaeGcc = '';

  String dataCarrierTypeCode = '';
  bool antiTamperingIndicator = false;
  bool pseudoGtinNtinFlag = false;
  bool coldChainRequired = false;

  String activePotencyAi7004 = '';
  @override
  void initState() {
    super.initState();
    if (widget.initialExtension != null) {
      populateFormFromExtension(widget.initialExtension!);
      extension = widget.initialExtension;
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
            populateFormFromExtension(widget.initialExtension!);
            extension = widget.initialExtension;
          }
        });
      }
    }
    if (widget.initialExtension != oldWidget.initialExtension) {
      final next = widget.initialExtension;
      if (next != null) {
        populateFormFromExtension(next);
        _applyState(() {
          extension = next;
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
      initialNdcNumber: ndcNumber,
      initialDinNumber: dinNumber,
      initialEanPharmaCode: eanPharmaCode,
      initialDrugClass: drugClass,
      initialTherapeuticClass: therapeuticClass,
      initialPharmacologicalClass: pharmacologicalClass,
      initialAtcCode: atcCode,
      initialAdditionalAtcCodes: additionalAtcCodes,
      initialIsControlledSubstance: isControlledSubstance,
      initialDeaSchedule: deaSchedule,
      initialControlClass: controlClass,
      initialDosageForm: dosageForm,
      initialStrength: strength,
      initialStrengthUnit: strengthUnit,
      initialRouteOfAdministration: routeOfAdministration,
      initialActiveIngredients: activeIngredients,
      initialInactiveIngredients: inactiveIngredients,
      initialStorageConditions: storageConditions,
      initialMinStorageTemp: minStorageTemp,
      initialMaxStorageTemp: maxStorageTemp,
      initialRequiresRefrigeration: requiresRefrigeration,
      initialRequiresFreezing: requiresFreezing,
      initialLightSensitive: lightSensitive,
      initialHumiditySensitive: humiditySensitive,
      initialColdChainRequired: coldChainRequired,
      initialRequiresPrescription: requiresPrescription,
      initialPrescriptionType: prescriptionType,
      initialFdaApplicationNumber: fdaApplicationNumber,
      initialFdaApprovalDate: fdaApprovalDate,
      initialEmaProcedureNumber: emaProcedureNumber,
      initialEmaApprovalDate: emaApprovalDate,
      initialBlackBoxWarning: blackBoxWarning,
      initialBlackBoxWarningText: blackBoxWarningText,
      initialPregnancyCategory: pregnancyCategory,
      initialContraindications: contraindications,
      initialDrugInteractions: drugInteractions,
      initialRegulatedProductName: regulatedProductName,
      initialDosageFormTypeCode: dosageFormTypeCode,
      initialRouteOfAdministrationCode: routeOfAdministrationCode,
      initialMahGln: mahGln,
      initialMahName: mahName,
      initialMahCountry: mahCountry,
      initialLicensedAgentGlns: licensedAgentGlns,
      initialMaNumber: maNumber,
      initialMaValidFrom: maValidFrom,
      initialMaValidTo: maValidTo,
      initialRegulatoryStatus: regulatoryStatus,
      initialPrescriptionStatus: prescriptionStatus,
      initialControlledSubstance: controlledSubstance,
      initialControlledSubstanceSchedule: controlledSubstanceSchedule,
      initialAdditionalMonitoring: additionalMonitoring,
      initialShelfLifeMonths: shelfLifeMonths,
      initialShelfLifeAfterOpenDays: shelfLifeAfterOpenDays,
      initialCountryOfManufacture: countryOfManufacture,
      initialPackSizeDescription: packSizeDescription,
      initialActivePotencyAi7004: activePotencyAi7004,
      initialNhmnGermanyPzn: nhmnGermanyPzn,
      initialNhmnFranceCip: nhmnFranceCip,
      initialNhmnSpainCn: nhmnSpainCn,
      initialNhmnBrazilAnvisa: nhmnBrazilAnvisa,
      initialNhmnPortugalAim: nhmnPortugalAim,
      initialNhmnUsaNdc: nhmnUsaNdc,
      initialNhmnItalyAifa: nhmnItalyAifa,
      initialLocalDrugCodeUaeGcc: localDrugCodeUaeGcc,
      initialDataCarrierTypeCode: dataCarrierTypeCode,
      initialAntiTamperingIndicator: antiTamperingIndicator,
      initialPseudoGtinNtinFlag: pseudoGtinNtinFlag,
      onDrugIdentificationChanged:
          ({required ndcNumber, required dinNumber, required eanPharmaCode}) {
            ndcNumber = ndcNumber;
            dinNumber = dinNumber;
            eanPharmaCode = eanPharmaCode;
          },
      onDrugClassificationChanged:
          ({
            required drugClass,
            required therapeuticClass,
            required pharmacologicalClass,
            required atcCode,
            required additionalAtcCodes,
          }) {
            drugClass = drugClass;
            therapeuticClass = therapeuticClass;
            pharmacologicalClass = pharmacologicalClass;
            atcCode = atcCode;
            additionalAtcCodes = additionalAtcCodes;
          },
      onControlledSubstanceChanged:
          ({
            required isControlledSubstance,
            required deaSchedule,
            required controlClass,
          }) {
            isControlledSubstance = isControlledSubstance;
            deaSchedule = deaSchedule;
            controlClass = controlClass;
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
            dosageForm = dosageForm;
            strength = strength;
            strengthUnit = strengthUnit;
            routeOfAdministration = routeOfAdministration;
            activeIngredients = activeIngredients;
            inactiveIngredients = inactiveIngredients;
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
            storageConditions = storageConditions;
            minStorageTemp = minStorageTemp;
            maxStorageTemp = maxStorageTemp;
            requiresRefrigeration = requiresRefrigeration;
            requiresFreezing = requiresFreezing;
            lightSensitive = lightSensitive;
            humiditySensitive = humiditySensitive;
            coldChainRequired = coldChainRequired;
          },
      onPrescriptionRequirementsChanged:
          ({required requiresPrescription, required prescriptionType}) {
            requiresPrescription = requiresPrescription;
            prescriptionType = prescriptionType;
          },
      onRegulatoryApprovalsChanged:
          ({
            required fdaApplicationNumber,
            required fdaApprovalDate,
            required emaProcedureNumber,
            required emaApprovalDate,
          }) {
            fdaApplicationNumber = fdaApplicationNumber;
            fdaApprovalDate = fdaApprovalDate;
            emaProcedureNumber = emaProcedureNumber;
            emaApprovalDate = emaApprovalDate;
          },
      onWarningsPrecautionsChanged:
          ({
            required blackBoxWarning,
            required blackBoxWarningText,
            required pregnancyCategory,
            required contraindications,
            required drugInteractions,
          }) {
            blackBoxWarning = blackBoxWarning;
            blackBoxWarningText = blackBoxWarningText;
            pregnancyCategory = pregnancyCategory;
            contraindications = contraindications;
            drugInteractions = drugInteractions;
          },
      onTechProductCodedChanged:
          ({
            required regulatedProductName,
            required dosageFormTypeCode,
            required routeOfAdministrationCode,
          }) {
            regulatedProductName = regulatedProductName;
            dosageFormTypeCode = dosageFormTypeCode;
            routeOfAdministrationCode = routeOfAdministrationCode;
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
            mahGln = mahGln;
            mahName = mahName;
            mahCountry = mahCountry;
            licensedAgentGlns = licensedAgentGlns;
            maNumber = maNumber;
            maValidFrom = maValidFrom;
            maValidTo = maValidTo;
            regulatoryStatus = regulatoryStatus;
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
            prescriptionStatus = prescriptionStatus;
            controlledSubstance = controlledSubstance;
            controlledSubstanceSchedule = controlledSubstanceSchedule;
            additionalMonitoring = additionalMonitoring;
            shelfLifeMonths = shelfLifeMonths;
            shelfLifeAfterOpenDays = shelfLifeAfterOpenDays;
            countryOfManufacture = countryOfManufacture;
            packSizeDescription = packSizeDescription;
            activePotencyAi7004 = activePotencyAi7004;
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
            nhmnGermanyPzn = nhmnGermanyPzn;
            nhmnFranceCip = nhmnFranceCip;
            nhmnSpainCn = nhmnSpainCn;
            nhmnBrazilAnvisa = nhmnBrazilAnvisa;
            nhmnPortugalAim = nhmnPortugalAim;
            nhmnUsaNdc = nhmnUsaNdc;
            nhmnItalyAifa = nhmnItalyAifa;
            localDrugCodeUaeGcc = localDrugCodeUaeGcc;
          },
      onDataCarrierIntegrityChanged:
          ({required dataCarrierTypeCode, required antiTamperingIndicator}) {
            dataCarrierTypeCode = dataCarrierTypeCode;
            antiTamperingIndicator = antiTamperingIndicator;
          },
    );
  }
}
