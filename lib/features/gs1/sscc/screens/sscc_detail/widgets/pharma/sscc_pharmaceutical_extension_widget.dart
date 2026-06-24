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
  bool _hasExtension = false;

  bool _coldChainRequired = false;
  final _minTemperatureCelsiusController = TextEditingController();
  final _maxTemperatureCelsiusController = TextEditingController();
  bool _temperatureMonitoringRequired = false;
  final _temperatureMonitoringDeviceIdController = TextEditingController();
  final _temperatureExcursionLimitMinutesController = TextEditingController();

  bool _gdpCompliant = true;
  final _gdpCertificateNumberController = TextEditingController();
  DateTime? _gdpCertificateExpiry;
  final _gdpIssuingAuthorityController = TextEditingController();

  bool _whoPqsRequired = false;
  final _whoPqsEquipmentCodeController = TextEditingController();

  bool _containsControlledSubstance = false;
  String? _deaSchedule;
  final _deaOrderFormNumberController = TextEditingController();
  final _incbAuthorizationNumberController = TextEditingController();
  final _narcoticTransitPermitController = TextEditingController();

  String? _hazmatClass;
  final _hazmatUnNumberController = TextEditingController();
  String? _hazmatPackingGroup;
  final _hazmatSpecialProvisionsController = TextEditingController();

  bool _humidityControlled = false;
  final _minHumidityPercentController = TextEditingController();
  final _maxHumidityPercentController = TextEditingController();
  bool _lightSensitive = false;
  bool _orientationSensitive = false;
  bool _shockSensitive = false;

  bool _chainOfCustodyRequired = false;
  bool _requiresSignatureOnReceipt = false;
  bool _requiresPharmacistVerification = false;

  final _carrierGdpQualificationNumberController = TextEditingController();
  DateTime? _carrierGdpQualificationExpiry;
  final _vehicleQualificationNumberController = TextEditingController();
  DateTime? _vehicleLastQualificationDate;

  bool _clinicalTrialShipment = false;
  final _clinicalTrialProtocolNumberController = TextEditingController();
  final _irbApprovalNumberController = TextEditingController();

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
  void didUpdateWidget(covariant SSCCPharmaceuticalExtensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ssccId != oldWidget.ssccId ||
        widget.ssccCode != oldWidget.ssccCode) {
      _loadExtension();
    }
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
