import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/services/gln_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/models/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Widget that displays/edits pharmaceutical extension data for a GLN (location)
/// Can be embedded in GLN detail screens or used standalone
class GLNPharmaceuticalExtensionWidget extends StatefulWidget {
  final int? glnId;
  final String? glnCode;
  final bool isEditing;
  final Function(GLNPharmaceuticalExtension?)? onSaved;

  const GLNPharmaceuticalExtensionWidget({
    Key? key,
    this.glnId,
    this.glnCode,
    this.isEditing = false,
    this.onSaved,
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

  @override
  void initState() {
    super.initState();
    _loadExtension();
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
    super.dispose();
  }

  Future<void> _loadExtension() async {
    // Skip loading if no valid GLN code or ID is provided (e.g., when creating a new GLN)
    final hasValidGlnCode = widget.glnCode != null && widget.glnCode!.isNotEmpty;
    final hasValidGlnId = widget.glnId != null;
    
    if (!hasValidGlnCode && !hasValidGlnId) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final service = getIt<GLNPharmaceuticalExtensionService>();

      GLNPharmaceuticalExtension? ext;
      if (hasValidGlnCode) {
        ext = await service.getByGlnCode(widget.glnCode!);
      } else if (widget.glnId != null) {
        ext = await service.getByGlnId(widget.glnId!);
      }

      if (!mounted) return;

      if (ext != null) {
        _populateFormFromExtension(ext);
        setState(() {
          _extension = ext;
          _hasExtension = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading GLN pharmaceutical extension: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    );
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
      _authorisedPrincipalMahGlnsController.text.isNotEmpty;

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
    );
  }

  /// Validate the extension form
  String? validate() {
    // All fields are optional
    return null;
  }

  Future<bool> save() async {
    if (widget.glnCode == null && widget.glnId == null) {
      return false;
    }

    try {
      final service = getIt<GLNPharmaceuticalExtensionService>();
      final extension = _buildExtensionFromForm();

      GLNPharmaceuticalExtension? result;
      if (_hasExtension && _extension?.id != null) {
        result = await service.update(_extension!.id!, extension);
      } else {
        result = await service.create(extension);
      }

      if (result != null) {
        setState(() {
          _extension = result;
          _hasExtension = true;
        });
        widget.onSaved?.call(result);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving GLN pharmaceutical extension: $e');
      return false;
    }
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
              'Pharmaceutical extension',
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
                  'Saved',
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
        const SectionLabel('UAE registry & national IDs'),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _brandsyncPartyIdController,
                label: 'BrandSync Party ID',
                enabled: widget.isEditing,
                maxLength: 50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _tatmeenPartyCodeController,
                label: 'Tatmeen Party Code',
                enabled: widget.isEditing,
                maxLength: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel('Licensed agent (import markets)'),
        _buildTextField(
          controller: _licensedAgentAuthorisationController,
          label: 'Licensed agent authorisation number',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _authorisedPrincipalMahGlnsController,
          label: 'Authorised principal MAH GLNs',
          hint: 'Comma-separated 13-digit GLNs',
          enabled: widget.isEditing,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        const SectionLabel('Pharmacovigilance & recall'),
        _buildTextField(
          controller: _pharmacovigilanceEmailController,
          label: 'Pharmacovigilance contact email',
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
                label: 'Recall contact email (24/7)',
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 254,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _recallContactPhoneController,
                label: 'Recall contact phone',
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel('EPCIS & data exchange'),
        _buildTextField(
          controller: _epcisCaptureEndpointUrlController,
          label: 'EPCIS capture endpoint URL',
          hint: 'https://…',
          enabled: widget.isEditing,
          keyboardType: TextInputType.url,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildFacilitySection() {
    return _buildSection(
      'Healthcare Facility Type',
      Icons.local_hospital,
      [
        DropdownButtonFormField<HealthcareFacilityType>(
          value: _healthcareFacilityType,
          decoration: const InputDecoration(
            labelText: 'Facility Type',
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
      'FDA Establishment Data',
      Icons.verified_user,
      [
        _buildTextField(
          controller: _fdaEstablishmentIdController,
          label: 'FDA Establishment ID',
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _fdaRegistrationNumberController,
          label: 'FDA Registration Number',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _fdaEstablishmentTypeController,
          label: 'FDA Establishment Type',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Registration Date',
                value: _fdaRegistrationDate,
                onChanged: widget.isEditing
                    ? (date) => setState(() => _fdaRegistrationDate = date)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'Registration Expiry',
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
      'DEA Registration',
      Icons.security,
      [
        _buildTextField(
          controller: _deaRegistrationNumberController,
          label: 'DEA Registration Number',
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: 'DEA Registration Expiry',
          value: _deaRegistrationExpiry,
          onChanged: widget.isEditing
              ? (date) => setState(() => _deaRegistrationExpiry = date)
              : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _deaScheduleAuthorizationController,
          label: 'DEA Schedule Authorization',
          enabled: widget.isEditing,
          hint: 'e.g., II, III, IV, V',
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _deaBusinessActivityController,
          label: 'DEA Business Activity',
          enabled: widget.isEditing,
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildStateLicenseSection() {
    return _buildSection(
      'State/Provincial License',
      Icons.badge,
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _stateLicenseNumberController,
                label: 'License Number',
                enabled: widget.isEditing,
                maxLength: 50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _stateLicenseState,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Select State')),
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
          label: 'License Type',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: 'License Expiry',
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
      'Wholesale Distribution',
      Icons.local_shipping,
      [
        _buildTextField(
          controller: _wholesaleLicenseNumberController,
          label: 'Wholesale License Number',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: 'Wholesale License Expiry',
          value: _wholesaleLicenseExpiry,
          onChanged: widget.isEditing
              ? (date) => setState(() => _wholesaleLicenseExpiry = date)
              : null,
        ),
        const SizedBox(height: 12),
        _buildSwitch(
          label: 'Authorized Trading Partner (ATP)',
          value: _isAuthorizedTradingPartner,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isAuthorizedTradingPartner = value)
              : null,
        ),
        if (_isAuthorizedTradingPartner) ...[
          const SizedBox(height: 12),
          _buildDateField(
            label: 'ATP Verification Date',
            value: _atpVerificationDate,
            onChanged: widget.isEditing
                ? (date) => setState(() => _atpVerificationDate = date)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: 'VAWD Accredited',
          value: _vawdAccredited,
          onChanged: widget.isEditing
              ? (value) => setState(() => _vawdAccredited = value)
              : null,
        ),
        if (_vawdAccredited) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _vawdAccreditationNumberController,
            label: 'VAWD Accreditation Number',
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'VAWD Expiry Date',
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
      'Cold Chain & Storage Capabilities',
      Icons.ac_unit,
      [
        _buildSwitch(
          label: 'Cold Chain Capability',
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
                  label: 'Min Temp (°C)',
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _coldStorageMaxTempController,
                  label: 'Max Temp (°C)',
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
          label: 'Freezer Capability',
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
                  label: 'Freezer Min (°C)',
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _freezerMaxTempController,
                  label: 'Freezer Max (°C)',
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
          label: 'Controlled Room Temperature',
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
                  label: 'CRT Min (°C)',
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _crtMaxTempController,
                  label: 'CRT Max (°C)',
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
          label: 'Humidity Control',
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
                  label: 'Min Humidity (%)',
                  enabled: widget.isEditing,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _humidityRangeMaxController,
                  label: 'Max Humidity (%)',
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
          label: 'GDP Certified',
          value: _gdpCertified,
          onChanged: widget.isEditing
              ? (value) => setState(() => _gdpCertified = value)
              : null,
        ),
        if (_gdpCertified) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _gdpCertificationNumberController,
            label: 'GDP Certification Number',
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'GDP Certification Expiry',
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
      'Clinical Trial Site',
      Icons.science,
      [
        _buildSwitch(
          label: 'Clinical Trial Site',
          value: _isClinicalTrialSite,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isClinicalTrialSite = value)
              : null,
        ),
        if (_isClinicalTrialSite) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _clinicalTrialPhaseAuthorizedController,
            label: 'Clinical Trial Phase Authorized',
            enabled: widget.isEditing,
            hint: 'e.g., Phase I, II, III, IV',
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _irbApprovalNumberController,
            label: 'IRB Approval Number',
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'IRB Approval Expiry',
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
      'DSCSA Compliance',
      Icons.verified,
      [
        _buildSwitch(
          label: 'DSCSA Compliant',
          value: _isDscsaCompliant,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isDscsaCompliant = value)
              : null,
        ),
        if (_isDscsaCompliant) ...[
          const SizedBox(height: 12),
          _buildDateField(
            label: 'DSCSA Compliance Date',
            value: _dscsaComplianceDate,
            onChanged: widget.isEditing
                ? (date) => setState(() => _dscsaComplianceDate = date)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: 'Serialization Capability',
          value: _hasSerializationCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasSerializationCapability = value)
              : null,
        ),
        const SizedBox(height: 12),
        _buildSwitch(
          label: 'Aggregation Capability',
          value: _hasAggregationCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasAggregationCapability = value)
              : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _interoperabilitySystemController,
          label: 'Interoperability System',
          enabled: widget.isEditing,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildHealthcareIdsSection() {
    return _buildSection(
      'Healthcare Identifiers',
      Icons.numbers,
      [
        _buildTextField(
          controller: _npiNumberController,
          label: 'NPI Number',
          enabled: widget.isEditing,
          maxLength: 15,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _ncpdpIdController,
          label: 'NCPDP ID',
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _medicareProviderNumberController,
          label: 'Medicare Provider Number',
          enabled: widget.isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _medicaidProviderNumberController,
          label: 'Medicaid Provider Number',
          enabled: widget.isEditing,
          maxLength: 20,
        ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return _buildSection(
      'Certifications & Accreditations',
      Icons.workspace_premium,
      [
        _buildSwitch(
          label: 'ISO Certified',
          value: _isIsoCertified,
          onChanged: widget.isEditing
              ? (value) => setState(() => _isIsoCertified = value)
              : null,
        ),
        if (_isIsoCertified) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _isoCertificationTypeController,
            label: 'ISO Certification Type',
            enabled: widget.isEditing,
            hint: 'e.g., ISO 9001, ISO 13485',
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _isoCertificationNumberController,
            label: 'ISO Certification Number',
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'ISO Certification Expiry',
            value: _isoCertificationExpiry,
            onChanged: widget.isEditing
                ? (date) => setState(() => _isoCertificationExpiry = date)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        _buildSwitch(
          label: 'JCAHO Accredited',
          value: _jcahoAccredited,
          onChanged: widget.isEditing
              ? (value) => setState(() => _jcahoAccredited = value)
              : null,
        ),
        if (_jcahoAccredited) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _jcahoAccreditationNumberController,
            label: 'JCAHO Accreditation Number',
            enabled: widget.isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'JCAHO Accreditation Expiry',
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
      'International Regulatory IDs',
      Icons.public,
      [
        _buildTextField(
          controller: _emaSiteIdController,
          label: 'EMA Site ID (Europe)',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _pmdaSiteIdController,
          label: 'PMDA Site ID (Japan)',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _anvisaSiteIdController,
          label: 'ANVISA Site ID (Brazil)',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nmpaSiteIdController,
          label: 'NMPA Site ID (China)',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
      ],
    );
  }

  Widget _buildOperationalSection() {
    return _buildSection(
      'Operational Details',
      Icons.access_time,
      [
        _buildTextField(
          controller: _receivingHoursController,
          label: 'Receiving Hours',
          enabled: widget.isEditing,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _dispatchHoursController,
          label: 'Dispatch Hours',
          enabled: widget.isEditing,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        _buildSwitch(
          label: 'Has Weighbridge',
          value: _hasWeighbridge,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasWeighbridge = value)
              : null,
        ),
        _buildSwitch(
          label: 'Has Loading Dock',
          value: _hasLoadingDock,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasLoadingDock = value)
              : null,
        ),
        _buildSwitch(
          label: 'Has Forklift Capability',
          value: _hasForkliftCapability,
          onChanged: widget.isEditing
              ? (value) => setState(() => _hasForkliftCapability = value)
              : null,
        ),
        _buildSwitch(
          label: 'Can Receive Hazmat',
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
      'Contact Information',
      Icons.contact_phone,
      [
        const Text(
          'Pharmacist in Charge',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _pharmacistInChargeController,
          label: 'Name',
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _picLicenseNumberController,
          label: 'License Number',
          enabled: widget.isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        const Text(
          'Responsible Person',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _responsiblePersonNameController,
          label: 'Name',
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _responsiblePersonEmailController,
                label: 'Email',
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _responsiblePersonPhoneController,
                label: 'Phone',
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Quality Contact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _qualityContactNameController,
          label: 'Name',
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _qualityContactEmailController,
                label: 'Email',
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _qualityContactPhoneController,
                label: 'Phone',
                enabled: widget.isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Regulatory Contact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _regulatoryContactNameController,
          label: 'Name',
          enabled: widget.isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _regulatoryContactEmailController,
                label: 'Email',
                enabled: widget.isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _regulatoryContactPhoneController,
                label: 'Phone',
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
                  : 'Not set',
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
