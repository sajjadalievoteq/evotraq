import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_controlled_substance_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_data_carrier_integrity_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_dosage_route_composition_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_drug_classification_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_drug_identification_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_national_identifiers_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_prescription_requirements_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_regulatory_approvals_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_storage_handling_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_tech_dispensing_lifecycle_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_tech_mah_authorization_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_tech_product_coded_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_warnings_precautions_widget.dart';

class PharmaceuticalExtensionGroupedBody extends StatelessWidget {
  const PharmaceuticalExtensionGroupedBody({
    super.key,
    required this.isEditing,
    required this.isLoading,
    required this.onDrugIdentificationChanged,
    required this.onDrugClassificationChanged,
    required this.onControlledSubstanceChanged,
    required this.onDosageRouteCompositionChanged,
    required this.onStorageHandlingChanged,
    required this.onPrescriptionRequirementsChanged,
    required this.onRegulatoryApprovalsChanged,
    required this.onWarningsPrecautionsChanged,
    required this.onTechProductCodedChanged,
    required this.onTechMahAuthorizationChanged,
    required this.onTechDispensingLifecycleChanged,
    required this.onNationalIdentifiersChanged,
    required this.onDataCarrierIntegrityChanged,
    required this.initialNdcNumber,
    required this.initialDinNumber,
    required this.initialEanPharmaCode,
    required this.initialDrugClass,
    required this.initialTherapeuticClass,
    required this.initialPharmacologicalClass,
    required this.initialAtcCode,
    required this.initialAdditionalAtcCodes,
    required this.initialIsControlledSubstance,
    required this.initialDeaSchedule,
    required this.initialControlClass,
    required this.initialDosageForm,
    required this.initialStrength,
    required this.initialStrengthUnit,
    required this.initialRouteOfAdministration,
    required this.initialActiveIngredients,
    required this.initialInactiveIngredients,
    required this.initialStorageConditions,
    required this.initialMinStorageTemp,
    required this.initialMaxStorageTemp,
    required this.initialRequiresRefrigeration,
    required this.initialRequiresFreezing,
    required this.initialLightSensitive,
    required this.initialHumiditySensitive,
    required this.initialColdChainRequired,
    required this.initialRequiresPrescription,
    required this.initialPrescriptionType,
    required this.initialFdaApplicationNumber,
    required this.initialFdaApprovalDate,
    required this.initialEmaProcedureNumber,
    required this.initialEmaApprovalDate,
    required this.initialBlackBoxWarning,
    required this.initialBlackBoxWarningText,
    required this.initialPregnancyCategory,
    required this.initialContraindications,
    required this.initialDrugInteractions,
    required this.initialRegulatedProductName,
    required this.initialDosageFormTypeCode,
    required this.initialRouteOfAdministrationCode,
    required this.initialMahGln,
    required this.initialMahName,
    required this.initialMahCountry,
    required this.initialLicensedAgentGlns,
    required this.initialMaNumber,
    required this.initialMaValidFrom,
    required this.initialMaValidTo,
    required this.initialRegulatoryStatus,
    required this.initialPrescriptionStatus,
    required this.initialControlledSubstance,
    required this.initialControlledSubstanceSchedule,
    required this.initialAdditionalMonitoring,
    required this.initialShelfLifeMonths,
    required this.initialShelfLifeAfterOpenDays,
    required this.initialCountryOfManufacture,
    required this.initialPackSizeDescription,
    required this.initialActivePotencyAi7004,
    required this.initialNhmnGermanyPzn,
    required this.initialNhmnFranceCip,
    required this.initialNhmnSpainCn,
    required this.initialNhmnBrazilAnvisa,
    required this.initialNhmnPortugalAim,
    required this.initialNhmnUsaNdc,
    required this.initialNhmnItalyAifa,
    required this.initialLocalDrugCodeUaeGcc,
    required this.initialDataCarrierTypeCode,
    required this.initialAntiTamperingIndicator,
    required this.initialPseudoGtinNtinFlag,
  });

  final bool isEditing;
  final bool isLoading;

  final void Function({
    required String ndcNumber,
    required String dinNumber,
    required String eanPharmaCode,
  }) onDrugIdentificationChanged;

  final void Function({
    required String drugClass,
    required String therapeuticClass,
    required String pharmacologicalClass,
    required String atcCode,
    required String additionalAtcCodes,
  }) onDrugClassificationChanged;

  final void Function({
    required bool isControlledSubstance,
    required DeaSchedule deaSchedule,
    required String controlClass,
  }) onControlledSubstanceChanged;

  final void Function({
    required String dosageForm,
    required String strength,
    required String strengthUnit,
    required String routeOfAdministration,
    required List<ActiveIngredient> activeIngredients,
    required String inactiveIngredients,
  }) onDosageRouteCompositionChanged;

  final void Function({
    required String storageConditions,
    required String minStorageTemp,
    required String maxStorageTemp,
    required bool requiresRefrigeration,
    required bool requiresFreezing,
    required bool lightSensitive,
    required bool humiditySensitive,
    required bool coldChainRequired,
  }) onStorageHandlingChanged;

