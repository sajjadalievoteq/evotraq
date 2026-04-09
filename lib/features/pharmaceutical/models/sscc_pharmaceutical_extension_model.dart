import 'package:equatable/equatable.dart';

/// SSCC Pharmaceutical Extension model
/// Based on GDP, cold chain, controlled substances, and
/// pharmaceutical logistics regulatory compliance
class SSCCPharmaceuticalExtension extends Equatable {
  final int? id;
  final int? ssccId;
  final String? ssccCode;

  // Cold Chain Requirements
  final bool coldChainRequired;
  final double? minTemperatureCelsius;
  final double? maxTemperatureCelsius;
  final bool temperatureMonitoringRequired;
  final String? temperatureMonitoringDeviceId;
  final int? temperatureExcursionLimitMinutes;

  // GDP (Good Distribution Practice) Compliance
  final bool gdpCompliant;
  final String? gdpCertificateNumber;
  final DateTime? gdpCertificateExpiry;
  final String? gdpIssuingAuthority;

  // WHO PQS (Prequalified) Requirements
  final bool whoPqsRequired;
  final String? whoPqsEquipmentCode;

  // Controlled Substances (DEA/INCB)
  final bool containsControlledSubstance;
  final String? deaSchedule;
  final String? deaOrderFormNumber;
  final String? incbAuthorizationNumber;
  final String? narcoticTransitPermit;

  // Hazardous Materials
  final String? hazmatClass;
  final String? hazmatUnNumber;
  final String? hazmatPackingGroup;
  final String? hazmatSpecialProvisions;

  // Environmental Controls
  final bool humidityControlled;
  final int? minHumidityPercent;
  final int? maxHumidityPercent;
  final bool lightSensitive;
  final bool orientationSensitive;
  final bool shockSensitive;

  // Chain of Custody
  final bool chainOfCustodyRequired;
  final bool requiresSignatureOnReceipt;
  final bool requiresPharmacistVerification;

  // Carrier/Transport Qualification
  final String? carrierGdpQualificationNumber;
  final DateTime? carrierGdpQualificationExpiry;
  final String? vehicleQualificationNumber;
  final DateTime? vehicleLastQualificationDate;

  // Clinical Trial Shipments
  final bool clinicalTrialShipment;
  final String? clinicalTrialProtocolNumber;
  final String? irbApprovalNumber;

  // Special Handling
  final String? specialHandlingInstructions;
  final bool fragile;
  final bool doNotStack;
  final bool thisSideUp;

