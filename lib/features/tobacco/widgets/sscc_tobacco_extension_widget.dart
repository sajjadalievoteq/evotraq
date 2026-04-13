import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/sscc_tobacco_extension_service.dart';
import '../models/sscc_tobacco_extension_model.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import '../../../core/cubit/system_settings_cubit.dart';

/// ISO 3166-1 alpha-3 country codes for dropdowns
const Map<String, String> _countryOptions = {
  'USA': 'United States',
  'CAN': 'Canada',
  'MEX': 'Mexico',
  'GBR': 'United Kingdom',
  'DEU': 'Germany',
  'FRA': 'France',
  'ITA': 'Italy',
  'ESP': 'Spain',
  'NLD': 'Netherlands',
  'BEL': 'Belgium',
  'CHE': 'Switzerland',
  'AUT': 'Austria',
  'POL': 'Poland',
  'CZE': 'Czech Republic',
  'HUN': 'Hungary',
  'ROU': 'Romania',
  'BGR': 'Bulgaria',
  'GRC': 'Greece',
  'PRT': 'Portugal',
  'SWE': 'Sweden',
  'DNK': 'Denmark',
  'FIN': 'Finland',
  'NOR': 'Norway',
  'IRL': 'Ireland',
  'AUS': 'Australia',
  'NZL': 'New Zealand',
  'JPN': 'Japan',
  'KOR': 'South Korea',
  'CHN': 'China',
  'IND': 'India',
  'BRA': 'Brazil',
  'ARG': 'Argentina',
  'ZAF': 'South Africa',
  'ARE': 'United Arab Emirates',
  'SAU': 'Saudi Arabia',
  'TUR': 'Turkey',
  'RUS': 'Russia',
  'UKR': 'Ukraine',
  'SGP': 'Singapore',
  'MYS': 'Malaysia',
  'THA': 'Thailand',
  'IDN': 'Indonesia',
  'PHL': 'Philippines',
  'VNM': 'Vietnam',
};

/// US State codes for state transit permit dropdown
const Map<String, String> _usStateOptions = {
  'AL': 'Alabama',
  'AK': 'Alaska',
  'AZ': 'Arizona',
  'AR': 'Arkansas',
  'CA': 'California',
  'CO': 'Colorado',
  'CT': 'Connecticut',
  'DE': 'Delaware',
  'FL': 'Florida',
  'GA': 'Georgia',
  'HI': 'Hawaii',
  'ID': 'Idaho',
  'IL': 'Illinois',
  'IN': 'Indiana',
  'IA': 'Iowa',
  'KS': 'Kansas',
  'KY': 'Kentucky',
  'LA': 'Louisiana',
  'ME': 'Maine',
  'MD': 'Maryland',
  'MA': 'Massachusetts',
  'MI': 'Michigan',
  'MN': 'Minnesota',
  'MS': 'Mississippi',
  'MO': 'Missouri',
  'MT': 'Montana',
  'NE': 'Nebraska',
  'NV': 'Nevada',
  'NH': 'New Hampshire',
  'NJ': 'New Jersey',
  'NM': 'New Mexico',
  'NY': 'New York',
  'NC': 'North Carolina',
  'ND': 'North Dakota',
  'OH': 'Ohio',
  'OK': 'Oklahoma',
  'OR': 'Oregon',
  'PA': 'Pennsylvania',
  'RI': 'Rhode Island',
  'SC': 'South Carolina',
  'SD': 'South Dakota',
  'TN': 'Tennessee',
  'TX': 'Texas',
  'UT': 'Utah',
  'VT': 'Vermont',
  'VA': 'Virginia',
  'WA': 'Washington',
  'WV': 'West Virginia',
  'WI': 'Wisconsin',
  'WY': 'Wyoming',
  'DC': 'District of Columbia',
  'PR': 'Puerto Rico',
};

/// Common seal types for tobacco transport
const List<String> _sealTypeOptions = [
  'Bolt Seal',
  'Cable Seal',
  'Padlock Seal',
  'Plastic Seal',
  'Metal Seal',
  'Electronic Seal',
  'RFID Seal',
  'Customs Seal',
  'Carrier Seal',
  'Shipper Seal',
];

/// Widget that displays/edits tobacco extension data for a SSCC (shipping container)
/// Can be embedded in SSCC detail screens or used standalone
class SSCCTobaccoExtensionWidget extends StatefulWidget {
  final int? ssccId;
  final String? ssccCode;
  final bool isEditing;
  final Function(SSCCTobaccoExtension?)? onSaved;

