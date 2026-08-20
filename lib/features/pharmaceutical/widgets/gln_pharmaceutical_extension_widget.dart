import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_types.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_clinical_trial_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_cold_chain_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_contacts_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_certifications_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_dea_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_dscsa_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_facility_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_fda_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_healthcare_ids_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_international_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_operational_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_registry_safety_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_state_license_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_wholesale_section.dart';

import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_actions.dart';

class GLNPharmaceuticalExtensionWidget extends StatefulWidget {
  final int? glnId;
  final String? glnCode;
  final bool isEditing;
  final Function(GLNPharmaceuticalExtension?)? onSaved;

  final GLNPharmaceuticalExtension? initialExtension;

  const GLNPharmaceuticalExtensionWidget({
    Key? key,
    this.glnId,
    this.glnCode,
    this.isEditing = false,
    this.onSaved,
    this.initialExtension,
  }) : super(key: key);

  @override
  State<GLNPharmaceuticalExtensionWidget> createState() =>
      GLNPharmaceuticalExtensionWidgetState();
}

class GLNPharmaceuticalExtensionWidgetState
    extends State<GLNPharmaceuticalExtensionWidget> {
  GLNPharmaceuticalExtension? extension;
  bool isLoading = true;

  HealthcareFacilityType healthcareFacilityType = HealthcareFacilityType.other;

  final fdaEstablishmentIdController = TextEditingController();
  final fdaRegistrationNumberController = TextEditingController();
  DateTime? fdaRegistrationDate;
  DateTime? fdaRegistrationExpiry;
  final fdaEstablishmentTypeController = TextEditingController();

  final deaRegistrationNumberController = TextEditingController();
  DateTime? deaRegistrationExpiry;
  final deaScheduleAuthorizationController = TextEditingController();
  final deaBusinessActivityController = TextEditingController();

  final stateLicenseNumberController = TextEditingController();
  final stateLicenseTypeController = TextEditingController();
  DateTime? stateLicenseExpiry;
  String? stateLicenseState;

  final wholesaleLicenseNumberController = TextEditingController();
  DateTime? wholesaleLicenseExpiry;
  bool isAuthorizedTradingPartner = false;
  DateTime? atpVerificationDate;
  bool vawdAccredited = false;
  final vawdAccreditationNumberController = TextEditingController();
  DateTime? vawdExpiryDate;

  bool hasColdChainCapability = false;
  final coldStorageMinTempController = TextEditingController();
  final coldStorageMaxTempController = TextEditingController();
  bool hasFreezerCapability = false;
  final freezerMinTempController = TextEditingController();
  final freezerMaxTempController = TextEditingController();
  bool hasControlledRoomTemp = false;
  final crtMinTempController = TextEditingController();
  final crtMaxTempController = TextEditingController();
  bool hasHumidityControl = false;
  final humidityRangeMinController = TextEditingController();
  final humidityRangeMaxController = TextEditingController();
  bool gdpCertified = false;
  final gdpCertificationNumberController = TextEditingController();
  DateTime? gdpCertificationExpiry;

  bool isClinicalTrialSite = false;
  final clinicalTrialPhaseAuthorizedController = TextEditingController();
  final irbApprovalNumberController = TextEditingController();
  DateTime? irbApprovalExpiry;

  bool isDscsaCompliant = false;
  DateTime? dscsaComplianceDate;
  bool hasSerializationCapability = false;
  bool hasAggregationCapability = false;
  final interoperabilitySystemController = TextEditingController();

  final npiNumberController = TextEditingController();
  final ncpdpIdController = TextEditingController();
  final medicareProviderNumberController = TextEditingController();
  final medicaidProviderNumberController = TextEditingController();

  bool isIsoCertified = false;
  final isoCertificationTypeController = TextEditingController();
  final isoCertificationNumberController = TextEditingController();
  DateTime? isoCertificationExpiry;
  bool jcahoAccredited = false;
  final jcahoAccreditationNumberController = TextEditingController();
  DateTime? jcahoAccreditationExpiry;

  final emaSiteIdController = TextEditingController();
  final pmdaSiteIdController = TextEditingController();
  final anvisaSiteIdController = TextEditingController();
  final nmpaSiteIdController = TextEditingController();

  final receivingHoursController = TextEditingController();
  final dispatchHoursController = TextEditingController();
  bool hasWeighbridge = false;
  bool hasLoadingDock = false;
  bool hasForkliftCapability = false;
  bool canReceiveHazmat = false;

  final pharmacistInChargeController = TextEditingController();
  final picLicenseNumberController = TextEditingController();
  final responsiblePersonNameController = TextEditingController();
  final responsiblePersonEmailController = TextEditingController();
  final responsiblePersonPhoneController = TextEditingController();
  final qualityContactNameController = TextEditingController();
  final qualityContactEmailController = TextEditingController();
  final qualityContactPhoneController = TextEditingController();
  final regulatoryContactNameController = TextEditingController();
  final regulatoryContactEmailController = TextEditingController();
  final regulatoryContactPhoneController = TextEditingController();

  final brandsyncPartyIdController = TextEditingController();
  final tatmeenPartyCodeController = TextEditingController();
  final pharmacovigilanceEmailController = TextEditingController();
  final recallContactEmailController = TextEditingController();
  final recallContactPhoneController = TextEditingController();
  final epcisCaptureEndpointUrlController = TextEditingController();
  final licensedAgentAuthorisationController = TextEditingController();
  final authorisedPrincipalMahGlnsController = TextEditingController();

  bool mahQualificationIndicator = false;
  final mahTargetMarketsController = TextEditingController();
  final mahRegulatoryRegistrationNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadExtension();
  }

  @override
  void didUpdateWidget(covariant GLNPharmaceuticalExtensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialExtension != oldWidget.initialExtension &&
        widget.initialExtension != null) {
      populateFormFromExtension(widget.initialExtension!);
      setState(() {
        extension = widget.initialExtension;
      });
    }
  }

  @override
  void dispose() {
    fdaEstablishmentIdController.dispose();
    fdaRegistrationNumberController.dispose();
    fdaEstablishmentTypeController.dispose();
    deaRegistrationNumberController.dispose();
    deaScheduleAuthorizationController.dispose();
    deaBusinessActivityController.dispose();
    stateLicenseNumberController.dispose();
    stateLicenseTypeController.dispose();
    wholesaleLicenseNumberController.dispose();
    vawdAccreditationNumberController.dispose();
    coldStorageMinTempController.dispose();
    coldStorageMaxTempController.dispose();
    freezerMinTempController.dispose();
    freezerMaxTempController.dispose();
    crtMinTempController.dispose();
    crtMaxTempController.dispose();
    humidityRangeMinController.dispose();
    humidityRangeMaxController.dispose();
    gdpCertificationNumberController.dispose();
    clinicalTrialPhaseAuthorizedController.dispose();
    irbApprovalNumberController.dispose();
    interoperabilitySystemController.dispose();
    npiNumberController.dispose();
    ncpdpIdController.dispose();
    medicareProviderNumberController.dispose();
    medicaidProviderNumberController.dispose();
    isoCertificationTypeController.dispose();
    isoCertificationNumberController.dispose();
    jcahoAccreditationNumberController.dispose();
    emaSiteIdController.dispose();
    pmdaSiteIdController.dispose();
    anvisaSiteIdController.dispose();
    nmpaSiteIdController.dispose();
    receivingHoursController.dispose();
    dispatchHoursController.dispose();
    pharmacistInChargeController.dispose();
    picLicenseNumberController.dispose();
    responsiblePersonNameController.dispose();
    responsiblePersonEmailController.dispose();
    responsiblePersonPhoneController.dispose();
    qualityContactNameController.dispose();
    qualityContactEmailController.dispose();
    qualityContactPhoneController.dispose();
    regulatoryContactNameController.dispose();
    regulatoryContactEmailController.dispose();
    regulatoryContactPhoneController.dispose();
    brandsyncPartyIdController.dispose();
    tatmeenPartyCodeController.dispose();
    pharmacovigilanceEmailController.dispose();
    recallContactEmailController.dispose();
    recallContactPhoneController.dispose();
    epcisCaptureEndpointUrlController.dispose();
    licensedAgentAuthorisationController.dispose();
    authorisedPrincipalMahGlnsController.dispose();
    mahTargetMarketsController.dispose();
    mahRegulatoryRegistrationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlnPharmaceuticalRegistrySafetySection(
          brandsyncPartyIdController: brandsyncPartyIdController,
          tatmeenPartyCodeController: tatmeenPartyCodeController,
          mahTargetMarketsController: mahTargetMarketsController,
          mahRegistrationNumberController:
              mahRegulatoryRegistrationNumberController,
          licensedAgentAuthorisationController:
              licensedAgentAuthorisationController,
          authorisedPrincipalMahGlnsController:
              authorisedPrincipalMahGlnsController,
          pharmacovigilanceEmailController: pharmacovigilanceEmailController,
          recallContactEmailController: recallContactEmailController,
          recallContactPhoneController: recallContactPhoneController,
          epcisCaptureEndpointUrlController: epcisCaptureEndpointUrlController,
          mahQualificationIndicator: mahQualificationIndicator,
          isEditing: widget.isEditing,
          onMahQualificationChanged: (value) {
            setState(() => mahQualificationIndicator = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalFacilitySection(
          facilityType: healthcareFacilityType,
          isEditing: widget.isEditing,
          onChanged: (value) {
            setState(() => healthcareFacilityType = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalFdaSection(
          establishmentIdController: fdaEstablishmentIdController,
          registrationNumberController: fdaRegistrationNumberController,
          establishmentTypeController: fdaEstablishmentTypeController,
          registrationDate: fdaRegistrationDate,
          registrationExpiry: fdaRegistrationExpiry,
          isEditing: widget.isEditing,
          onRegistrationDateChanged: (date) {
            setState(() => fdaRegistrationDate = date);
          },
          onRegistrationExpiryChanged: (date) {
            setState(() => fdaRegistrationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalDeaSection(
          registrationNumberController: deaRegistrationNumberController,
          scheduleAuthorizationController: deaScheduleAuthorizationController,
          businessActivityController: deaBusinessActivityController,
          registrationExpiry: deaRegistrationExpiry,
          isEditing: widget.isEditing,
          onRegistrationExpiryChanged: (date) {
            setState(() => deaRegistrationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalStateLicenseSection(
          licenseNumberController: stateLicenseNumberController,
          licenseTypeController: stateLicenseTypeController,
          selectedState: stateLicenseState,
          licenseExpiry: stateLicenseExpiry,
          isEditing: widget.isEditing,
          onStateChanged: (value) {
            setState(() => stateLicenseState = value);
          },
          onLicenseExpiryChanged: (date) {
            setState(() => stateLicenseExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalWholesaleSection(
          licenseNumberController: wholesaleLicenseNumberController,
          vawdAccreditationNumberController: vawdAccreditationNumberController,
          licenseExpiry: wholesaleLicenseExpiry,
          isAuthorizedTradingPartner: isAuthorizedTradingPartner,
          atpVerificationDate: atpVerificationDate,
          vawdAccredited: vawdAccredited,
          vawdExpiryDate: vawdExpiryDate,
          isEditing: widget.isEditing,
          onLicenseExpiryChanged: (date) {
            setState(() => wholesaleLicenseExpiry = date);
          },
          onAuthorizedTradingPartnerChanged: (value) {
            setState(() => isAuthorizedTradingPartner = value);
          },
          onAtpVerificationDateChanged: (date) {
            setState(() => atpVerificationDate = date);
          },
          onVawdAccreditedChanged: (value) {
            setState(() => vawdAccredited = value);
          },
          onVawdExpiryDateChanged: (date) {
            setState(() => vawdExpiryDate = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalColdChainSection(
          coldStorageMinController: coldStorageMinTempController,
          coldStorageMaxController: coldStorageMaxTempController,
          freezerMinController: freezerMinTempController,
          freezerMaxController: freezerMaxTempController,
          crtMinController: crtMinTempController,
          crtMaxController: crtMaxTempController,
          humidityMinController: humidityRangeMinController,
          humidityMaxController: humidityRangeMaxController,
          gdpCertificationNumberController: gdpCertificationNumberController,
          hasColdChainCapability: hasColdChainCapability,
          hasFreezerCapability: hasFreezerCapability,
          hasControlledRoomTemp: hasControlledRoomTemp,
          hasHumidityControl: hasHumidityControl,
          gdpCertified: gdpCertified,
          gdpCertificationExpiry: gdpCertificationExpiry,
          isEditing: widget.isEditing,
          onColdChainCapabilityChanged: (value) {
            setState(() => hasColdChainCapability = value);
          },
          onFreezerCapabilityChanged: (value) {
            setState(() => hasFreezerCapability = value);
          },
          onControlledRoomTempChanged: (value) {
            setState(() => hasControlledRoomTemp = value);
          },
          onHumidityControlChanged: (value) {
            setState(() => hasHumidityControl = value);
          },
          onGdpCertifiedChanged: (value) {
            setState(() => gdpCertified = value);
          },
          onGdpCertificationExpiryChanged: (date) {
            setState(() => gdpCertificationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalClinicalTrialSection(
          phaseAuthorizedController: clinicalTrialPhaseAuthorizedController,
          irbApprovalNumberController: irbApprovalNumberController,
          isClinicalTrialSite: isClinicalTrialSite,
          irbApprovalExpiry: irbApprovalExpiry,
          isEditing: widget.isEditing,
          onClinicalTrialSiteChanged: (value) {
            setState(() => isClinicalTrialSite = value);
          },
          onIrbApprovalExpiryChanged: (date) {
            setState(() => irbApprovalExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalDscsaSection(
          interoperabilitySystemController: interoperabilitySystemController,
          isDscsaCompliant: isDscsaCompliant,
          complianceDate: dscsaComplianceDate,
          hasSerializationCapability: hasSerializationCapability,
          hasAggregationCapability: hasAggregationCapability,
          isEditing: widget.isEditing,
          onDscsaCompliantChanged: (value) {
            setState(() => isDscsaCompliant = value);
          },
          onComplianceDateChanged: (date) {
            setState(() => dscsaComplianceDate = date);
          },
          onSerializationCapabilityChanged: (value) {
            setState(() => hasSerializationCapability = value);
          },
          onAggregationCapabilityChanged: (value) {
            setState(() => hasAggregationCapability = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalHealthcareIdsSection(
          npiNumberController: npiNumberController,
          ncpdpIdController: ncpdpIdController,
          medicareProviderNumberController: medicareProviderNumberController,
          medicaidProviderNumberController: medicaidProviderNumberController,
          isEditing: widget.isEditing,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalCertificationsSection(
          isoTypeController: isoCertificationTypeController,
          isoNumberController: isoCertificationNumberController,
          jcahoNumberController: jcahoAccreditationNumberController,
          isIsoCertified: isIsoCertified,
          isoExpiry: isoCertificationExpiry,
          isJcahoAccredited: jcahoAccredited,
          jcahoExpiry: jcahoAccreditationExpiry,
          isEditing: widget.isEditing,
          onIsoCertifiedChanged: (value) {
            setState(() => isIsoCertified = value);
          },
          onIsoExpiryChanged: (date) {
            setState(() => isoCertificationExpiry = date);
          },
          onJcahoAccreditedChanged: (value) {
            setState(() => jcahoAccredited = value);
          },
          onJcahoExpiryChanged: (date) {
            setState(() => jcahoAccreditationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalInternationalSection(
          emaSiteIdController: emaSiteIdController,
          pmdaSiteIdController: pmdaSiteIdController,
          anvisaSiteIdController: anvisaSiteIdController,
          nmpaSiteIdController: nmpaSiteIdController,
          isEditing: widget.isEditing,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalOperationalSection(
          receivingHoursController: receivingHoursController,
          dispatchHoursController: dispatchHoursController,
          hasWeighbridge: hasWeighbridge,
          hasLoadingDock: hasLoadingDock,
          hasForkliftCapability: hasForkliftCapability,
          canReceiveHazmat: canReceiveHazmat,
          isEditing: widget.isEditing,
          onWeighbridgeChanged: (value) {
            setState(() => hasWeighbridge = value);
          },
          onLoadingDockChanged: (value) {
            setState(() => hasLoadingDock = value);
          },
          onForkliftCapabilityChanged: (value) {
            setState(() => hasForkliftCapability = value);
          },
          onReceiveHazmatChanged: (value) {
            setState(() => canReceiveHazmat = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalContactsSection(
          pharmacistInChargeController: pharmacistInChargeController,
          picLicenseNumberController: picLicenseNumberController,
          responsibleNameController: responsiblePersonNameController,
          responsibleEmailController: responsiblePersonEmailController,
          responsiblePhoneController: responsiblePersonPhoneController,
          qualityNameController: qualityContactNameController,
          qualityEmailController: qualityContactEmailController,
          qualityPhoneController: qualityContactPhoneController,
          regulatoryNameController: regulatoryContactNameController,
          regulatoryEmailController: regulatoryContactEmailController,
          regulatoryPhoneController: regulatoryContactPhoneController,
          isEditing: widget.isEditing,
        ),
      ],
    );
  }
}
