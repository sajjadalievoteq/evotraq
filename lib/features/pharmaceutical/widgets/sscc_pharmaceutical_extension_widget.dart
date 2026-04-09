import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../models/sscc_pharmaceutical_extension_model.dart';
import '../services/sscc_pharmaceutical_extension_service.dart';
import '../../../core/cubit/system_settings_cubit.dart';

/// DEA Schedule options for controlled substances
const List<String> _deaScheduleOptions = [
  'Schedule I',
  'Schedule II',
  'Schedule III',
  'Schedule IV',
  'Schedule V',
];

/// Hazmat packing group options
const List<String> _hazmatPackingGroupOptions = [
  'I',   // Great danger
  'II',  // Medium danger
  'III', // Minor danger
];

/// Hazmat class options for pharmaceutical transport
const Map<String, String> _hazmatClassOptions = {
  '2.2': 'Non-flammable Gas',
  '3': 'Flammable Liquid',
  '6.1': 'Toxic Substances',
  '6.2': 'Infectious Substances',
  '8': 'Corrosive Substances',
  '9': 'Miscellaneous Dangerous Goods',
};

/// Widget that displays/edits pharmaceutical extension data for a SSCC (shipping container)
/// Can be embedded in SSCC detail screens or used standalone
class SSCCPharmaceuticalExtensionWidget extends StatefulWidget {
  final int? ssccId;
  final String? ssccCode;
  final bool isEditing;
  final Function(SSCCPharmaceuticalExtension?)? onSaved;

  const SSCCPharmaceuticalExtensionWidget({
    Key? key,
    this.ssccId,
    this.ssccCode,
    this.isEditing = false,
    this.onSaved,
  }) : super(key: key);

  @override
  State<SSCCPharmaceuticalExtensionWidget> createState() =>
      SSCCPharmaceuticalExtensionWidgetState();
}

