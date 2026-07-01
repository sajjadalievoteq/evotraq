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
import 'package:traqtrace_app/core/config/app_assets.dart';

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

  final _euTransportUnitIdController = TextEditingController();
  final _euRouteAuthorizationNumberController = TextEditingController();
  DateTime? _euRouteAuthorizationDate;
  DateTime? _euRouteAuthorizationExpiry;
  bool _euFirstRetailOutlet = false;

  final _taxStampAggregationLevelController = TextEditingController();
  final _aggregatedStampCountController = TextEditingController();
  final _taxStampAuthorityIdController = TextEditingController();

  final _customsDeclarationNumberController = TextEditingController();
  DateTime? _customsDeclarationDate;
  final _exportLicenseNumberController = TextEditingController();
  DateTime? _exportLicenseDate;
  DateTime? _exportLicenseExpiry;
  final _importPermitNumberController = TextEditingController();
  DateTime? _importPermitDate;
  String? _countryOfOrigin;
  String? _countryOfDestination;

  final _sealNumberController = TextEditingController();
  String? _sealType;
  final _sealedByController = TextEditingController();
  DateTime? _sealedDate;

  final _carrierLicenseNumberController = TextEditingController();
  final _carrierTobaccoPermitNumberController = TextEditingController();
  final _driverIdController = TextEditingController();
  final _vehicleRegistrationController = TextEditingController();

  final _pactActManifestNumberController = TextEditingController();
  final _stateTransitPermitNumberController = TextEditingController();
  String? _stateTransitPermitState;

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
        leading: TraqIcon(AppAssets.iconShipment),
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
                      _taxStampAggregationLevelController.text.isEmpty
                          ? null
                          : _taxStampAggregationLevelController.text,
                  onTaxStampAggregationLevelChanged: (value) => setState(
                    () => _taxStampAggregationLevelController.text =
                        value ?? '',
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