  const SSCCTobaccoExtensionWidget({
    Key? key,
    this.ssccId,
    this.ssccCode,
    this.isEditing = false,
    this.onSaved,
  }) : super(key: key);

  @override
  State<SSCCTobaccoExtensionWidget> createState() =>
      SSCCTobaccoExtensionWidgetState();
}

/// State class for SSCCTobaccoExtensionWidget
class SSCCTobaccoExtensionWidgetState extends State<SSCCTobaccoExtensionWidget> {
  SSCCTobaccoExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  // EU TPD Transport Section
  final _euTransportUnitIdController = TextEditingController();
  final _euRouteAuthorizationNumberController = TextEditingController();
  DateTime? _euRouteAuthorizationDate;
  DateTime? _euRouteAuthorizationExpiry;
  bool _euFirstRetailOutlet = false;

  // Tax Stamp Aggregation
  final _taxStampAggregationLevelController = TextEditingController();
  final _aggregatedStampCountController = TextEditingController();
  final _taxStampAuthorityIdController = TextEditingController();

  // Export/Import Documentation
  final _customsDeclarationNumberController = TextEditingController();
  DateTime? _customsDeclarationDate;
  final _exportLicenseNumberController = TextEditingController();
  DateTime? _exportLicenseDate;
  DateTime? _exportLicenseExpiry;
  final _importPermitNumberController = TextEditingController();
  DateTime? _importPermitDate;
  String? _countryOfOrigin; // Dropdown - ISO 3166-1 alpha-3
  String? _countryOfDestination; // Dropdown - ISO 3166-1 alpha-3

  // Transport Security
  final _sealNumberController = TextEditingController();
  String? _sealType; // Dropdown
  final _sealedByController = TextEditingController();
  DateTime? _sealedDate;

  // Carrier Information
  final _carrierLicenseNumberController = TextEditingController();
  final _carrierTobaccoPermitNumberController = TextEditingController();
  final _driverIdController = TextEditingController();
  final _vehicleRegistrationController = TextEditingController();

  // State/Regional Compliance (US)
  final _pactActManifestNumberController = TextEditingController();
  final _stateTransitPermitNumberController = TextEditingController();
  String? _stateTransitPermitState; // Dropdown - US state code