/// State class for SSCCPharmaceuticalExtensionWidget
class SSCCPharmaceuticalExtensionWidgetState
    extends State<SSCCPharmaceuticalExtensionWidget> {
  SSCCPharmaceuticalExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  // Cold Chain Requirements
  bool _coldChainRequired = false;
  final _minTemperatureCelsiusController = TextEditingController();
  final _maxTemperatureCelsiusController = TextEditingController();
  bool _temperatureMonitoringRequired = false;
  final _temperatureMonitoringDeviceIdController = TextEditingController();
  final _temperatureExcursionLimitMinutesController = TextEditingController();

  // GDP (Good Distribution Practice) Compliance
  bool _gdpCompliant = true;
  final _gdpCertificateNumberController = TextEditingController();
  DateTime? _gdpCertificateExpiry;
  final _gdpIssuingAuthorityController = TextEditingController();

  // WHO PQS Requirements
  bool _whoPqsRequired = false;
  final _whoPqsEquipmentCodeController = TextEditingController();

  // Controlled Substances (DEA/INCB)
  bool _containsControlledSubstance = false;
  String? _deaSchedule; // Dropdown
  final _deaOrderFormNumberController = TextEditingController();
  final _incbAuthorizationNumberController = TextEditingController();
  final _narcoticTransitPermitController = TextEditingController();

  // Hazardous Materials
  String? _hazmatClass; // Dropdown
  final _hazmatUnNumberController = TextEditingController();
  String? _hazmatPackingGroup; // Dropdown
  final _hazmatSpecialProvisionsController = TextEditingController();

  // Environmental Controls
  bool _humidityControlled = false;
  final _minHumidityPercentController = TextEditingController();
  final _maxHumidityPercentController = TextEditingController();
  bool _lightSensitive = false;
  bool _orientationSensitive = false;
  bool _shockSensitive = false;

  // Chain of Custody
  bool _chainOfCustodyRequired = false;
  bool _requiresSignatureOnReceipt = false;
  bool _requiresPharmacistVerification = false;

  // Carrier/Transport Qualification
  final _carrierGdpQualificationNumberController = TextEditingController();
  DateTime? _carrierGdpQualificationExpiry;
  final _vehicleQualificationNumberController = TextEditingController();
  DateTime? _vehicleLastQualificationDate;

  // Clinical Trial Shipments
  bool _clinicalTrialShipment = false;
  final _clinicalTrialProtocolNumberController = TextEditingController();
  final _irbApprovalNumberController = TextEditingController();

  // Special Handling
  final _specialHandlingInstructionsController = TextEditingController();
  bool _fragile = false;
  bool _doNotStack = false;
  bool _thisSideUp = false;

  @override
  void initState() {
    super.initState();
    _loadExtension();
  }

  @override
  void dispose() {
    _minTemperatureCelsiusController.dispose();
    _maxTemperatureCelsiusController.dispose();
    _temperatureMonitoringDeviceIdController.dispose();
    _temperatureExcursionLimitMinutesController.dispose();
    _gdpCertificateNumberController.dispose();
    _gdpIssuingAuthorityController.dispose();
    _whoPqsEquipmentCodeController.dispose();
    _deaOrderFormNumberController.dispose();
    _incbAuthorizationNumberController.dispose();
    _narcoticTransitPermitController.dispose();
    _hazmatUnNumberController.dispose();
    _hazmatSpecialProvisionsController.dispose();
    _minHumidityPercentController.dispose();
    _maxHumidityPercentController.dispose();
    _carrierGdpQualificationNumberController.dispose();
    _vehicleQualificationNumberController.dispose();
    _clinicalTrialProtocolNumberController.dispose();
    _irbApprovalNumberController.dispose();
    _specialHandlingInstructionsController.dispose();
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
      final service = Provider.of<SSCCPharmaceuticalExtensionService>(context, listen: false);
      SSCCPharmaceuticalExtension? extension;

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

  void _populateFields(SSCCPharmaceuticalExtension ext) {
    _coldChainRequired = ext.coldChainRequired;
    _minTemperatureCelsiusController.text =
        ext.minTemperatureCelsius?.toString() ?? '';
    _maxTemperatureCelsiusController.text =
        ext.maxTemperatureCelsius?.toString() ?? '';
    _temperatureMonitoringRequired = ext.temperatureMonitoringRequired;
    _temperatureMonitoringDeviceIdController.text =
        ext.temperatureMonitoringDeviceId ?? '';
    _temperatureExcursionLimitMinutesController.text =
        ext.temperatureExcursionLimitMinutes?.toString() ?? '';

    _gdpCompliant = ext.gdpCompliant;
    _gdpCertificateNumberController.text = ext.gdpCertificateNumber ?? '';
    _gdpCertificateExpiry = ext.gdpCertificateExpiry;
    _gdpIssuingAuthorityController.text = ext.gdpIssuingAuthority ?? '';

    _whoPqsRequired = ext.whoPqsRequired;
    _whoPqsEquipmentCodeController.text = ext.whoPqsEquipmentCode ?? '';

    _containsControlledSubstance = ext.containsControlledSubstance;
    _deaSchedule = ext.deaSchedule;
    _deaOrderFormNumberController.text = ext.deaOrderFormNumber ?? '';
    _incbAuthorizationNumberController.text = ext.incbAuthorizationNumber ?? '';
    _narcoticTransitPermitController.text = ext.narcoticTransitPermit ?? '';

    _hazmatClass = ext.hazmatClass;
    _hazmatUnNumberController.text = ext.hazmatUnNumber ?? '';
    _hazmatPackingGroup = ext.hazmatPackingGroup;
    _hazmatSpecialProvisionsController.text = ext.hazmatSpecialProvisions ?? '';

    _humidityControlled = ext.humidityControlled;
    _minHumidityPercentController.text =
        ext.minHumidityPercent?.toString() ?? '';
    _maxHumidityPercentController.text =
        ext.maxHumidityPercent?.toString() ?? '';
    _lightSensitive = ext.lightSensitive;
    _orientationSensitive = ext.orientationSensitive;
    _shockSensitive = ext.shockSensitive;

    _chainOfCustodyRequired = ext.chainOfCustodyRequired;
    _requiresSignatureOnReceipt = ext.requiresSignatureOnReceipt;
    _requiresPharmacistVerification = ext.requiresPharmacistVerification;

    _carrierGdpQualificationNumberController.text =
        ext.carrierGdpQualificationNumber ?? '';
    _carrierGdpQualificationExpiry = ext.carrierGdpQualificationExpiry;
    _vehicleQualificationNumberController.text =
        ext.vehicleQualificationNumber ?? '';
    _vehicleLastQualificationDate = ext.vehicleLastQualificationDate;

    _clinicalTrialShipment = ext.clinicalTrialShipment;
    _clinicalTrialProtocolNumberController.text =
        ext.clinicalTrialProtocolNumber ?? '';
    _irbApprovalNumberController.text = ext.irbApprovalNumber ?? '';

    _specialHandlingInstructionsController.text =
        ext.specialHandlingInstructions ?? '';
    _fragile = ext.fragile;
    _doNotStack = ext.doNotStack;
    _thisSideUp = ext.thisSideUp;
  }

  /// Check if user has entered any pharmaceutical data
  bool get hasData =>
      _coldChainRequired ||
      _minTemperatureCelsiusController.text.isNotEmpty ||
      _maxTemperatureCelsiusController.text.isNotEmpty ||
      _temperatureMonitoringRequired ||
      _gdpCompliant ||
      _gdpCertificateNumberController.text.isNotEmpty ||
      _whoPqsRequired ||
      _containsControlledSubstance ||
      _deaSchedule != null ||
      _hazmatClass != null ||
      _clinicalTrialShipment;

  /// Build the extension object from form data for external use
  SSCCPharmaceuticalExtension? buildExtension({int? ssccId, String? ssccCode}) {
    if (!hasData) return null;

    return _buildExtensionFromFields().copyWith(
      ssccId: ssccId ?? widget.ssccId,
      ssccCode: ssccCode ?? widget.ssccCode,
    );
  }

  SSCCPharmaceuticalExtension _buildExtensionFromFields() {
    return SSCCPharmaceuticalExtension(
      id: _extension?.id,
      ssccId: widget.ssccId,
      ssccCode: widget.ssccCode,
      coldChainRequired: _coldChainRequired,
      minTemperatureCelsius: _minTemperatureCelsiusController.text.isEmpty
          ? null
          : double.tryParse(_minTemperatureCelsiusController.text),
      maxTemperatureCelsius: _maxTemperatureCelsiusController.text.isEmpty
          ? null
          : double.tryParse(_maxTemperatureCelsiusController.text),
      temperatureMonitoringRequired: _temperatureMonitoringRequired,
      temperatureMonitoringDeviceId:
          _temperatureMonitoringDeviceIdController.text.isEmpty
              ? null
              : _temperatureMonitoringDeviceIdController.text,
      temperatureExcursionLimitMinutes:
          _temperatureExcursionLimitMinutesController.text.isEmpty
              ? null
              : int.tryParse(_temperatureExcursionLimitMinutesController.text),
      gdpCompliant: _gdpCompliant,
      gdpCertificateNumber: _gdpCertificateNumberController.text.isEmpty
          ? null
          : _gdpCertificateNumberController.text,
      gdpCertificateExpiry: _gdpCertificateExpiry,
      gdpIssuingAuthority: _gdpIssuingAuthorityController.text.isEmpty
          ? null
          : _gdpIssuingAuthorityController.text,
      whoPqsRequired: _whoPqsRequired,
      whoPqsEquipmentCode: _whoPqsEquipmentCodeController.text.isEmpty
          ? null
          : _whoPqsEquipmentCodeController.text,
      containsControlledSubstance: _containsControlledSubstance,
      deaSchedule: _deaSchedule,
      deaOrderFormNumber: _deaOrderFormNumberController.text.isEmpty
          ? null
          : _deaOrderFormNumberController.text,
      incbAuthorizationNumber: _incbAuthorizationNumberController.text.isEmpty
          ? null
          : _incbAuthorizationNumberController.text,
      narcoticTransitPermit: _narcoticTransitPermitController.text.isEmpty
          ? null
          : _narcoticTransitPermitController.text,
      hazmatClass: _hazmatClass,
      hazmatUnNumber: _hazmatUnNumberController.text.isEmpty
          ? null
          : _hazmatUnNumberController.text,
      hazmatPackingGroup: _hazmatPackingGroup,
      hazmatSpecialProvisions: _hazmatSpecialProvisionsController.text.isEmpty
          ? null
          : _hazmatSpecialProvisionsController.text,
      humidityControlled: _humidityControlled,
      minHumidityPercent: _minHumidityPercentController.text.isEmpty
          ? null
          : int.tryParse(_minHumidityPercentController.text),
      maxHumidityPercent: _maxHumidityPercentController.text.isEmpty
          ? null
          : int.tryParse(_maxHumidityPercentController.text),
      lightSensitive: _lightSensitive,
      orientationSensitive: _orientationSensitive,
      shockSensitive: _shockSensitive,
      chainOfCustodyRequired: _chainOfCustodyRequired,
      requiresSignatureOnReceipt: _requiresSignatureOnReceipt,
      requiresPharmacistVerification: _requiresPharmacistVerification,
      carrierGdpQualificationNumber:
          _carrierGdpQualificationNumberController.text.isEmpty
              ? null
              : _carrierGdpQualificationNumberController.text,
      carrierGdpQualificationExpiry: _carrierGdpQualificationExpiry,
      vehicleQualificationNumber:
          _vehicleQualificationNumberController.text.isEmpty
              ? null
              : _vehicleQualificationNumberController.text,
      vehicleLastQualificationDate: _vehicleLastQualificationDate,
      clinicalTrialShipment: _clinicalTrialShipment,
      clinicalTrialProtocolNumber:
          _clinicalTrialProtocolNumberController.text.isEmpty
              ? null
              : _clinicalTrialProtocolNumberController.text,
      irbApprovalNumber: _irbApprovalNumberController.text.isEmpty
          ? null
          : _irbApprovalNumberController.text,
      specialHandlingInstructions:
          _specialHandlingInstructionsController.text.isEmpty
              ? null
              : _specialHandlingInstructionsController.text,
      fragile: _fragile,
      doNotStack: _doNotStack,
      thisSideUp: _thisSideUp,
    );
  }

  /// Save the extension - can be called from parent widget
  Future<SSCCPharmaceuticalExtension?> saveExtension(
      int ssccId, String ssccCode) async {
    try {
      final service = Provider.of<SSCCPharmaceuticalExtensionService>(context, listen: false);
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
      debugPrint('Error saving SSCC pharmaceutical extension: $e');
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
    bool isPharmaceuticalMode = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      isPharmaceuticalMode = settings.isPharmaceuticalMode;
    } catch (e) {
      // Widget is deactivated, return empty
      return const SizedBox.shrink();
    }

    if (!isPharmaceuticalMode) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: ExpansionTile(
        collapsedBackgroundColor: const Color(0xFF121F17),
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: const Text('Pharmaceutical Extension'),
        subtitle: Text(
            _hasExtension ? 'Extension data loaded' : 'No extension data'),
        leading: const Icon(Icons.medical_services),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColdChainSection(),
                const Divider(height: 32),
                _buildGdpSection(),
                const Divider(height: 32),
                _buildControlledSubstancesSection(),
                const Divider(height: 32),
                _buildHazmatSection(),
                const Divider(height: 32),
                _buildEnvironmentalSection(),
                const Divider(height: 32),
                _buildChainOfCustodySection(),
                const Divider(height: 32),
                _buildCarrierSection(),
                const Divider(height: 32),
                _buildClinicalTrialSection(),
                const Divider(height: 32),
                _buildSpecialHandlingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColdChainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cold Chain Requirements',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Cold Chain Required'),
          subtitle: const Text('Shipment requires temperature control'),
          value: _coldChainRequired,
          onChanged: widget.isEditing
              ? (value) => setState(() => _coldChainRequired = value)
              : null,
        ),
        if (_coldChainRequired) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minTemperatureCelsiusController,
                  decoration: const InputDecoration(
                    labelText: 'Min Temperature (°C)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: widget.isEditing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxTemperatureCelsiusController,
                  decoration: const InputDecoration(
                    labelText: 'Max Temperature (°C)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: widget.isEditing,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Temperature Monitoring Required'),
            subtitle: const Text('Continuous monitoring during transport'),
            value: _temperatureMonitoringRequired,
            onChanged: widget.isEditing
                ? (value) =>
                    setState(() => _temperatureMonitoringRequired = value)
                : null,
          ),
          if (_temperatureMonitoringRequired) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _temperatureMonitoringDeviceIdController,
              decoration: const InputDecoration(
                labelText: 'Monitoring Device ID',
                hintText: 'Data logger or IoT sensor ID',
                border: OutlineInputBorder(),
              ),
              enabled: widget.isEditing,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _temperatureExcursionLimitMinutesController,
              decoration: const InputDecoration(
                labelText: 'Excursion Limit (minutes)',
                hintText: 'Max allowed time out of range',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: widget.isEditing,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildGdpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GDP (Good Distribution Practice) Compliance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('GDP Compliant'),
          subtitle: const Text('Shipment meets GDP requirements'),
          value: _gdpCompliant,
          onChanged: widget.isEditing
              ? (value) => setState(() => _gdpCompliant = value)
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _gdpCertificateNumberController,
                decoration: const InputDecoration(
                  labelText: 'GDP Certificate Number',
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
                title: const Text('Expiry'),
                subtitle: Text(_gdpCertificateExpiry != null
                    ? _gdpCertificateExpiry!.toLocal().toString().split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _gdpCertificateExpiry,
                          (date) =>
                              setState(() => _gdpCertificateExpiry = date),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _gdpIssuingAuthorityController,
          decoration: const InputDecoration(
            labelText: 'Issuing Authority',
            hintText: 'e.g., MHRA, EMA, FDA',
            border: OutlineInputBorder(),
          ),
          enabled: widget.isEditing,
          maxLength: 255,
          inputFormatters: [LengthLimitingTextInputFormatter(255)],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('WHO PQS Required'),
          subtitle: const Text('Prequalification Standard equipment required'),
          value: _whoPqsRequired,
          onChanged: widget.isEditing
              ? (value) => setState(() => _whoPqsRequired = value)
              : null,
        ),
        if (_whoPqsRequired) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _whoPqsEquipmentCodeController,
            decoration: const InputDecoration(
              labelText: 'WHO PQS Equipment Code',
              hintText: 'PQS equipment identifier',
              border: OutlineInputBorder(),
            ),
            enabled: widget.isEditing,
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
          ),
        ],
      ],
    );
  }

  Widget _buildControlledSubstancesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controlled Substances (DEA/INCB)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Contains Controlled Substance'),
          subtitle: const Text('Shipment contains DEA/INCB scheduled substances'),
          value: _containsControlledSubstance,
          onChanged: widget.isEditing
              ? (value) =>
                  setState(() => _containsControlledSubstance = value)
              : null,
        ),
        if (_containsControlledSubstance) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'DEA Schedule',
              border: OutlineInputBorder(),
            ),
            value: _deaSchedule,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Select Schedule'),
              ),
              ..._deaScheduleOptions.map((schedule) => DropdownMenuItem(
                value: schedule,
                child: Text(schedule),
              )),
            ],
            onChanged: widget.isEditing
                ? (value) => setState(() => _deaSchedule = value)
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _deaOrderFormNumberController,
            decoration: const InputDecoration(
              labelText: 'DEA Order Form Number (DEA-222)',
              border: OutlineInputBorder(),
            ),
            enabled: widget.isEditing,
            maxLength: 100,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _incbAuthorizationNumberController,
            decoration: const InputDecoration(
              labelText: 'INCB Authorization Number',
              hintText: 'International Narcotics Control Board',
              border: OutlineInputBorder(),
            ),
            enabled: widget.isEditing,
            maxLength: 100,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _narcoticTransitPermitController,
            decoration: const InputDecoration(
              labelText: 'Narcotic Transit Permit',
              border: OutlineInputBorder(),
            ),
            enabled: widget.isEditing,
            maxLength: 100,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
        ],
      ],
    );
  }

  Widget _buildHazmatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hazardous Materials',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'HAZMAT Class',
                  border: OutlineInputBorder(),
                ),
                value: _hazmatClass,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Class'),
                  ),
                  ..._hazmatClassOptions.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}'),
                  )),
                ],
                onChanged: widget.isEditing
                    ? (value) => setState(() => _hazmatClass = value)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _hazmatUnNumberController,
                decoration: const InputDecoration(
                  labelText: 'UN Number',
                  hintText: 'e.g., UN1234',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 10,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Packing Group',
                  border: OutlineInputBorder(),
                ),
                value: _hazmatPackingGroup,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Group'),
                  ),
                  ..._hazmatPackingGroupOptions.map((group) => DropdownMenuItem(
                    value: group,
                    child: Text('$group - ${group == 'I' ? 'High Danger' : group == 'II' ? 'Medium Danger' : 'Low Danger'}'),
                  )),
                ],
                onChanged: widget.isEditing
                    ? (value) => setState(() => _hazmatPackingGroup = value)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _hazmatSpecialProvisionsController,
                decoration: const InputDecoration(
                  labelText: 'Special Provisions',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.isEditing,
                maxLength: 500,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnvironmentalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environmental Controls',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Humidity Controlled'),
          subtitle: const Text('Requires humidity control'),
          value: _humidityControlled,
          onChanged: widget.isEditing
              ? (value) => setState(() => _humidityControlled = value)
              : null,
        ),
        if (_humidityControlled) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minHumidityPercentController,
                  decoration: const InputDecoration(
                    labelText: 'Min Humidity (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: widget.isEditing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxHumidityPercentController,
                  decoration: const InputDecoration(
                    labelText: 'Max Humidity (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: widget.isEditing,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Light Sensitive'),
          subtitle: const Text('Protect from light'),
          value: _lightSensitive,
          onChanged: widget.isEditing
              ? (value) => setState(() => _lightSensitive = value)
              : null,
        ),
        SwitchListTile(
          title: const Text('Orientation Sensitive'),
          subtitle: const Text('Must maintain specific orientation'),
          value: _orientationSensitive,
          onChanged: widget.isEditing
              ? (value) => setState(() => _orientationSensitive = value)
              : null,
        ),
        SwitchListTile(
          title: const Text('Shock Sensitive'),
          subtitle: const Text('Handle with care - shock sensitive'),
          value: _shockSensitive,
          onChanged: widget.isEditing
              ? (value) => setState(() => _shockSensitive = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildChainOfCustodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chain of Custody',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Chain of Custody Required'),
          subtitle: const Text('Track full custody chain'),
          value: _chainOfCustodyRequired,
          onChanged: widget.isEditing
              ? (value) => setState(() => _chainOfCustodyRequired = value)
              : null,
        ),
        SwitchListTile(
          title: const Text('Requires Signature on Receipt'),
          subtitle: const Text('Must sign upon delivery'),
          value: _requiresSignatureOnReceipt,
          onChanged: widget.isEditing
              ? (value) => setState(() => _requiresSignatureOnReceipt = value)
              : null,
        ),
        SwitchListTile(
          title: const Text('Requires Pharmacist Verification'),
          subtitle: const Text('Pharmacist must verify receipt'),
          value: _requiresPharmacistVerification,
          onChanged: widget.isEditing
              ? (value) =>
                  setState(() => _requiresPharmacistVerification = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildCarrierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carrier/Transport Qualification',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _carrierGdpQualificationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Carrier GDP Qualification Number',
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
                title: const Text('Expiry'),
                subtitle: Text(_carrierGdpQualificationExpiry != null
                    ? _carrierGdpQualificationExpiry!
                        .toLocal()
                        .toString()
                        .split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _carrierGdpQualificationExpiry,
                          (date) => setState(
                              () => _carrierGdpQualificationExpiry = date),
                        ),
                      )
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
                controller: _vehicleQualificationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Qualification Number',
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
                title: const Text('Last Qualified'),
                subtitle: Text(_vehicleLastQualificationDate != null
                    ? _vehicleLastQualificationDate!
                        .toLocal()
                        .toString()
                        .split(' ')[0]
                    : 'Not set'),
                trailing: widget.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                          context,
                          _vehicleLastQualificationDate,
                          (date) => setState(
                              () => _vehicleLastQualificationDate = date),
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

  Widget _buildClinicalTrialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical Trial Shipments',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Clinical Trial Shipment'),
          subtitle: const Text('Shipment for clinical trial'),
          value: _clinicalTrialShipment,
          onChanged: widget.isEditing
              ? (value) => setState(() => _clinicalTrialShipment = value)
              : null,
        ),
        if (_clinicalTrialShipment) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _clinicalTrialProtocolNumberController,
            decoration: const InputDecoration(
              labelText: 'Clinical Trial Protocol Number',
              border: OutlineInputBorder(),
            ),
            enabled: widget.isEditing,
            maxLength: 100,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _irbApprovalNumberController,
            decoration: const InputDecoration(
              labelText: 'IRB Approval Number',
              hintText: 'Institutional Review Board approval',
              border: OutlineInputBorder(),
            ),
            enabled: widget.isEditing,
            maxLength: 100,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialHandlingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Handling',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Fragile'),
                value: _fragile,
                onChanged: widget.isEditing
                    ? (value) => setState(() => _fragile = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Do Not Stack'),
                value: _doNotStack,
                onChanged: widget.isEditing
                    ? (value) => setState(() => _doNotStack = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('This Side Up'),
                value: _thisSideUp,
                onChanged: widget.isEditing
                    ? (value) => setState(() => _thisSideUp = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialHandlingInstructionsController,
          decoration: const InputDecoration(
            labelText: 'Special Handling Instructions',
            hintText: 'Additional handling requirements',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          enabled: widget.isEditing,
          maxLength: 1000,
          inputFormatters: [LengthLimitingTextInputFormatter(1000)],
        ),
      ],
    );
  }
}