  // Audit Fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SSCCPharmaceuticalExtension({
    this.id,
    this.ssccId,
    this.ssccCode,
    this.coldChainRequired = false,
    this.minTemperatureCelsius,
    this.maxTemperatureCelsius,
    this.temperatureMonitoringRequired = false,
    this.temperatureMonitoringDeviceId,
    this.temperatureExcursionLimitMinutes,
    this.gdpCompliant = true,
    this.gdpCertificateNumber,
    this.gdpCertificateExpiry,
    this.gdpIssuingAuthority,
    this.whoPqsRequired = false,
    this.whoPqsEquipmentCode,
    this.containsControlledSubstance = false,
    this.deaSchedule,
    this.deaOrderFormNumber,
    this.incbAuthorizationNumber,
    this.narcoticTransitPermit,
    this.hazmatClass,
    this.hazmatUnNumber,
    this.hazmatPackingGroup,
    this.hazmatSpecialProvisions,
    this.humidityControlled = false,
    this.minHumidityPercent,
    this.maxHumidityPercent,
    this.lightSensitive = false,
    this.orientationSensitive = false,
    this.shockSensitive = false,
    this.chainOfCustodyRequired = false,
    this.requiresSignatureOnReceipt = false,
    this.requiresPharmacistVerification = false,
    this.carrierGdpQualificationNumber,
    this.carrierGdpQualificationExpiry,
    this.vehicleQualificationNumber,
    this.vehicleLastQualificationDate,
    this.clinicalTrialShipment = false,
    this.clinicalTrialProtocolNumber,
    this.irbApprovalNumber,
    this.specialHandlingInstructions,
    this.fragile = false,
    this.doNotStack = false,
    this.thisSideUp = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SSCCPharmaceuticalExtension.fromJson(Map<String, dynamic> json) {
    return SSCCPharmaceuticalExtension(
      id: json['id'],
      ssccId: json['ssccId'],
      ssccCode: json['ssccCode'],
      coldChainRequired: json['coldChainRequired'] ?? false,
      minTemperatureCelsius: json['minTemperatureCelsius'] != null
          ? (json['minTemperatureCelsius'] as num).toDouble()
          : null,
      maxTemperatureCelsius: json['maxTemperatureCelsius'] != null
          ? (json['maxTemperatureCelsius'] as num).toDouble()
          : null,
      temperatureMonitoringRequired:
          json['temperatureMonitoringRequired'] ?? false,
      temperatureMonitoringDeviceId: json['temperatureMonitoringDeviceId'],
      temperatureExcursionLimitMinutes: json['temperatureExcursionLimitMinutes'],
      gdpCompliant: json['gdpCompliant'] ?? true,
      gdpCertificateNumber: json['gdpCertificateNumber'],
      gdpCertificateExpiry: json['gdpCertificateExpiry'] != null
          ? DateTime.parse(json['gdpCertificateExpiry'])
          : null,
      gdpIssuingAuthority: json['gdpIssuingAuthority'],
      whoPqsRequired: json['whoPqsRequired'] ?? false,
      whoPqsEquipmentCode: json['whoPqsEquipmentCode'],
      containsControlledSubstance: json['containsControlledSubstance'] ?? false,
      deaSchedule: json['deaSchedule'],
      deaOrderFormNumber: json['deaOrderFormNumber'],
      incbAuthorizationNumber: json['incbAuthorizationNumber'],
      narcoticTransitPermit: json['narcoticTransitPermit'],
      hazmatClass: json['hazmatClass'],
      hazmatUnNumber: json['hazmatUnNumber'],
      hazmatPackingGroup: json['hazmatPackingGroup'],
      hazmatSpecialProvisions: json['hazmatSpecialProvisions'],
      humidityControlled: json['humidityControlled'] ?? false,
      minHumidityPercent: json['minHumidityPercent'],
      maxHumidityPercent: json['maxHumidityPercent'],
      lightSensitive: json['lightSensitive'] ?? false,
      orientationSensitive: json['orientationSensitive'] ?? false,
      shockSensitive: json['shockSensitive'] ?? false,
      chainOfCustodyRequired: json['chainOfCustodyRequired'] ?? false,
      requiresSignatureOnReceipt: json['requiresSignatureOnReceipt'] ?? false,
      requiresPharmacistVerification:
          json['requiresPharmacistVerification'] ?? false,
      carrierGdpQualificationNumber: json['carrierGdpQualificationNumber'],
      carrierGdpQualificationExpiry: json['carrierGdpQualificationExpiry'] != null
          ? DateTime.parse(json['carrierGdpQualificationExpiry'])
          : null,
      vehicleQualificationNumber: json['vehicleQualificationNumber'],
      vehicleLastQualificationDate: json['vehicleLastQualificationDate'] != null
          ? DateTime.parse(json['vehicleLastQualificationDate'])
          : null,
      clinicalTrialShipment: json['clinicalTrialShipment'] ?? false,
      clinicalTrialProtocolNumber: json['clinicalTrialProtocolNumber'],
      irbApprovalNumber: json['irbApprovalNumber'],
      specialHandlingInstructions: json['specialHandlingInstructions'],
      fragile: json['fragile'] ?? false,
      doNotStack: json['doNotStack'] ?? false,
      thisSideUp: json['thisSideUp'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ssccId != null) 'ssccId': ssccId,
      if (ssccCode != null) 'ssccCode': ssccCode,
      'coldChainRequired': coldChainRequired,
      if (minTemperatureCelsius != null)
        'minTemperatureCelsius': minTemperatureCelsius,
      if (maxTemperatureCelsius != null)
        'maxTemperatureCelsius': maxTemperatureCelsius,
      'temperatureMonitoringRequired': temperatureMonitoringRequired,
      if (temperatureMonitoringDeviceId != null)
        'temperatureMonitoringDeviceId': temperatureMonitoringDeviceId,
      if (temperatureExcursionLimitMinutes != null)
        'temperatureExcursionLimitMinutes': temperatureExcursionLimitMinutes,
      'gdpCompliant': gdpCompliant,
      if (gdpCertificateNumber != null)
        'gdpCertificateNumber': gdpCertificateNumber,
      if (gdpCertificateExpiry != null)
        'gdpCertificateExpiry':
            gdpCertificateExpiry!.toIso8601String().split('T').first,
      if (gdpIssuingAuthority != null)
        'gdpIssuingAuthority': gdpIssuingAuthority,
      'whoPqsRequired': whoPqsRequired,
      if (whoPqsEquipmentCode != null)
        'whoPqsEquipmentCode': whoPqsEquipmentCode,
      'containsControlledSubstance': containsControlledSubstance,
      if (deaSchedule != null) 'deaSchedule': deaSchedule,
      if (deaOrderFormNumber != null) 'deaOrderFormNumber': deaOrderFormNumber,
      if (incbAuthorizationNumber != null)
        'incbAuthorizationNumber': incbAuthorizationNumber,
      if (narcoticTransitPermit != null)
        'narcoticTransitPermit': narcoticTransitPermit,
      if (hazmatClass != null) 'hazmatClass': hazmatClass,
      if (hazmatUnNumber != null) 'hazmatUnNumber': hazmatUnNumber,
      if (hazmatPackingGroup != null) 'hazmatPackingGroup': hazmatPackingGroup,
      if (hazmatSpecialProvisions != null)
        'hazmatSpecialProvisions': hazmatSpecialProvisions,
      'humidityControlled': humidityControlled,
      if (minHumidityPercent != null) 'minHumidityPercent': minHumidityPercent,
      if (maxHumidityPercent != null) 'maxHumidityPercent': maxHumidityPercent,
      'lightSensitive': lightSensitive,
      'orientationSensitive': orientationSensitive,
      'shockSensitive': shockSensitive,
      'chainOfCustodyRequired': chainOfCustodyRequired,
      'requiresSignatureOnReceipt': requiresSignatureOnReceipt,
      'requiresPharmacistVerification': requiresPharmacistVerification,
      if (carrierGdpQualificationNumber != null)
        'carrierGdpQualificationNumber': carrierGdpQualificationNumber,
      if (carrierGdpQualificationExpiry != null)
        'carrierGdpQualificationExpiry':
            carrierGdpQualificationExpiry!.toIso8601String().split('T').first,
      if (vehicleQualificationNumber != null)
        'vehicleQualificationNumber': vehicleQualificationNumber,
      if (vehicleLastQualificationDate != null)
        'vehicleLastQualificationDate':
            vehicleLastQualificationDate!.toIso8601String().split('T').first,
      'clinicalTrialShipment': clinicalTrialShipment,
      if (clinicalTrialProtocolNumber != null)
        'clinicalTrialProtocolNumber': clinicalTrialProtocolNumber,
      if (irbApprovalNumber != null) 'irbApprovalNumber': irbApprovalNumber,
      if (specialHandlingInstructions != null)
        'specialHandlingInstructions': specialHandlingInstructions,
      'fragile': fragile,
      'doNotStack': doNotStack,
      'thisSideUp': thisSideUp,
    };
  }