  // Manufacturing Batch Tracking
  bool _containsMultipleBatches = false;
  final _primaryBatchNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExtension();
  }

  @override
  void dispose() {
    _euTransportUnitIdController.dispose();
    _euRouteAuthorizationNumberController.dispose();
    _taxStampAggregationLevelController.dispose();
    _aggregatedStampCountController.dispose();
    _taxStampAuthorityIdController.dispose();
    _customsDeclarationNumberController.dispose();
    _exportLicenseNumberController.dispose();
    _importPermitNumberController.dispose();
    _sealNumberController.dispose();
    _sealedByController.dispose();
    _carrierLicenseNumberController.dispose();
    _carrierTobaccoPermitNumberController.dispose();
    _driverIdController.dispose();
    _vehicleRegistrationController.dispose();
    _pactActManifestNumberController.dispose();
    _stateTransitPermitNumberController.dispose();
    _primaryBatchNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadExtension() async {
    // Load extension data if we have an ssccId OR ssccCode
    // ssccId is preferred (from existing saved SSCC)
    // ssccCode is used as fallback (when viewing by code)
    final hasValidSsccId = widget.ssccId != null;
    final hasValidSsccCode = widget.ssccCode != null && widget.ssccCode!.isNotEmpty;

    if (!hasValidSsccId && !hasValidSsccCode) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExtension = false;
        });
      }
      return;
    }

    try {
      final service = getIt<SSCCTobaccoExtensionService>();
      SSCCTobaccoExtension? extension;

      // Prefer loading by ssccId, fallback to ssccCode
      if (hasValidSsccId) {
        extension = await service.getBySsccId(widget.ssccId!);
      } else if (hasValidSsccCode) {
        extension = await service.getBySsccCode(widget.ssccCode!);
      }

      if (mounted) {
        setState(() {
          _extension = extension;
          _hasExtension = extension != null;
          _isLoading = false;
          if (extension != null) {
            _populateFields(extension);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExtension = false;
        });
      }
    }
  }

  void _populateFields(SSCCTobaccoExtension ext) {
    _euTransportUnitIdController.text = ext.euTransportUnitId ?? '';
    _euRouteAuthorizationNumberController.text = ext.euRouteAuthorizationNumber ?? '';
    _euRouteAuthorizationDate = ext.euRouteAuthorizationDate;
    _euRouteAuthorizationExpiry = ext.euRouteAuthorizationExpiry;
    _euFirstRetailOutlet = ext.euFirstRetailOutlet;

    _taxStampAggregationLevelController.text = ext.taxStampAggregationLevel ?? '';
    _aggregatedStampCountController.text = ext.aggregatedStampCount?.toString() ?? '';
    _taxStampAuthorityIdController.text = ext.taxStampAuthorityId ?? '';

    _customsDeclarationNumberController.text = ext.customsDeclarationNumber ?? '';
    _customsDeclarationDate = ext.customsDeclarationDate;
    _exportLicenseNumberController.text = ext.exportLicenseNumber ?? '';
    _exportLicenseDate = ext.exportLicenseDate;
    _exportLicenseExpiry = ext.exportLicenseExpiry;
    _importPermitNumberController.text = ext.importPermitNumber ?? '';
    _importPermitDate = ext.importPermitDate;
    _countryOfOrigin = ext.countryOfOrigin;
    _countryOfDestination = ext.countryOfDestination;

    _sealNumberController.text = ext.sealNumber ?? '';
    _sealType = ext.sealType;
    _sealedByController.text = ext.sealedBy ?? '';
    _sealedDate = ext.sealedDate;

    _carrierLicenseNumberController.text = ext.carrierLicenseNumber ?? '';
    _carrierTobaccoPermitNumberController.text = ext.carrierTobaccoPermitNumber ?? '';
    _driverIdController.text = ext.driverId ?? '';
    _vehicleRegistrationController.text = ext.vehicleRegistration ?? '';

    _pactActManifestNumberController.text = ext.pactActManifestNumber ?? '';
    _stateTransitPermitNumberController.text = ext.stateTransitPermitNumber ?? '';
    _stateTransitPermitState = ext.stateTransitPermitState;

    _containsMultipleBatches = ext.containsMultipleBatches;
    _primaryBatchNumberController.text = ext.primaryBatchNumber ?? '';
  }

  /// Check if user has entered any tobacco data
  bool get hasData =>
      _euTransportUnitIdController.text.isNotEmpty ||
      _euRouteAuthorizationNumberController.text.isNotEmpty ||
      _euFirstRetailOutlet ||
      _taxStampAggregationLevelController.text.isNotEmpty ||
      _aggregatedStampCountController.text.isNotEmpty ||
      _taxStampAuthorityIdController.text.isNotEmpty ||
      _customsDeclarationNumberController.text.isNotEmpty ||
      _exportLicenseNumberController.text.isNotEmpty ||
      _sealNumberController.text.isNotEmpty ||
      _carrierLicenseNumberController.text.isNotEmpty ||
      _pactActManifestNumberController.text.isNotEmpty ||
      _containsMultipleBatches ||
      _countryOfOrigin != null ||
      _countryOfDestination != null ||
      _sealType != null ||
      _stateTransitPermitState != null;

  /// Build the extension object from form data for external use
  SSCCTobaccoExtension? buildExtension({int? ssccId, String? ssccCode}) {
    if (!hasData) return null;

    return _buildExtensionFromFields().copyWith(
      ssccId: ssccId ?? widget.ssccId,
      ssccCode: ssccCode ?? widget.ssccCode,
    );
  }

  SSCCTobaccoExtension _buildExtensionFromFields() {
    return SSCCTobaccoExtension(
      id: _extension?.id,
      ssccId: widget.ssccId,
      ssccCode: widget.ssccCode,
      euTransportUnitId: _euTransportUnitIdController.text.isEmpty
          ? null
          : _euTransportUnitIdController.text,
      euRouteAuthorizationNumber: _euRouteAuthorizationNumberController.text.isEmpty
          ? null
          : _euRouteAuthorizationNumberController.text,
      euRouteAuthorizationDate: _euRouteAuthorizationDate,
      euRouteAuthorizationExpiry: _euRouteAuthorizationExpiry,
      euFirstRetailOutlet: _euFirstRetailOutlet,
      taxStampAggregationLevel: _taxStampAggregationLevelController.text.isEmpty
          ? null
          : _taxStampAggregationLevelController.text,
      aggregatedStampCount: _aggregatedStampCountController.text.isEmpty
          ? null
          : int.tryParse(_aggregatedStampCountController.text),
      taxStampAuthorityId: _taxStampAuthorityIdController.text.isEmpty
          ? null
          : _taxStampAuthorityIdController.text,
      customsDeclarationNumber: _customsDeclarationNumberController.text.isEmpty
          ? null
          : _customsDeclarationNumberController.text,
      customsDeclarationDate: _customsDeclarationDate,
      exportLicenseNumber: _exportLicenseNumberController.text.isEmpty
          ? null
          : _exportLicenseNumberController.text,
      exportLicenseDate: _exportLicenseDate,
      exportLicenseExpiry: _exportLicenseExpiry,
      importPermitNumber: _importPermitNumberController.text.isEmpty
          ? null
          : _importPermitNumberController.text,
      importPermitDate: _importPermitDate,
      countryOfOrigin: _countryOfOrigin,
      countryOfDestination: _countryOfDestination,
      sealNumber: _sealNumberController.text.isEmpty
          ? null
          : _sealNumberController.text,
      sealType: _sealType,
      sealedBy: _sealedByController.text.isEmpty
          ? null
          : _sealedByController.text,
      sealedDate: _sealedDate,
      carrierLicenseNumber: _carrierLicenseNumberController.text.isEmpty
          ? null
          : _carrierLicenseNumberController.text,
      carrierTobaccoPermitNumber: _carrierTobaccoPermitNumberController.text.isEmpty
          ? null
          : _carrierTobaccoPermitNumberController.text,
      driverId: _driverIdController.text.isEmpty
          ? null
          : _driverIdController.text,
      vehicleRegistration: _vehicleRegistrationController.text.isEmpty
          ? null
          : _vehicleRegistrationController.text,
      pactActManifestNumber: _pactActManifestNumberController.text.isEmpty
          ? null
          : _pactActManifestNumberController.text,
      stateTransitPermitNumber: _stateTransitPermitNumberController.text.isEmpty
          ? null
          : _stateTransitPermitNumberController.text,
      stateTransitPermitState: _stateTransitPermitState,
      containsMultipleBatches: _containsMultipleBatches,
      primaryBatchNumber: _primaryBatchNumberController.text.isEmpty
          ? null
          : _primaryBatchNumberController.text,
    );
  }

  /// Save the extension - can be called from parent widget
  Future<SSCCTobaccoExtension?> saveExtension(int ssccId, String ssccCode) async {
    try {
      final service = getIt<SSCCTobaccoExtensionService>();
      final extensionToSave = _buildExtensionFromFields().copyWith(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );

      final saved = await service.saveBySsccId(ssccId, extensionToSave);
      
      if (mounted) {
        setState(() {
          _extension = saved;
          _hasExtension = true;
        });
      }

      widget.onSaved?.call(saved);
      return saved;
    } catch (e) {
      debugPrint('Error saving SSCC tobacco extension: $e');
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? currentDate,
      Function(DateTime?) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.brown.shade700,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: const Text('Tobacco Extension'),
        subtitle: Text(_hasExtension ? 'Extension data loaded' : 'No extension data'),
        leading: const Icon(Icons.local_shipping),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEuTpdSection(),
                const Divider(height: 32),
                _buildTaxStampSection(),
                const Divider(height: 32),
                _buildExportImportSection(),
                const Divider(height: 32),
                _buildTransportSecuritySection(),
                const Divider(height: 32),
                _buildCarrierSection(),
                const Divider(height: 32),
                _buildStateComplianceSection(),
                const Divider(height: 32),
                _buildBatchTrackingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEuTpdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EU TPD Transport Compliance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _euTransportUnitIdController,
          decoration: const InputDecoration(
            labelText: 'EU Transport Unit ID',
            hintText: 'TPD transport unit identifier',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _euRouteAuthorizationNumberController,
          decoration: const InputDecoration(
            labelText: 'Route Authorization Number',
            hintText: 'Authorization for transport route',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Route Auth. Date'),
                subtitle: Text(_euRouteAuthorizationDate != null
                    ? _euRouteAuthorizationDate!.toLocal().toString().split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _euRouteAuthorizationDate,
                          (date) => setState(() => _euRouteAuthorizationDate = date),
                        ),
                      )
                    : null,
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Route Auth. Expiry'),
                subtitle: Text(_euRouteAuthorizationExpiry != null
                    ? _euRouteAuthorizationExpiry!.toLocal().toString().split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _euRouteAuthorizationExpiry,
                          (date) => setState(() => _euRouteAuthorizationExpiry = date),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('First Retail Outlet Delivery'),
          subtitle: const Text('Is this the first point of sale?'),
          value: _euFirstRetailOutlet,
          onChanged: widget.isEditing
              ? (value) => setState(() => _euFirstRetailOutlet = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildTaxStampSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax Stamp Aggregation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Aggregation Level',
            border: OutlineInputBorder(),
          ),
          value: _taxStampAggregationLevelController.text.isEmpty
              ? null
              : _taxStampAggregationLevelController.text,
          items: const [
            DropdownMenuItem(value: 'PACK', child: Text('Pack')),
            DropdownMenuItem(value: 'CARTON', child: Text('Carton')),
            DropdownMenuItem(value: 'MASTERCASE', child: Text('Master Case')),
            DropdownMenuItem(value: 'PALLET', child: Text('Pallet')),
            DropdownMenuItem(value: 'CONTAINER', child: Text('Container')),
          ],
          onChanged: widget.isEditing
              ? (value) => setState(
                  () => _taxStampAggregationLevelController.text = value ?? '')
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _aggregatedStampCountController,
          decoration: const InputDecoration(
            labelText: 'Aggregated Stamp Count',
            hintText: 'Total number of tax stamps in container',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          enabled: widget.isEditing,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _taxStampAuthorityIdController,
          decoration: const InputDecoration(
            labelText: 'Tax Stamp Authority ID',
            hintText: 'Issuing authority identifier',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
      ],
    );
  }

  Widget _buildExportImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export/Import Documentation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customsDeclarationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Customs Declaration Number',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: ListTile(
                title: const Text('Date'),
                subtitle: Text(_customsDeclarationDate != null
                    ? _customsDeclarationDate!.toLocal().toString().split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _customsDeclarationDate,
                          (date) => setState(() => _customsDeclarationDate = date),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _exportLicenseNumberController,
          decoration: const InputDecoration(
            labelText: 'Export License Number',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _importPermitNumberController,
          decoration: const InputDecoration(
            labelText: 'Import Permit Number',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _countryOfOrigin,
                decoration: const InputDecoration(
                  labelText: 'Country of Origin',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ..._countryOptions.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  )),
                ],
                onChanged: widget.isEditing ? (value) {
                  setState(() => _countryOfOrigin = value);
                } : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _countryOfDestination,
                decoration: const InputDecoration(
                  labelText: 'Country of Destination',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ..._countryOptions.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  )),
                ],
                onChanged: widget.isEditing ? (value) {
                  setState(() => _countryOfDestination = value);
                } : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transport Security',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sealNumberController,
                decoration: const InputDecoration(
                  labelText: 'Seal Number',
                  hintText: 'Container seal ID',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Seal Type',
                  border: OutlineInputBorder(),
                ),
                value: _sealType,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Seal Type'),
                  ),
                  ..._sealTypeOptions.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )),
                ],
                onChanged: widget.isEditing
                    ? (value) => setState(() => _sealType = value)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sealedByController,
                decoration: const InputDecoration(
                  labelText: 'Sealed By',
                  hintText: 'Person/organization who applied seal',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 255,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: ListTile(
                title: const Text('Sealed Date'),
                subtitle: Text(_sealedDate != null
                    ? _sealedDate!.toLocal().toString().split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _sealedDate,
                          (date) => setState(() => _sealedDate = date),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarrierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carrier Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _carrierLicenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Carrier License Number',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _carrierTobaccoPermitNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tobacco Permit Number',
                  hintText: 'Carrier tobacco transport permit',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _driverIdController,
                decoration: const InputDecoration(
                  labelText: 'Driver ID',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _vehicleRegistrationController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Registration',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStateComplianceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State/Regional Compliance (US)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pactActManifestNumberController,
          decoration: const InputDecoration(
            labelText: 'PACT Act Manifest Number',
            hintText: 'Prevent All Cigarette Trafficking manifest',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _stateTransitPermitNumberController,
                decoration: const InputDecoration(
                  labelText: 'State Transit Permit Number',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _stateTransitPermitState,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select'),
                  ),
                  ..._usStateOptions.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  )),
                ],
                onChanged: widget.isEditing ? (value) {
                  setState(() => _stateTransitPermitState = value);
                } : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manufacturing Batch Tracking',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Contains Multiple Batches'),
          subtitle: const Text('Container has products from multiple batches'),
          value: _containsMultipleBatches,
          onChanged: widget.isEditing
              ? (value) => setState(() => _containsMultipleBatches = value)
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _primaryBatchNumberController,
          decoration: const InputDecoration(
            labelText: 'Primary Batch Number',
            hintText: 'Main batch in container',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
      ],
    );
  }
}
