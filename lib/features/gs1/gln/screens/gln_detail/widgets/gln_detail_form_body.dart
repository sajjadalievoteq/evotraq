import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_contact_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_digital_location_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_geospatial_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_identification_structure_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_legal_entity_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_license_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_lifecycle_status_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_location_address_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_operational_location_type_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/core_groups/gln_types_classification_core_group.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_form_skeleton.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_detail_header_card.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/widgets/gln_industry_extensions_section.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_lazy_viewport_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/tobacco/widgets/gln_tobacco_extension_widget.dart';

class GlnDetailFormBody extends StatelessWidget {
  const GlnDetailFormBody({
    super.key,
    required this.formKey,
    required this.onRefresh,
    required this.showSkeleton,
    this.forceMountAllSections = false,
    required this.gln,
    required this.idStructureReadOnly,
    required this.canEditMasterData,
    required this.formReadOnly,
    required this.allowMasterDataActions,
    required this.embedded,
    required this.onSubmit,
    required this.setFieldError,
    required this.glnCodeController,
    required this.gs1CompanyPrefixController,
    required this.locationReferenceDigitsController,
    required this.checkDigitController,
    required this.parentGlnCodeController,
    required this.glnExtensionComponentController,
    required this.registeredLegalNameController,
    required this.tradingNameController,
    required this.leiCodeController,
    required this.taxRegistrationNumberController,
    required this.countryOfIncorporationNumericController,
    required this.websiteController,
    required this.locationNameController,
    required this.mobileLocationIdentifierController,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.cityController,
    required this.stateProvinceController,
    required this.postalCodeController,
    required this.countryController,
    required this.digitalAddressValueController,
    required this.contactNameController,
    required this.contactEmailController,
    required this.contactPhoneController,
    required this.supplyChainRolesController,
    required this.locationRolesController,
    required this.licenseNumberController,
    required this.licenseTypeController,
    required this.operatingStatus,
    required this.industryClassification,
    required this.glnSource,
    required this.mobility,
    required this.digitalAddressType,
    required this.locationTypeLabel,
    required this.glnTypes,
    required this.glnTypesErrorText,
    required this.licenseValidFrom,
    required this.licenseExpiry,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.nonReuseUntil,
    required this.displayCoordinates,
    required this.pharmaExtensionKey,
    required this.tobaccoExtensionKey,
    required this.onOperatingStatusChanged,
    required this.onPickEffectiveFrom,
    required this.onPickEffectiveTo,
    required this.onGlnTypesChanged,
    required this.onIndustryClassificationChanged,
    required this.onGlnSourceChanged,
    required this.onMobilityChanged,
    required this.onDigitalAddressTypeChanged,
    required this.onLocationTypeChanged,
    required this.onPickLicenseValidFrom,
    required this.onPickLicenseExpiry,
    required this.onCoordinatesChanged,
  });

  final GlobalKey<FormState> formKey;
  final Future<void> Function() onRefresh;
  final bool showSkeleton;
  final bool forceMountAllSections;
  final GLN? gln;
  final bool idStructureReadOnly;
  final bool canEditMasterData;
  final bool formReadOnly;
  final bool allowMasterDataActions;
  final bool embedded;
  final VoidCallback onSubmit;
  final void Function(String fieldName, String? error) setFieldError;

  final TextEditingController glnCodeController;
  final TextEditingController gs1CompanyPrefixController;
  final TextEditingController locationReferenceDigitsController;
  final TextEditingController checkDigitController;
  final TextEditingController parentGlnCodeController;
  final TextEditingController glnExtensionComponentController;
  final TextEditingController registeredLegalNameController;
  final TextEditingController tradingNameController;
  final TextEditingController leiCodeController;
  final TextEditingController taxRegistrationNumberController;
  final TextEditingController countryOfIncorporationNumericController;
  final TextEditingController websiteController;
  final TextEditingController locationNameController;
  final TextEditingController mobileLocationIdentifierController;
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController cityController;
  final TextEditingController stateProvinceController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final TextEditingController digitalAddressValueController;
  final TextEditingController contactNameController;
  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;
  final TextEditingController supplyChainRolesController;
  final TextEditingController locationRolesController;
  final TextEditingController licenseNumberController;
  final TextEditingController licenseTypeController;

