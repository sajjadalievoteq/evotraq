import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_carrier_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_chain_of_custody_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_clinical_trial_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_cold_chain_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_controlled_substances_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_environmental_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_gdp_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_hazmat_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sections/sscc_pharma_special_handling_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/skeleton/sscc_section_loading_skeleton.dart';

class SSCCPharmaceuticalExtensionWidget extends StatefulWidget {
  final int? ssccId;
  final String? ssccCode;
  final bool isEditing;
  final Color? borderColor;
  final Function(SSCCPharmaceuticalExtension?)? onSaved;

  const SSCCPharmaceuticalExtensionWidget({
    Key? key,
    this.ssccId,
    this.ssccCode,
    this.isEditing = false,
    this.borderColor,
    this.onSaved,
  }) : super(key: key);

  @override
  State<SSCCPharmaceuticalExtensionWidget> createState() =>
      SSCCPharmaceuticalExtensionWidgetState();
}

class SSCCPharmaceuticalExtensionWidgetState
    extends State<SSCCPharmaceuticalExtensionWidget> {
  SSCCPharmaceuticalExtension? _extension;
  bool _isLoading = true;

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

  bool _coldChainRequired = false;
  TextEditingController get _minTemperatureCelsiusController =>
      _c('minTemperatureCelsius');
  TextEditingController get _maxTemperatureCelsiusController =>
      _c('maxTemperatureCelsius');
  bool _temperatureMonitoringRequired = false;
  TextEditingController get _temperatureMonitoringDeviceIdController =>
      _c('temperatureMonitoringDeviceId');
  TextEditingController get _temperatureExcursionLimitMinutesController =>
      _c('temperatureExcursionLimitMinutes');

  bool _gdpCompliant = true;
  TextEditingController get _gdpCertificateNumberController =>
      _c('gdpCertificateNumber');
  DateTime? _gdpCertificateExpiry;
  TextEditingController get _gdpIssuingAuthorityController =>
      _c('gdpIssuingAuthority');

  bool _whoPqsRequired = false;
  TextEditingController get _whoPqsEquipmentCodeController =>
      _c('whoPqsEquipmentCode');

  bool _containsControlledSubstance = false;
  String? _deaSchedule;
  TextEditingController get _deaOrderFormNumberController =>
      _c('deaOrderFormNumber');
  TextEditingController get _incbAuthorizationNumberController =>
      _c('incbAuthorizationNumber');
  TextEditingController get _narcoticTransitPermitController =>
      _c('narcoticTransitPermit');

  String? _hazmatClass;
  TextEditingController get _hazmatUnNumberController => _c('hazmatUnNumber');
  String? _hazmatPackingGroup;
  TextEditingController get _hazmatSpecialProvisionsController =>
      _c('hazmatSpecialProvisions');

  bool _humidityControlled = false;
  TextEditingController get _minHumidityPercentController =>
      _c('minHumidityPercent');
  TextEditingController get _maxHumidityPercentController =>
      _c('maxHumidityPercent');
  bool _lightSensitive = false;
  bool _orientationSensitive = false;
  bool _shockSensitive = false;

  bool _chainOfCustodyRequired = false;
  bool _requiresSignatureOnReceipt = false;
  bool _requiresPharmacistVerification = false;

  TextEditingController get _carrierGdpQualificationNumberController =>
      _c('carrierGdpQualificationNumber');
  DateTime? _carrierGdpQualificationExpiry;
  TextEditingController get _vehicleQualificationNumberController =>
      _c('vehicleQualificationNumber');
  DateTime? _vehicleLastQualificationDate;

  bool _clinicalTrialShipment = false;
  TextEditingController get _clinicalTrialProtocolNumberController =>
      _c('clinicalTrialProtocolNumber');
  TextEditingController get _irbApprovalNumberController =>
      _c('irbApprovalNumber');

  TextEditingController get _specialHandlingInstructionsController =>
      _c('specialHandlingInstructions');
  bool _fragile = false;
  bool _doNotStack = false;
  bool _thisSideUp = false;

  @override
  void initState() {
    super.initState();
    _loadExtension();
  }

  @override
  void didUpdateWidget(covariant SSCCPharmaceuticalExtensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ssccId != oldWidget.ssccId ||
        widget.ssccCode != oldWidget.ssccCode) {
      _loadExtension();
    }
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
        });
      }
      return;
    }

    try {
      final service = getIt<SSCCPharmaceuticalExtensionService>();
      SSCCPharmaceuticalExtension? extension;

      if (hasValidSsccId) {
        extension = await service.getBySsccId(widget.ssccId!);
      } else if (hasValidSsccCode) {
        extension = await service.getBySsccCode(widget.ssccCode!);
      }

      if (mounted) {
        setState(() {
          _extension = extension;
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
        });
      }
    }
  }

  void _populateFields(SSCCPharmaceuticalExtension ext) {
    _coldChainRequired = ext.coldChainRequired;
    _setSeedOrController(
      'minTemperatureCelsius',
      ext.minTemperatureCelsius?.toString() ?? '',
    );
    _setSeedOrController(
      'maxTemperatureCelsius',
      ext.maxTemperatureCelsius?.toString() ?? '',
    );
    _temperatureMonitoringRequired = ext.temperatureMonitoringRequired;
    _setSeedOrController(
      'temperatureMonitoringDeviceId',
      ext.temperatureMonitoringDeviceId ?? '',
    );
    _setSeedOrController(
      'temperatureExcursionLimitMinutes',
      ext.temperatureExcursionLimitMinutes?.toString() ?? '',
    );

    _gdpCompliant = ext.gdpCompliant;
    _setSeedOrController('gdpCertificateNumber', ext.gdpCertificateNumber ?? '');
    _gdpCertificateExpiry = ext.gdpCertificateExpiry;
    _setSeedOrController('gdpIssuingAuthority', ext.gdpIssuingAuthority ?? '');

    _whoPqsRequired = ext.whoPqsRequired;
    _setSeedOrController('whoPqsEquipmentCode', ext.whoPqsEquipmentCode ?? '');

    _containsControlledSubstance = ext.containsControlledSubstance;
    _deaSchedule = ext.deaSchedule;
    _setSeedOrController('deaOrderFormNumber', ext.deaOrderFormNumber ?? '');
    _setSeedOrController(
      'incbAuthorizationNumber',
      ext.incbAuthorizationNumber ?? '',
    );
    _setSeedOrController(
      'narcoticTransitPermit',
      ext.narcoticTransitPermit ?? '',
    );

    _hazmatClass = ext.hazmatClass;
    _setSeedOrController('hazmatUnNumber', ext.hazmatUnNumber ?? '');
    _hazmatPackingGroup = ext.hazmatPackingGroup;
    _setSeedOrController(
      'hazmatSpecialProvisions',
      ext.hazmatSpecialProvisions ?? '',
    );

    _humidityControlled = ext.humidityControlled;
    _setSeedOrController(
      'minHumidityPercent',
      ext.minHumidityPercent?.toString() ?? '',
    );
    _setSeedOrController(
      'maxHumidityPercent',
      ext.maxHumidityPercent?.toString() ?? '',
    );
    _lightSensitive = ext.lightSensitive;
    _orientationSensitive = ext.orientationSensitive;
    _shockSensitive = ext.shockSensitive;

    _chainOfCustodyRequired = ext.chainOfCustodyRequired;
    _requiresSignatureOnReceipt = ext.requiresSignatureOnReceipt;
    _requiresPharmacistVerification = ext.requiresPharmacistVerification;

    _setSeedOrController(
      'carrierGdpQualificationNumber',
      ext.carrierGdpQualificationNumber ?? '',
    );
    _carrierGdpQualificationExpiry = ext.carrierGdpQualificationExpiry;
    _setSeedOrController(
      'vehicleQualificationNumber',
      ext.vehicleQualificationNumber ?? '',
    );
    _vehicleLastQualificationDate = ext.vehicleLastQualificationDate;

    _clinicalTrialShipment = ext.clinicalTrialShipment;
    _setSeedOrController(
      'clinicalTrialProtocolNumber',
      ext.clinicalTrialProtocolNumber ?? '',
    );
    _setSeedOrController('irbApprovalNumber', ext.irbApprovalNumber ?? '');

    _setSeedOrController(
      'specialHandlingInstructions',
      ext.specialHandlingInstructions ?? '',
    );
    _fragile = ext.fragile;
    _doNotStack = ext.doNotStack;
    _thisSideUp = ext.thisSideUp;
  }

  bool get hasData =>
      _coldChainRequired ||
      _text('minTemperatureCelsius').isNotEmpty ||
      _text('maxTemperatureCelsius').isNotEmpty ||
      _temperatureMonitoringRequired ||
      _gdpCompliant ||
      _text('gdpCertificateNumber').isNotEmpty ||
      _whoPqsRequired ||
      _containsControlledSubstance ||
      _deaSchedule != null ||
      _hazmatClass != null ||
      _clinicalTrialShipment;

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
      minTemperatureCelsius: _text('minTemperatureCelsius').isEmpty
          ? null
          : double.tryParse(_text('minTemperatureCelsius')),
      maxTemperatureCelsius: _text('maxTemperatureCelsius').isEmpty
          ? null
          : double.tryParse(_text('maxTemperatureCelsius')),
      temperatureMonitoringRequired: _temperatureMonitoringRequired,
      temperatureMonitoringDeviceId:
          _text('temperatureMonitoringDeviceId').isEmpty
              ? null
              : _text('temperatureMonitoringDeviceId'),
      temperatureExcursionLimitMinutes:
          _text('temperatureExcursionLimitMinutes').isEmpty
              ? null
              : int.tryParse(_text('temperatureExcursionLimitMinutes')),
      gdpCompliant: _gdpCompliant,
      gdpCertificateNumber: _text('gdpCertificateNumber').isEmpty
          ? null
          : _text('gdpCertificateNumber'),
      gdpCertificateExpiry: _gdpCertificateExpiry,
      gdpIssuingAuthority: _text('gdpIssuingAuthority').isEmpty
          ? null
          : _text('gdpIssuingAuthority'),
      whoPqsRequired: _whoPqsRequired,
      whoPqsEquipmentCode: _text('whoPqsEquipmentCode').isEmpty
          ? null
          : _text('whoPqsEquipmentCode'),
      containsControlledSubstance: _containsControlledSubstance,
      deaSchedule: _deaSchedule,
      deaOrderFormNumber: _text('deaOrderFormNumber').isEmpty
          ? null
          : _text('deaOrderFormNumber'),
      incbAuthorizationNumber: _text('incbAuthorizationNumber').isEmpty
          ? null
          : _text('incbAuthorizationNumber'),
      narcoticTransitPermit: _text('narcoticTransitPermit').isEmpty
          ? null
          : _text('narcoticTransitPermit'),
      hazmatClass: _hazmatClass,
      hazmatUnNumber: _text('hazmatUnNumber').isEmpty
          ? null
          : _text('hazmatUnNumber'),
      hazmatPackingGroup: _hazmatPackingGroup,
      hazmatSpecialProvisions: _text('hazmatSpecialProvisions').isEmpty
          ? null
          : _text('hazmatSpecialProvisions'),
      humidityControlled: _humidityControlled,
      minHumidityPercent: _text('minHumidityPercent').isEmpty
          ? null
          : int.tryParse(_text('minHumidityPercent')),
      maxHumidityPercent: _text('maxHumidityPercent').isEmpty
          ? null
          : int.tryParse(_text('maxHumidityPercent')),
      lightSensitive: _lightSensitive,
      orientationSensitive: _orientationSensitive,
      shockSensitive: _shockSensitive,
      chainOfCustodyRequired: _chainOfCustodyRequired,
      requiresSignatureOnReceipt: _requiresSignatureOnReceipt,
      requiresPharmacistVerification: _requiresPharmacistVerification,
      carrierGdpQualificationNumber:
          _text('carrierGdpQualificationNumber').isEmpty
              ? null
              : _text('carrierGdpQualificationNumber'),
      carrierGdpQualificationExpiry: _carrierGdpQualificationExpiry,
      vehicleQualificationNumber:
          _text('vehicleQualificationNumber').isEmpty
              ? null
              : _text('vehicleQualificationNumber'),
      vehicleLastQualificationDate: _vehicleLastQualificationDate,
      clinicalTrialShipment: _clinicalTrialShipment,
      clinicalTrialProtocolNumber:
          _text('clinicalTrialProtocolNumber').isEmpty
              ? null
              : _text('clinicalTrialProtocolNumber'),
      irbApprovalNumber: _text('irbApprovalNumber').isEmpty
          ? null
          : _text('irbApprovalNumber'),
      specialHandlingInstructions:
          _text('specialHandlingInstructions').isEmpty
              ? null
              : _text('specialHandlingInstructions'),
      fragile: _fragile,
      doNotStack: _doNotStack,
      thisSideUp: _thisSideUp,
    );
  }

  Future<SSCCPharmaceuticalExtension?> saveExtension(
      int ssccId, String ssccCode) async {
    try {
      final service = getIt<SSCCPharmaceuticalExtensionService>();
      final extensionToSave = _buildExtensionFromFields().copyWith(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );

      final saved = await service.saveBySsccId(ssccId, extensionToSave);

      if (mounted) {
        setState(() {
          _extension = saved;
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
    bool isPharmaceuticalMode = false;
    try {
      final settings = context.read<SystemSettingsCubit>().state.settings;
      isPharmaceuticalMode = settings.isPharmaceuticalMode;
    } catch (e) {
      return const SizedBox.shrink();
    }

    if (!isPharmaceuticalMode) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const SsccSectionLoadingSkeleton(fieldCount: 3);
    }

    final outline = _outlineColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pharmaceutical Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        SsccPharmaColdChainSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          coldChainRequired: _coldChainRequired,
          onColdChainRequiredChanged: (value) =>
              setState(() => _coldChainRequired = value),
          minTemperatureCelsiusController: _minTemperatureCelsiusController,
          maxTemperatureCelsiusController: _maxTemperatureCelsiusController,
          temperatureMonitoringRequired: _temperatureMonitoringRequired,
          onTemperatureMonitoringRequiredChanged: (value) =>
              setState(() => _temperatureMonitoringRequired = value),
          temperatureMonitoringDeviceIdController:
              _temperatureMonitoringDeviceIdController,
          temperatureExcursionLimitMinutesController:
              _temperatureExcursionLimitMinutesController,
        ),
        SsccPharmaGdpSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          gdpCompliant: _gdpCompliant,
          onGdpCompliantChanged: (value) =>
              setState(() => _gdpCompliant = value),
          gdpCertificateNumberController: _gdpCertificateNumberController,
          gdpCertificateExpiry: _gdpCertificateExpiry,
          onGdpCertificateExpiryTap: widget.isEditing
              ? () => _selectDate(
                    context,
                    _gdpCertificateExpiry,
                    (date) => setState(() => _gdpCertificateExpiry = date),
                  )
              : null,
          gdpIssuingAuthorityController: _gdpIssuingAuthorityController,
          whoPqsRequired: _whoPqsRequired,
          onWhoPqsRequiredChanged: (value) =>
              setState(() => _whoPqsRequired = value),
          whoPqsEquipmentCodeController: _whoPqsEquipmentCodeController,
        ),
        SsccPharmaControlledSubstancesSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          containsControlledSubstance: _containsControlledSubstance,
          onContainsControlledSubstanceChanged: (value) =>
              setState(() => _containsControlledSubstance = value),
          deaSchedule: _deaSchedule,
          onDeaScheduleChanged: (value) =>
              setState(() => _deaSchedule = value),
          deaOrderFormNumberController: _deaOrderFormNumberController,
          incbAuthorizationNumberController: _incbAuthorizationNumberController,
          narcoticTransitPermitController: _narcoticTransitPermitController,
        ),
        SsccPharmaHazmatSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          hazmatClass: _hazmatClass,
          onHazmatClassChanged: (value) =>
              setState(() => _hazmatClass = value),
          hazmatUnNumberController: _hazmatUnNumberController,
          hazmatPackingGroup: _hazmatPackingGroup,
          onHazmatPackingGroupChanged: (value) =>
              setState(() => _hazmatPackingGroup = value),
          hazmatSpecialProvisionsController: _hazmatSpecialProvisionsController,
        ),
        SsccPharmaEnvironmentalSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          humidityControlled: _humidityControlled,
          onHumidityControlledChanged: (value) =>
              setState(() => _humidityControlled = value),
          minHumidityPercentController: _minHumidityPercentController,
          maxHumidityPercentController: _maxHumidityPercentController,
          lightSensitive: _lightSensitive,
          onLightSensitiveChanged: (value) =>
              setState(() => _lightSensitive = value),
          orientationSensitive: _orientationSensitive,
          onOrientationSensitiveChanged: (value) =>
              setState(() => _orientationSensitive = value),
          shockSensitive: _shockSensitive,
          onShockSensitiveChanged: (value) =>
              setState(() => _shockSensitive = value),
        ),
        SsccPharmaChainOfCustodySection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          chainOfCustodyRequired: _chainOfCustodyRequired,
          onChainOfCustodyRequiredChanged: (value) =>
              setState(() => _chainOfCustodyRequired = value),
          requiresSignatureOnReceipt: _requiresSignatureOnReceipt,
          onRequiresSignatureOnReceiptChanged: (value) =>
              setState(() => _requiresSignatureOnReceipt = value),
          requiresPharmacistVerification: _requiresPharmacistVerification,
          onRequiresPharmacistVerificationChanged: (value) =>
              setState(() => _requiresPharmacistVerification = value),
        ),
        SsccPharmaCarrierSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          carrierGdpQualificationNumberController:
              _carrierGdpQualificationNumberController,
          carrierGdpQualificationExpiry: _carrierGdpQualificationExpiry,
          onCarrierGdpQualificationExpiryTap: widget.isEditing
              ? () => _selectDate(
                    context,
                    _carrierGdpQualificationExpiry,
                    (date) =>
                        setState(() => _carrierGdpQualificationExpiry = date),
                  )
              : null,
          vehicleQualificationNumberController:
              _vehicleQualificationNumberController,
          vehicleLastQualificationDate: _vehicleLastQualificationDate,
          onVehicleLastQualificationDateTap: widget.isEditing
              ? () => _selectDate(
                    context,
                    _vehicleLastQualificationDate,
                    (date) =>
                        setState(() => _vehicleLastQualificationDate = date),
                  )
              : null,
        ),
        SsccPharmaClinicalTrialSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          clinicalTrialShipment: _clinicalTrialShipment,
          onClinicalTrialShipmentChanged: (value) =>
              setState(() => _clinicalTrialShipment = value),
          clinicalTrialProtocolNumberController:
              _clinicalTrialProtocolNumberController,
          irbApprovalNumberController: _irbApprovalNumberController,
        ),
        SsccPharmaSpecialHandlingSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          fragile: _fragile,
          onFragileChanged: (value) => setState(() => _fragile = value),
          doNotStack: _doNotStack,
          onDoNotStackChanged: (value) => setState(() => _doNotStack = value),
          thisSideUp: _thisSideUp,
          onThisSideUpChanged: (value) => setState(() => _thisSideUp = value),
          specialHandlingInstructionsController:
              _specialHandlingInstructionsController,
        ),
      ],
    );
  }

  Color _outlineColor(BuildContext context) =>
      widget.borderColor ?? Theme.of(context).colorScheme.outlineVariant;
}
