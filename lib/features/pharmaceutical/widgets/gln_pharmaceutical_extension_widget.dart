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

part 'gln_pharmaceutical_extension_actions.dart';

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
  GLNPharmaceuticalExtension? _extension;
  bool _isLoading = true;

  HealthcareFacilityType _healthcareFacilityType = HealthcareFacilityType.other;

  final _fdaEstablishmentIdController = TextEditingController();
  final _fdaRegistrationNumberController = TextEditingController();
  DateTime? _fdaRegistrationDate;
  DateTime? _fdaRegistrationExpiry;
  final _fdaEstablishmentTypeController = TextEditingController();

  final _deaRegistrationNumberController = TextEditingController();
  DateTime? _deaRegistrationExpiry;
  final _deaScheduleAuthorizationController = TextEditingController();
  final _deaBusinessActivityController = TextEditingController();

  final _stateLicenseNumberController = TextEditingController();
  final _stateLicenseTypeController = TextEditingController();
  DateTime? _stateLicenseExpiry;
  String? _stateLicenseState;

  final _wholesaleLicenseNumberController = TextEditingController();
  DateTime? _wholesaleLicenseExpiry;
  bool _isAuthorizedTradingPartner = false;
  DateTime? _atpVerificationDate;
  bool _vawdAccredited = false;
  final _vawdAccreditationNumberController = TextEditingController();
  DateTime? _vawdExpiryDate;

  bool _hasColdChainCapability = false;
  final _coldStorageMinTempController = TextEditingController();
  final _coldStorageMaxTempController = TextEditingController();
  bool _hasFreezerCapability = false;
  final _freezerMinTempController = TextEditingController();
  final _freezerMaxTempController = TextEditingController();
  bool _hasControlledRoomTemp = false;
  final _crtMinTempController = TextEditingController();
  final _crtMaxTempController = TextEditingController();
  bool _hasHumidityControl = false;
  final _humidityRangeMinController = TextEditingController();
  final _humidityRangeMaxController = TextEditingController();
  bool _gdpCertified = false;
  final _gdpCertificationNumberController = TextEditingController();
  DateTime? _gdpCertificationExpiry;

  bool _isClinicalTrialSite = false;
  final _clinicalTrialPhaseAuthorizedController = TextEditingController();
  final _irbApprovalNumberController = TextEditingController();
  DateTime? _irbApprovalExpiry;

  bool _isDscsaCompliant = false;
  DateTime? _dscsaComplianceDate;
  bool _hasSerializationCapability = false;
  bool _hasAggregationCapability = false;
  final _interoperabilitySystemController = TextEditingController();

  final _npiNumberController = TextEditingController();
  final _ncpdpIdController = TextEditingController();
  final _medicareProviderNumberController = TextEditingController();
  final _medicaidProviderNumberController = TextEditingController();

  bool _isIsoCertified = false;
  final _isoCertificationTypeController = TextEditingController();
  final _isoCertificationNumberController = TextEditingController();
  DateTime? _isoCertificationExpiry;
  bool _jcahoAccredited = false;
  final _jcahoAccreditationNumberController = TextEditingController();
  DateTime? _jcahoAccreditationExpiry;

  final _emaSiteIdController = TextEditingController();
  final _pmdaSiteIdController = TextEditingController();
  final _anvisaSiteIdController = TextEditingController();
  final _nmpaSiteIdController = TextEditingController();

  final _receivingHoursController = TextEditingController();
  final _dispatchHoursController = TextEditingController();
  bool _hasWeighbridge = false;
  bool _hasLoadingDock = false;
  bool _hasForkliftCapability = false;
  bool _canReceiveHazmat = false;

  final _pharmacistInChargeController = TextEditingController();
  final _picLicenseNumberController = TextEditingController();
  final _responsiblePersonNameController = TextEditingController();
  final _responsiblePersonEmailController = TextEditingController();
  final _responsiblePersonPhoneController = TextEditingController();
  final _qualityContactNameController = TextEditingController();
  final _qualityContactEmailController = TextEditingController();
  final _qualityContactPhoneController = TextEditingController();
  final _regulatoryContactNameController = TextEditingController();
  final _regulatoryContactEmailController = TextEditingController();
  final _regulatoryContactPhoneController = TextEditingController();

  final _brandsyncPartyIdController = TextEditingController();
  final _tatmeenPartyCodeController = TextEditingController();
  final _pharmacovigilanceEmailController = TextEditingController();
  final _recallContactEmailController = TextEditingController();
  final _recallContactPhoneController = TextEditingController();
  final _epcisCaptureEndpointUrlController = TextEditingController();
  final _licensedAgentAuthorisationController = TextEditingController();
  final _authorisedPrincipalMahGlnsController = TextEditingController();

  bool _mahQualificationIndicator = false;
  final _mahTargetMarketsController = TextEditingController();
  final _mahRegulatoryRegistrationNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExtension();
  }

  @override
  void didUpdateWidget(covariant GLNPharmaceuticalExtensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialExtension != oldWidget.initialExtension &&
        widget.initialExtension != null) {
      _populateFormFromExtension(widget.initialExtension!);
      setState(() {
        _extension = widget.initialExtension;
      });
    }
  }

  @override
  void dispose() {
    _fdaEstablishmentIdController.dispose();
    _fdaRegistrationNumberController.dispose();
    _fdaEstablishmentTypeController.dispose();
    _deaRegistrationNumberController.dispose();
    _deaScheduleAuthorizationController.dispose();
    _deaBusinessActivityController.dispose();
    _stateLicenseNumberController.dispose();
    _stateLicenseTypeController.dispose();
    _wholesaleLicenseNumberController.dispose();
    _vawdAccreditationNumberController.dispose();
    _coldStorageMinTempController.dispose();
    _coldStorageMaxTempController.dispose();
    _freezerMinTempController.dispose();
    _freezerMaxTempController.dispose();
    _crtMinTempController.dispose();
    _crtMaxTempController.dispose();
    _humidityRangeMinController.dispose();
    _humidityRangeMaxController.dispose();
    _gdpCertificationNumberController.dispose();
    _clinicalTrialPhaseAuthorizedController.dispose();
    _irbApprovalNumberController.dispose();
    _interoperabilitySystemController.dispose();
    _npiNumberController.dispose();
    _ncpdpIdController.dispose();
    _medicareProviderNumberController.dispose();
    _medicaidProviderNumberController.dispose();
    _isoCertificationTypeController.dispose();
    _isoCertificationNumberController.dispose();
    _jcahoAccreditationNumberController.dispose();
    _emaSiteIdController.dispose();
    _pmdaSiteIdController.dispose();
    _anvisaSiteIdController.dispose();
    _nmpaSiteIdController.dispose();
    _receivingHoursController.dispose();
    _dispatchHoursController.dispose();
    _pharmacistInChargeController.dispose();
    _picLicenseNumberController.dispose();
    _responsiblePersonNameController.dispose();
    _responsiblePersonEmailController.dispose();
    _responsiblePersonPhoneController.dispose();
    _qualityContactNameController.dispose();
    _qualityContactEmailController.dispose();
    _qualityContactPhoneController.dispose();
    _regulatoryContactNameController.dispose();
    _regulatoryContactEmailController.dispose();
    _regulatoryContactPhoneController.dispose();
    _brandsyncPartyIdController.dispose();
    _tatmeenPartyCodeController.dispose();
    _pharmacovigilanceEmailController.dispose();
    _recallContactEmailController.dispose();
    _recallContactPhoneController.dispose();
    _epcisCaptureEndpointUrlController.dispose();
    _licensedAgentAuthorisationController.dispose();
    _authorisedPrincipalMahGlnsController.dispose();
    _mahTargetMarketsController.dispose();
    _mahRegulatoryRegistrationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlnPharmaceuticalRegistrySafetySection(
          brandsyncPartyIdController: _brandsyncPartyIdController,
          tatmeenPartyCodeController: _tatmeenPartyCodeController,
          mahTargetMarketsController: _mahTargetMarketsController,
          mahRegistrationNumberController:
              _mahRegulatoryRegistrationNumberController,
          licensedAgentAuthorisationController:
              _licensedAgentAuthorisationController,
          authorisedPrincipalMahGlnsController:
              _authorisedPrincipalMahGlnsController,
          pharmacovigilanceEmailController: _pharmacovigilanceEmailController,
          recallContactEmailController: _recallContactEmailController,
          recallContactPhoneController: _recallContactPhoneController,
          epcisCaptureEndpointUrlController: _epcisCaptureEndpointUrlController,
          mahQualificationIndicator: _mahQualificationIndicator,
          isEditing: widget.isEditing,
          onMahQualificationChanged: (value) {
            setState(() => _mahQualificationIndicator = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalFacilitySection(
          facilityType: _healthcareFacilityType,
          isEditing: widget.isEditing,
          onChanged: (value) {
            setState(() => _healthcareFacilityType = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalFdaSection(
          establishmentIdController: _fdaEstablishmentIdController,
          registrationNumberController: _fdaRegistrationNumberController,
          establishmentTypeController: _fdaEstablishmentTypeController,
          registrationDate: _fdaRegistrationDate,
          registrationExpiry: _fdaRegistrationExpiry,
          isEditing: widget.isEditing,
          onRegistrationDateChanged: (date) {
            setState(() => _fdaRegistrationDate = date);
          },
          onRegistrationExpiryChanged: (date) {
            setState(() => _fdaRegistrationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalDeaSection(
          registrationNumberController: _deaRegistrationNumberController,
          scheduleAuthorizationController: _deaScheduleAuthorizationController,
          businessActivityController: _deaBusinessActivityController,
          registrationExpiry: _deaRegistrationExpiry,
          isEditing: widget.isEditing,
          onRegistrationExpiryChanged: (date) {
            setState(() => _deaRegistrationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalStateLicenseSection(
          licenseNumberController: _stateLicenseNumberController,
          licenseTypeController: _stateLicenseTypeController,
          selectedState: _stateLicenseState,
          licenseExpiry: _stateLicenseExpiry,
          isEditing: widget.isEditing,
          onStateChanged: (value) {
            setState(() => _stateLicenseState = value);
          },
          onLicenseExpiryChanged: (date) {
            setState(() => _stateLicenseExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalWholesaleSection(
          licenseNumberController: _wholesaleLicenseNumberController,
          vawdAccreditationNumberController: _vawdAccreditationNumberController,
          licenseExpiry: _wholesaleLicenseExpiry,
          isAuthorizedTradingPartner: _isAuthorizedTradingPartner,
          atpVerificationDate: _atpVerificationDate,
          vawdAccredited: _vawdAccredited,
          vawdExpiryDate: _vawdExpiryDate,
          isEditing: widget.isEditing,
          onLicenseExpiryChanged: (date) {
            setState(() => _wholesaleLicenseExpiry = date);
          },
          onAuthorizedTradingPartnerChanged: (value) {
            setState(() => _isAuthorizedTradingPartner = value);
          },
          onAtpVerificationDateChanged: (date) {
            setState(() => _atpVerificationDate = date);
          },
          onVawdAccreditedChanged: (value) {
            setState(() => _vawdAccredited = value);
          },
          onVawdExpiryDateChanged: (date) {
            setState(() => _vawdExpiryDate = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalColdChainSection(
          coldStorageMinController: _coldStorageMinTempController,
          coldStorageMaxController: _coldStorageMaxTempController,
          freezerMinController: _freezerMinTempController,
          freezerMaxController: _freezerMaxTempController,
          crtMinController: _crtMinTempController,
          crtMaxController: _crtMaxTempController,
          humidityMinController: _humidityRangeMinController,
          humidityMaxController: _humidityRangeMaxController,
          gdpCertificationNumberController: _gdpCertificationNumberController,
          hasColdChainCapability: _hasColdChainCapability,
          hasFreezerCapability: _hasFreezerCapability,
          hasControlledRoomTemp: _hasControlledRoomTemp,
          hasHumidityControl: _hasHumidityControl,
          gdpCertified: _gdpCertified,
          gdpCertificationExpiry: _gdpCertificationExpiry,
          isEditing: widget.isEditing,
          onColdChainCapabilityChanged: (value) {
            setState(() => _hasColdChainCapability = value);
          },
          onFreezerCapabilityChanged: (value) {
            setState(() => _hasFreezerCapability = value);
          },
          onControlledRoomTempChanged: (value) {
            setState(() => _hasControlledRoomTemp = value);
          },
          onHumidityControlChanged: (value) {
            setState(() => _hasHumidityControl = value);
          },
          onGdpCertifiedChanged: (value) {
            setState(() => _gdpCertified = value);
          },
          onGdpCertificationExpiryChanged: (date) {
            setState(() => _gdpCertificationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalClinicalTrialSection(
          phaseAuthorizedController: _clinicalTrialPhaseAuthorizedController,
          irbApprovalNumberController: _irbApprovalNumberController,
          isClinicalTrialSite: _isClinicalTrialSite,
          irbApprovalExpiry: _irbApprovalExpiry,
          isEditing: widget.isEditing,
          onClinicalTrialSiteChanged: (value) {
            setState(() => _isClinicalTrialSite = value);
          },
          onIrbApprovalExpiryChanged: (date) {
            setState(() => _irbApprovalExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalDscsaSection(
          interoperabilitySystemController: _interoperabilitySystemController,
          isDscsaCompliant: _isDscsaCompliant,
          complianceDate: _dscsaComplianceDate,
          hasSerializationCapability: _hasSerializationCapability,
          hasAggregationCapability: _hasAggregationCapability,
          isEditing: widget.isEditing,
          onDscsaCompliantChanged: (value) {
            setState(() => _isDscsaCompliant = value);
          },
          onComplianceDateChanged: (date) {
            setState(() => _dscsaComplianceDate = date);
          },
          onSerializationCapabilityChanged: (value) {
            setState(() => _hasSerializationCapability = value);
          },
          onAggregationCapabilityChanged: (value) {
            setState(() => _hasAggregationCapability = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalHealthcareIdsSection(
          npiNumberController: _npiNumberController,
          ncpdpIdController: _ncpdpIdController,
          medicareProviderNumberController: _medicareProviderNumberController,
          medicaidProviderNumberController: _medicaidProviderNumberController,
          isEditing: widget.isEditing,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalCertificationsSection(
          isoTypeController: _isoCertificationTypeController,
          isoNumberController: _isoCertificationNumberController,
          jcahoNumberController: _jcahoAccreditationNumberController,
          isIsoCertified: _isIsoCertified,
          isoExpiry: _isoCertificationExpiry,
          isJcahoAccredited: _jcahoAccredited,
          jcahoExpiry: _jcahoAccreditationExpiry,
          isEditing: widget.isEditing,
          onIsoCertifiedChanged: (value) {
            setState(() => _isIsoCertified = value);
          },
          onIsoExpiryChanged: (date) {
            setState(() => _isoCertificationExpiry = date);
          },
          onJcahoAccreditedChanged: (value) {
            setState(() => _jcahoAccredited = value);
          },
          onJcahoExpiryChanged: (date) {
            setState(() => _jcahoAccreditationExpiry = date);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalInternationalSection(
          emaSiteIdController: _emaSiteIdController,
          pmdaSiteIdController: _pmdaSiteIdController,
          anvisaSiteIdController: _anvisaSiteIdController,
          nmpaSiteIdController: _nmpaSiteIdController,
          isEditing: widget.isEditing,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalOperationalSection(
          receivingHoursController: _receivingHoursController,
          dispatchHoursController: _dispatchHoursController,
          hasWeighbridge: _hasWeighbridge,
          hasLoadingDock: _hasLoadingDock,
          hasForkliftCapability: _hasForkliftCapability,
          canReceiveHazmat: _canReceiveHazmat,
          isEditing: widget.isEditing,
          onWeighbridgeChanged: (value) {
            setState(() => _hasWeighbridge = value);
          },
          onLoadingDockChanged: (value) {
            setState(() => _hasLoadingDock = value);
          },
          onForkliftCapabilityChanged: (value) {
            setState(() => _hasForkliftCapability = value);
          },
          onReceiveHazmatChanged: (value) {
            setState(() => _canReceiveHazmat = value);
          },
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalContactsSection(
          pharmacistInChargeController: _pharmacistInChargeController,
          picLicenseNumberController: _picLicenseNumberController,
          responsibleNameController: _responsiblePersonNameController,
          responsibleEmailController: _responsiblePersonEmailController,
          responsiblePhoneController: _responsiblePersonPhoneController,
          qualityNameController: _qualityContactNameController,
          qualityEmailController: _qualityContactEmailController,
          qualityPhoneController: _qualityContactPhoneController,
          regulatoryNameController: _regulatoryContactNameController,
          regulatoryEmailController: _regulatoryContactEmailController,
          regulatoryPhoneController: _regulatoryContactPhoneController,
          isEditing: widget.isEditing,
        ),
      ],
    );
  }
}