  final String operatingStatus;
  final String industryClassification;
  final String glnSource;
  final String mobility;
  final String digitalAddressType;
  final String locationTypeLabel;
  final List<String> glnTypes;
  final String? glnTypesErrorText;
  final DateTime? licenseValidFrom;
  final DateTime? licenseExpiry;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime? nonReuseUntil;
  final GeospatialCoordinates? displayCoordinates;

  final GlobalKey<GLNPharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<GLNTobaccoExtensionWidgetState> tobaccoExtensionKey;

  final ValueChanged<String?> onOperatingStatusChanged;
  final VoidCallback onPickEffectiveFrom;
  final VoidCallback onPickEffectiveTo;
  final ValueChanged<List<String>> onGlnTypesChanged;
  final ValueChanged<String?> onIndustryClassificationChanged;
  final ValueChanged<String?> onGlnSourceChanged;
  final ValueChanged<String?> onMobilityChanged;
  final ValueChanged<String?> onDigitalAddressTypeChanged;
  final ValueChanged<String?> onLocationTypeChanged;
  final VoidCallback onPickLicenseValidFrom;
  final VoidCallback onPickLicenseExpiry;
  final ValueChanged<GeospatialCoordinates?> onCoordinatesChanged;

  Widget _lazy({
    required double placeholderHeight,
    required WidgetBuilder builder,
  }) {
    return Gs1LazyViewportSection(
      forceMount: forceMountAllSections,
      placeholderHeight: placeholderHeight,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationLine =
        '${locationNameController.text}, ${cityController.text}';

    if (showSkeleton) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            top: context.horizontalPadding.left,
            right: context.horizontalPadding.left,
            left: context.horizontalPadding.left,
          ),
          child: Form(
            key: formKey,
            child: Gs1FormShimmerLayer(
              show: true,
              formColumn: const SizedBox.shrink(),
              skeleton: const GlnDetailFormSkeleton(),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          top: context.horizontalPadding.left,
          right: context.horizontalPadding.left,
          left: context.horizontalPadding.left,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlnDetailHeaderCard(
                glnCodeText: glnCodeController.text,
                registeredLegalName: registeredLegalNameController.text,
                locationLine: locationLine,
              ),
              GlnIdentificationStructureCoreGroup(
                setFieldError: setFieldError,
                readOnly: idStructureReadOnly,
                glnCodeController: glnCodeController,
                gs1CompanyPrefixController: gs1CompanyPrefixController,
                locationReferenceDigitsController:
                    locationReferenceDigitsController,
                checkDigitController: checkDigitController,
                parentGlnCodeController: parentGlnCodeController,
                glnExtensionComponentController:
                    glnExtensionComponentController,
                initialGs1CompanyPrefixLength: gln?.gs1CompanyPrefixLength,
                showFieldSkeleton: false,
              ),
              GlnLifecycleStatusCoreGroup(
                showFieldSkeleton: false,
                isEditing: canEditMasterData,
                operatingStatus: operatingStatus,
                onOperatingStatusChanged: onOperatingStatusChanged,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                nonReuseUntil: nonReuseUntil,
                onPickEffectiveFrom: onPickEffectiveFrom,
                onPickEffectiveTo: onPickEffectiveTo,
              ),
              _lazy(
                placeholderHeight: 280,
                builder: (_) => GlnTypesClassificationCoreGroup(
                  showFieldSkeleton: false,
                  isEditing: canEditMasterData,
                  setFieldError: setFieldError,
                  glnTypes: glnTypes,
                  onGlnTypesChanged: onGlnTypesChanged,
                  glnTypesErrorText: glnTypesErrorText,
                  industryClassification: industryClassification,
                  onIndustryClassificationChanged:
                      onIndustryClassificationChanged,
                  glnSource: glnSource,
                  onGlnSourceChanged: onGlnSourceChanged,
                  supplyChainRolesController: supplyChainRolesController,
                  locationRolesController: locationRolesController,
                ),
              ),
              _lazy(
                placeholderHeight: 360,
                builder: (_) => GlnLegalEntityCoreGroup(
                  showFieldSkeleton: false,
                  setFieldError: setFieldError,
                  readOnly: formReadOnly,
                  registeredLegalNameController: registeredLegalNameController,
                  tradingNameController: tradingNameController,
                  leiCodeController: leiCodeController,
                  taxRegistrationNumberController:
                      taxRegistrationNumberController,
                  countryOfIncorporationNumericController:
                      countryOfIncorporationNumericController,
                  websiteController: websiteController,
                ),
              ),
              _lazy(
                placeholderHeight: 420,
                builder: (_) => GlnLocationAddressCoreGroup(
                  showFieldSkeleton: false,
                  setFieldError: setFieldError,
                  readOnly: formReadOnly,
                  locationNameController: locationNameController,
                  mobility: mobility,
                  onMobilityChanged: onMobilityChanged,
                  mobileLocationIdentifierController:
                      mobileLocationIdentifierController,
                  addressLine1Controller: addressLine1Controller,
                  addressLine2Controller: addressLine2Controller,
                  cityController: cityController,
                  stateProvinceController: stateProvinceController,
                  postalCodeController: postalCodeController,
                  countryController: countryController,
                ),
              ),
              _lazy(
                placeholderHeight: 180,
                builder: (_) => GlnDigitalLocationCoreGroup(
                  showFieldSkeleton: false,
                  setFieldError: setFieldError,
                  readOnly: formReadOnly,
                  digitalAddressType: digitalAddressType,
                  onDigitalAddressTypeChanged: onDigitalAddressTypeChanged,
                  digitalAddressValueController: digitalAddressValueController,
                ),
              ),
              _lazy(
                placeholderHeight: 220,
                builder: (_) => GlnContactCoreGroup(
                  showFieldSkeleton: false,
                  setFieldError: setFieldError,
                  readOnly: formReadOnly,
                  contactNameController: contactNameController,
                  contactEmailController: contactEmailController,
                  contactPhoneController: contactPhoneController,
                ),
              ),
              _lazy(
                placeholderHeight: 140,
                builder: (_) => GlnOperationalLocationTypeCoreGroup(
                  showFieldSkeleton: false,
                  isEditing: canEditMasterData,
                  locationTypeLabel: locationTypeLabel,
                  onLocationTypeChanged: onLocationTypeChanged,
                ),
              ),
              _lazy(
                placeholderHeight: 260,
                builder: (_) => GlnLicenseCoreGroup(
                  showFieldSkeleton: false,
                  setFieldError: setFieldError,
                  readOnly: formReadOnly,
                  isEditing: canEditMasterData,
                  licenseValidFrom: licenseValidFrom,
                  licenseExpiry: licenseExpiry,
                  onPickLicenseValidFrom: onPickLicenseValidFrom,
                  onPickLicenseExpiry: onPickLicenseExpiry,
                  licenseNumberController: licenseNumberController,
                  licenseTypeController: licenseTypeController,
                ),
              ),
              _lazy(
                placeholderHeight: 200,
                builder: (_) => GlnGeospatialCoreGroup(
                  showFieldSkeleton: false,
                  displayCoordinates: displayCoordinates ?? gln?.coordinates,
                  onCoordinatesChanged: onCoordinatesChanged,
                  isEditing: canEditMasterData,
                ),
              ),
              _lazy(
                placeholderHeight: 320,
                builder: (_) => GlnIndustryExtensionsSection(
                  glnCodeController: glnCodeController,
                  gln: gln,
                  isEditing: canEditMasterData,
                  showFieldSkeleton: false,
                  pharmaExtensionKey: pharmaExtensionKey,
                  tobaccoExtensionKey: tobaccoExtensionKey,
                ),
              ),
              const SizedBox(height: 32),
              if ((MediaQuery.of(context).size.width < 600 || embedded) &&
                  allowMasterDataActions)
                CustomButtonWidget(
                  onTap: onSubmit,
                  title: GlnUiConstants.detailSaveButton,
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
