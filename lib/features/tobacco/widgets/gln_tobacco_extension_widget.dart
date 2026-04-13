import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/gln_tobacco_extension_service.dart';
import '../models/gln_tobacco_extension_model.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import '../../../core/cubit/system_settings_cubit.dart';

/// Widget that displays/edits tobacco extension data for a GLN (location)
/// Can be embedded in GLN detail screens or used standalone
class GLNTobaccoExtensionWidget extends StatefulWidget {
  final int? glnId;
  final String? glnCode;
  final bool isEditing;
  final Function(GLNTobaccoExtension?)? onSaved;

  const GLNTobaccoExtensionWidget({
    Key? key,
    this.glnId,
    this.glnCode,
    this.isEditing = false,
    this.onSaved,
  }) : super(key: key);

  @override
  State<GLNTobaccoExtensionWidget> createState() =>
      GLNTobaccoExtensionWidgetState();
}

/// State class for GLNTobaccoExtensionWidget
class GLNTobaccoExtensionWidgetState extends State<GLNTobaccoExtensionWidget> {
  GLNTobaccoExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  // US State options (for state_tobacco_license_state - max 3 chars)
  static const Map<String, String> _usStateOptions = {
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
    'WI': 'Wisconsin', 'WY': 'Wyoming', 'DC': 'Washington DC',
    'PR': 'Puerto Rico', 'VI': 'Virgin Islands', 'GU': 'Guam',
  };

  // Country options (ISO 3166-1 alpha-3) for WHO FCTC Party Country
  static const Map<String, String> _countryOptions = {
    'USA': 'United States', 'GBR': 'United Kingdom', 'DEU': 'Germany',
    'FRA': 'France', 'ITA': 'Italy', 'ESP': 'Spain', 'CAN': 'Canada',
    'AUS': 'Australia', 'JPN': 'Japan', 'CHN': 'China', 'IND': 'India',
    'BRA': 'Brazil', 'MEX': 'Mexico', 'RUS': 'Russia', 'ZAF': 'South Africa',
    'KOR': 'South Korea', 'IDN': 'Indonesia', 'TUR': 'Turkey', 'SAU': 'Saudi Arabia',
    'ARE': 'United Arab Emirates', 'EGY': 'Egypt', 'NGA': 'Nigeria',
    'ARG': 'Argentina', 'COL': 'Colombia', 'CHL': 'Chile', 'PER': 'Peru',
    'VEN': 'Venezuela', 'PHL': 'Philippines', 'VNM': 'Vietnam', 'THA': 'Thailand',
    'MYS': 'Malaysia', 'SGP': 'Singapore', 'PAK': 'Pakistan', 'BGD': 'Bangladesh',
    'NLD': 'Netherlands', 'BEL': 'Belgium', 'SWE': 'Sweden', 'NOR': 'Norway',
    'DNK': 'Denmark', 'FIN': 'Finland', 'CHE': 'Switzerland', 'AUT': 'Austria',
    'POL': 'Poland', 'CZE': 'Czech Republic', 'PRT': 'Portugal', 'GRC': 'Greece',
    'IRL': 'Ireland', 'NZL': 'New Zealand', 'HKG': 'Hong Kong', 'TWN': 'Taiwan',
  };

  // State variables for dropdowns (replacing text controllers)
  String? _stateTobaccoLicenseState;
  String? _whoFctcPartyCountry;

  // EU TPD Section
  final _euEconomicOperatorIdController = TextEditingController();
  final _euFacilityIdController = TextEditingController();
  bool _euTpdRegistered = false;
  DateTime? _euTpdRegistrationDate;
  bool _euFirstRetailOutlet = false;
  final _euImporterIdController = TextEditingController();

  // Tax Stamp Authority
  final _taxStampAuthorityIdController = TextEditingController();
  final _taxStampAuthorityNameController = TextEditingController();
  DateTime? _taxStampAuthorizationDate;
  DateTime? _taxStampAuthorizationExpiry;
  final _authorizedTaxStampTypesController = TextEditingController();

  // FDA Tobacco Registration
  final _fdaTobaccoEstablishmentIdController = TextEditingController();
  DateTime? _fdaTobaccoRegistrationDate;
  DateTime? _fdaTobaccoRegistrationExpiry;
  final _fdaPmtaSiteListingController = TextEditingController();
  final _fdaSeSiteListingController = TextEditingController();

  // PACT Act Compliance
  bool _pactActRegistered = false;
  final _pactActRegistrationNumberController = TextEditingController();
  DateTime? _pactActRegistrationDate;
  final _pactAtfLicenseNumberController = TextEditingController();

  // State Tobacco License
  final _stateTobaccoLicenseNumberController = TextEditingController();
  final _stateTobaccoLicenseTypeController = TextEditingController();
  DateTime? _stateTobaccoLicenseExpiry;
  // _stateTobaccoLicenseState is now a dropdown state variable (defined above)