  SSCCPharmaceuticalExtension copyWith({
    int? id,
    int? ssccId,
    String? ssccCode,
    bool? coldChainRequired,
    double? minTemperatureCelsius,
    double? maxTemperatureCelsius,
    bool? temperatureMonitoringRequired,
    String? temperatureMonitoringDeviceId,
    int? temperatureExcursionLimitMinutes,
    bool? gdpCompliant,
    String? gdpCertificateNumber,
    DateTime? gdpCertificateExpiry,
    String? gdpIssuingAuthority,
    bool? whoPqsRequired,
    String? whoPqsEquipmentCode,
    bool? containsControlledSubstance,
    String? deaSchedule,
    String? deaOrderFormNumber,
    String? incbAuthorizationNumber,
    String? narcoticTransitPermit,
    String? hazmatClass,
    String? hazmatUnNumber,
    String? hazmatPackingGroup,
    String? hazmatSpecialProvisions,
    bool? humidityControlled,
    int? minHumidityPercent,
    int? maxHumidityPercent,
    bool? lightSensitive,
    bool? orientationSensitive,
    bool? shockSensitive,
    bool? chainOfCustodyRequired,
    bool? requiresSignatureOnReceipt,
    bool? requiresPharmacistVerification,
    String? carrierGdpQualificationNumber,
    DateTime? carrierGdpQualificationExpiry,
    String? vehicleQualificationNumber,
    DateTime? vehicleLastQualificationDate,
    bool? clinicalTrialShipment,
    String? clinicalTrialProtocolNumber,
    String? irbApprovalNumber,
    String? specialHandlingInstructions,
    bool? fragile,
    bool? doNotStack,
    bool? thisSideUp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SSCCPharmaceuticalExtension(
      id: id ?? this.id,
      ssccId: ssccId ?? this.ssccId,
      ssccCode: ssccCode ?? this.ssccCode,
      coldChainRequired: coldChainRequired ?? this.coldChainRequired,
      minTemperatureCelsius:
          minTemperatureCelsius ?? this.minTemperatureCelsius,
      maxTemperatureCelsius:
          maxTemperatureCelsius ?? this.maxTemperatureCelsius,
      temperatureMonitoringRequired:
          temperatureMonitoringRequired ?? this.temperatureMonitoringRequired,
      temperatureMonitoringDeviceId:
          temperatureMonitoringDeviceId ?? this.temperatureMonitoringDeviceId,
      temperatureExcursionLimitMinutes: temperatureExcursionLimitMinutes ??
          this.temperatureExcursionLimitMinutes,
      gdpCompliant: gdpCompliant ?? this.gdpCompliant,
      gdpCertificateNumber: gdpCertificateNumber ?? this.gdpCertificateNumber,
      gdpCertificateExpiry: gdpCertificateExpiry ?? this.gdpCertificateExpiry,
      gdpIssuingAuthority: gdpIssuingAuthority ?? this.gdpIssuingAuthority,
      whoPqsRequired: whoPqsRequired ?? this.whoPqsRequired,
      whoPqsEquipmentCode: whoPqsEquipmentCode ?? this.whoPqsEquipmentCode,
      containsControlledSubstance:
          containsControlledSubstance ?? this.containsControlledSubstance,
      deaSchedule: deaSchedule ?? this.deaSchedule,
      deaOrderFormNumber: deaOrderFormNumber ?? this.deaOrderFormNumber,
      incbAuthorizationNumber:
          incbAuthorizationNumber ?? this.incbAuthorizationNumber,
      narcoticTransitPermit:
          narcoticTransitPermit ?? this.narcoticTransitPermit,
      hazmatClass: hazmatClass ?? this.hazmatClass,
      hazmatUnNumber: hazmatUnNumber ?? this.hazmatUnNumber,
      hazmatPackingGroup: hazmatPackingGroup ?? this.hazmatPackingGroup,
      hazmatSpecialProvisions:
          hazmatSpecialProvisions ?? this.hazmatSpecialProvisions,
      humidityControlled: humidityControlled ?? this.humidityControlled,
      minHumidityPercent: minHumidityPercent ?? this.minHumidityPercent,
      maxHumidityPercent: maxHumidityPercent ?? this.maxHumidityPercent,
      lightSensitive: lightSensitive ?? this.lightSensitive,
      orientationSensitive: orientationSensitive ?? this.orientationSensitive,
      shockSensitive: shockSensitive ?? this.shockSensitive,
      chainOfCustodyRequired:
          chainOfCustodyRequired ?? this.chainOfCustodyRequired,
      requiresSignatureOnReceipt:
          requiresSignatureOnReceipt ?? this.requiresSignatureOnReceipt,
      requiresPharmacistVerification:
          requiresPharmacistVerification ?? this.requiresPharmacistVerification,
      carrierGdpQualificationNumber:
          carrierGdpQualificationNumber ?? this.carrierGdpQualificationNumber,
      carrierGdpQualificationExpiry:
          carrierGdpQualificationExpiry ?? this.carrierGdpQualificationExpiry,
      vehicleQualificationNumber:
          vehicleQualificationNumber ?? this.vehicleQualificationNumber,
      vehicleLastQualificationDate:
          vehicleLastQualificationDate ?? this.vehicleLastQualificationDate,
      clinicalTrialShipment:
          clinicalTrialShipment ?? this.clinicalTrialShipment,
      clinicalTrialProtocolNumber:
          clinicalTrialProtocolNumber ?? this.clinicalTrialProtocolNumber,
      irbApprovalNumber: irbApprovalNumber ?? this.irbApprovalNumber,
      specialHandlingInstructions:
          specialHandlingInstructions ?? this.specialHandlingInstructions,
      fragile: fragile ?? this.fragile,
      doNotStack: doNotStack ?? this.doNotStack,
      thisSideUp: thisSideUp ?? this.thisSideUp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ssccId,
        ssccCode,
        coldChainRequired,
        minTemperatureCelsius,
        maxTemperatureCelsius,
        temperatureMonitoringRequired,
        temperatureMonitoringDeviceId,
        temperatureExcursionLimitMinutes,
        gdpCompliant,
        gdpCertificateNumber,
        gdpCertificateExpiry,
        gdpIssuingAuthority,
        whoPqsRequired,
        whoPqsEquipmentCode,
        containsControlledSubstance,
        deaSchedule,
        deaOrderFormNumber,
        incbAuthorizationNumber,
        narcoticTransitPermit,
        hazmatClass,
        hazmatUnNumber,
        hazmatPackingGroup,
        hazmatSpecialProvisions,
        humidityControlled,
        minHumidityPercent,
        maxHumidityPercent,
        lightSensitive,
        orientationSensitive,
        shockSensitive,
        chainOfCustodyRequired,
        requiresSignatureOnReceipt,
        requiresPharmacistVerification,
        carrierGdpQualificationNumber,
        carrierGdpQualificationExpiry,
        vehicleQualificationNumber,
        vehicleLastQualificationDate,
        clinicalTrialShipment,
        clinicalTrialProtocolNumber,
        irbApprovalNumber,
        specialHandlingInstructions,
        fragile,
        doNotStack,
        thisSideUp,
        createdAt,
        updatedAt,
      ];
}

/// DEA schedule types
enum DEASchedule {
  scheduleI('I'),
  scheduleII('II'),
  scheduleIII('III'),
  scheduleIV('IV'),
  scheduleV('V');

  const DEASchedule(this.code);
  final String code;
}

/// Hazmat class types
enum HazmatClass {
  class1('1', 'Explosives'),
  class2('2', 'Gases'),
  class3('3', 'Flammable Liquids'),
  class4('4', 'Flammable Solids'),
  class5('5', 'Oxidizers'),
  class6('6', 'Toxic/Infectious'),
  class7('7', 'Radioactive'),
  class8('8', 'Corrosives'),
  class9('9', 'Miscellaneous');

  const HazmatClass(this.code, this.description);
  final String code;
  final String description;
}
