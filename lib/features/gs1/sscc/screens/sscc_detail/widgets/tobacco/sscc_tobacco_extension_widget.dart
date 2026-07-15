import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_tobacco_extension_service.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_tobacco_extension_model.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/skeleton/sscc_section_loading_skeleton.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_batch_tracking_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_carrier_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_eu_tpd_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_export_import_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_state_compliance_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_tax_stamp_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sections/sscc_tobacco_transport_security_section.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

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

class SSCCTobaccoExtensionWidgetState extends State<SSCCTobaccoExtensionWidget> {
  SSCCTobaccoExtension? _extension;
  bool _isLoading = true;
  bool _hasExtension = false;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _seedTexts = {};

  TextEditingController _c(String key) => _controllers.putIfAbsent(
        key,
        () => TextEditingController(text: _seedTexts[key] ?? ''),
      );

  String _text(String key) =>
      _controllers[key]?.text ?? _seedTexts[key] ?? '';

  void _setSeedOrController(String key, String value) {
    _seedTexts[key] = value;
    _controllers[key]?.text = value;
  }

  TextEditingController get _euTransportUnitIdController =>
      _c('euTransportUnitId');
  TextEditingController get _euRouteAuthorizationNumberController =>
      _c('euRouteAuthorizationNumber');
  DateTime? _euRouteAuthorizationDate;
  DateTime? _euRouteAuthorizationExpiry;
  bool _euFirstRetailOutlet = false;

  TextEditingController get _aggregatedStampCountController =>
      _c('aggregatedStampCount');
  TextEditingController get _taxStampAuthorityIdController =>
      _c('taxStampAuthorityId');

  TextEditingController get _customsDeclarationNumberController =>
      _c('customsDeclarationNumber');
  DateTime? _customsDeclarationDate;
  TextEditingController get _exportLicenseNumberController =>
      _c('exportLicenseNumber');
  DateTime? _exportLicenseDate;
  DateTime? _exportLicenseExpiry;
  TextEditingController get _importPermitNumberController =>
      _c('importPermitNumber');
  DateTime? _importPermitDate;
  String? _countryOfOrigin;
  String? _countryOfDestination;

  TextEditingController get _sealNumberController => _c('sealNumber');
  String? _sealType;
  TextEditingController get _sealedByController => _c('sealedBy');
  DateTime? _sealedDate;

  TextEditingController get _carrierLicenseNumberController =>
      _c('carrierLicenseNumber');
  TextEditingController get _carrierTobaccoPermitNumberController =>
      _c('carrierTobaccoPermitNumber');
  TextEditingController get _driverIdController => _c('driverId');
  TextEditingController get _vehicleRegistrationController =>
      _c('vehicleRegistration');

  TextEditingController get _pactActManifestNumberController =>
      _c('pactActManifestNumber');
  TextEditingController get _stateTransitPermitNumberController =>
      _c('stateTransitPermitNumber');
  String? _stateTransitPermitState;

  bool _containsMultipleBatches = false;
  TextEditingController get _primaryBatchNumberController =>
      _c('primaryBatchNumber');

  @override
  void initState() {
    super.initState();
    _loadExtension();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _seedTexts.clear();
    super.dispose();
  }

  Future<void> _loadExtension() async {
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
    _setSeedOrController('euTransportUnitId', ext.euTransportUnitId ?? '');
    _setSeedOrController(
      'euRouteAuthorizationNumber',
      ext.euRouteAuthorizationNumber ?? '',
    );
    _euRouteAuthorizationDate = ext.euRouteAuthorizationDate;
    _euRouteAuthorizationExpiry = ext.euRouteAuthorizationExpiry;
    _euFirstRetailOutlet = ext.euFirstRetailOutlet;

    _setSeedOrController(
      'taxStampAggregationLevel',
      ext.taxStampAggregationLevel ?? '',
    );
    _setSeedOrController(
      'aggregatedStampCount',
      ext.aggregatedStampCount?.toString() ?? '',
    );
    _setSeedOrController('taxStampAuthorityId', ext.taxStampAuthorityId ?? '');

    _setSeedOrController(
      'customsDeclarationNumber',
      ext.customsDeclarationNumber ?? '',
    );
    _customsDeclarationDate = ext.customsDeclarationDate;
    _setSeedOrController('exportLicenseNumber', ext.exportLicenseNumber ?? '');
    _exportLicenseDate = ext.exportLicenseDate;
    _exportLicenseExpiry = ext.exportLicenseExpiry;
    _setSeedOrController('importPermitNumber', ext.importPermitNumber ?? '');
    _importPermitDate = ext.importPermitDate;
    _countryOfOrigin = ext.countryOfOrigin;
    _countryOfDestination = ext.countryOfDestination;

    _setSeedOrController('sealNumber', ext.sealNumber ?? '');
    _sealType = ext.sealType;
    _setSeedOrController('sealedBy', ext.sealedBy ?? '');
    _sealedDate = ext.sealedDate;

    _setSeedOrController(
      'carrierLicenseNumber',
      ext.carrierLicenseNumber ?? '',
    );
    _setSeedOrController(
      'carrierTobaccoPermitNumber',
      ext.carrierTobaccoPermitNumber ?? '',
    );
    _setSeedOrController('driverId', ext.driverId ?? '');
    _setSeedOrController(
      'vehicleRegistration',
      ext.vehicleRegistration ?? '',
    );

    _setSeedOrController(
      'pactActManifestNumber',
      ext.pactActManifestNumber ?? '',
    );
    _setSeedOrController(
      'stateTransitPermitNumber',
      ext.stateTransitPermitNumber ?? '',
    );
    _stateTransitPermitState = ext.stateTransitPermitState;

    _containsMultipleBatches = ext.containsMultipleBatches;
    _setSeedOrController('primaryBatchNumber', ext.primaryBatchNumber ?? '');
  }