  // Wholesale/Distribution
  final _tobaccoWholesaleLicenseNumberController = TextEditingController();
  DateTime? _tobaccoWholesaleLicenseExpiry;
  bool _masterSettlementAgreementParticipant = false;
  final _msaEscrowAccountStatusController = TextEditingController();

  // Manufacturing
  bool _isManufacturingFacility = false;
  final _manufacturingLicenseNumberController = TextEditingController();
  DateTime? _manufacturingLicenseExpiry;
  final _manufacturingCapacityController = TextEditingController();
  final _tobaccoTypesManufacturedController = TextEditingController();

  // UI Issuer
  bool _isUiIssuer = false;
  final _uiIssuerRegistrationIdController = TextEditingController();
  final _uiSystemProviderController = TextEditingController();
  final _antiTamperingDeviceProviderController = TextEditingController();

  // Import/Export
  final _customsRegistrationNumberController = TextEditingController();
  bool _authorizedEconomicOperator = false;
  final _aeoCertificateNumberController = TextEditingController();
  DateTime? _aeoCertificateExpiry;
  bool _bondedWarehouse = false;
  final _bondedWarehouseLicenseNumberController = TextEditingController();

  // Security & Compliance
  bool _hasSecurityFeatures = false;
  bool _videoSurveillance = false;
  bool _accessControlSystem = false;
  final _inventoryTrackingSystemController = TextEditingController();

  // Retailer-Specific
  bool _isRetailLocation = false;
  final _ageVerificationSystemController = TextEditingController();
  final _tobaccoSalesPermitNumberController = TextEditingController();
  DateTime? _tobaccoSalesPermitExpiry;

  // Operational Details
  final _receivingHoursController = TextEditingController();
  final _dispatchHoursController = TextEditingController();
  final _storageCapacityPalletsController = TextEditingController();
  bool _hasClimateControl = false;
  final _climateControlTempMinController = TextEditingController();
  final _climateControlTempMaxController = TextEditingController();
  final _climateControlHumidityMinController = TextEditingController();
  final _climateControlHumidityMaxController = TextEditingController();

  // Responsible Persons
  final _responsiblePersonNameController = TextEditingController();
  final _responsiblePersonEmailController = TextEditingController();
  final _responsiblePersonPhoneController = TextEditingController();
  final _qualityManagerNameController = TextEditingController();
  final _qualityManagerEmailController = TextEditingController();
  final _qualityManagerPhoneController = TextEditingController();
  final _regulatoryAffairsContactNameController = TextEditingController();
  final _regulatoryAffairsContactEmailController = TextEditingController();
  final _regulatoryAffairsContactPhoneController = TextEditingController();

