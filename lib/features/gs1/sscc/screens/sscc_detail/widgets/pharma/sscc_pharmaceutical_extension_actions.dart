part of 'sscc_pharmaceutical_extension_widget.dart';

extension SSCCPharmaceuticalExtensionActions
    on SSCCPharmaceuticalExtensionWidgetState {
  Future<void> _loadExtension() async {
    final hasValidSsccId = widget.ssccId != null;
    final hasValidSsccCode =
        widget.ssccCode != null && widget.ssccCode!.isNotEmpty;

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
    _setSeedOrController(
      'gdpCertificateNumber',
      ext.gdpCertificateNumber ?? '',
    );
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

    return _extensionFromFields().copyWith(
      ssccId: ssccId ?? widget.ssccId,
      ssccCode: ssccCode ?? widget.ssccCode,
    );
  }

  SSCCPharmaceuticalExtension _extensionFromFields() {
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
      vehicleQualificationNumber: _text('vehicleQualificationNumber').isEmpty
          ? null
          : _text('vehicleQualificationNumber'),
      vehicleLastQualificationDate: _vehicleLastQualificationDate,
      clinicalTrialShipment: _clinicalTrialShipment,
      clinicalTrialProtocolNumber: _text('clinicalTrialProtocolNumber').isEmpty
          ? null
          : _text('clinicalTrialProtocolNumber'),
      irbApprovalNumber: _text('irbApprovalNumber').isEmpty
          ? null
          : _text('irbApprovalNumber'),
      specialHandlingInstructions: _text('specialHandlingInstructions').isEmpty
          ? null
          : _text('specialHandlingInstructions'),
      fragile: _fragile,
      doNotStack: _doNotStack,
      thisSideUp: _thisSideUp,
    );
  }

  Future<SSCCPharmaceuticalExtension?> saveExtension(
    int ssccId,
    String ssccCode,
  ) async {
    try {
      final service = getIt<SSCCPharmaceuticalExtensionService>();
      final extensionToSave = _extensionFromFields().copyWith(
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

  Future<void> _selectDate(
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
