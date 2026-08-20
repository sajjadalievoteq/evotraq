import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_carrier_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_chain_of_custody_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_clinical_trial_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_cold_chain_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_controlled_substances_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_environmental_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_gdp_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_hazmat_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma_sections/sscc_pharma_special_handling_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/skeleton/sscc_section_loading_skeleton.dart';

import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_actions.dart';

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
  SSCCPharmaceuticalExtension? extension;
  bool isLoading = true;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _seedTexts = {};

  TextEditingController _c(String key) => _controllers.putIfAbsent(
    key,
    () => TextEditingController(text: _seedTexts[key] ?? ''),
  );

  String text(String key) => _controllers[key]?.text ?? _seedTexts[key] ?? '';

  void setSeedOrController(String key, String value) {
    _seedTexts[key] = value;
    _controllers[key]?.text = value;
  }

  bool coldChainRequired = false;
  TextEditingController get _minTemperatureCelsiusController =>
      _c('minTemperatureCelsius');
  TextEditingController get _maxTemperatureCelsiusController =>
      _c('maxTemperatureCelsius');
  bool temperatureMonitoringRequired = false;
  TextEditingController get _temperatureMonitoringDeviceIdController =>
      _c('temperatureMonitoringDeviceId');
  TextEditingController get _temperatureExcursionLimitMinutesController =>
      _c('temperatureExcursionLimitMinutes');

  bool gdpCompliant = true;
  TextEditingController get _gdpCertificateNumberController =>
      _c('gdpCertificateNumber');
  DateTime? gdpCertificateExpiry;
  TextEditingController get _gdpIssuingAuthorityController =>
      _c('gdpIssuingAuthority');

  bool whoPqsRequired = false;
  TextEditingController get _whoPqsEquipmentCodeController =>
      _c('whoPqsEquipmentCode');

  bool containsControlledSubstance = false;
  String? deaSchedule;
  TextEditingController get _deaOrderFormNumberController =>
      _c('deaOrderFormNumber');
  TextEditingController get _incbAuthorizationNumberController =>
      _c('incbAuthorizationNumber');
  TextEditingController get _narcoticTransitPermitController =>
      _c('narcoticTransitPermit');

  String? hazmatClass;
  TextEditingController get _hazmatUnNumberController => _c('hazmatUnNumber');
  String? hazmatPackingGroup;
  TextEditingController get _hazmatSpecialProvisionsController =>
      _c('hazmatSpecialProvisions');

  bool humidityControlled = false;
  TextEditingController get _minHumidityPercentController =>
      _c('minHumidityPercent');
  TextEditingController get _maxHumidityPercentController =>
      _c('maxHumidityPercent');
  bool lightSensitive = false;
  bool orientationSensitive = false;
  bool shockSensitive = false;

  bool chainOfCustodyRequired = false;
  bool requiresSignatureOnReceipt = false;
  bool requiresPharmacistVerification = false;

  TextEditingController get _carrierGdpQualificationNumberController =>
      _c('carrierGdpQualificationNumber');
  DateTime? carrierGdpQualificationExpiry;
  TextEditingController get _vehicleQualificationNumberController =>
      _c('vehicleQualificationNumber');
  DateTime? vehicleLastQualificationDate;

  bool clinicalTrialShipment = false;
  TextEditingController get _clinicalTrialProtocolNumberController =>
      _c('clinicalTrialProtocolNumber');
  TextEditingController get _irbApprovalNumberController =>
      _c('irbApprovalNumber');

  TextEditingController get _specialHandlingInstructionsController =>
      _c('specialHandlingInstructions');
  bool fragile = false;
  bool doNotStack = false;
  bool thisSideUp = false;

  @override
  void initState() {
    super.initState();
    loadExtension();
  }

  @override
  void didUpdateWidget(covariant SSCCPharmaceuticalExtensionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ssccId != oldWidget.ssccId ||
        widget.ssccCode != oldWidget.ssccCode) {
      loadExtension();
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

    if (isLoading) {
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
          coldChainRequired: coldChainRequired,
          onColdChainRequiredChanged: (value) =>
              setState(() => coldChainRequired = value),
          minTemperatureCelsiusController: _minTemperatureCelsiusController,
          maxTemperatureCelsiusController: _maxTemperatureCelsiusController,
          temperatureMonitoringRequired: temperatureMonitoringRequired,
          onTemperatureMonitoringRequiredChanged: (value) =>
              setState(() => temperatureMonitoringRequired = value),
          temperatureMonitoringDeviceIdController:
              _temperatureMonitoringDeviceIdController,
          temperatureExcursionLimitMinutesController:
              _temperatureExcursionLimitMinutesController,
        ),
        SsccPharmaGdpSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          gdpCompliant: gdpCompliant,
          onGdpCompliantChanged: (value) =>
              setState(() => gdpCompliant = value),
          gdpCertificateNumberController: _gdpCertificateNumberController,
          gdpCertificateExpiry: gdpCertificateExpiry,
          onGdpCertificateExpiryTap: widget.isEditing
              ? () => selectDate(
                  context,
                  gdpCertificateExpiry,
                  (date) => setState(() => gdpCertificateExpiry = date),
                )
              : null,
          gdpIssuingAuthorityController: _gdpIssuingAuthorityController,
          whoPqsRequired: whoPqsRequired,
          onWhoPqsRequiredChanged: (value) =>
              setState(() => whoPqsRequired = value),
          whoPqsEquipmentCodeController: _whoPqsEquipmentCodeController,
        ),
        SsccPharmaControlledSubstancesSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          containsControlledSubstance: containsControlledSubstance,
          onContainsControlledSubstanceChanged: (value) =>
              setState(() => containsControlledSubstance = value),
          deaSchedule: deaSchedule,
          onDeaScheduleChanged: (value) => setState(() => deaSchedule = value),
          deaOrderFormNumberController: _deaOrderFormNumberController,
          incbAuthorizationNumberController: _incbAuthorizationNumberController,
          narcoticTransitPermitController: _narcoticTransitPermitController,
        ),
        SsccPharmaHazmatSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          hazmatClass: hazmatClass,
          onHazmatClassChanged: (value) => setState(() => hazmatClass = value),
          hazmatUnNumberController: _hazmatUnNumberController,
          hazmatPackingGroup: hazmatPackingGroup,
          onHazmatPackingGroupChanged: (value) =>
              setState(() => hazmatPackingGroup = value),
          hazmatSpecialProvisionsController: _hazmatSpecialProvisionsController,
        ),
        SsccPharmaEnvironmentalSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          humidityControlled: humidityControlled,
          onHumidityControlledChanged: (value) =>
              setState(() => humidityControlled = value),
          minHumidityPercentController: _minHumidityPercentController,
          maxHumidityPercentController: _maxHumidityPercentController,
          lightSensitive: lightSensitive,
          onLightSensitiveChanged: (value) =>
              setState(() => lightSensitive = value),
          orientationSensitive: orientationSensitive,
          onOrientationSensitiveChanged: (value) =>
              setState(() => orientationSensitive = value),
          shockSensitive: shockSensitive,
          onShockSensitiveChanged: (value) =>
              setState(() => shockSensitive = value),
        ),
        SsccPharmaChainOfCustodySection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          chainOfCustodyRequired: chainOfCustodyRequired,
          onChainOfCustodyRequiredChanged: (value) =>
              setState(() => chainOfCustodyRequired = value),
          requiresSignatureOnReceipt: requiresSignatureOnReceipt,
          onRequiresSignatureOnReceiptChanged: (value) =>
              setState(() => requiresSignatureOnReceipt = value),
          requiresPharmacistVerification: requiresPharmacistVerification,
          onRequiresPharmacistVerificationChanged: (value) =>
              setState(() => requiresPharmacistVerification = value),
        ),
        SsccPharmaCarrierSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          carrierGdpQualificationNumberController:
              _carrierGdpQualificationNumberController,
          carrierGdpQualificationExpiry: carrierGdpQualificationExpiry,
          onCarrierGdpQualificationExpiryTap: widget.isEditing
              ? () => selectDate(
                  context,
                  carrierGdpQualificationExpiry,
                  (date) =>
                      setState(() => carrierGdpQualificationExpiry = date),
                )
              : null,
          vehicleQualificationNumberController:
              _vehicleQualificationNumberController,
          vehicleLastQualificationDate: vehicleLastQualificationDate,
          onVehicleLastQualificationDateTap: widget.isEditing
              ? () => selectDate(
                  context,
                  vehicleLastQualificationDate,
                  (date) =>
                      setState(() => vehicleLastQualificationDate = date),
                )
              : null,
        ),
        SsccPharmaClinicalTrialSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          clinicalTrialShipment: clinicalTrialShipment,
          onClinicalTrialShipmentChanged: (value) =>
              setState(() => clinicalTrialShipment = value),
          clinicalTrialProtocolNumberController:
              _clinicalTrialProtocolNumberController,
          irbApprovalNumberController: _irbApprovalNumberController,
        ),
        SsccPharmaSpecialHandlingSection(
          outlineColor: outline,
          isEditing: widget.isEditing,
          fragile: fragile,
          onFragileChanged: (value) => setState(() => fragile = value),
          doNotStack: doNotStack,
          onDoNotStackChanged: (value) => setState(() => doNotStack = value),
          thisSideUp: thisSideUp,
          onThisSideUpChanged: (value) => setState(() => thisSideUp = value),
          specialHandlingInstructionsController:
              _specialHandlingInstructionsController,
        ),
      ],
    );
  }

  Color _outlineColor(BuildContext context) =>
      widget.borderColor ?? Theme.of(context).colorScheme.outlineVariant;
}
