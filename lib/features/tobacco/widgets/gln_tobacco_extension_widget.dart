import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:traqtrace_app/data/models/gs1/gln/gln_tobacco_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import '../../../core/cubit/system_settings_cubit.dart';

/// Widget that displays/edits tobacco extension data for a GLN (location)
/// Can be embedded in GLN detail screens or used standalone
class GLNTobaccoExtensionWidget extends StatefulWidget {
  final int? glnId;
  final String? glnCode;
  final bool isEditing;
  final Function(GLNTobaccoExtension?)? onSaved;

  /// From master-data GLN GET response when present; avoids a separate extension API call.
  final GLNTobaccoExtension? initialExtension;

  const GLNTobaccoExtensionWidget({
    Key? key,
    this.glnId,
    this.glnCode,
    this.isEditing = false,
    this.onSaved,
    this.initialExtension,
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
  void didUpdateWidget(covariant GLNTobaccoExtensionWidget oldWidget) {
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

    // Tobacco extension is supplied by the master-data GLN response when present.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
          GlnTobaccoExtensionUiConstants.expansionTitle,
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
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionEuTpd),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchEuTpdRegistered),
                  value: _euTpdRegistered,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _euTpdRegistered = value)
                      : null,
                ),
                _buildTextField(_euEconomicOperatorIdController,
                    GlnTobaccoExtensionUiConstants.labelEuEconomicOperatorId,
                    helperText: GlnTobaccoExtensionUiConstants.helperEuEconomicOperatorId,
                    maxLength: 50),
                _buildTextField(_euFacilityIdController, GlnTobaccoExtensionUiConstants.labelEuFacilityId,
                    maxLength: 50),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelTpdRegistrationDate,
                    _euTpdRegistrationDate, (date) {
                  setState(() => _euTpdRegistrationDate = date);
                }),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchFirstRetailOutlet),
                  subtitle: const Text(GlnTobaccoExtensionUiConstants.subtitleFirstRetailOutlet),
                  value: _euFirstRetailOutlet,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _euFirstRetailOutlet = value)
                      : null,
                ),
                _buildTextField(_euImporterIdController, GlnTobaccoExtensionUiConstants.labelEuImporterId,
                    maxLength: 50),
                const SizedBox(height: 16),

                // Tax Stamp Authority Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionTaxStampAuthority),
                _buildTextField(_taxStampAuthorityIdController,
                    GlnTobaccoExtensionUiConstants.labelTaxStampAuthorityId, maxLength: 50),
                _buildTextField(_taxStampAuthorityNameController,
                    GlnTobaccoExtensionUiConstants.labelTaxStampAuthorityName, maxLength: 200),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelAuthorizationDate,
                    _taxStampAuthorizationDate, (date) {
                  setState(() => _taxStampAuthorizationDate = date);
                }),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelAuthorizationExpiry,
                    _taxStampAuthorizationExpiry, (date) {
                  setState(() => _taxStampAuthorizationExpiry = date);
                }),
                _buildTextField(_authorizedTaxStampTypesController,
                    GlnTobaccoExtensionUiConstants.labelAuthorizedTaxStampTypes,
                    helperText: GlnTobaccoExtensionUiConstants.helperCommaSeparatedList,
                    maxLength: 500),
                const SizedBox(height: 16),

                // FDA Tobacco Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionFdaTobaccoUs),
                _buildTextField(_fdaTobaccoEstablishmentIdController,
                    GlnTobaccoExtensionUiConstants.labelFdaTobaccoEstablishmentId, maxLength: 50),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelRegistrationDateGeneric,
                    _fdaTobaccoRegistrationDate, (date) {
                  setState(() => _fdaTobaccoRegistrationDate = date);
                }),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelRegistrationExpiryGeneric,
                    _fdaTobaccoRegistrationExpiry, (date) {
                  setState(() => _fdaTobaccoRegistrationExpiry = date);
                }),
                _buildTextField(_fdaPmtaSiteListingController,
                    GlnTobaccoExtensionUiConstants.labelPmtaSiteListing, maxLength: 200),
                _buildTextField(_fdaSeSiteListingController,
                    GlnTobaccoExtensionUiConstants.labelSeSiteListing, maxLength: 200),
                const SizedBox(height: 16),

                // PACT Act Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionPactActUs),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchPactActRegistered),
                  subtitle: const Text(GlnTobaccoExtensionUiConstants.subtitlePactAct),
                  value: _pactActRegistered,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _pactActRegistered = value)
                      : null,
                ),
                if (_pactActRegistered) ...[
                  _buildTextField(_pactActRegistrationNumberController,
                      GlnTobaccoExtensionUiConstants.labelPactActRegistrationNumber, maxLength: 50),
                  _buildDateField(GlnTobaccoExtensionUiConstants.labelRegistrationDateGeneric,
                      _pactActRegistrationDate, (date) {
                    setState(() => _pactActRegistrationDate = date);
                  }),
                  _buildTextField(_pactAtfLicenseNumberController,
                      GlnTobaccoExtensionUiConstants.labelAtfLicenseNumber, maxLength: 50),
                ],
                const SizedBox(height: 16),

                // State License Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionStateTobaccoLicense),
                _buildTextField(_stateTobaccoLicenseNumberController,
                    GlnTobaccoExtensionUiConstants.labelStateLicenseNumber, maxLength: 50),
                _buildTextField(_stateTobaccoLicenseTypeController,
                    GlnTobaccoExtensionUiConstants.labelLicenseTypeShort, maxLength: 50),
                DropdownButtonFormField<String>(
                  value: _stateTobaccoLicenseState,
                  decoration: const InputDecoration(
                    labelText: GlnTobaccoExtensionUiConstants.labelStateDropdown,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text(GlnExtensionSharedUiConstants.selectState)),
                    ..._usStateOptions.entries.map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    )),
                  ],
                  onChanged: widget.isEditing ? (value) => setState(() => _stateTobaccoLicenseState = value) : null,
                ),
                const SizedBox(height: 16),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelLicenseExpiryGeneric,
                    _stateTobaccoLicenseExpiry, (date) {
                  setState(() => _stateTobaccoLicenseExpiry = date);
                }),
                const SizedBox(height: 16),

                // Wholesale Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionWholesaleDistribution),
                _buildTextField(_tobaccoWholesaleLicenseNumberController,
                    GlnTobaccoExtensionUiConstants.labelWholesaleLicenseNumber, maxLength: 50),
                _buildDateField(GlnTobaccoExtensionUiConstants.labelWholesaleLicenseExpiry,
                    _tobaccoWholesaleLicenseExpiry, (date) {
                  setState(() => _tobaccoWholesaleLicenseExpiry = date);
                }),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchMsaParticipant),
                  value: _masterSettlementAgreementParticipant,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _masterSettlementAgreementParticipant = value)
                      : null,
                ),
                if (_masterSettlementAgreementParticipant)
                  _buildTextField(_msaEscrowAccountStatusController,
                      GlnTobaccoExtensionUiConstants.labelMsaEscrowAccountStatus, maxLength: 50),
                const SizedBox(height: 16),

                // Manufacturing Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionManufacturing),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchManufacturingFacility),
                  value: _isManufacturingFacility,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _isManufacturingFacility = value)
                      : null,
                ),
                if (_isManufacturingFacility) ...[  
                  _buildTextField(_manufacturingLicenseNumberController,
                      GlnTobaccoExtensionUiConstants.labelManufacturingLicenseNumber, maxLength: 50),
                  _buildDateField(GlnTobaccoExtensionUiConstants.labelManufacturingLicenseExpiry,
                      _manufacturingLicenseExpiry, (date) {
                    setState(() => _manufacturingLicenseExpiry = date);
                  }),
                  _buildTextField(_manufacturingCapacityController,
                      GlnTobaccoExtensionUiConstants.labelManufacturingCapacity,
                      keyboardType: TextInputType.number, maxLength: 20),
                  _buildTextField(_tobaccoTypesManufacturedController,
                      GlnTobaccoExtensionUiConstants.labelTobaccoTypesManufactured,
                      helperText: GlnTobaccoExtensionUiConstants.helperTobaccoTypesManufactured,
                      maxLength: 500),
                ],
                const SizedBox(height: 16),

                // UI Issuer Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionUniqueIdentifierIssuance),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchUiIssuer),
                  subtitle: const Text(GlnTobaccoExtensionUiConstants.subtitleUiIssuer),
                  value: _isUiIssuer,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _isUiIssuer = value)
                      : null,
                ),
                if (_isUiIssuer) ...[  
                  _buildTextField(_uiIssuerRegistrationIdController,
                      GlnTobaccoExtensionUiConstants.labelUiIssuerRegistrationId, maxLength: 50),
                  _buildTextField(_uiSystemProviderController,
                      GlnTobaccoExtensionUiConstants.labelUiSystemProvider, maxLength: 200),
                  _buildTextField(_antiTamperingDeviceProviderController,
                      GlnTobaccoExtensionUiConstants.labelAntiTamperingDeviceProvider, maxLength: 200),
                ],
                const SizedBox(height: 16),

                // Import/Export Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionImportExport),
                _buildTextField(_customsRegistrationNumberController,
                    GlnTobaccoExtensionUiConstants.labelCustomsRegistrationNumber, maxLength: 50),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchAuthorizedEconomicOperator),
                  value: _authorizedEconomicOperator,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _authorizedEconomicOperator = value)
                      : null,
                ),
                if (_authorizedEconomicOperator) ...[  
                  _buildTextField(_aeoCertificateNumberController,
                      GlnTobaccoExtensionUiConstants.labelAeoCertificateNumber, maxLength: 50),
                  _buildDateField(GlnTobaccoExtensionUiConstants.labelAeoCertificateExpiry, _aeoCertificateExpiry,
                      (date) {
                    setState(() => _aeoCertificateExpiry = date);
                  }),
                ],
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchBondedWarehouse),
                  value: _bondedWarehouse,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _bondedWarehouse = value)
                      : null,
                ),
                if (_bondedWarehouse)
                  _buildTextField(_bondedWarehouseLicenseNumberController,
                      GlnTobaccoExtensionUiConstants.labelBondedWarehouseLicenseNumber, maxLength: 50),
                const SizedBox(height: 16),

                // Security Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionSecurityCompliance),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchHasSecurityFeatures),
                  value: _hasSecurityFeatures,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _hasSecurityFeatures = value)
                      : null,
                ),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchVideoSurveillance),
                  value: _videoSurveillance,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _videoSurveillance = value)
                      : null,
                ),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchAccessControlSystem),
                  value: _accessControlSystem,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _accessControlSystem = value)
                      : null,
                ),
                _buildTextField(_inventoryTrackingSystemController,
                    GlnTobaccoExtensionUiConstants.labelInventoryTrackingSystem, maxLength: 200),
                const SizedBox(height: 16),

                // Retail Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionRetail),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchRetailLocation),
                  value: _isRetailLocation,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _isRetailLocation = value)
                      : null,
                ),
                if (_isRetailLocation) ...[  
                  _buildTextField(_ageVerificationSystemController,
                      GlnTobaccoExtensionUiConstants.labelAgeVerificationSystem, maxLength: 200),
                  _buildTextField(_tobaccoSalesPermitNumberController,
                      GlnTobaccoExtensionUiConstants.labelTobaccoSalesPermitNumber, maxLength: 50),
                  _buildDateField(GlnTobaccoExtensionUiConstants.labelSalesPermitExpiry, _tobaccoSalesPermitExpiry,
                      (date) {
                    setState(() => _tobaccoSalesPermitExpiry = date);
                  }),
                ],
                const SizedBox(height: 16),

                // Operational Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionOperationalDetails),
                _buildTextField(_receivingHoursController,
                    GlnTobaccoExtensionUiConstants.labelReceivingHours, maxLength: 100),
                _buildTextField(_dispatchHoursController,
                    GlnTobaccoExtensionUiConstants.labelDispatchHours, maxLength: 100),
                _buildTextField(_storageCapacityPalletsController,
                    GlnTobaccoExtensionUiConstants.labelStorageCapacityPallets,
                    keyboardType: TextInputType.number, maxLength: 20),
                SwitchListTile(
                  title: const Text(GlnTobaccoExtensionUiConstants.switchClimateControl),
                  value: _hasClimateControl,
                  onChanged: widget.isEditing
                      ? (value) => setState(() => _hasClimateControl = value)
                      : null,
                ),
                if (_hasClimateControl) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_climateControlTempMinController,
                            GlnTobaccoExtensionUiConstants.labelMinTempC,
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_climateControlTempMaxController,
                            GlnTobaccoExtensionUiConstants.labelMaxTempC,
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_climateControlHumidityMinController,
                            GlnTobaccoExtensionUiConstants.labelMinHumidityPct,
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_climateControlHumidityMaxController,
                            GlnTobaccoExtensionUiConstants.labelMaxHumidityPct,
                            keyboardType: TextInputType.number, maxLength: 10),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Responsible Persons Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionResponsiblePersons),
                _buildTextField(_responsiblePersonNameController,
                    GlnTobaccoExtensionUiConstants.labelResponsiblePersonName, maxLength: 200),
                _buildTextField(_responsiblePersonEmailController,
                    GlnTobaccoExtensionUiConstants.labelResponsiblePersonEmail, maxLength: 255),
                _buildTextField(_responsiblePersonPhoneController,
                    GlnTobaccoExtensionUiConstants.labelResponsiblePersonPhone, maxLength: 50),
                _buildTextField(_qualityManagerNameController,
                    GlnTobaccoExtensionUiConstants.labelQualityManagerName, maxLength: 200),
                _buildTextField(_qualityManagerEmailController,
                    GlnTobaccoExtensionUiConstants.labelQualityManagerEmail, maxLength: 255),
                _buildTextField(_qualityManagerPhoneController,
                    GlnTobaccoExtensionUiConstants.labelQualityManagerPhone, maxLength: 50),
                _buildTextField(_regulatoryAffairsContactNameController,
                    GlnTobaccoExtensionUiConstants.labelRegulatoryAffairsContactName, maxLength: 200),
                _buildTextField(_regulatoryAffairsContactEmailController,
                    GlnTobaccoExtensionUiConstants.labelRegulatoryAffairsContactEmail, maxLength: 255),
                _buildTextField(_regulatoryAffairsContactPhoneController,
                    GlnTobaccoExtensionUiConstants.labelRegulatoryAffairsContactPhone, maxLength: 50),
                const SizedBox(height: 16),

                // International Section
                _buildSectionHeader(GlnTobaccoExtensionUiConstants.sectionInternationalRegulatoryIds),
                DropdownButtonFormField<String>(
                  value: _whoFctcPartyCountry,
                  decoration: const InputDecoration(
                    labelText: GlnTobaccoExtensionUiConstants.labelWhoFctcPartyCountry,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text(GlnExtensionSharedUiConstants.selectCountry)),
                    ..._countryOptions.entries.map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    )),
                  ],
                  onChanged: widget.isEditing ? (value) => setState(() => _whoFctcPartyCountry = value) : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(_ukTobaccoTraceabilityIdController,
                    GlnTobaccoExtensionUiConstants.labelUkTobaccoTraceabilityId, maxLength: 50),
                _buildTextField(_canadaTobaccoLicenseIdController,
                    GlnTobaccoExtensionUiConstants.labelCanadaTobaccoLicenseId, maxLength: 50),
                _buildTextField(_australiaTobaccoLicenseIdController,
                    GlnTobaccoExtensionUiConstants.labelAustraliaTobaccoLicenseId, maxLength: 50),
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
                    : GlnExtensionSharedUiConstants.dateNotSet,
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