  bool get hasData =>
      _text('euTransportUnitId').isNotEmpty ||
      _text('euRouteAuthorizationNumber').isNotEmpty ||
      _euFirstRetailOutlet ||
      _text('taxStampAggregationLevel').isNotEmpty ||
      _text('aggregatedStampCount').isNotEmpty ||
      _text('taxStampAuthorityId').isNotEmpty ||
      _text('customsDeclarationNumber').isNotEmpty ||
      _text('exportLicenseNumber').isNotEmpty ||
      _text('sealNumber').isNotEmpty ||
      _text('carrierLicenseNumber').isNotEmpty ||
      _text('pactActManifestNumber').isNotEmpty ||
      _containsMultipleBatches ||
      _countryOfOrigin != null ||
      _countryOfDestination != null ||
      _sealType != null ||
      _stateTransitPermitState != null;

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
      euTransportUnitId: _text('euTransportUnitId').isEmpty
          ? null
          : _text('euTransportUnitId'),
      euRouteAuthorizationNumber: _text('euRouteAuthorizationNumber').isEmpty
          ? null
          : _text('euRouteAuthorizationNumber'),
      euRouteAuthorizationDate: _euRouteAuthorizationDate,
      euRouteAuthorizationExpiry: _euRouteAuthorizationExpiry,
      euFirstRetailOutlet: _euFirstRetailOutlet,
      taxStampAggregationLevel: _text('taxStampAggregationLevel').isEmpty
          ? null
          : _text('taxStampAggregationLevel'),
      aggregatedStampCount: _text('aggregatedStampCount').isEmpty
          ? null
          : int.tryParse(_text('aggregatedStampCount')),
      taxStampAuthorityId: _text('taxStampAuthorityId').isEmpty
          ? null
          : _text('taxStampAuthorityId'),
      customsDeclarationNumber: _text('customsDeclarationNumber').isEmpty
          ? null
          : _text('customsDeclarationNumber'),
      customsDeclarationDate: _customsDeclarationDate,
      exportLicenseNumber: _text('exportLicenseNumber').isEmpty
          ? null
          : _text('exportLicenseNumber'),
      exportLicenseDate: _exportLicenseDate,
      exportLicenseExpiry: _exportLicenseExpiry,
      importPermitNumber: _text('importPermitNumber').isEmpty
          ? null
          : _text('importPermitNumber'),
      importPermitDate: _importPermitDate,
      countryOfOrigin: _countryOfOrigin,
      countryOfDestination: _countryOfDestination,
      sealNumber: _text('sealNumber').isEmpty ? null : _text('sealNumber'),
      sealType: _sealType,
      sealedBy: _text('sealedBy').isEmpty ? null : _text('sealedBy'),
      sealedDate: _sealedDate,
      carrierLicenseNumber: _text('carrierLicenseNumber').isEmpty
          ? null
          : _text('carrierLicenseNumber'),
      carrierTobaccoPermitNumber: _text('carrierTobaccoPermitNumber').isEmpty
          ? null
          : _text('carrierTobaccoPermitNumber'),
      driverId: _text('driverId').isEmpty ? null : _text('driverId'),
      vehicleRegistration: _text('vehicleRegistration').isEmpty
          ? null
          : _text('vehicleRegistration'),
      pactActManifestNumber: _text('pactActManifestNumber').isEmpty
          ? null
          : _text('pactActManifestNumber'),
      stateTransitPermitNumber: _text('stateTransitPermitNumber').isEmpty
          ? null
          : _text('stateTransitPermitNumber'),
      stateTransitPermitState: _stateTransitPermitState,
      containsMultipleBatches: _containsMultipleBatches,
      primaryBatchNumber: _text('primaryBatchNumber').isEmpty
          ? null
          : _text('primaryBatchNumber'),
    );
  }

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
    bool isTobaccoMode = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      isTobaccoMode = settings.isTobaccoMode;
    } catch (e) {
      return const SizedBox.shrink();
    }

    if (!isTobaccoMode) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const SsccSectionLoadingSkeleton(fieldCount: 2);
    }

    return Card(
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.brown.shade700,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: const Text('Tobacco Extension'),
        subtitle: Text(_hasExtension ? 'Extension data loaded' : 'No extension data'),
        leading: TraqIcon(NavIcons.shipping),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SsccTobaccoEuTpdSection(
                  isEditing: widget.isEditing,
                  euTransportUnitIdController: _euTransportUnitIdController,
                  euRouteAuthorizationNumberController:
                      _euRouteAuthorizationNumberController,
                  euRouteAuthorizationDate: _euRouteAuthorizationDate,
                  onEuRouteAuthorizationDateTap: widget.isEditing
                      ? () => _selectDate(
                            context,
                            _euRouteAuthorizationDate,
                            (date) => setState(
                                () => _euRouteAuthorizationDate = date),
                          )
                      : null,
                  euRouteAuthorizationExpiry: _euRouteAuthorizationExpiry,
                  onEuRouteAuthorizationExpiryTap: widget.isEditing
                      ? () => _selectDate(
                            context,
                            _euRouteAuthorizationExpiry,
                            (date) => setState(
                                () => _euRouteAuthorizationExpiry = date),
                          )
                      : null,
                  euFirstRetailOutlet: _euFirstRetailOutlet,
                  onEuFirstRetailOutletChanged: (value) =>
                      setState(() => _euFirstRetailOutlet = value),
                ),
                const Divider(height: 32),
                SsccTobaccoTaxStampSection(
                  isEditing: widget.isEditing,
                  taxStampAggregationLevel:
                      _text('taxStampAggregationLevel').isEmpty
                          ? null
                          : _text('taxStampAggregationLevel'),
                  onTaxStampAggregationLevelChanged: (value) => setState(
                    () => _setSeedOrController(
                      'taxStampAggregationLevel',
                      value ?? '',
                    ),
                  ),
                  aggregatedStampCountController:
                      _aggregatedStampCountController,
                  taxStampAuthorityIdController: _taxStampAuthorityIdController,
                ),
                const Divider(height: 32),
                SsccTobaccoExportImportSection(
                  isEditing: widget.isEditing,
                  customsDeclarationNumberController:
                      _customsDeclarationNumberController,
                  customsDeclarationDate: _customsDeclarationDate,
                  onCustomsDeclarationDateTap: widget.isEditing
                      ? () => _selectDate(
                            context,
                            _customsDeclarationDate,
                            (date) =>
                                setState(() => _customsDeclarationDate = date),
                          )
                      : null,
                  exportLicenseNumberController: _exportLicenseNumberController,
                  importPermitNumberController: _importPermitNumberController,
                  countryOfOrigin: _countryOfOrigin,
                  onCountryOfOriginChanged: (value) =>
                      setState(() => _countryOfOrigin = value),
                  countryOfDestination: _countryOfDestination,
                  onCountryOfDestinationChanged: (value) =>
                      setState(() => _countryOfDestination = value),
                ),
                const Divider(height: 32),
                SsccTobaccoTransportSecuritySection(
                  isEditing: widget.isEditing,
                  sealNumberController: _sealNumberController,
                  sealType: _sealType,
                  onSealTypeChanged: (value) =>
                      setState(() => _sealType = value),
                  sealedByController: _sealedByController,
                  sealedDate: _sealedDate,
                  onSealedDateTap: widget.isEditing
                      ? () => _selectDate(
                            context,
                            _sealedDate,
                            (date) => setState(() => _sealedDate = date),
                          )
                      : null,
                ),
                const Divider(height: 32),
                SsccTobaccoCarrierSection(
                  isEditing: widget.isEditing,
                  carrierLicenseNumberController:
                      _carrierLicenseNumberController,
                  carrierTobaccoPermitNumberController:
                      _carrierTobaccoPermitNumberController,
                  driverIdController: _driverIdController,
                  vehicleRegistrationController:
                      _vehicleRegistrationController,
                ),
                const Divider(height: 32),
                SsccTobaccoStateComplianceSection(
                  isEditing: widget.isEditing,
                  pactActManifestNumberController:
                      _pactActManifestNumberController,
                  stateTransitPermitNumberController:
                      _stateTransitPermitNumberController,
                  stateTransitPermitState: _stateTransitPermitState,
                  onStateTransitPermitStateChanged: (value) =>
                      setState(() => _stateTransitPermitState = value),
                ),
                const Divider(height: 32),
                SsccTobaccoBatchTrackingSection(
                  isEditing: widget.isEditing,
                  containsMultipleBatches: _containsMultipleBatches,
                  onContainsMultipleBatchesChanged: (value) =>
                      setState(() => _containsMultipleBatches = value),
                  primaryBatchNumberController: _primaryBatchNumberController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