  final void Function({
    required bool requiresPrescription,
    required String prescriptionType,
  }) onPrescriptionRequirementsChanged;

  final void Function({
    required String fdaApplicationNumber,
    required DateTime? fdaApprovalDate,
    required String emaProcedureNumber,
    required DateTime? emaApprovalDate,
  }) onRegulatoryApprovalsChanged;

  final void Function({
    required bool blackBoxWarning,
    required String blackBoxWarningText,
    required PregnancyCategory pregnancyCategory,
    required String contraindications,
    required String drugInteractions,
  }) onWarningsPrecautionsChanged;

  final void Function({
    required String regulatedProductName,
    required String dosageFormTypeCode,
    required String routeOfAdministrationCode,
  }) onTechProductCodedChanged;

  final void Function({
    required String mahGln,
    required String mahName,
    required String mahCountry,
    required String licensedAgentGlns,
    required String maNumber,
    required DateTime? maValidFrom,
    required DateTime? maValidTo,
    required String regulatoryStatus,
  }) onTechMahAuthorizationChanged;

  final void Function({
    required String prescriptionStatus,
    required bool controlledSubstance,
    required String controlledSubstanceSchedule,
    required bool additionalMonitoring,
    required String shelfLifeMonths,
    required String shelfLifeAfterOpenDays,
    required String countryOfManufacture,
    required String packSizeDescription,
    required String activePotencyAi7004,
  }) onTechDispensingLifecycleChanged;

  final void Function({
    required String nhmnGermanyPzn,
    required String nhmnFranceCip,
    required String nhmnSpainCn,
    required String nhmnBrazilAnvisa,
    required String nhmnPortugalAim,
    required String nhmnUsaNdc,
    required String nhmnItalyAifa,
    required String localDrugCodeUaeGcc,
  }) onNationalIdentifiersChanged;

  final void Function({
    required String dataCarrierTypeCode,
    required bool antiTamperingIndicator,
  }) onDataCarrierIntegrityChanged;

