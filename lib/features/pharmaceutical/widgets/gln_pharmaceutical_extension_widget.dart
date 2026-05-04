import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';

/// Widget that displays/edits pharmaceutical extension data for a GLN (location)
/// Can be embedded in GLN detail screens or used standalone
class GLNPharmaceuticalExtensionWidget extends StatefulWidget {
  final int? glnId;
  final String? glnCode;
  final bool isEditing;
  final Function(GLNPharmaceuticalExtension?)? onSaved;

  /// From master-data GLN payload (`GET .../glns/code/{code}`); avoids a separate extension API call.
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

// US State options (ISO 3166-2:US codes)
const Map<String, String> _usStateOptions = {
  'AL': 'Alabama', 'AK': 'Alaska', 'AZ': 'Arizona', 'AR': 'Arkansas',
  'CA': 'California', 'CO': 'Colorado', 'CT': 'Connecticut', 'DE': 'Delaware',
  'FL': 'Florida', 'GA': 'Georgia', 'HI': 'Hawaii', 'ID': 'Idaho',
  'IL': 'Illinois', 'IN': 'Indiana', 'IA': 'Iowa', 'KS': 'Kansas',
  'KY': 'Kentucky', 'LA': 'Louisiana', 'ME': 'Maine', 'MD': 'Maryland',
  'MA': 'Massachusetts', 'MI': 'Michigan', 'MN': 'Minnesota', 'MS': 'Mississippi',
  'MO': 'Missouri', 'MT': 'Montana', 'NE': 'Nebraska', 'NV': 'Nevada',
  'NH': 'New Hampshire', 'NJ': 'New Jersey', 'NM': 'New Mexico', 'NY': 'New York',
  'NC': 'North Carolina', 'ND': 'North Dakota', 'OH': 'Ohio', 'OK': 'Oklahoma',
  'OR': 'Oregon', 'PA': 'Pennsylvania', 'RI': 'Rhode Island', 'SC': 'South Carolina',
  'SD': 'South Dakota', 'TN': 'Tennessee', 'TX': 'Texas', 'UT': 'Utah',
  'VT': 'Vermont', 'VA': 'Virginia', 'WA': 'Washington', 'WV': 'West Virginia',
  'WI': 'Wisconsin', 'WY': 'Wyoming', 'DC': 'District of Columbia',
  'PR': 'Puerto Rico', 'GU': 'Guam', 'VI': 'Virgin Islands',
};

/// State class for GLNPharmaceuticalExtensionWidget
class GLNPharmaceuticalExtensionWidgetState
    extends State<GLNPharmaceuticalExtensionWidget> {
  GLNPharmaceuticalExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  // Healthcare Facility Type
  HealthcareFacilityType _healthcareFacilityType = HealthcareFacilityType.other;
  
  // FDA Establishment Data
  final _fdaEstablishmentIdController = TextEditingController();
  final _fdaRegistrationNumberController = TextEditingController();
  DateTime? _fdaRegistrationDate;
  DateTime? _fdaRegistrationExpiry;
  final _fdaEstablishmentTypeController = TextEditingController();

  // DEA Registration
  final _deaRegistrationNumberController = TextEditingController();
  DateTime? _deaRegistrationExpiry;
  final _deaScheduleAuthorizationController = TextEditingController();
  final _deaBusinessActivityController = TextEditingController();

  // State Licenses
  final _stateLicenseNumberController = TextEditingController();
  final _stateLicenseTypeController = TextEditingController();
  DateTime? _stateLicenseExpiry;
  String? _stateLicenseState; // Changed from TextEditingController to state variable for dropdown

  // Wholesale/Distribution
  final _wholesaleLicenseNumberController = TextEditingController();
  DateTime? _wholesaleLicenseExpiry;
  bool _isAuthorizedTradingPartner = false;
  DateTime? _atpVerificationDate;
  bool _vawdAccredited = false;
  final _vawdAccreditationNumberController = TextEditingController();
  DateTime? _vawdExpiryDate;

  // Cold Chain & Storage
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

  // Clinical Trials
  bool _isClinicalTrialSite = false;
  final _clinicalTrialPhaseAuthorizedController = TextEditingController();
  final _irbApprovalNumberController = TextEditingController();
  DateTime? _irbApprovalExpiry;

  // DSCSA Compliance
  bool _isDscsaCompliant = false;
  DateTime? _dscsaComplianceDate;
  bool _hasSerializationCapability = false;
  bool _hasAggregationCapability = false;
  final _interoperabilitySystemController = TextEditingController();

  // Healthcare IDs
  final _npiNumberController = TextEditingController();
  final _ncpdpIdController = TextEditingController();
  final _medicareProviderNumberController = TextEditingController();
  final _medicaidProviderNumberController = TextEditingController();

  // Certifications
  bool _isIsoCertified = false;
  final _isoCertificationTypeController = TextEditingController();
  final _isoCertificationNumberController = TextEditingController();
  DateTime? _isoCertificationExpiry;
  bool _jcahoAccredited = false;
  final _jcahoAccreditationNumberController = TextEditingController();
  DateTime? _jcahoAccreditationExpiry;

  // International Regulatory
  final _emaSiteIdController = TextEditingController();
  final _pmdaSiteIdController = TextEditingController();
  final _anvisaSiteIdController = TextEditingController();
  final _nmpaSiteIdController = TextEditingController();

  // Operational Details
  final _receivingHoursController = TextEditingController();
  final _dispatchHoursController = TextEditingController();
  bool _hasWeighbridge = false;
  bool _hasLoadingDock = false;
  bool _hasForkliftCapability = false;
  bool _canReceiveHazmat = false;

  // Contact Information
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
        _hasExtension = true;
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
    // _stateLicenseStateController removed - using state variable for dropdown
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

  Future<void> _loadExtension() async {
    if (widget.initialExtension != null) {
      _populateFormFromExtension(widget.initialExtension!);
      if (mounted) {
        setState(() {
          _extension = widget.initialExtension;
          _hasExtension = true;
          _isLoading = false;
        });
      }
      return;
    }

    // Pharmaceutical extension is supplied by the master-data GLN response when present.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormFromExtension(GLNPharmaceuticalExtension ext) {
    _healthcareFacilityType = ext.healthcareFacilityType ?? HealthcareFacilityType.other;
    
    // FDA
    _fdaEstablishmentIdController.text = ext.fdaEstablishmentId ?? '';
    _fdaRegistrationNumberController.text = ext.fdaRegistrationNumber ?? '';
    _fdaRegistrationDate = ext.fdaRegistrationDate;
    _fdaRegistrationExpiry = ext.fdaRegistrationExpiry;
    _fdaEstablishmentTypeController.text = ext.fdaEstablishmentType ?? '';

    // DEA
    _deaRegistrationNumberController.text = ext.deaRegistrationNumber ?? '';
    _deaRegistrationExpiry = ext.deaRegistrationExpiry;
    _deaScheduleAuthorizationController.text = ext.deaScheduleAuthorization ?? '';
    _deaBusinessActivityController.text = ext.deaBusinessActivity ?? '';

    // State License
    _stateLicenseNumberController.text = ext.stateLicenseNumber ?? '';
    _stateLicenseTypeController.text = ext.stateLicenseType ?? '';
    _stateLicenseExpiry = ext.stateLicenseExpiry;
    _stateLicenseState = ext.stateLicenseState;

    // Wholesale
    _wholesaleLicenseNumberController.text = ext.wholesaleLicenseNumber ?? '';
    _wholesaleLicenseExpiry = ext.wholesaleLicenseExpiry;
    _isAuthorizedTradingPartner = ext.isAuthorizedTradingPartner;
    _atpVerificationDate = ext.atpVerificationDate;
    _vawdAccredited = ext.vawdAccredited;
    _vawdAccreditationNumberController.text = ext.vawdAccreditationNumber ?? '';
    _vawdExpiryDate = ext.vawdExpiryDate;

    // Cold Chain
    _hasColdChainCapability = ext.hasColdChainCapability;
    _coldStorageMinTempController.text = ext.coldStorageMinTempCelsius?.toString() ?? '';
    _coldStorageMaxTempController.text = ext.coldStorageMaxTempCelsius?.toString() ?? '';
    _hasFreezerCapability = ext.hasFreezerCapability;
    _freezerMinTempController.text = ext.freezerMinTempCelsius?.toString() ?? '';
    _freezerMaxTempController.text = ext.freezerMaxTempCelsius?.toString() ?? '';
    _hasControlledRoomTemp = ext.hasControlledRoomTemp;
    _crtMinTempController.text = ext.crtMinTempCelsius?.toString() ?? '';
    _crtMaxTempController.text = ext.crtMaxTempCelsius?.toString() ?? '';
    _hasHumidityControl = ext.hasHumidityControl;
    _humidityRangeMinController.text = ext.humidityRangeMin?.toString() ?? '';
    _humidityRangeMaxController.text = ext.humidityRangeMax?.toString() ?? '';
    _gdpCertified = ext.gdpCertified;
    _gdpCertificationNumberController.text = ext.gdpCertificationNumber ?? '';
    _gdpCertificationExpiry = ext.gdpCertificationExpiry;

    // Clinical Trial
    _isClinicalTrialSite = ext.isClinicalTrialSite;
    _clinicalTrialPhaseAuthorizedController.text = ext.clinicalTrialPhaseAuthorized ?? '';
    _irbApprovalNumberController.text = ext.irbApprovalNumber ?? '';
    _irbApprovalExpiry = ext.irbApprovalExpiry;

    // DSCSA
    _isDscsaCompliant = ext.isDscsaCompliant;
    _dscsaComplianceDate = ext.dscsaComplianceDate;
    _hasSerializationCapability = ext.hasSerializationCapability;
    _hasAggregationCapability = ext.hasAggregationCapability;
    _interoperabilitySystemController.text = ext.interoperabilitySystem ?? '';

    // Healthcare IDs
    _npiNumberController.text = ext.npiNumber ?? '';
    _ncpdpIdController.text = ext.ncpdpId ?? '';
    _medicareProviderNumberController.text = ext.medicareProviderNumber ?? '';
    _medicaidProviderNumberController.text = ext.medicaidProviderNumber ?? '';

    // ISO Certification
    _isIsoCertified = ext.isIsoCertified;
    _isoCertificationTypeController.text = ext.isoCertificationType ?? '';
    _isoCertificationNumberController.text = ext.isoCertificationNumber ?? '';
    _isoCertificationExpiry = ext.isoCertificationExpiry;

    // JCAHO
    _jcahoAccredited = ext.jcahoAccredited;
    _jcahoAccreditationNumberController.text = ext.jcahoAccreditationNumber ?? '';
    _jcahoAccreditationExpiry = ext.jcahoAccreditationExpiry;

    // International
    _emaSiteIdController.text = ext.emaSiteId ?? '';
    _pmdaSiteIdController.text = ext.pmdaSiteId ?? '';
    _anvisaSiteIdController.text = ext.anvisaSiteId ?? '';
    _nmpaSiteIdController.text = ext.nmpaSiteId ?? '';

    // Operational
    _receivingHoursController.text = ext.receivingHours ?? '';
    _dispatchHoursController.text = ext.dispatchHours ?? '';
    _hasWeighbridge = ext.hasWeighbridge;
    _hasLoadingDock = ext.hasLoadingDock;
    _hasForkliftCapability = ext.hasForkliftCapability;
    _canReceiveHazmat = ext.canReceiveHazmat;

    // Contacts
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
          ? _fdaEstablishmentIdController.text : null,
      fdaRegistrationNumber: _fdaRegistrationNumberController.text.isNotEmpty 
          ? _fdaRegistrationNumberController.text : null,
      fdaRegistrationDate: _fdaRegistrationDate,
      fdaRegistrationExpiry: _fdaRegistrationExpiry,
      fdaEstablishmentType: _fdaEstablishmentTypeController.text.isNotEmpty 
          ? _fdaEstablishmentTypeController.text : null,
      deaRegistrationNumber: _deaRegistrationNumberController.text.isNotEmpty 
          ? _deaRegistrationNumberController.text : null,
      deaRegistrationExpiry: _deaRegistrationExpiry,
      deaScheduleAuthorization: _deaScheduleAuthorizationController.text.isNotEmpty 
          ? _deaScheduleAuthorizationController.text : null,
      deaBusinessActivity: _deaBusinessActivityController.text.isNotEmpty 
          ? _deaBusinessActivityController.text : null,
      stateLicenseNumber: _stateLicenseNumberController.text.isNotEmpty 
          ? _stateLicenseNumberController.text : null,
      stateLicenseType: _stateLicenseTypeController.text.isNotEmpty 
          ? _stateLicenseTypeController.text : null,
      stateLicenseExpiry: _stateLicenseExpiry,
      stateLicenseState: _stateLicenseState,
      wholesaleLicenseNumber: _wholesaleLicenseNumberController.text.isNotEmpty 
          ? _wholesaleLicenseNumberController.text : null,
      wholesaleLicenseExpiry: _wholesaleLicenseExpiry,
      isAuthorizedTradingPartner: _isAuthorizedTradingPartner,
      atpVerificationDate: _atpVerificationDate,
      vawdAccredited: _vawdAccredited,
      vawdAccreditationNumber: _vawdAccreditationNumberController.text.isNotEmpty 
          ? _vawdAccreditationNumberController.text : null,
      vawdExpiryDate: _vawdExpiryDate,
      hasColdChainCapability: _hasColdChainCapability,
      coldStorageMinTempCelsius: double.tryParse(_coldStorageMinTempController.text),
      coldStorageMaxTempCelsius: double.tryParse(_coldStorageMaxTempController.text),
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
          ? _gdpCertificationNumberController.text : null,
      gdpCertificationExpiry: _gdpCertificationExpiry,
      isClinicalTrialSite: _isClinicalTrialSite,
      clinicalTrialPhaseAuthorized: _clinicalTrialPhaseAuthorizedController.text.isNotEmpty 
          ? _clinicalTrialPhaseAuthorizedController.text : null,
      irbApprovalNumber: _irbApprovalNumberController.text.isNotEmpty 
          ? _irbApprovalNumberController.text : null,
      irbApprovalExpiry: _irbApprovalExpiry,
      isDscsaCompliant: _isDscsaCompliant,
      dscsaComplianceDate: _dscsaComplianceDate,
      hasSerializationCapability: _hasSerializationCapability,
      hasAggregationCapability: _hasAggregationCapability,
      interoperabilitySystem: _interoperabilitySystemController.text.isNotEmpty 
          ? _interoperabilitySystemController.text : null,
      npiNumber: _npiNumberController.text.isNotEmpty 
          ? _npiNumberController.text : null,
      ncpdpId: _ncpdpIdController.text.isNotEmpty 
          ? _ncpdpIdController.text : null,
      medicareProviderNumber: _medicareProviderNumberController.text.isNotEmpty 
          ? _medicareProviderNumberController.text : null,
      medicaidProviderNumber: _medicaidProviderNumberController.text.isNotEmpty 
          ? _medicaidProviderNumberController.text : null,
      isIsoCertified: _isIsoCertified,
      isoCertificationType: _isoCertificationTypeController.text.isNotEmpty 
          ? _isoCertificationTypeController.text : null,
      isoCertificationNumber: _isoCertificationNumberController.text.isNotEmpty 
          ? _isoCertificationNumberController.text : null,
      isoCertificationExpiry: _isoCertificationExpiry,
      jcahoAccredited: _jcahoAccredited,
      jcahoAccreditationNumber: _jcahoAccreditationNumberController.text.isNotEmpty 
          ? _jcahoAccreditationNumberController.text : null,
      jcahoAccreditationExpiry: _jcahoAccreditationExpiry,
      emaSiteId: _emaSiteIdController.text.isNotEmpty 
          ? _emaSiteIdController.text : null,
      pmdaSiteId: _pmdaSiteIdController.text.isNotEmpty 
          ? _pmdaSiteIdController.text : null,
      anvisaSiteId: _anvisaSiteIdController.text.isNotEmpty 
          ? _anvisaSiteIdController.text : null,
      nmpaSiteId: _nmpaSiteIdController.text.isNotEmpty 
          ? _nmpaSiteIdController.text : null,
      receivingHours: _receivingHoursController.text.isNotEmpty 
          ? _receivingHoursController.text : null,
      dispatchHours: _dispatchHoursController.text.isNotEmpty 
          ? _dispatchHoursController.text : null,
      hasWeighbridge: _hasWeighbridge,
      hasLoadingDock: _hasLoadingDock,
      hasForkliftCapability: _hasForkliftCapability,
      canReceiveHazmat: _canReceiveHazmat,
      pharmacistInCharge: _pharmacistInChargeController.text.isNotEmpty 
          ? _pharmacistInChargeController.text : null,
      picLicenseNumber: _picLicenseNumberController.text.isNotEmpty 
          ? _picLicenseNumberController.text : null,
      responsiblePersonName: _responsiblePersonNameController.text.isNotEmpty 
          ? _responsiblePersonNameController.text : null,
      responsiblePersonEmail: _responsiblePersonEmailController.text.isNotEmpty 
          ? _responsiblePersonEmailController.text : null,
      responsiblePersonPhone: _responsiblePersonPhoneController.text.isNotEmpty 
          ? _responsiblePersonPhoneController.text : null,
      qualityContactName: _qualityContactNameController.text.isNotEmpty 
          ? _qualityContactNameController.text : null,
      qualityContactEmail: _qualityContactEmailController.text.isNotEmpty 
          ? _qualityContactEmailController.text : null,
      qualityContactPhone: _qualityContactPhoneController.text.isNotEmpty 
          ? _qualityContactPhoneController.text : null,
      regulatoryContactName: _regulatoryContactNameController.text.isNotEmpty 
          ? _regulatoryContactNameController.text : null,
      regulatoryContactEmail: _regulatoryContactEmailController.text.isNotEmpty 
          ? _regulatoryContactEmailController.text : null,
      regulatoryContactPhone: _regulatoryContactPhoneController.text.isNotEmpty 
          ? _regulatoryContactPhoneController.text : null,
      brandsyncPartyId: _brandsyncPartyIdController.text.isNotEmpty
          ? _brandsyncPartyIdController.text
          : null,
      tatmeenPartyCode: _tatmeenPartyCodeController.text.isNotEmpty
          ? _tatmeenPartyCodeController.text
          : null,
      pharmacovigilanceEmail:
          _pharmacovigilanceEmailController.text.isNotEmpty
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
    final parts =
        t.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? null : parts;
  }

  /// Check if user has entered any pharmaceutical data
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

  /// Build the extension object from form data for external callers
  GLNPharmaceuticalExtension? buildExtension({int? glnId, String? glnCode}) {
    if (!hasData) return null;
    
    final extension = _buildExtensionFromForm();
    // Return a copy with the provided glnId and glnCode if different
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

  /// Validate the extension form
  String? validate() {
    // All fields are optional
    return null;
  }

  Future<bool> save() async {
    // Persisted with master-data GLN create/update ([GLN.toJson] → `/master-data/glns` ).
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        collapsedIconColor: scheme.primary,
        iconColor: scheme.primary,
        collapsedTextColor: scheme.onSurface,
        textColor: scheme.onSurface,
        title: Row(
          children: [
            Icon(
              Icons.local_pharmacy,
              color: _hasExtension ? scheme.primary : scheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              GlnPharmaceuticalExtensionUiConstants.expansionTitle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            if (_hasExtension)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  GlnPharmaceuticalExtensionUiConstants.badgeSaved,
                  style: TextStyle(fontSize: 12, color: scheme.onPrimaryContainer),
                ),
              ),
          ],
        ),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUaeRegistryAndSafetySection(),
                const SizedBox(height: 16),
                _buildFacilitySection(),
                const SizedBox(height: 16),
                _buildFdaSection(),
                const SizedBox(height: 16),
                _buildDeaSection(),
                const SizedBox(height: 16),
                _buildStateLicenseSection(),
                const SizedBox(height: 16),
                _buildWholesaleSection(),
                const SizedBox(height: 16),
                _buildColdChainSection(),
                const SizedBox(height: 16),
                _buildClinicalTrialSection(),
                const SizedBox(height: 16),
                _buildDscsaSection(),
                const SizedBox(height: 16),
                _buildHealthcareIdsSection(),
                const SizedBox(height: 16),
                _buildCertificationsSection(),
                const SizedBox(height: 16),
                _buildInternationalSection(),
                const SizedBox(height: 16),
                _buildOperationalSection(),
                const SizedBox(height: 16),
                _buildContactsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUaeRegistryAndSafetySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(GlnPharmaceuticalExtensionUiConstants.sectionUaeRegistry),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _brandsyncPartyIdController,
                label: GlnPharmaceuticalExtensionUiConstants.labelBrandSyncPartyId,
                enabled: widget.isEditing,
                maxLength: 50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _tatmeenPartyCodeController,
                label: GlnPharmaceuticalExtensionUiConstants.labelTatmeenPartyCode,
                enabled: widget.isEditing,
                maxLength: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel(GlnPharmaceuticalExtensionUiConstants.sectionMahTargetMarkets),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelMahQualificationIndicator,
          value: _mahQualificationIndicator,
          onChanged: widget.isEditing
              ? (value) => setState(() => _mahQualificationIndicator = value)
              : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _mahTargetMarketsController,
          label: GlnPharmaceuticalExtensionUiConstants.labelMahTargetMarketsIso,
          hint: GlnPharmaceuticalExtensionUiConstants.hintMahTargetMarketsIso,
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _mahRegulatoryRegistrationNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelMahRegulatoryRegistrationNumber,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        const SectionLabel(GlnPharmaceuticalExtensionUiConstants.sectionLicensedAgent),
        _buildTextField(
          controller: _licensedAgentAuthorisationController,
          label: GlnPharmaceuticalExtensionUiConstants.labelLicensedAgentAuthorisationNumber,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _authorisedPrincipalMahGlnsController,
          label: GlnPharmaceuticalExtensionUiConstants.labelAuthorisedPrincipalMahGlns,
          hint: GlnPharmaceuticalExtensionUiConstants.hintAuthorisedPrincipalMahGlns,
          enabled: widget.isEditing,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        const SectionLabel(GlnPharmaceuticalExtensionUiConstants.sectionPharmacovigilance),
        _buildTextField(
          controller: _pharmacovigilanceEmailController,
          label: GlnPharmaceuticalExtensionUiConstants.labelPharmacovigilanceEmail,
          enabled: widget.isEditing,
          keyboardType: TextInputType.emailAddress,
          maxLength: 254,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _recallContactEmailController,
                label: GlnPharmaceuticalExtensionUiConstants.labelRecallContactEmail,
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 254,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _recallContactPhoneController,
                label: GlnPharmaceuticalExtensionUiConstants.labelRecallContactPhone,
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel(GlnPharmaceuticalExtensionUiConstants.sectionEpicsDataExchange),
        _buildTextField(
          controller: _epcisCaptureEndpointUrlController,
          label: GlnPharmaceuticalExtensionUiConstants.labelEpicsCaptureEndpointUrl,
          hint: GlnPharmaceuticalExtensionUiConstants.hintHttpsUrl,
          enabled: widget.isEditing,
          keyboardType: TextInputType.url,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildFacilitySection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardHealthcareFacilityType,
      Icons.local_hospital,
      [
        DropdownButtonFormField<HealthcareFacilityType>(
          value: _healthcareFacilityType,
          decoration: const InputDecoration(
            labelText: GlnPharmaceuticalExtensionUiConstants.labelFacilityType,
            border: OutlineInputBorder(),
          ),
          items: HealthcareFacilityType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: widget.isEditing
              ? (value) {
                  if (value != null) {
                    setState(() {
                      _healthcareFacilityType = value;
                    });
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildFdaSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardFdaEstablishment,
      Icons.verified_user,
      [
        _buildTextField(
          controller: _fdaEstablishmentIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelFdaEstablishmentId,
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _fdaRegistrationNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelFdaRegistrationNumber,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _fdaEstablishmentTypeController,
          label: GlnPharmaceuticalExtensionUiConstants.labelFdaEstablishmentType,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: GlnPharmaceuticalExtensionUiConstants.labelRegistrationDate,
                value: _fdaRegistrationDate,
                onChanged: widget.isEditing
                    ? (date) => setState(() => _fdaRegistrationDate = date)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: GlnPharmaceuticalExtensionUiConstants.labelRegistrationExpiry,
                value: _fdaRegistrationExpiry,
                onChanged: widget.isEditing
                    ? (date) => setState(() => _fdaRegistrationExpiry = date)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeaSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardDeaRegistration,
      Icons.security,
      [
        _buildTextField(
          controller: _deaRegistrationNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelDeaRegistrationNumber,
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: GlnPharmaceuticalExtensionUiConstants.labelDeaRegistrationExpiry,
          value: _deaRegistrationExpiry,
          onChanged: widget.isEditing
              ? (date) => setState(() => _deaRegistrationExpiry = date)
              : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _deaScheduleAuthorizationController,
          label: GlnPharmaceuticalExtensionUiConstants.labelDeaScheduleAuthorization,
          enabled: widget.isEditing,
          hint: GlnPharmaceuticalExtensionUiConstants.hintDeaSchedule,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _deaBusinessActivityController,
          label: GlnPharmaceuticalExtensionUiConstants.labelDeaBusinessActivity,
          enabled: widget.isEditing,
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildStateLicenseSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardStateProvincialLicense,
      Icons.badge,
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _stateLicenseNumberController,
                label: GlnPharmaceuticalExtensionUiConstants.labelLicenseNumber,
                enabled: widget.isEditing,
                maxLength: 50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _stateLicenseState,
                decoration: const InputDecoration(
                  labelText: GlnPharmaceuticalExtensionUiConstants.labelStateDropdown,
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text(GlnExtensionSharedUiConstants.selectState),
                  ),
                  ..._usStateOptions.entries.map((entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text('${entry.key} - ${entry.value}'),
                  )),
                ],
                onChanged: widget.isEditing ? (value) => setState(() => _stateLicenseState = value) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _stateLicenseTypeController,
          label: GlnPharmaceuticalExtensionUiConstants.labelLicenseType,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: GlnPharmaceuticalExtensionUiConstants.labelLicenseExpiry,
          value: _stateLicenseExpiry,
          onChanged: widget.isEditing
              ? (date) => setState(() => _stateLicenseExpiry = date)
              : null,
        ),
      ],
    );
  }

  Widget _buildWholesaleSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardWholesaleDistribution,
      Icons.local_shipping,
      [
        _buildTextField(
          controller: _wholesaleLicenseNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelWholesaleLicenseNumber,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: GlnPharmaceuticalExtensionUiConstants.labelWholesaleLicenseExpiry,
          value: _wholesaleLicenseExpiry,
          onChanged: widget.isEditing
              ? (date) => setState(() => _wholesaleLicenseExpiry = date)
              : null,
        ),
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelAuthorizedTradingPartner,
          value: _isAuthorizedTradingPartner,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isAuthorizedTradingPartner = value)
              : null,
        ),
        if (_isAuthorizedTradingPartner) ...[
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelAtpVerificationDate,
            value: _atpVerificationDate,
            onChanged: widget.isEditing
                ? (date) => setState(() => _atpVerificationDate = date)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelVawdAccredited,
          value: _vawdAccredited,
          onChanged: widget.isEditing
              ? (value) => setState(() => _vawdAccredited = value)
              : null,
        ),
        if (_vawdAccredited) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _vawdAccreditationNumberController,
            label: GlnPharmaceuticalExtensionUiConstants.labelVawdAccreditationNumber,
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelVawdExpiryDate,
            value: _vawdExpiryDate,
            onChanged: widget.isEditing
                ? (date) => setState(() => _vawdExpiryDate = date)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildColdChainSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardColdChainStorage,
      Icons.ac_unit,
      [
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelColdChainCapability,
          value: _hasColdChainCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasColdChainCapability = value)
              : null,
        ),
        if (_hasColdChainCapability) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _coldStorageMinTempController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelMinTempC,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _coldStorageMaxTempController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelMaxTempC,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelFreezerCapability,
          value: _hasFreezerCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasFreezerCapability = value)
              : null,
        ),
        if (_hasFreezerCapability) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _freezerMinTempController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelFreezerMinC,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _freezerMaxTempController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelFreezerMaxC,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelControlledRoomTemperature,
          value: _hasControlledRoomTemp,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasControlledRoomTemp = value)
              : null,
        ),
        if (_hasControlledRoomTemp) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _crtMinTempController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelCrtMinC,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _crtMaxTempController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelCrtMaxC,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHumidityControl,
          value: _hasHumidityControl,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasHumidityControl = value)
              : null,
        ),
        if (_hasHumidityControl) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _humidityRangeMinController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelMinHumidityPct,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _humidityRangeMaxController,
                  label: GlnPharmaceuticalExtensionUiConstants.labelMaxHumidityPct,
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelGdpCertified,
          value: _gdpCertified,
          onChanged: widget.isEditing
              ? (value) => setState(() => _gdpCertified = value)
              : null,
        ),
        if (_gdpCertified) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _gdpCertificationNumberController,
            label: GlnPharmaceuticalExtensionUiConstants.labelGdpCertificationNumber,
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelGdpCertificationExpiry,
            value: _gdpCertificationExpiry,
            onChanged: widget.isEditing
                ? (date) => setState(() => _gdpCertificationExpiry = date)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildClinicalTrialSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardClinicalTrialSite,
      Icons.science,
      [
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelClinicalTrialSiteSwitch,
          value: _isClinicalTrialSite,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isClinicalTrialSite = value)
              : null,
        ),
        if (_isClinicalTrialSite) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _clinicalTrialPhaseAuthorizedController,
            label: GlnPharmaceuticalExtensionUiConstants.labelClinicalTrialPhaseAuthorized,
            enabled: widget.isEditing,
            hint: GlnPharmaceuticalExtensionUiConstants.hintClinicalTrialPhase,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _irbApprovalNumberController,
            label: GlnPharmaceuticalExtensionUiConstants.labelIrbApprovalNumber,
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelIrbApprovalExpiry,
            value: _irbApprovalExpiry,
            onChanged: widget.isEditing
                ? (date) => setState(() => _irbApprovalExpiry = date)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildDscsaSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardDscsaCompliance,
      Icons.verified,
      [
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelDscsaCompliant,
          value: _isDscsaCompliant,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isDscsaCompliant = value)
              : null,
        ),
        if (_isDscsaCompliant) ...[
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelDscsaComplianceDate,
            value: _dscsaComplianceDate,
            onChanged: widget.isEditing
                ? (date) => setState(() => _dscsaComplianceDate = date)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelSerializationCapability,
          value: _hasSerializationCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasSerializationCapability = value)
              : null,
        ),
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelAggregationCapability,
          value: _hasAggregationCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasAggregationCapability = value)
              : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _interoperabilitySystemController,
          label: GlnPharmaceuticalExtensionUiConstants.labelInteroperabilitySystem,
          enabled: widget.isEditing,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildHealthcareIdsSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardHealthcareIdentifiers,
      Icons.numbers,
      [
        _buildTextField(
          controller: _npiNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelNpiNumber,
          enabled: widget.isEditing,
          maxLength: 15,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _ncpdpIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelNcpdpId,
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _medicareProviderNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelMedicareProviderNumber,
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _medicaidProviderNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelMedicaidProviderNumber,
          enabled: widget.isEditing,
          maxLength: 20,
        ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardCertificationsAccreditations,
      Icons.workspace_premium,
      [
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelIsoCertified,
          value: _isIsoCertified,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isIsoCertified = value)
              : null,
        ),
        if (_isIsoCertified) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _isoCertificationTypeController,
            label: GlnPharmaceuticalExtensionUiConstants.labelIsoCertificationType,
            enabled: widget.isEditing,
            hint: GlnPharmaceuticalExtensionUiConstants.hintIsoCertificationType,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _isoCertificationNumberController,
            label: GlnPharmaceuticalExtensionUiConstants.labelIsoCertificationNumber,
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelIsoCertificationExpiry,
            value: _isoCertificationExpiry,
            onChanged: widget.isEditing
                ? (date) => setState(() => _isoCertificationExpiry = date)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelJcahoAccredited,
          value: _jcahoAccredited,
          onChanged: widget.isEditing
              ? (value) => setState(() => _jcahoAccredited = value)
              : null,
        ),
        if (_jcahoAccredited) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _jcahoAccreditationNumberController,
            label: GlnPharmaceuticalExtensionUiConstants.labelJcahoAccreditationNumber,
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelJcahoAccreditationExpiry,
            value: _jcahoAccreditationExpiry,
            onChanged: widget.isEditing
                ? (date) => setState(() => _jcahoAccreditationExpiry = date)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildInternationalSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardInternationalRegulatoryIds,
      Icons.public,
      [
        _buildTextField(
          controller: _emaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelEmaSiteId,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _pmdaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelPmdaSiteId,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _anvisaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelAnvisaSiteId,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nmpaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelNmpaSiteId,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
      ],
    );
  }

  Widget _buildOperationalSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardOperationalDetails,
      Icons.access_time,
      [
        _buildTextField(
          controller: _receivingHoursController,
          label: GlnPharmaceuticalExtensionUiConstants.labelReceivingHours,
          enabled: widget.isEditing,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _dispatchHoursController,
          label: GlnPharmaceuticalExtensionUiConstants.labelDispatchHours,
          enabled: widget.isEditing,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHasWeighbridge,
          value: _hasWeighbridge,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasWeighbridge = value)
              : null,
        ),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHasLoadingDock,
          value: _hasLoadingDock,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasLoadingDock = value)
              : null,
        ),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHasForkliftCapability,
          value: _hasForkliftCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasForkliftCapability = value)
              : null,
        ),
        _buildSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelCanReceiveHazmat,
          value: _canReceiveHazmat,
          onChanged: widget.isEditing
              ? (value) => setState(() => _canReceiveHazmat = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildContactsSection() {
    return _buildSection(
      GlnPharmaceuticalExtensionUiConstants.cardContactInformation,
      Icons.contact_phone,
      [
        const Text(
          GlnPharmaceuticalExtensionUiConstants.headingPharmacistInCharge,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _pharmacistInChargeController,
          label: GlnPharmaceuticalExtensionUiConstants.labelName,
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _picLicenseNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelLicenseNumber,
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        const Text(
          GlnPharmaceuticalExtensionUiConstants.headingResponsiblePerson,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _responsiblePersonNameController,
          label: GlnPharmaceuticalExtensionUiConstants.labelName,
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _responsiblePersonEmailController,
                label: GlnPharmaceuticalExtensionUiConstants.labelEmail,
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _responsiblePersonPhoneController,
                label: GlnPharmaceuticalExtensionUiConstants.labelPhone,
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          GlnPharmaceuticalExtensionUiConstants.headingQualityContact,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _qualityContactNameController,
          label: GlnPharmaceuticalExtensionUiConstants.labelName,
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _qualityContactEmailController,
                label: GlnPharmaceuticalExtensionUiConstants.labelEmail,
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _qualityContactPhoneController,
                label: GlnPharmaceuticalExtensionUiConstants.labelPhone,
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          GlnPharmaceuticalExtensionUiConstants.headingRegulatoryContact,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _regulatoryContactNameController,
          label: GlnPharmaceuticalExtensionUiConstants.labelName,
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _regulatoryContactEmailController,
                label: GlnPharmaceuticalExtensionUiConstants.labelEmail,
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _regulatoryContactPhoneController,
                label: GlnPharmaceuticalExtensionUiConstants.labelPhone,
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF121F17)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121F17),
              ),
            ),
          ],
        ),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: maxLength != null
          ? [LengthLimitingTextInputFormatter(maxLength)]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime?)? onChanged,
  }) {
    return InkWell(
      onTap: onChanged != null
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                onChanged(date);
              }
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: onChanged == null,
          fillColor: onChanged == null ? Colors.grey.shade100 : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
                  : GlnExtensionSharedUiConstants.dateNotSet,
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey,
              ),
            ),
            if (onChanged != null)
              const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
