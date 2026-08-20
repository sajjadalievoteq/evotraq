import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_widget.dart';

extension SSCCPharmaceuticalExtensionActions
    on SSCCPharmaceuticalExtensionWidgetState {
  Future<void> loadExtension() async {
    final hasValidSsccId = widget.ssccId != null;
    final hasValidSsccCode =
        widget.ssccCode != null && widget.ssccCode!.isNotEmpty;

    if (!hasValidSsccId && !hasValidSsccCode) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final service = getIt<SSCCPharmaceuticalExtensionService>();
      SSCCPharmaceuticalExtension? loadedExtension;

      if (hasValidSsccId) {
        loadedExtension = await service.getBySsccId(widget.ssccId!);
      } else if (hasValidSsccCode) {
        loadedExtension = await service.getBySsccCode(widget.ssccCode!);
      }

      if (mounted) {
        setState(() {
          extension = loadedExtension;
          isLoading = false;
          if (loadedExtension != null) {
            _populateFields(loadedExtension);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _populateFields(SSCCPharmaceuticalExtension ext) {
    coldChainRequired = ext.coldChainRequired;
    setSeedOrController(
      'minTemperatureCelsius',
      ext.minTemperatureCelsius?.toString() ?? '',
    );
    setSeedOrController(
      'maxTemperatureCelsius',
      ext.maxTemperatureCelsius?.toString() ?? '',
    );
    temperatureMonitoringRequired = ext.temperatureMonitoringRequired;
    setSeedOrController(
      'temperatureMonitoringDeviceId',
      ext.temperatureMonitoringDeviceId ?? '',
    );
    setSeedOrController(
      'temperatureExcursionLimitMinutes',
      ext.temperatureExcursionLimitMinutes?.toString() ?? '',
    );

    gdpCompliant = ext.gdpCompliant;
    setSeedOrController('gdpCertificateNumber', ext.gdpCertificateNumber ?? '');
    gdpCertificateExpiry = ext.gdpCertificateExpiry;
    setSeedOrController('gdpIssuingAuthority', ext.gdpIssuingAuthority ?? '');

    whoPqsRequired = ext.whoPqsRequired;
    setSeedOrController('whoPqsEquipmentCode', ext.whoPqsEquipmentCode ?? '');

    containsControlledSubstance = ext.containsControlledSubstance;
    deaSchedule = ext.deaSchedule;
    setSeedOrController('deaOrderFormNumber', ext.deaOrderFormNumber ?? '');
    setSeedOrController(
      'incbAuthorizationNumber',
      ext.incbAuthorizationNumber ?? '',
    );
    setSeedOrController(
      'narcoticTransitPermit',
      ext.narcoticTransitPermit ?? '',
    );

    hazmatClass = ext.hazmatClass;
    setSeedOrController('hazmatUnNumber', ext.hazmatUnNumber ?? '');
    hazmatPackingGroup = ext.hazmatPackingGroup;
    setSeedOrController(
      'hazmatSpecialProvisions',
      ext.hazmatSpecialProvisions ?? '',
    );

    humidityControlled = ext.humidityControlled;
    setSeedOrController(
      'minHumidityPercent',
      ext.minHumidityPercent?.toString() ?? '',
    );
    setSeedOrController(
      'maxHumidityPercent',
      ext.maxHumidityPercent?.toString() ?? '',
    );
    lightSensitive = ext.lightSensitive;
    orientationSensitive = ext.orientationSensitive;
    shockSensitive = ext.shockSensitive;

    chainOfCustodyRequired = ext.chainOfCustodyRequired;
    requiresSignatureOnReceipt = ext.requiresSignatureOnReceipt;
    requiresPharmacistVerification = ext.requiresPharmacistVerification;

    setSeedOrController(
      'carrierGdpQualificationNumber',
      ext.carrierGdpQualificationNumber ?? '',
    );
    carrierGdpQualificationExpiry = ext.carrierGdpQualificationExpiry;
    setSeedOrController(
      'vehicleQualificationNumber',
      ext.vehicleQualificationNumber ?? '',
    );
    vehicleLastQualificationDate = ext.vehicleLastQualificationDate;

    clinicalTrialShipment = ext.clinicalTrialShipment;
    setSeedOrController(
      'clinicalTrialProtocolNumber',
      ext.clinicalTrialProtocolNumber ?? '',
    );
    setSeedOrController('irbApprovalNumber', ext.irbApprovalNumber ?? '');

    setSeedOrController(
      'specialHandlingInstructions',
      ext.specialHandlingInstructions ?? '',
    );
    fragile = ext.fragile;
    doNotStack = ext.doNotStack;
    thisSideUp = ext.thisSideUp;
  }

  bool get hasData =>
      coldChainRequired ||
      text('minTemperatureCelsius').isNotEmpty ||
      text('maxTemperatureCelsius').isNotEmpty ||
      temperatureMonitoringRequired ||
      gdpCompliant ||
      text('gdpCertificateNumber').isNotEmpty ||
      whoPqsRequired ||
      containsControlledSubstance ||
      deaSchedule != null ||
      hazmatClass != null ||
      clinicalTrialShipment;

  SSCCPharmaceuticalExtension? buildExtension({int? ssccId, String? ssccCode}) {
    if (!hasData) return null;

    return extensionFromFields().copyWith(
      ssccId: ssccId ?? widget.ssccId,
      ssccCode: ssccCode ?? widget.ssccCode,
    );
  }

  SSCCPharmaceuticalExtension extensionFromFields() {
    return SSCCPharmaceuticalExtension(
      id: extension?.id,
      ssccId: widget.ssccId,
      ssccCode: widget.ssccCode,
      coldChainRequired: coldChainRequired,
      minTemperatureCelsius: text('minTemperatureCelsius').isEmpty
          ? null
          : double.tryParse(text('minTemperatureCelsius')),
      maxTemperatureCelsius: text('maxTemperatureCelsius').isEmpty
          ? null
          : double.tryParse(text('maxTemperatureCelsius')),
      temperatureMonitoringRequired: temperatureMonitoringRequired,
      temperatureMonitoringDeviceId:
          text('temperatureMonitoringDeviceId').isEmpty
          ? null
          : text('temperatureMonitoringDeviceId'),
      temperatureExcursionLimitMinutes:
          text('temperatureExcursionLimitMinutes').isEmpty
          ? null
          : int.tryParse(text('temperatureExcursionLimitMinutes')),
      gdpCompliant: gdpCompliant,
      gdpCertificateNumber: text('gdpCertificateNumber').isEmpty
          ? null
          : text('gdpCertificateNumber'),
      gdpCertificateExpiry: gdpCertificateExpiry,
      gdpIssuingAuthority: text('gdpIssuingAuthority').isEmpty
          ? null
          : text('gdpIssuingAuthority'),
      whoPqsRequired: whoPqsRequired,
      whoPqsEquipmentCode: text('whoPqsEquipmentCode').isEmpty
          ? null
          : text('whoPqsEquipmentCode'),
      containsControlledSubstance: containsControlledSubstance,
      deaSchedule: deaSchedule,
      deaOrderFormNumber: text('deaOrderFormNumber').isEmpty
          ? null
          : text('deaOrderFormNumber'),
      incbAuthorizationNumber: text('incbAuthorizationNumber').isEmpty
          ? null
          : text('incbAuthorizationNumber'),
      narcoticTransitPermit: text('narcoticTransitPermit').isEmpty
          ? null
          : text('narcoticTransitPermit'),
      hazmatClass: hazmatClass,
      hazmatUnNumber: text('hazmatUnNumber').isEmpty
          ? null
          : text('hazmatUnNumber'),
      hazmatPackingGroup: hazmatPackingGroup,
      hazmatSpecialProvisions: text('hazmatSpecialProvisions').isEmpty
          ? null
          : text('hazmatSpecialProvisions'),
      humidityControlled: humidityControlled,
      minHumidityPercent: text('minHumidityPercent').isEmpty
          ? null
          : int.tryParse(text('minHumidityPercent')),
      maxHumidityPercent: text('maxHumidityPercent').isEmpty
          ? null
          : int.tryParse(text('maxHumidityPercent')),
      lightSensitive: lightSensitive,
      orientationSensitive: orientationSensitive,
      shockSensitive: shockSensitive,
      chainOfCustodyRequired: chainOfCustodyRequired,
      requiresSignatureOnReceipt: requiresSignatureOnReceipt,
      requiresPharmacistVerification: requiresPharmacistVerification,
      carrierGdpQualificationNumber:
          text('carrierGdpQualificationNumber').isEmpty
          ? null
          : text('carrierGdpQualificationNumber'),
      carrierGdpQualificationExpiry: carrierGdpQualificationExpiry,
      vehicleQualificationNumber: text('vehicleQualificationNumber').isEmpty
          ? null
          : text('vehicleQualificationNumber'),
      vehicleLastQualificationDate: vehicleLastQualificationDate,
      clinicalTrialShipment: clinicalTrialShipment,
      clinicalTrialProtocolNumber: text('clinicalTrialProtocolNumber').isEmpty
          ? null
          : text('clinicalTrialProtocolNumber'),
      irbApprovalNumber: text('irbApprovalNumber').isEmpty
          ? null
          : text('irbApprovalNumber'),
      specialHandlingInstructions: text('specialHandlingInstructions').isEmpty
          ? null
          : text('specialHandlingInstructions'),
      fragile: fragile,
      doNotStack: doNotStack,
      thisSideUp: thisSideUp,
    );
  }

  Future<SSCCPharmaceuticalExtension?> saveExtension(
    int ssccId,
    String ssccCode,
  ) async {
    try {
      final service = getIt<SSCCPharmaceuticalExtensionService>();
      final extensionToSave = extensionFromFields().copyWith(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );

      final saved = await service.saveBySsccId(ssccId, extensionToSave);

      if (mounted) {
        setState(() {
          extension = saved;
        });
      }

      widget.onSaved?.call(saved);
      return saved;
    } catch (e) {
      debugPrint('Error saving SSCC pharmaceutical extension: $e');
      return null;
    }
  }

  Future<void> selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onSelected,
  ) async {
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
}