  final String initialNdcNumber;
  final String initialDinNumber;
  final String initialEanPharmaCode;
  final String initialDrugClass;
  final String initialTherapeuticClass;
  final String initialPharmacologicalClass;
  final String initialAtcCode;
  final String initialAdditionalAtcCodes;
  final bool initialIsControlledSubstance;
  final DeaSchedule initialDeaSchedule;
  final String initialControlClass;
  final String initialDosageForm;
  final String initialStrength;
  final String initialStrengthUnit;
  final String initialRouteOfAdministration;
  final List<ActiveIngredient> initialActiveIngredients;
  final String initialInactiveIngredients;
  final String initialStorageConditions;
  final String initialMinStorageTemp;
  final String initialMaxStorageTemp;
  final bool initialRequiresRefrigeration;
  final bool initialRequiresFreezing;
  final bool initialLightSensitive;
  final bool initialHumiditySensitive;
  final bool initialColdChainRequired;
  final bool initialRequiresPrescription;
  final String initialPrescriptionType;
  final String initialFdaApplicationNumber;
  final DateTime? initialFdaApprovalDate;
  final String initialEmaProcedureNumber;
  final DateTime? initialEmaApprovalDate;
  final bool initialBlackBoxWarning;
  final String initialBlackBoxWarningText;
  final PregnancyCategory initialPregnancyCategory;
  final String initialContraindications;
  final String initialDrugInteractions;
  final String initialRegulatedProductName;
  final String initialDosageFormTypeCode;
  final String initialRouteOfAdministrationCode;
  final String initialMahGln;
  final String initialMahName;
  final String initialMahCountry;
  final String initialLicensedAgentGlns;
  final String initialMaNumber;
  final DateTime? initialMaValidFrom;
  final DateTime? initialMaValidTo;
  final String initialRegulatoryStatus;
  final String initialPrescriptionStatus;
  final bool initialControlledSubstance;
  final String initialControlledSubstanceSchedule;
  final bool initialAdditionalMonitoring;
  final String initialShelfLifeMonths;
  final String initialShelfLifeAfterOpenDays;
  final String initialCountryOfManufacture;
  final String initialPackSizeDescription;
  final String initialActivePotencyAi7004;
  final String initialNhmnGermanyPzn;
  final String initialNhmnFranceCip;
  final String initialNhmnSpainCn;
  final String initialNhmnBrazilAnvisa;
  final String initialNhmnPortugalAim;
  final String initialNhmnUsaNdc;
  final String initialNhmnItalyAifa;
  final String initialLocalDrugCodeUaeGcc;
  final String initialDataCarrierTypeCode;
  final bool initialAntiTamperingIndicator;
  final bool initialPseudoGtinNtinFlag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pharmaceutical Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 16),

        DrugIdentificationGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialNdcNumber: initialNdcNumber,
          initialDinNumber: initialDinNumber,
          initialEanPharmaCode: initialEanPharmaCode,
          onChanged: onDrugIdentificationChanged,
        ),
        DrugClassificationGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialDrugClass: initialDrugClass,
          initialTherapeuticClass: initialTherapeuticClass,
          initialPharmacologicalClass: initialPharmacologicalClass,
          initialAtcCode: initialAtcCode,
          initialAdditionalAtcCodes: initialAdditionalAtcCodes,
          onChanged: onDrugClassificationChanged,
        ),
        ControlledSubstanceGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialIsControlledSubstance: initialIsControlledSubstance,
          initialDeaSchedule: initialDeaSchedule,
          initialControlClass: initialControlClass,
          onChanged: onControlledSubstanceChanged,
        ),
        DosageRouteCompositionGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialDosageForm: initialDosageForm,
          initialStrength: initialStrength,
          initialStrengthUnit: initialStrengthUnit,
          initialRouteOfAdministration: initialRouteOfAdministration,
          initialActiveIngredients: initialActiveIngredients,
          initialInactiveIngredients: initialInactiveIngredients,
          onChanged: onDosageRouteCompositionChanged,
        ),
        StorageHandlingGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialStorageConditions: initialStorageConditions,
          initialMinStorageTemp: initialMinStorageTemp,
          initialMaxStorageTemp: initialMaxStorageTemp,
          initialRequiresRefrigeration: initialRequiresRefrigeration,
          initialRequiresFreezing: initialRequiresFreezing,
          initialLightSensitive: initialLightSensitive,
          initialHumiditySensitive: initialHumiditySensitive,
          initialColdChainRequired: initialColdChainRequired,
          onChanged: onStorageHandlingChanged,
        ),
        PrescriptionRequirementsGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialRequiresPrescription: initialRequiresPrescription,
          initialPrescriptionType: initialPrescriptionType,
          onChanged: onPrescriptionRequirementsChanged,
        ),
        RegulatoryApprovalsGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialFdaApplicationNumber: initialFdaApplicationNumber,
          initialFdaApprovalDate: initialFdaApprovalDate,
          initialEmaProcedureNumber: initialEmaProcedureNumber,
          initialEmaApprovalDate: initialEmaApprovalDate,
          onChanged: onRegulatoryApprovalsChanged,
        ), WarningsPrecautionsGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialBlackBoxWarning: initialBlackBoxWarning,
          initialBlackBoxWarningText: initialBlackBoxWarningText,
          initialPregnancyCategory: initialPregnancyCategory,
          initialContraindications: initialContraindications,
          initialDrugInteractions: initialDrugInteractions,
          onChanged: onWarningsPrecautionsChanged,
        ),
        TechProductCodedGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialRegulatedProductName: initialRegulatedProductName,
          initialDosageFormTypeCode: initialDosageFormTypeCode,
          initialRouteOfAdministrationCode: initialRouteOfAdministrationCode,
          onChanged: onTechProductCodedChanged,
        ),
        TechMahAuthorizationGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialMahGln: initialMahGln,
          initialMahName: initialMahName,
          initialMahCountry: initialMahCountry,
          initialLicensedAgentGlns: initialLicensedAgentGlns,
          initialMaNumber: initialMaNumber,
          initialMaValidFrom: initialMaValidFrom,
          initialMaValidTo: initialMaValidTo,
          initialRegulatoryStatus: initialRegulatoryStatus,
          onChanged: onTechMahAuthorizationChanged,
        ),
        TechDispensingLifecycleGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialPrescriptionStatus: initialPrescriptionStatus,
          initialControlledSubstance: initialControlledSubstance,
          initialControlledSubstanceSchedule: initialControlledSubstanceSchedule,
          initialAdditionalMonitoring: initialAdditionalMonitoring,
          initialShelfLifeMonths: initialShelfLifeMonths,
          initialShelfLifeAfterOpenDays: initialShelfLifeAfterOpenDays,
          initialCountryOfManufacture: initialCountryOfManufacture,
          initialPackSizeDescription: initialPackSizeDescription,
          initialActivePotencyAi7004: initialActivePotencyAi7004,
          onChanged: onTechDispensingLifecycleChanged,
        ),
        NationalIdentifiersGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialNhmnGermanyPzn: initialNhmnGermanyPzn,
          initialNhmnFranceCip: initialNhmnFranceCip,
          initialNhmnSpainCn: initialNhmnSpainCn,
          initialNhmnBrazilAnvisa: initialNhmnBrazilAnvisa,
          initialNhmnPortugalAim: initialNhmnPortugalAim,
          initialNhmnUsaNdc: initialNhmnUsaNdc,
          initialNhmnItalyAifa: initialNhmnItalyAifa,
          initialLocalDrugCodeUaeGcc: initialLocalDrugCodeUaeGcc,
          onChanged: onNationalIdentifiersChanged,
        ),
        DataCarrierIntegrityGroupWidget(
          isEditing: isEditing && !isLoading,
          showFieldSkeleton: isLoading,
          initialDataCarrierTypeCode: initialDataCarrierTypeCode,
          initialAntiTamperingIndicator: initialAntiTamperingIndicator,
          initialPseudoGtinNtinFlag: initialPseudoGtinNtinFlag,
          onChanged: onDataCarrierIntegrityChanged,
        ),
      ],
    );
  }
}
