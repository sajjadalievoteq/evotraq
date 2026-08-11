part of 'gln_pharmaceutical_extension_widget.dart';

extension GLNPharmaceuticalExtensionActions
    on GLNPharmaceuticalExtensionWidgetState {
  Future<void> _loadExtension() async {
    if (widget.initialExtension != null) {
      _populateFormFromExtension(widget.initialExtension!);
      if (mounted) {
        setState(() {
          _extension = widget.initialExtension;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormFromExtension(GLNPharmaceuticalExtension ext) {
    _healthcareFacilityType =
        ext.healthcareFacilityType ?? HealthcareFacilityType.other;

    _fdaEstablishmentIdController.text = ext.fdaEstablishmentId ?? '';
    _fdaRegistrationNumberController.text = ext.fdaRegistrationNumber ?? '';
    _fdaRegistrationDate = ext.fdaRegistrationDate;
    _fdaRegistrationExpiry = ext.fdaRegistrationExpiry;
    _fdaEstablishmentTypeController.text = ext.fdaEstablishmentType ?? '';

    _deaRegistrationNumberController.text = ext.deaRegistrationNumber ?? '';
    _deaRegistrationExpiry = ext.deaRegistrationExpiry;
    _deaScheduleAuthorizationController.text =
        ext.deaScheduleAuthorization ?? '';
    _deaBusinessActivityController.text = ext.deaBusinessActivity ?? '';

    _stateLicenseNumberController.text = ext.stateLicenseNumber ?? '';
    _stateLicenseTypeController.text = ext.stateLicenseType ?? '';
    _stateLicenseExpiry = ext.stateLicenseExpiry;
    _stateLicenseState = ext.stateLicenseState;

    _wholesaleLicenseNumberController.text = ext.wholesaleLicenseNumber ?? '';
    _wholesaleLicenseExpiry = ext.wholesaleLicenseExpiry;
    _isAuthorizedTradingPartner = ext.isAuthorizedTradingPartner;
    _atpVerificationDate = ext.atpVerificationDate;
    _vawdAccredited = ext.vawdAccredited;
    _vawdAccreditationNumberController.text = ext.vawdAccreditationNumber ?? '';
    _vawdExpiryDate = ext.vawdExpiryDate;

    _hasColdChainCapability = ext.hasColdChainCapability;
    _coldStorageMinTempController.text =
        ext.coldStorageMinTempCelsius?.toString() ?? '';
    _coldStorageMaxTempController.text =
        ext.coldStorageMaxTempCelsius?.toString() ?? '';
    _hasFreezerCapability = ext.hasFreezerCapability;
    _freezerMinTempController.text =
        ext.freezerMinTempCelsius?.toString() ?? '';
    _freezerMaxTempController.text =
        ext.freezerMaxTempCelsius?.toString() ?? '';
    _hasControlledRoomTemp = ext.hasControlledRoomTemp;
    _crtMinTempController.text = ext.crtMinTempCelsius?.toString() ?? '';
    _crtMaxTempController.text = ext.crtMaxTempCelsius?.toString() ?? '';
    _hasHumidityControl = ext.hasHumidityControl;
    _humidityRangeMinController.text = ext.humidityRangeMin?.toString() ?? '';
    _humidityRangeMaxController.text = ext.humidityRangeMax?.toString() ?? '';
    _gdpCertified = ext.gdpCertified;
    _gdpCertificationNumberController.text = ext.gdpCertificationNumber ?? '';
    _gdpCertificationExpiry = ext.gdpCertificationExpiry;

    _isClinicalTrialSite = ext.isClinicalTrialSite;
    _clinicalTrialPhaseAuthorizedController.text =
        ext.clinicalTrialPhaseAuthorized ?? '';
    _irbApprovalNumberController.text = ext.irbApprovalNumber ?? '';
    _irbApprovalExpiry = ext.irbApprovalExpiry;

    _isDscsaCompliant = ext.isDscsaCompliant;
    _dscsaComplianceDate = ext.dscsaComplianceDate;
    _hasSerializationCapability = ext.hasSerializationCapability;
    _hasAggregationCapability = ext.hasAggregationCapability;
    _interoperabilitySystemController.text = ext.interoperabilitySystem ?? '';

    _npiNumberController.text = ext.npiNumber ?? '';
    _ncpdpIdController.text = ext.ncpdpId ?? '';
    _medicareProviderNumberController.text = ext.medicareProviderNumber ?? '';
    _medicaidProviderNumberController.text = ext.medicaidProviderNumber ?? '';

    _isIsoCertified = ext.isIsoCertified;
    _isoCertificationTypeController.text = ext.isoCertificationType ?? '';
    _isoCertificationNumberController.text = ext.isoCertificationNumber ?? '';
    _isoCertificationExpiry = ext.isoCertificationExpiry;

    _jcahoAccredited = ext.jcahoAccredited;
    _jcahoAccreditationNumberController.text =
        ext.jcahoAccreditationNumber ?? '';
    _jcahoAccreditationExpiry = ext.jcahoAccreditationExpiry;

    _emaSiteIdController.text = ext.emaSiteId ?? '';
    _pmdaSiteIdController.text = ext.pmdaSiteId ?? '';
    _anvisaSiteIdController.text = ext.anvisaSiteId ?? '';
    _nmpaSiteIdController.text = ext.nmpaSiteId ?? '';

    _receivingHoursController.text = ext.receivingHours ?? '';
    _dispatchHoursController.text = ext.dispatchHours ?? '';
    _hasWeighbridge = ext.hasWeighbridge;
    _hasLoadingDock = ext.hasLoadingDock;
    _hasForkliftCapability = ext.hasForkliftCapability;
    _canReceiveHazmat = ext.canReceiveHazmat;

    _pharmacistInChargeController.text = ext.pharmacistInCharge ?? '';
    _picLicenseNumberController.text = ext.picLicenseNumber ?? '';
    _responsiblePersonNameController.text = ext.responsiblePersonName ?? '';
    _responsiblePersonEmailController.text = ext.responsiblePersonEmail ?? '';
    _responsiblePersonPhoneController.text = ext.responsiblePersonPhone ?? '';
    _qualityContactNameController.text = ext.qualityContactName ?? '';
    _qualityContactEmailController.text = ext.qualityContactEmail ?? '';
    _qualityContactPhoneController.text = ext.qualityContactPhone ?? '';
    _regulatoryContactNameController.text = ext.regulatoryContactName ?? '';
    _regulatoryContactEmailController.text = ext.regulatoryContactEmail ?? '';
    _regulatoryContactPhoneController.text = ext.regulatoryContactPhone ?? '';

    _mahQualificationIndicator = ext.mahQualificationIndicator;
    _mahTargetMarketsController.text = ext.mahTargetMarkets?.join(', ') ?? '';
    _mahRegulatoryRegistrationNumberController.text =
        ext.mahRegulatoryRegistrationNumber ?? '';

    _brandsyncPartyIdController.text = ext.brandsyncPartyId ?? '';
    _tatmeenPartyCodeController.text = ext.tatmeenPartyCode ?? '';
    _pharmacovigilanceEmailController.text = ext.pharmacovigilanceEmail ?? '';
    _recallContactEmailController.text = ext.recallContactEmail ?? '';
    _recallContactPhoneController.text = ext.recallContactPhone ?? '';
    _epcisCaptureEndpointUrlController.text = ext.epcisCaptureEndpointUrl ?? '';
    _licensedAgentAuthorisationController.text =
        ext.licensedAgentAuthorisationNumber ?? '';
    _authorisedPrincipalMahGlnsController.text =
        ext.authorisedPrincipalMahGlns ?? '';
  }

  GLNPharmaceuticalExtension _buildExtensionFromForm() {
    return GLNPharmaceuticalExtension(
      id: _extension?.id,
      glnId: widget.glnId ?? 0,
      glnCode: widget.glnCode,
      healthcareFacilityType: _healthcareFacilityType,
      fdaEstablishmentId: _fdaEstablishmentIdController.text.isNotEmpty
          ? _fdaEstablishmentIdController.text
          : null,
      fdaRegistrationNumber: _fdaRegistrationNumberController.text.isNotEmpty
          ? _fdaRegistrationNumberController.text
          : null,
      fdaRegistrationDate: _fdaRegistrationDate,
      fdaRegistrationExpiry: _fdaRegistrationExpiry,
      fdaEstablishmentType: _fdaEstablishmentTypeController.text.isNotEmpty
          ? _fdaEstablishmentTypeController.text
          : null,
      deaRegistrationNumber: _deaRegistrationNumberController.text.isNotEmpty
          ? _deaRegistrationNumberController.text
          : null,
      deaRegistrationExpiry: _deaRegistrationExpiry,
      deaScheduleAuthorization:
          _deaScheduleAuthorizationController.text.isNotEmpty
          ? _deaScheduleAuthorizationController.text
          : null,
      deaBusinessActivity: _deaBusinessActivityController.text.isNotEmpty
          ? _deaBusinessActivityController.text
          : null,
      stateLicenseNumber: _stateLicenseNumberController.text.isNotEmpty
          ? _stateLicenseNumberController.text
          : null,
      stateLicenseType: _stateLicenseTypeController.text.isNotEmpty
          ? _stateLicenseTypeController.text
          : null,
      stateLicenseExpiry: _stateLicenseExpiry,
      stateLicenseState: _stateLicenseState,
      wholesaleLicenseNumber: _wholesaleLicenseNumberController.text.isNotEmpty
          ? _wholesaleLicenseNumberController.text
          : null,
      wholesaleLicenseExpiry: _wholesaleLicenseExpiry,
      isAuthorizedTradingPartner: _isAuthorizedTradingPartner,
      atpVerificationDate: _atpVerificationDate,
      vawdAccredited: _vawdAccredited,
      vawdAccreditationNumber:
          _vawdAccreditationNumberController.text.isNotEmpty
          ? _vawdAccreditationNumberController.text
          : null,
      vawdExpiryDate: _vawdExpiryDate,
      hasColdChainCapability: _hasColdChainCapability,
      coldStorageMinTempCelsius: double.tryParse(
        _coldStorageMinTempController.text,
      ),
      coldStorageMaxTempCelsius: double.tryParse(
        _coldStorageMaxTempController.text,
      ),
      hasFreezerCapability: _hasFreezerCapability,
      freezerMinTempCelsius: double.tryParse(_freezerMinTempController.text),
      freezerMaxTempCelsius: double.tryParse(_freezerMaxTempController.text),
      hasControlledRoomTemp: _hasControlledRoomTemp,
      crtMinTempCelsius: double.tryParse(_crtMinTempController.text),
      crtMaxTempCelsius: double.tryParse(_crtMaxTempController.text),
      hasHumidityControl: _hasHumidityControl,
      humidityRangeMin: double.tryParse(_humidityRangeMinController.text),
      humidityRangeMax: double.tryParse(_humidityRangeMaxController.text),
      gdpCertified: _gdpCertified,
      gdpCertificationNumber: _gdpCertificationNumberController.text.isNotEmpty
          ? _gdpCertificationNumberController.text
          : null,
      gdpCertificationExpiry: _gdpCertificationExpiry,
      isClinicalTrialSite: _isClinicalTrialSite,
      clinicalTrialPhaseAuthorized:
          _clinicalTrialPhaseAuthorizedController.text.isNotEmpty
          ? _clinicalTrialPhaseAuthorizedController.text
          : null,
      irbApprovalNumber: _irbApprovalNumberController.text.isNotEmpty
          ? _irbApprovalNumberController.text
          : null,
      irbApprovalExpiry: _irbApprovalExpiry,
      isDscsaCompliant: _isDscsaCompliant,
      dscsaComplianceDate: _dscsaComplianceDate,
      hasSerializationCapability: _hasSerializationCapability,
      hasAggregationCapability: _hasAggregationCapability,
      interoperabilitySystem: _interoperabilitySystemController.text.isNotEmpty
          ? _interoperabilitySystemController.text
          : null,
      npiNumber: _npiNumberController.text.isNotEmpty
          ? _npiNumberController.text
          : null,
      ncpdpId: _ncpdpIdController.text.isNotEmpty
          ? _ncpdpIdController.text
          : null,
      medicareProviderNumber: _medicareProviderNumberController.text.isNotEmpty
          ? _medicareProviderNumberController.text
          : null,
      medicaidProviderNumber: _medicaidProviderNumberController.text.isNotEmpty
          ? _medicaidProviderNumberController.text
          : null,
      isIsoCertified: _isIsoCertified,
      isoCertificationType: _isoCertificationTypeController.text.isNotEmpty
          ? _isoCertificationTypeController.text
          : null,
      isoCertificationNumber: _isoCertificationNumberController.text.isNotEmpty
          ? _isoCertificationNumberController.text
          : null,
      isoCertificationExpiry: _isoCertificationExpiry,
      jcahoAccredited: _jcahoAccredited,
      jcahoAccreditationNumber:
          _jcahoAccreditationNumberController.text.isNotEmpty
          ? _jcahoAccreditationNumberController.text
          : null,
      jcahoAccreditationExpiry: _jcahoAccreditationExpiry,
      emaSiteId: _emaSiteIdController.text.isNotEmpty
          ? _emaSiteIdController.text
          : null,
      pmdaSiteId: _pmdaSiteIdController.text.isNotEmpty
          ? _pmdaSiteIdController.text
          : null,
      anvisaSiteId: _anvisaSiteIdController.text.isNotEmpty
          ? _anvisaSiteIdController.text
          : null,
      nmpaSiteId: _nmpaSiteIdController.text.isNotEmpty
          ? _nmpaSiteIdController.text
          : null,
      receivingHours: _receivingHoursController.text.isNotEmpty
          ? _receivingHoursController.text
          : null,
      dispatchHours: _dispatchHoursController.text.isNotEmpty
          ? _dispatchHoursController.text
          : null,
      hasWeighbridge: _hasWeighbridge,
      hasLoadingDock: _hasLoadingDock,
      hasForkliftCapability: _hasForkliftCapability,
      canReceiveHazmat: _canReceiveHazmat,
      pharmacistInCharge: _pharmacistInChargeController.text.isNotEmpty
          ? _pharmacistInChargeController.text
          : null,
      picLicenseNumber: _picLicenseNumberController.text.isNotEmpty
          ? _picLicenseNumberController.text
          : null,
      responsiblePersonName: _responsiblePersonNameController.text.isNotEmpty
          ? _responsiblePersonNameController.text
          : null,
      responsiblePersonEmail: _responsiblePersonEmailController.text.isNotEmpty
          ? _responsiblePersonEmailController.text
          : null,
      responsiblePersonPhone: _responsiblePersonPhoneController.text.isNotEmpty
          ? _responsiblePersonPhoneController.text
          : null,
      qualityContactName: _qualityContactNameController.text.isNotEmpty
          ? _qualityContactNameController.text
          : null,
      qualityContactEmail: _qualityContactEmailController.text.isNotEmpty
          ? _qualityContactEmailController.text
          : null,
      qualityContactPhone: _qualityContactPhoneController.text.isNotEmpty
          ? _qualityContactPhoneController.text
          : null,
      regulatoryContactName: _regulatoryContactNameController.text.isNotEmpty
          ? _regulatoryContactNameController.text
          : null,
      regulatoryContactEmail: _regulatoryContactEmailController.text.isNotEmpty
          ? _regulatoryContactEmailController.text
          : null,
      regulatoryContactPhone: _regulatoryContactPhoneController.text.isNotEmpty
          ? _regulatoryContactPhoneController.text
          : null,
      brandsyncPartyId: _brandsyncPartyIdController.text.isNotEmpty
          ? _brandsyncPartyIdController.text
          : null,
      tatmeenPartyCode: _tatmeenPartyCodeController.text.isNotEmpty
          ? _tatmeenPartyCodeController.text
          : null,
      pharmacovigilanceEmail: _pharmacovigilanceEmailController.text.isNotEmpty
          ? _pharmacovigilanceEmailController.text
          : null,
      recallContactEmail: _recallContactEmailController.text.isNotEmpty
          ? _recallContactEmailController.text
          : null,
      recallContactPhone: _recallContactPhoneController.text.isNotEmpty
          ? _recallContactPhoneController.text
          : null,
      epcisCaptureEndpointUrl:
          _epcisCaptureEndpointUrlController.text.isNotEmpty
          ? _epcisCaptureEndpointUrlController.text
          : null,
      licensedAgentAuthorisationNumber:
          _licensedAgentAuthorisationController.text.isNotEmpty
          ? _licensedAgentAuthorisationController.text
          : null,
      authorisedPrincipalMahGlns:
          _authorisedPrincipalMahGlnsController.text.isNotEmpty
          ? _authorisedPrincipalMahGlnsController.text
          : null,
      mahQualificationIndicator: _mahQualificationIndicator,
      mahTargetMarkets: _mahMarketsFromForm(),
      mahRegulatoryRegistrationNumber:
          _mahRegulatoryRegistrationNumberController.text.isNotEmpty
          ? _mahRegulatoryRegistrationNumberController.text
          : null,
    );
  }

  List<String>? _mahMarketsFromForm() {
    final t = _mahTargetMarketsController.text.trim();
    if (t.isEmpty) return null;
    final parts = t
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }

  bool get hasData =>
      _fdaEstablishmentIdController.text.isNotEmpty ||
      _fdaRegistrationNumberController.text.isNotEmpty ||
      _deaRegistrationNumberController.text.isNotEmpty ||
      _stateLicenseNumberController.text.isNotEmpty ||
      _wholesaleLicenseNumberController.text.isNotEmpty ||
      _isAuthorizedTradingPartner ||
      _vawdAccredited ||
      _hasColdChainCapability ||
      _gdpCertified ||
      _isClinicalTrialSite ||
      _isDscsaCompliant ||
      _npiNumberController.text.isNotEmpty ||
      _healthcareFacilityType != HealthcareFacilityType.other ||
      _brandsyncPartyIdController.text.isNotEmpty ||
      _tatmeenPartyCodeController.text.isNotEmpty ||
      _pharmacovigilanceEmailController.text.isNotEmpty ||
      _recallContactEmailController.text.isNotEmpty ||
      _recallContactPhoneController.text.isNotEmpty ||
      _epcisCaptureEndpointUrlController.text.isNotEmpty ||
      _licensedAgentAuthorisationController.text.isNotEmpty ||
      _authorisedPrincipalMahGlnsController.text.isNotEmpty ||
      _mahQualificationIndicator ||
      _mahTargetMarketsController.text.isNotEmpty ||
      _mahRegulatoryRegistrationNumberController.text.isNotEmpty;

  GLNPharmaceuticalExtension? buildExtension({int? glnId, String? glnCode}) {
    if (!hasData) return null;

    final extension = _buildExtensionFromForm();
    return GLNPharmaceuticalExtension(
      id: extension.id,
      glnId: glnId ?? widget.glnId ?? extension.glnId,
      glnCode: glnCode ?? widget.glnCode ?? extension.glnCode,
      healthcareFacilityType: extension.healthcareFacilityType,
      fdaEstablishmentId: extension.fdaEstablishmentId,
      fdaRegistrationNumber: extension.fdaRegistrationNumber,
      fdaRegistrationDate: extension.fdaRegistrationDate,
      fdaRegistrationExpiry: extension.fdaRegistrationExpiry,
      fdaEstablishmentType: extension.fdaEstablishmentType,
      deaRegistrationNumber: extension.deaRegistrationNumber,
      deaRegistrationExpiry: extension.deaRegistrationExpiry,
      deaScheduleAuthorization: extension.deaScheduleAuthorization,
      deaBusinessActivity: extension.deaBusinessActivity,
      stateLicenseNumber: extension.stateLicenseNumber,
      stateLicenseType: extension.stateLicenseType,
      stateLicenseExpiry: extension.stateLicenseExpiry,
      stateLicenseState: extension.stateLicenseState,
      wholesaleLicenseNumber: extension.wholesaleLicenseNumber,
      wholesaleLicenseExpiry: extension.wholesaleLicenseExpiry,
      isAuthorizedTradingPartner: extension.isAuthorizedTradingPartner,
      atpVerificationDate: extension.atpVerificationDate,
      vawdAccredited: extension.vawdAccredited,
      vawdAccreditationNumber: extension.vawdAccreditationNumber,
      vawdExpiryDate: extension.vawdExpiryDate,
      hasColdChainCapability: extension.hasColdChainCapability,
      coldStorageMinTempCelsius: extension.coldStorageMinTempCelsius,
      coldStorageMaxTempCelsius: extension.coldStorageMaxTempCelsius,
      hasFreezerCapability: extension.hasFreezerCapability,
      freezerMinTempCelsius: extension.freezerMinTempCelsius,
      freezerMaxTempCelsius: extension.freezerMaxTempCelsius,
      hasControlledRoomTemp: extension.hasControlledRoomTemp,
      crtMinTempCelsius: extension.crtMinTempCelsius,
      crtMaxTempCelsius: extension.crtMaxTempCelsius,
      hasHumidityControl: extension.hasHumidityControl,
      humidityRangeMin: extension.humidityRangeMin,
      humidityRangeMax: extension.humidityRangeMax,
      gdpCertified: extension.gdpCertified,
      gdpCertificationNumber: extension.gdpCertificationNumber,
      gdpCertificationExpiry: extension.gdpCertificationExpiry,
      isClinicalTrialSite: extension.isClinicalTrialSite,
      clinicalTrialPhaseAuthorized: extension.clinicalTrialPhaseAuthorized,
      irbApprovalNumber: extension.irbApprovalNumber,
      irbApprovalExpiry: extension.irbApprovalExpiry,
      isDscsaCompliant: extension.isDscsaCompliant,
      dscsaComplianceDate: extension.dscsaComplianceDate,
      hasSerializationCapability: extension.hasSerializationCapability,
      hasAggregationCapability: extension.hasAggregationCapability,
      interoperabilitySystem: extension.interoperabilitySystem,
      npiNumber: extension.npiNumber,
      ncpdpId: extension.ncpdpId,
      medicareProviderNumber: extension.medicareProviderNumber,
      medicaidProviderNumber: extension.medicaidProviderNumber,
      isIsoCertified: extension.isIsoCertified,
      isoCertificationType: extension.isoCertificationType,
      isoCertificationNumber: extension.isoCertificationNumber,
      isoCertificationExpiry: extension.isoCertificationExpiry,
      jcahoAccredited: extension.jcahoAccredited,
      jcahoAccreditationNumber: extension.jcahoAccreditationNumber,
      jcahoAccreditationExpiry: extension.jcahoAccreditationExpiry,
      emaSiteId: extension.emaSiteId,
      pmdaSiteId: extension.pmdaSiteId,
      anvisaSiteId: extension.anvisaSiteId,
      nmpaSiteId: extension.nmpaSiteId,
      receivingHours: extension.receivingHours,
      dispatchHours: extension.dispatchHours,
      hasWeighbridge: extension.hasWeighbridge,
      hasLoadingDock: extension.hasLoadingDock,
      hasForkliftCapability: extension.hasForkliftCapability,
      canReceiveHazmat: extension.canReceiveHazmat,
      pharmacistInCharge: extension.pharmacistInCharge,
      picLicenseNumber: extension.picLicenseNumber,
      responsiblePersonName: extension.responsiblePersonName,
      responsiblePersonEmail: extension.responsiblePersonEmail,
      responsiblePersonPhone: extension.responsiblePersonPhone,
      qualityContactName: extension.qualityContactName,
      qualityContactEmail: extension.qualityContactEmail,
      qualityContactPhone: extension.qualityContactPhone,
      regulatoryContactName: extension.regulatoryContactName,
      regulatoryContactEmail: extension.regulatoryContactEmail,
      regulatoryContactPhone: extension.regulatoryContactPhone,
      brandsyncPartyId: extension.brandsyncPartyId,
      tatmeenPartyCode: extension.tatmeenPartyCode,
      pharmacovigilanceEmail: extension.pharmacovigilanceEmail,
      recallContactEmail: extension.recallContactEmail,
      recallContactPhone: extension.recallContactPhone,
      epcisCaptureEndpointUrl: extension.epcisCaptureEndpointUrl,
      licensedAgentAuthorisationNumber:
          extension.licensedAgentAuthorisationNumber,
      authorisedPrincipalMahGlns: extension.authorisedPrincipalMahGlns,
      mahQualificationIndicator: extension.mahQualificationIndicator,
      mahTargetMarkets: extension.mahTargetMarkets,
      mahRegulatoryRegistrationNumber:
          extension.mahRegulatoryRegistrationNumber,
    );
  }

  String? validate() {
    return null;
  }

  Future<bool> save() async {
    return false;
  }
}