  // International
  // _whoFctcPartyCountry is now a dropdown state variable (defined above)
  final _ukTobaccoTraceabilityIdController = TextEditingController();
  final _canadaTobaccoLicenseIdController = TextEditingController();
  final _australiaTobaccoLicenseIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExtension();
  }

  @override
  void dispose() {
    _euEconomicOperatorIdController.dispose();
    _euFacilityIdController.dispose();
    _euImporterIdController.dispose();
    _taxStampAuthorityIdController.dispose();
    _taxStampAuthorityNameController.dispose();
    _authorizedTaxStampTypesController.dispose();
    _fdaTobaccoEstablishmentIdController.dispose();
    _fdaPmtaSiteListingController.dispose();
    _fdaSeSiteListingController.dispose();
    _pactActRegistrationNumberController.dispose();
    _pactAtfLicenseNumberController.dispose();
    _stateTobaccoLicenseNumberController.dispose();
    _stateTobaccoLicenseTypeController.dispose();
    _tobaccoWholesaleLicenseNumberController.dispose();
    _msaEscrowAccountStatusController.dispose();
    _manufacturingLicenseNumberController.dispose();
    _manufacturingCapacityController.dispose();
    _tobaccoTypesManufacturedController.dispose();
    _uiIssuerRegistrationIdController.dispose();
    _uiSystemProviderController.dispose();
    _antiTamperingDeviceProviderController.dispose();
    _customsRegistrationNumberController.dispose();
    _aeoCertificateNumberController.dispose();
    _bondedWarehouseLicenseNumberController.dispose();
    _inventoryTrackingSystemController.dispose();
    _ageVerificationSystemController.dispose();
    _tobaccoSalesPermitNumberController.dispose();
    _receivingHoursController.dispose();
    _dispatchHoursController.dispose();
    _storageCapacityPalletsController.dispose();
    _climateControlTempMinController.dispose();
    _climateControlTempMaxController.dispose();
    _climateControlHumidityMinController.dispose();
    _climateControlHumidityMaxController.dispose();
    _responsiblePersonNameController.dispose();
    _responsiblePersonEmailController.dispose();
    _responsiblePersonPhoneController.dispose();
    _qualityManagerNameController.dispose();
    _qualityManagerEmailController.dispose();
    _qualityManagerPhoneController.dispose();
    _regulatoryAffairsContactNameController.dispose();
    _regulatoryAffairsContactEmailController.dispose();
    _regulatoryAffairsContactPhoneController.dispose();
    _ukTobaccoTraceabilityIdController.dispose();
    _canadaTobaccoLicenseIdController.dispose();
    _australiaTobaccoLicenseIdController.dispose();
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
      final service = getIt<GLNTobaccoExtensionService>();

      GLNTobaccoExtension? ext;
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
      debugPrint('Error loading GLN tobacco extension: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFormFromExtension(GLNTobaccoExtension ext) {
    _euEconomicOperatorIdController.text = ext.euEconomicOperatorId ?? '';
    _euFacilityIdController.text = ext.euFacilityId ?? '';
    _euTpdRegistered = ext.euTpdRegistered;
    _euTpdRegistrationDate = ext.euTpdRegistrationDate;
    _euFirstRetailOutlet = ext.euFirstRetailOutlet;
    _euImporterIdController.text = ext.euImporterId ?? '';
    _taxStampAuthorityIdController.text = ext.taxStampAuthorityId ?? '';
    _taxStampAuthorityNameController.text = ext.taxStampAuthorityName ?? '';
    _taxStampAuthorizationDate = ext.taxStampAuthorizationDate;
    _taxStampAuthorizationExpiry = ext.taxStampAuthorizationExpiry;
    _authorizedTaxStampTypesController.text = ext.authorizedTaxStampTypes ?? '';
    _fdaTobaccoEstablishmentIdController.text = ext.fdaTobaccoEstablishmentId ?? '';
    _fdaTobaccoRegistrationDate = ext.fdaTobaccoRegistrationDate;
    _fdaTobaccoRegistrationExpiry = ext.fdaTobaccoRegistrationExpiry;
    _fdaPmtaSiteListingController.text = ext.fdaPmtaSiteListing ?? '';
    _fdaSeSiteListingController.text = ext.fdaSeSiteListing ?? '';
    _pactActRegistered = ext.pactActRegistered;
    _pactActRegistrationNumberController.text = ext.pactActRegistrationNumber ?? '';
    _pactActRegistrationDate = ext.pactActRegistrationDate;
    _pactAtfLicenseNumberController.text = ext.pactAtfLicenseNumber ?? '';
    _stateTobaccoLicenseNumberController.text = ext.stateTobaccoLicenseNumber ?? '';
    _stateTobaccoLicenseTypeController.text = ext.stateTobaccoLicenseType ?? '';
    _stateTobaccoLicenseExpiry = ext.stateTobaccoLicenseExpiry;
    _stateTobaccoLicenseState = ext.stateTobaccoLicenseState;
    _tobaccoWholesaleLicenseNumberController.text = ext.tobaccoWholesaleLicenseNumber ?? '';
    _tobaccoWholesaleLicenseExpiry = ext.tobaccoWholesaleLicenseExpiry;
    _masterSettlementAgreementParticipant = ext.masterSettlementAgreementParticipant;
    _msaEscrowAccountStatusController.text = ext.msaEscrowAccountStatus ?? '';
    _isManufacturingFacility = ext.isManufacturingFacility;
    _manufacturingLicenseNumberController.text = ext.manufacturingLicenseNumber ?? '';
    _manufacturingLicenseExpiry = ext.manufacturingLicenseExpiry;
    _manufacturingCapacityController.text = ext.manufacturingCapacityUnitsPerDay?.toString() ?? '';
    _tobaccoTypesManufacturedController.text = ext.tobaccoTypesManufactured ?? '';
    _isUiIssuer = ext.isUiIssuer;
    _uiIssuerRegistrationIdController.text = ext.uiIssuerRegistrationId ?? '';
    _uiSystemProviderController.text = ext.uiSystemProvider ?? '';
    _antiTamperingDeviceProviderController.text = ext.antiTamperingDeviceProvider ?? '';
    _customsRegistrationNumberController.text = ext.customsRegistrationNumber ?? '';
    _authorizedEconomicOperator = ext.authorizedEconomicOperator;
    _aeoCertificateNumberController.text = ext.aeoCertificateNumber ?? '';
    _aeoCertificateExpiry = ext.aeoCertificateExpiry;
    _bondedWarehouse = ext.bondedWarehouse;
    _bondedWarehouseLicenseNumberController.text = ext.bondedWarehouseLicenseNumber ?? '';
    _hasSecurityFeatures = ext.hasSecurityFeatures;
    _videoSurveillance = ext.videoSurveillance;
    _accessControlSystem = ext.accessControlSystem;
    _inventoryTrackingSystemController.text = ext.inventoryTrackingSystem ?? '';
    _isRetailLocation = ext.isRetailLocation;
    _ageVerificationSystemController.text = ext.ageVerificationSystem ?? '';
    _tobaccoSalesPermitNumberController.text = ext.tobaccoSalesPermitNumber ?? '';
    _tobaccoSalesPermitExpiry = ext.tobaccoSalesPermitExpiry;
    _receivingHoursController.text = ext.receivingHours ?? '';
    _dispatchHoursController.text = ext.dispatchHours ?? '';
    _storageCapacityPalletsController.text = ext.storageCapacityPallets?.toString() ?? '';
    _hasClimateControl = ext.hasClimateControl;
    _climateControlTempMinController.text = ext.climateControlTempMin?.toString() ?? '';
    _climateControlTempMaxController.text = ext.climateControlTempMax?.toString() ?? '';
    _climateControlHumidityMinController.text = ext.climateControlHumidityMin?.toString() ?? '';
    _climateControlHumidityMaxController.text = ext.climateControlHumidityMax?.toString() ?? '';
    _responsiblePersonNameController.text = ext.responsiblePersonName ?? '';
    _responsiblePersonEmailController.text = ext.responsiblePersonEmail ?? '';
    _responsiblePersonPhoneController.text = ext.responsiblePersonPhone ?? '';
    _qualityManagerNameController.text = ext.qualityManagerName ?? '';
    _qualityManagerEmailController.text = ext.qualityManagerEmail ?? '';
    _qualityManagerPhoneController.text = ext.qualityManagerPhone ?? '';
    _regulatoryAffairsContactNameController.text = ext.regulatoryAffairsContactName ?? '';
    _regulatoryAffairsContactEmailController.text = ext.regulatoryAffairsContactEmail ?? '';
    _regulatoryAffairsContactPhoneController.text = ext.regulatoryAffairsContactPhone ?? '';
    _whoFctcPartyCountry = ext.whoFctcPartyCountry;
    _ukTobaccoTraceabilityIdController.text = ext.ukTobaccoTraceabilityId ?? '';
    _canadaTobaccoLicenseIdController.text = ext.canadaTobaccoLicenseId ?? '';
    _australiaTobaccoLicenseIdController.text = ext.australiaTobaccoLicenseId ?? '';
  }

  /// Check if user has entered any tobacco data
  bool get hasData =>
      _euEconomicOperatorIdController.text.isNotEmpty ||
      _euTpdRegistered ||
      _fdaTobaccoEstablishmentIdController.text.isNotEmpty ||
      _pactActRegistered ||
      _stateTobaccoLicenseNumberController.text.isNotEmpty ||
      _isManufacturingFacility ||
      _isUiIssuer;

  /// Validate the extension form
  String? validate() {
    // All fields are optional
    return null;
  }

  /// Build the extension object from form data
  GLNTobaccoExtension? buildExtension({int? glnId, String? glnCode}) {
    if (!hasData) return null;

    return GLNTobaccoExtension(
      id: _extension?.id,
      glnId: glnId ?? widget.glnId ?? 0,
      glnCode: glnCode ?? widget.glnCode,
      euEconomicOperatorId: _euEconomicOperatorIdController.text.isEmpty
          ? null
          : _euEconomicOperatorIdController.text,
      euFacilityId: _euFacilityIdController.text.isEmpty
          ? null
          : _euFacilityIdController.text,
      euTpdRegistered: _euTpdRegistered,
      euTpdRegistrationDate: _euTpdRegistrationDate,
      euFirstRetailOutlet: _euFirstRetailOutlet,
      euImporterId: _euImporterIdController.text.isEmpty
          ? null
          : _euImporterIdController.text,
      taxStampAuthorityId: _taxStampAuthorityIdController.text.isEmpty
          ? null
          : _taxStampAuthorityIdController.text,
      taxStampAuthorityName: _taxStampAuthorityNameController.text.isEmpty
          ? null
          : _taxStampAuthorityNameController.text,
      taxStampAuthorizationDate: _taxStampAuthorizationDate,
      taxStampAuthorizationExpiry: _taxStampAuthorizationExpiry,
      authorizedTaxStampTypes: _authorizedTaxStampTypesController.text.isEmpty
          ? null
          : _authorizedTaxStampTypesController.text,
      fdaTobaccoEstablishmentId: _fdaTobaccoEstablishmentIdController.text.isEmpty
          ? null
          : _fdaTobaccoEstablishmentIdController.text,
      fdaTobaccoRegistrationDate: _fdaTobaccoRegistrationDate,
      fdaTobaccoRegistrationExpiry: _fdaTobaccoRegistrationExpiry,
      fdaPmtaSiteListing: _fdaPmtaSiteListingController.text.isEmpty
          ? null
          : _fdaPmtaSiteListingController.text,
      fdaSeSiteListing: _fdaSeSiteListingController.text.isEmpty
          ? null
          : _fdaSeSiteListingController.text,
      pactActRegistered: _pactActRegistered,
      pactActRegistrationNumber: _pactActRegistrationNumberController.text.isEmpty
          ? null
          : _pactActRegistrationNumberController.text,
      pactActRegistrationDate: _pactActRegistrationDate,
      pactAtfLicenseNumber: _pactAtfLicenseNumberController.text.isEmpty
          ? null
          : _pactAtfLicenseNumberController.text,
      stateTobaccoLicenseNumber: _stateTobaccoLicenseNumberController.text.isEmpty
          ? null
          : _stateTobaccoLicenseNumberController.text,
      stateTobaccoLicenseType: _stateTobaccoLicenseTypeController.text.isEmpty
          ? null
          : _stateTobaccoLicenseTypeController.text,
      stateTobaccoLicenseExpiry: _stateTobaccoLicenseExpiry,
      stateTobaccoLicenseState: _stateTobaccoLicenseState,
      tobaccoWholesaleLicenseNumber: _tobaccoWholesaleLicenseNumberController.text.isEmpty
          ? null
          : _tobaccoWholesaleLicenseNumberController.text,
      tobaccoWholesaleLicenseExpiry: _tobaccoWholesaleLicenseExpiry,
      masterSettlementAgreementParticipant: _masterSettlementAgreementParticipant,
      msaEscrowAccountStatus: _msaEscrowAccountStatusController.text.isEmpty
          ? null
          : _msaEscrowAccountStatusController.text,
      isManufacturingFacility: _isManufacturingFacility,
      manufacturingLicenseNumber: _manufacturingLicenseNumberController.text.isEmpty
          ? null
          : _manufacturingLicenseNumberController.text,
      manufacturingLicenseExpiry: _manufacturingLicenseExpiry,
      manufacturingCapacityUnitsPerDay: int.tryParse(_manufacturingCapacityController.text),
      tobaccoTypesManufactured: _tobaccoTypesManufacturedController.text.isEmpty
          ? null
          : _tobaccoTypesManufacturedController.text,
      isUiIssuer: _isUiIssuer,
      uiIssuerRegistrationId: _uiIssuerRegistrationIdController.text.isEmpty
          ? null
          : _uiIssuerRegistrationIdController.text,
      uiSystemProvider: _uiSystemProviderController.text.isEmpty
          ? null
          : _uiSystemProviderController.text,
      antiTamperingDeviceProvider: _antiTamperingDeviceProviderController.text.isEmpty
          ? null
          : _antiTamperingDeviceProviderController.text,
      customsRegistrationNumber: _customsRegistrationNumberController.text.isEmpty
          ? null
          : _customsRegistrationNumberController.text,
      authorizedEconomicOperator: _authorizedEconomicOperator,
      aeoCertificateNumber: _aeoCertificateNumberController.text.isEmpty
          ? null
          : _aeoCertificateNumberController.text,
      aeoCertificateExpiry: _aeoCertificateExpiry,
      bondedWarehouse: _bondedWarehouse,
      bondedWarehouseLicenseNumber: _bondedWarehouseLicenseNumberController.text.isEmpty
          ? null
          : _bondedWarehouseLicenseNumberController.text,
      hasSecurityFeatures: _hasSecurityFeatures,
      videoSurveillance: _videoSurveillance,
      accessControlSystem: _accessControlSystem,
      inventoryTrackingSystem: _inventoryTrackingSystemController.text.isEmpty
          ? null
          : _inventoryTrackingSystemController.text,
      isRetailLocation: _isRetailLocation,
      ageVerificationSystem: _ageVerificationSystemController.text.isEmpty
          ? null
          : _ageVerificationSystemController.text,
      tobaccoSalesPermitNumber: _tobaccoSalesPermitNumberController.text.isEmpty
          ? null
          : _tobaccoSalesPermitNumberController.text,
      tobaccoSalesPermitExpiry: _tobaccoSalesPermitExpiry,
      receivingHours: _receivingHoursController.text.isEmpty
          ? null
          : _receivingHoursController.text,
      dispatchHours: _dispatchHoursController.text.isEmpty
          ? null
          : _dispatchHoursController.text,
      storageCapacityPallets: int.tryParse(_storageCapacityPalletsController.text),
      hasClimateControl: _hasClimateControl,
      climateControlTempMin: double.tryParse(_climateControlTempMinController.text),
      climateControlTempMax: double.tryParse(_climateControlTempMaxController.text),
      climateControlHumidityMin: double.tryParse(_climateControlHumidityMinController.text),
      climateControlHumidityMax: double.tryParse(_climateControlHumidityMaxController.text),
      responsiblePersonName: _responsiblePersonNameController.text.isEmpty
          ? null
          : _responsiblePersonNameController.text,
      responsiblePersonEmail: _responsiblePersonEmailController.text.isEmpty
          ? null
          : _responsiblePersonEmailController.text,
      responsiblePersonPhone: _responsiblePersonPhoneController.text.isEmpty
          ? null
          : _responsiblePersonPhoneController.text,
      qualityManagerName: _qualityManagerNameController.text.isEmpty
          ? null
          : _qualityManagerNameController.text,
      qualityManagerEmail: _qualityManagerEmailController.text.isEmpty
          ? null
          : _qualityManagerEmailController.text,
      qualityManagerPhone: _qualityManagerPhoneController.text.isEmpty
          ? null
          : _qualityManagerPhoneController.text,
      regulatoryAffairsContactName: _regulatoryAffairsContactNameController.text.isEmpty
          ? null
          : _regulatoryAffairsContactNameController.text,
      regulatoryAffairsContactEmail: _regulatoryAffairsContactEmailController.text.isEmpty
          ? null
          : _regulatoryAffairsContactEmailController.text,
      regulatoryAffairsContactPhone: _regulatoryAffairsContactPhoneController.text.isEmpty
          ? null
          : _regulatoryAffairsContactPhoneController.text,
      whoFctcPartyCountry: _whoFctcPartyCountry,
      ukTobaccoTraceabilityId: _ukTobaccoTraceabilityIdController.text.isEmpty
          ? null
          : _ukTobaccoTraceabilityIdController.text,
      canadaTobaccoLicenseId: _canadaTobaccoLicenseIdController.text.isEmpty
          ? null
          : _canadaTobaccoLicenseIdController.text,
      australiaTobaccoLicenseId: _australiaTobaccoLicenseIdController.text.isEmpty
          ? null
          : _australiaTobaccoLicenseIdController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show if in tobacco mode
    // Use listen: false to avoid rebuilding when provider changes and to prevent
    // "Looking up a deactivated widget's ancestor" errors during navigation
    // Wrap in try-catch to handle case when widget is deactivated during mode change
    bool isTobaccoMode = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      isTobaccoMode = settings.isTobaccoMode;
    } catch (e) {
      // Widget is deactivated, return empty
      return const SizedBox.shrink();
    }
    
    if (!isTobaccoMode) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.brown.shade700,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        leading: Icon(
          Icons.smoking_rooms,
          color: _hasExtension ? Colors.brown : Colors.grey,
        ),
        title: Text(
          'Tobacco Location Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _hasExtension ? Colors.brown : null,
          ),
        ),
        initiallyExpanded: _hasExtension,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EU TPD Section
                _buildSectionHeader('EU Tobacco Products Directive (TPD)'),
                SwitchListTile(
                  title: const Text('EU TPD Registered'),
                  value: _euTpdRegistered,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _euTpdRegistered = value)
                      : null,
                ),
                _buildTextField(_euEconomicOperatorIdController, 'EU Economic Operator ID',
                    helperText: 'EU-TPD Economic Operator Identifier', maxLength: 50),
                _buildTextField(_euFacilityIdController, 'EU Facility ID', maxLength: 50),
                _buildDateField('TPD Registration Date', _euTpdRegistrationDate, (date) {
                  setState(() => _euTpdRegistrationDate = date);
                }),
                SwitchListTile(
                  title: const Text('First Retail Outlet'),
                  subtitle: const Text('Is this the first retail point of sale?'),
                  value: _euFirstRetailOutlet,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _euFirstRetailOutlet = value)
                      : null,
                ),
                _buildTextField(_euImporterIdController, 'EU Importer ID', maxLength: 50),
                const SizedBox(height: 16),

                // Tax Stamp Authority Section
                _buildSectionHeader('Tax Stamp Authority'),
                _buildTextField(_taxStampAuthorityIdController, 'Tax Stamp Authority ID', maxLength: 50),
                _buildTextField(_taxStampAuthorityNameController, 'Tax Stamp Authority Name', maxLength: 200),
                _buildDateField('Authorization Date', _taxStampAuthorizationDate, (date) {
                  setState(() => _taxStampAuthorizationDate = date);
                }),
                _buildDateField('Authorization Expiry', _taxStampAuthorizationExpiry, (date) {
                  setState(() => _taxStampAuthorizationExpiry = date);
                }),
                _buildTextField(_authorizedTaxStampTypesController, 'Authorized Tax Stamp Types',
                    helperText: 'Comma-separated list', maxLength: 500),
                const SizedBox(height: 16),

                // FDA Tobacco Section
                _buildSectionHeader('FDA Tobacco Registration (US)'),
                _buildTextField(_fdaTobaccoEstablishmentIdController, 'FDA Tobacco Establishment ID', maxLength: 50),
                _buildDateField('Registration Date', _fdaTobaccoRegistrationDate, (date) {
                  setState(() => _fdaTobaccoRegistrationDate = date);
                }),
                _buildDateField('Registration Expiry', _fdaTobaccoRegistrationExpiry, (date) {
                  setState(() => _fdaTobaccoRegistrationExpiry = date);
                }),
                _buildTextField(_fdaPmtaSiteListingController, 'PMTA Site Listing', maxLength: 200),
                _buildTextField(_fdaSeSiteListingController, 'SE Site Listing', maxLength: 200),
                const SizedBox(height: 16),

                // PACT Act Section
                _buildSectionHeader('PACT Act Compliance (US)'),
                SwitchListTile(
                  title: const Text('PACT Act Registered'),
                  subtitle: const Text('Prevent All Cigarette Trafficking Act'),
                  value: _pactActRegistered,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _pactActRegistered = value)
                      : null,
                ),
                if (_pactActRegistered) ...[
                  _buildTextField(_pactActRegistrationNumberController, 'PACT Act Registration Number', maxLength: 50),
                  _buildDateField('Registration Date', _pactActRegistrationDate, (date) {
                    setState(() => _pactActRegistrationDate = date);
                  }),
                  _buildTextField(_pactAtfLicenseNumberController, 'ATF License Number', maxLength: 50),
                ],
                const SizedBox(height: 16),

                // State License Section
                _buildSectionHeader('State Tobacco License'),
                _buildTextField(_stateTobaccoLicenseNumberController, 'State License Number', maxLength: 50),
                _buildTextField(_stateTobaccoLicenseTypeController, 'License Type', maxLength: 50),
                DropdownButtonFormField<String>(
                  value: _stateTobaccoLicenseState,
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
                  onChanged: widget.isEditing ? (value) => setState(() => _stateTobaccoLicenseState = value) : null,
                ),
                const SizedBox(height: 16),
                _buildDateField('License Expiry', _stateTobaccoLicenseExpiry, (date) {
                  setState(() => _stateTobaccoLicenseExpiry = date);
                }),
                const SizedBox(height: 16),

                // Wholesale Section
                _buildSectionHeader('Wholesale/Distribution'),
                _buildTextField(_tobaccoWholesaleLicenseNumberController, 'Wholesale License Number', maxLength: 50),
                _buildDateField('Wholesale License Expiry', _tobaccoWholesaleLicenseExpiry, (date) {
                  setState(() => _tobaccoWholesaleLicenseExpiry = date);
                }),
                SwitchListTile(
                  title: const Text('Master Settlement Agreement Participant'),
                  value: _masterSettlementAgreementParticipant,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _masterSettlementAgreementParticipant = value)
                      : null,
                ),
                if (_masterSettlementAgreementParticipant)
                  _buildTextField(_msaEscrowAccountStatusController, 'MSA Escrow Account Status', maxLength: 50),
                const SizedBox(height: 16),

                // Manufacturing Section
                _buildSectionHeader('Manufacturing'),
                SwitchListTile(
                  title: const Text('Manufacturing Facility'),
                  value: _isManufacturingFacility,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _isManufacturingFacility = value)
                      : null,
                ),
                if (_isManufacturingFacility) ...[  
                  _buildTextField(_manufacturingLicenseNumberController, 'Manufacturing License Number', maxLength: 50),
                  _buildDateField('Manufacturing License Expiry', _manufacturingLicenseExpiry, (date) {
                    setState(() => _manufacturingLicenseExpiry = date);
                  }),
                  _buildTextField(_manufacturingCapacityController, 'Manufacturing Capacity (units/day)',
                      keyboardType: TextInputType.number, maxLength: 20),
                  _buildTextField(_tobaccoTypesManufacturedController, 'Tobacco Types Manufactured',
                      helperText: 'e.g., Cigarettes, Cigars, RYO, etc.', maxLength: 500),
                ],
                const SizedBox(height: 16),

                // UI Issuer Section
                _buildSectionHeader('Unique Identifier Issuance'),
                SwitchListTile(
                  title: const Text('UI Issuer'),
                  subtitle: const Text('Authorized to issue Unique Identifiers'),
                  value: _isUiIssuer,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _isUiIssuer = value)
                      : null,
                ),
                if (_isUiIssuer) ...[  
                  _buildTextField(_uiIssuerRegistrationIdController, 'UI Issuer Registration ID', maxLength: 50),
                  _buildTextField(_uiSystemProviderController, 'UI System Provider', maxLength: 200),
                  _buildTextField(_antiTamperingDeviceProviderController, 'Anti-Tampering Device Provider', maxLength: 200),
                ],
                const SizedBox(height: 16),

                // Import/Export Section
                _buildSectionHeader('Import/Export'),
                _buildTextField(_customsRegistrationNumberController, 'Customs Registration Number', maxLength: 50),
                SwitchListTile(
                  title: const Text('Authorized Economic Operator (AEO)'),
                  value: _authorizedEconomicOperator,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _authorizedEconomicOperator = value)
                      : null,
                ),
                if (_authorizedEconomicOperator) ...[  
                  _buildTextField(_aeoCertificateNumberController, 'AEO Certificate Number', maxLength: 50),
                  _buildDateField('AEO Certificate Expiry', _aeoCertificateExpiry, (date) {
                    setState(() => _aeoCertificateExpiry = date);
                  }),
                ],
                SwitchListTile(
                  title: const Text('Bonded Warehouse'),
                  value: _bondedWarehouse,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _bondedWarehouse = value)
                      : null,
                ),
                if (_bondedWarehouse)
                  _buildTextField(_bondedWarehouseLicenseNumberController, 'Bonded Warehouse License Number', maxLength: 50),
                const SizedBox(height: 16),

                // Security Section
                _buildSectionHeader('Security & Compliance'),
                SwitchListTile(
                  title: const Text('Has Security Features'),
                  value: _hasSecurityFeatures,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _hasSecurityFeatures = value)
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Video Surveillance'),
                  value: _videoSurveillance,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _videoSurveillance = value)
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Access Control System'),
                  value: _accessControlSystem,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _accessControlSystem = value)
                      : null,
                ),
                _buildTextField(_inventoryTrackingSystemController, 'Inventory Tracking System', maxLength: 200),
                const SizedBox(height: 16),

                // Retail Section
                _buildSectionHeader('Retail'),
                SwitchListTile(
                  title: const Text('Retail Location'),
                  value: _isRetailLocation,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _isRetailLocation = value)
                      : null,
                ),
                if (_isRetailLocation) ...[  
                  _buildTextField(_ageVerificationSystemController, 'Age Verification System', maxLength: 200),
                  _buildTextField(_tobaccoSalesPermitNumberController, 'Tobacco Sales Permit Number', maxLength: 50),
                  _buildDateField('Sales Permit Expiry', _tobaccoSalesPermitExpiry, (date) {
                    setState(() => _tobaccoSalesPermitExpiry = date);
                  }),
                ],
                const SizedBox(height: 16),

                // Operational Section
                _buildSectionHeader('Operational Details'),
                _buildTextField(_receivingHoursController, 'Receiving Hours', maxLength: 100),
                _buildTextField(_dispatchHoursController, 'Dispatch Hours', maxLength: 100),
                _buildTextField(_storageCapacityPalletsController, 'Storage Capacity (pallets)',
                    keyboardType: TextInputType.number, maxLength: 20),
                SwitchListTile(
                  title: const Text('Climate Control'),
                  value: _hasClimateControl,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _hasClimateControl = value)
                      : null,
                ),
                if (_hasClimateControl) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_climateControlTempMinController, 'Min Temp (°C)',
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_climateControlTempMaxController, 'Max Temp (°C)',
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_climateControlHumidityMinController, 'Min Humidity (%)',
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_climateControlHumidityMaxController, 'Max Humidity (%)',
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Responsible Persons Section
                _buildSectionHeader('Responsible Persons'),
                _buildTextField(_responsiblePersonNameController, 'Responsible Person Name', maxLength: 200),
                _buildTextField(_responsiblePersonEmailController, 'Responsible Person Email', maxLength: 255),
                _buildTextField(_responsiblePersonPhoneController, 'Responsible Person Phone', maxLength: 50),
                _buildTextField(_qualityManagerNameController, 'Quality Manager Name', maxLength: 200),
                _buildTextField(_qualityManagerEmailController, 'Quality Manager Email', maxLength: 255),
                _buildTextField(_qualityManagerPhoneController, 'Quality Manager Phone', maxLength: 50),
                _buildTextField(_regulatoryAffairsContactNameController, 'Regulatory Affairs Contact Name', maxLength: 200),
                _buildTextField(_regulatoryAffairsContactEmailController, 'Regulatory Affairs Contact Email', maxLength: 255),
                _buildTextField(_regulatoryAffairsContactPhoneController, 'Regulatory Affairs Contact Phone', maxLength: 50),
                const SizedBox(height: 16),

                // International Section
                _buildSectionHeader('International Regulatory IDs'),
                DropdownButtonFormField<String>(
                  value: _whoFctcPartyCountry,
                  decoration: const InputDecoration(
                    labelText: 'WHO FCTC Party Country',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('Select Country')),
                    ..._countryOptions.entries.map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    )),
                  ],
                  onChanged: widget.isEditing ? (value) => setState(() => _whoFctcPartyCountry = value) : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(_ukTobaccoTraceabilityIdController, 'UK Tobacco Traceability ID', maxLength: 50),
                _buildTextField(_canadaTobaccoLicenseIdController, 'Canada Tobacco License ID', maxLength: 50),
                _buildTextField(_australiaTobaccoLicenseIdController, 'Australia Tobacco License ID', maxLength: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.brown,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? helperText,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        enabled: widget.isEditing,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: widget.isEditing
            ? () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                onChanged(selected);
              }
            : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null
                    ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                    : 'Not set',
                style: TextStyle(
                  color: date != null ? null : Colors.grey,
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: widget.isEditing ? Colors.brown : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
