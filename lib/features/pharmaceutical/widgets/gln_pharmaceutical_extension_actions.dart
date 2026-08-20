import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_types.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
extension GLNPharmaceuticalExtensionActions
    on GLNPharmaceuticalExtensionWidgetState {
  Future<void> loadExtension() async {
    if (widget.initialExtension != null) {
      populateFormFromExtension(widget.initialExtension!);
      if (mounted) {
        setState(() {
          extension = widget.initialExtension;
          isLoading = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  void populateFormFromExtension(GLNPharmaceuticalExtension ext) {
    healthcareFacilityType =
        ext.healthcareFacilityType ?? HealthcareFacilityType.other;
    fdaEstablishmentIdController.text = ext.fdaEstablishmentId ?? '';
    fdaRegistrationNumberController.text = ext.fdaRegistrationNumber ?? '';
    fdaRegistrationDate = ext.fdaRegistrationDate;
    fdaRegistrationExpiry = ext.fdaRegistrationExpiry;
    fdaEstablishmentTypeController.text = ext.fdaEstablishmentType ?? '';
    deaRegistrationNumberController.text = ext.deaRegistrationNumber ?? '';
    deaRegistrationExpiry = ext.deaRegistrationExpiry;
    deaScheduleAuthorizationController.text =
        ext.deaScheduleAuthorization ?? '';
    deaBusinessActivityController.text = ext.deaBusinessActivity ?? '';

    stateLicenseNumberController.text = ext.stateLicenseNumber ?? '';
    stateLicenseTypeController.text = ext.stateLicenseType ?? '';
    stateLicenseExpiry = ext.stateLicenseExpiry;
    stateLicenseState = ext.stateLicenseState;

    wholesaleLicenseNumberController.text = ext.wholesaleLicenseNumber ?? '';
    wholesaleLicenseExpiry = ext.wholesaleLicenseExpiry;
    isAuthorizedTradingPartner = ext.isAuthorizedTradingPartner;
    atpVerificationDate = ext.atpVerificationDate;
    vawdAccredited = ext.vawdAccredited;
    vawdAccreditationNumberController.text = ext.vawdAccreditationNumber ?? '';
    vawdExpiryDate = ext.vawdExpiryDate;

    hasColdChainCapability = ext.hasColdChainCapability;
    coldStorageMinTempController.text =
        ext.coldStorageMinTempCelsius?.toString() ?? '';
    coldStorageMaxTempController.text =
        ext.coldStorageMaxTempCelsius?.toString() ?? '';
    hasFreezerCapability = ext.hasFreezerCapability;
    freezerMinTempController.text =
        ext.freezerMinTempCelsius?.toString() ?? '';
    freezerMaxTempController.text =
        ext.freezerMaxTempCelsius?.toString() ?? '';
    hasControlledRoomTemp = ext.hasControlledRoomTemp;
    crtMinTempController.text = ext.crtMinTempCelsius?.toString() ?? '';
    crtMaxTempController.text = ext.crtMaxTempCelsius?.toString() ?? '';
    hasHumidityControl = ext.hasHumidityControl;
    humidityRangeMinController.text = ext.humidityRangeMin?.toString() ?? '';
    humidityRangeMaxController.text = ext.humidityRangeMax?.toString() ?? '';
    gdpCertified = ext.gdpCertified;
    gdpCertificationNumberController.text = ext.gdpCertificationNumber ?? '';
    gdpCertificationExpiry = ext.gdpCertificationExpiry;

    isClinicalTrialSite = ext.isClinicalTrialSite;
    clinicalTrialPhaseAuthorizedController.text =
        ext.clinicalTrialPhaseAuthorized ?? '';
    irbApprovalNumberController.text = ext.irbApprovalNumber ?? '';
    irbApprovalExpiry = ext.irbApprovalExpiry;

    isDscsaCompliant = ext.isDscsaCompliant;
    dscsaComplianceDate = ext.dscsaComplianceDate;
    hasSerializationCapability = ext.hasSerializationCapability;
    hasAggregationCapability = ext.hasAggregationCapability;
    interoperabilitySystemController.text = ext.interoperabilitySystem ?? '';

    npiNumberController.text = ext.npiNumber ?? '';
    ncpdpIdController.text = ext.ncpdpId ?? '';
    medicareProviderNumberController.text = ext.medicareProviderNumber ?? '';
    medicaidProviderNumberController.text = ext.medicaidProviderNumber ?? '';

    isIsoCertified = ext.isIsoCertified;
    isoCertificationTypeController.text = ext.isoCertificationType ?? '';
    isoCertificationNumberController.text = ext.isoCertificationNumber ?? '';
    isoCertificationExpiry = ext.isoCertificationExpiry;

    jcahoAccredited = ext.jcahoAccredited;
    jcahoAccreditationNumberController.text =
        ext.jcahoAccreditationNumber ?? '';
    jcahoAccreditationExpiry = ext.jcahoAccreditationExpiry;

    emaSiteIdController.text = ext.emaSiteId ?? '';
    pmdaSiteIdController.text = ext.pmdaSiteId ?? '';
    anvisaSiteIdController.text = ext.anvisaSiteId ?? '';
    nmpaSiteIdController.text = ext.nmpaSiteId ?? '';

    receivingHoursController.text = ext.receivingHours ?? '';
    dispatchHoursController.text = ext.dispatchHours ?? '';
    hasWeighbridge = ext.hasWeighbridge;
    hasLoadingDock = ext.hasLoadingDock;
    hasForkliftCapability = ext.hasForkliftCapability;
    canReceiveHazmat = ext.canReceiveHazmat;

    pharmacistInChargeController.text = ext.pharmacistInCharge ?? '';
    picLicenseNumberController.text = ext.picLicenseNumber ?? '';
    responsiblePersonNameController.text = ext.responsiblePersonName ?? '';
    responsiblePersonEmailController.text = ext.responsiblePersonEmail ?? '';
    responsiblePersonPhoneController.text = ext.responsiblePersonPhone ?? '';
    qualityContactNameController.text = ext.qualityContactName ?? '';
    qualityContactEmailController.text = ext.qualityContactEmail ?? '';
    qualityContactPhoneController.text = ext.qualityContactPhone ?? '';
    regulatoryContactNameController.text = ext.regulatoryContactName ?? '';
    regulatoryContactEmailController.text = ext.regulatoryContactEmail ?? '';
    regulatoryContactPhoneController.text = ext.regulatoryContactPhone ?? '';

    mahQualificationIndicator = ext.mahQualificationIndicator;
    mahTargetMarketsController.text = ext.mahTargetMarkets?.join(', ') ?? '';
    mahRegulatoryRegistrationNumberController.text =
        ext.mahRegulatoryRegistrationNumber ?? '';

    brandsyncPartyIdController.text = ext.brandsyncPartyId ?? '';
    tatmeenPartyCodeController.text = ext.tatmeenPartyCode ?? '';
    pharmacovigilanceEmailController.text = ext.pharmacovigilanceEmail ?? '';
    recallContactEmailController.text = ext.recallContactEmail ?? '';
    recallContactPhoneController.text = ext.recallContactPhone ?? '';
    epcisCaptureEndpointUrlController.text = ext.epcisCaptureEndpointUrl ?? '';
    licensedAgentAuthorisationController.text =
        ext.licensedAgentAuthorisationNumber ?? '';
    authorisedPrincipalMahGlnsController.text =
        ext.authorisedPrincipalMahGlns ?? '';
  }

  GLNPharmaceuticalExtension _buildExtensionFromForm() {
    return GLNPharmaceuticalExtension(
      id: extension?.id,
      glnId: widget.glnId ?? 0,
      glnCode: widget.glnCode,
      healthcareFacilityType: healthcareFacilityType,
      fdaEstablishmentId: fdaEstablishmentIdController.text.isNotEmpty
          ? fdaEstablishmentIdController.text
          : null,
      fdaRegistrationNumber: fdaRegistrationNumberController.text.isNotEmpty
          ? fdaRegistrationNumberController.text
          : null,
      fdaRegistrationDate: fdaRegistrationDate,
      fdaRegistrationExpiry: fdaRegistrationExpiry,
      fdaEstablishmentType: fdaEstablishmentTypeController.text.isNotEmpty
          ? fdaEstablishmentTypeController.text
          : null,
      deaRegistrationNumber: deaRegistrationNumberController.text.isNotEmpty
          ? deaRegistrationNumberController.text
          : null,
      deaRegistrationExpiry: deaRegistrationExpiry,
      deaScheduleAuthorization:
          deaScheduleAuthorizationController.text.isNotEmpty
          ? deaScheduleAuthorizationController.text
          : null,
      deaBusinessActivity: deaBusinessActivityController.text.isNotEmpty
          ? deaBusinessActivityController.text
          : null,
      stateLicenseNumber: stateLicenseNumberController.text.isNotEmpty
          ? stateLicenseNumberController.text
          : null,
      stateLicenseType: stateLicenseTypeController.text.isNotEmpty
          ? stateLicenseTypeController.text
          : null,
      stateLicenseExpiry: stateLicenseExpiry,
      stateLicenseState: stateLicenseState,
      wholesaleLicenseNumber: wholesaleLicenseNumberController.text.isNotEmpty
          ? wholesaleLicenseNumberController.text
          : null,
      wholesaleLicenseExpiry: wholesaleLicenseExpiry,
      isAuthorizedTradingPartner: isAuthorizedTradingPartner,
      atpVerificationDate: atpVerificationDate,
      vawdAccredited: vawdAccredited,
      vawdAccreditationNumber:
          vawdAccreditationNumberController.text.isNotEmpty
          ? vawdAccreditationNumberController.text
          : null,
      vawdExpiryDate: vawdExpiryDate,
      hasColdChainCapability: hasColdChainCapability,
      coldStorageMinTempCelsius: double.tryParse(
        coldStorageMinTempController.text,
      ),
      coldStorageMaxTempCelsius: double.tryParse(
        coldStorageMaxTempController.text,
      ),
      hasFreezerCapability: hasFreezerCapability,
      freezerMinTempCelsius: double.tryParse(freezerMinTempController.text),
      freezerMaxTempCelsius: double.tryParse(freezerMaxTempController.text),
      hasControlledRoomTemp: hasControlledRoomTemp,
      crtMinTempCelsius: double.tryParse(crtMinTempController.text),
      crtMaxTempCelsius: double.tryParse(crtMaxTempController.text),
      hasHumidityControl: hasHumidityControl,
      humidityRangeMin: double.tryParse(humidityRangeMinController.text),
      humidityRangeMax: double.tryParse(humidityRangeMaxController.text),
      gdpCertified: gdpCertified,
      gdpCertificationNumber: gdpCertificationNumberController.text.isNotEmpty
          ? gdpCertificationNumberController.text
          : null,
      gdpCertificationExpiry: gdpCertificationExpiry,
      isClinicalTrialSite: isClinicalTrialSite,
      clinicalTrialPhaseAuthorized:
          clinicalTrialPhaseAuthorizedController.text.isNotEmpty
          ? clinicalTrialPhaseAuthorizedController.text
          : null,
      irbApprovalNumber: irbApprovalNumberController.text.isNotEmpty
          ? irbApprovalNumberController.text
          : null,
      irbApprovalExpiry: irbApprovalExpiry,
      isDscsaCompliant: isDscsaCompliant,
      dscsaComplianceDate: dscsaComplianceDate,
      hasSerializationCapability: hasSerializationCapability,
      hasAggregationCapability: hasAggregationCapability,
      interoperabilitySystem: interoperabilitySystemController.text.isNotEmpty
          ? interoperabilitySystemController.text
          : null,
      npiNumber: npiNumberController.text.isNotEmpty
          ? npiNumberController.text
          : null,
      ncpdpId: ncpdpIdController.text.isNotEmpty
          ? ncpdpIdController.text
          : null,
      medicareProviderNumber: medicareProviderNumberController.text.isNotEmpty
          ? medicareProviderNumberController.text
          : null,
      medicaidProviderNumber: medicaidProviderNumberController.text.isNotEmpty
          ? medicaidProviderNumberController.text
          : null,
      isIsoCertified: isIsoCertified,
      isoCertificationType: isoCertificationTypeController.text.isNotEmpty
          ? isoCertificationTypeController.text
          : null,
      isoCertificationNumber: isoCertificationNumberController.text.isNotEmpty
          ? isoCertificationNumberController.text
          : null,
      isoCertificationExpiry: isoCertificationExpiry,
      jcahoAccredited: jcahoAccredited,
      jcahoAccreditationNumber:
          jcahoAccreditationNumberController.text.isNotEmpty
          ? jcahoAccreditationNumberController.text
          : null,
      jcahoAccreditationExpiry: jcahoAccreditationExpiry,
      emaSiteId: emaSiteIdController.text.isNotEmpty
          ? emaSiteIdController.text
          : null,
      pmdaSiteId: pmdaSiteIdController.text.isNotEmpty
          ? pmdaSiteIdController.text
          : null,
      anvisaSiteId: anvisaSiteIdController.text.isNotEmpty
          ? anvisaSiteIdController.text
          : null,
      nmpaSiteId: nmpaSiteIdController.text.isNotEmpty
          ? nmpaSiteIdController.text
          : null,
      receivingHours: receivingHoursController.text.isNotEmpty
          ? receivingHoursController.text
          : null,
      dispatchHours: dispatchHoursController.text.isNotEmpty
          ? dispatchHoursController.text
          : null,
      hasWeighbridge: hasWeighbridge,
      hasLoadingDock: hasLoadingDock,
      hasForkliftCapability: hasForkliftCapability,
      canReceiveHazmat: canReceiveHazmat,
      pharmacistInCharge: pharmacistInChargeController.text.isNotEmpty
          ? pharmacistInChargeController.text
          : null,
      picLicenseNumber: picLicenseNumberController.text.isNotEmpty
          ? picLicenseNumberController.text
          : null,
      responsiblePersonName: responsiblePersonNameController.text.isNotEmpty
          ? responsiblePersonNameController.text
          : null,
      responsiblePersonEmail: responsiblePersonEmailController.text.isNotEmpty
          ? responsiblePersonEmailController.text
          : null,
      responsiblePersonPhone: responsiblePersonPhoneController.text.isNotEmpty
          ? responsiblePersonPhoneController.text
          : null,
      qualityContactName: qualityContactNameController.text.isNotEmpty
          ? qualityContactNameController.text
          : null,
      qualityContactEmail: qualityContactEmailController.text.isNotEmpty
          ? qualityContactEmailController.text
          : null,
      qualityContactPhone: qualityContactPhoneController.text.isNotEmpty
          ? qualityContactPhoneController.text
          : null,
      regulatoryContactName: regulatoryContactNameController.text.isNotEmpty
          ? regulatoryContactNameController.text
          : null,
      regulatoryContactEmail: regulatoryContactEmailController.text.isNotEmpty
          ? regulatoryContactEmailController.text
          : null,
      regulatoryContactPhone: regulatoryContactPhoneController.text.isNotEmpty
          ? regulatoryContactPhoneController.text
          : null,
      brandsyncPartyId: brandsyncPartyIdController.text.isNotEmpty
          ? brandsyncPartyIdController.text
          : null,
      tatmeenPartyCode: tatmeenPartyCodeController.text.isNotEmpty
          ? tatmeenPartyCodeController.text
          : null,
      pharmacovigilanceEmail: pharmacovigilanceEmailController.text.isNotEmpty
          ? pharmacovigilanceEmailController.text
          : null,
      recallContactEmail: recallContactEmailController.text.isNotEmpty
          ? recallContactEmailController.text
          : null,
      recallContactPhone: recallContactPhoneController.text.isNotEmpty
          ? recallContactPhoneController.text
          : null,
      epcisCaptureEndpointUrl:
          epcisCaptureEndpointUrlController.text.isNotEmpty
          ? epcisCaptureEndpointUrlController.text
          : null,
      licensedAgentAuthorisationNumber:
          licensedAgentAuthorisationController.text.isNotEmpty
          ? licensedAgentAuthorisationController.text
          : null,
      authorisedPrincipalMahGlns:
          authorisedPrincipalMahGlnsController.text.isNotEmpty
          ? authorisedPrincipalMahGlnsController.text
          : null,
      mahQualificationIndicator: mahQualificationIndicator,
      mahTargetMarkets: _mahMarketsFromForm(),
      mahRegulatoryRegistrationNumber:
          mahRegulatoryRegistrationNumberController.text.isNotEmpty
          ? mahRegulatoryRegistrationNumberController.text
          : null,
    );
  }

  List<String>? _mahMarketsFromForm() {
    final t = mahTargetMarketsController.text.trim();
    if (t.isEmpty) return null;
    final parts = t
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }

  bool get hasData =>
      fdaEstablishmentIdController.text.isNotEmpty ||
      fdaRegistrationNumberController.text.isNotEmpty ||
      deaRegistrationNumberController.text.isNotEmpty ||
      stateLicenseNumberController.text.isNotEmpty ||
      wholesaleLicenseNumberController.text.isNotEmpty ||
      isAuthorizedTradingPartner ||
      vawdAccredited ||
      hasColdChainCapability ||
      gdpCertified ||
      isClinicalTrialSite ||
      isDscsaCompliant ||
      npiNumberController.text.isNotEmpty ||
      healthcareFacilityType != HealthcareFacilityType.other ||
      brandsyncPartyIdController.text.isNotEmpty ||
      tatmeenPartyCodeController.text.isNotEmpty ||
      pharmacovigilanceEmailController.text.isNotEmpty ||
      recallContactEmailController.text.isNotEmpty ||
      recallContactPhoneController.text.isNotEmpty ||
      epcisCaptureEndpointUrlController.text.isNotEmpty ||
      licensedAgentAuthorisationController.text.isNotEmpty ||
      authorisedPrincipalMahGlnsController.text.isNotEmpty ||
      mahQualificationIndicator ||
      mahTargetMarketsController.text.isNotEmpty ||
      mahRegulatoryRegistrationNumberController.text.isNotEmpty;

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
