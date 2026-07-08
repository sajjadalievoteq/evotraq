import 'package:equatable/equatable.dart';

class SensorMeasurement extends Equatable {
  final String type;
  
  final double? value;
  
  final String? unitOfMeasure;
  
  final String? component;
  
  final String? stringValue;
  
  final bool? booleanValue;
  
  final String? hexBinaryValue;
  
  final String? uriValue;
  
  final double? minValue;
  
  final double? maxValue;
  
  final double? meanValue;
  
  final double? standardDeviation;
  
  final double? perceptionAccuracy;
  
  final DateTime? measurementTime;
  
  final String? microorganism;
  
  final String? chemistryValue;

  const SensorMeasurement({
    required this.type,
    this.value,
    this.unitOfMeasure,
    this.component,
    this.stringValue,
    this.booleanValue,
    this.hexBinaryValue,
    this.uriValue,
    this.minValue,
    this.maxValue,
    this.meanValue,
    this.standardDeviation,
    this.perceptionAccuracy,
    this.measurementTime,
    this.microorganism,
    this.chemistryValue,
  });

  SensorMeasurement copyWith({
    String? type,
    double? value,
    String? unitOfMeasure,
    String? component,
    String? stringValue,
    bool? booleanValue,
    String? hexBinaryValue,
    String? uriValue,
    double? minValue,
    double? maxValue,
    double? meanValue,
    double? standardDeviation,
    double? perceptionAccuracy,
    DateTime? measurementTime,
    String? microorganism,
    String? chemistryValue,
  }) {
    return SensorMeasurement(
      type: type ?? this.type,
      value: value ?? this.value,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      component: component ?? this.component,
      stringValue: stringValue ?? this.stringValue,
      booleanValue: booleanValue ?? this.booleanValue,
      hexBinaryValue: hexBinaryValue ?? this.hexBinaryValue,
      uriValue: uriValue ?? this.uriValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      meanValue: meanValue ?? this.meanValue,
      standardDeviation: standardDeviation ?? this.standardDeviation,
      perceptionAccuracy: perceptionAccuracy ?? this.perceptionAccuracy,
      measurementTime: measurementTime ?? this.measurementTime,
      microorganism: microorganism ?? this.microorganism,
      chemistryValue: chemistryValue ?? this.chemistryValue,
    );
  }

  factory SensorMeasurement.fromJson(Map<String, dynamic> json) {
    return SensorMeasurement(
      type: json['type'] ?? 'unknown',
      value: json['value'] != null ? double.tryParse(json['value'].toString()) : null,
      unitOfMeasure: json['unitOfMeasure'],
      component: json['component'],
      stringValue: json['stringValue'],
      booleanValue: json['booleanValue'] != null ? 
        json['booleanValue'] is bool ? json['booleanValue'] : 
        json['booleanValue'].toString().toLowerCase() == 'true' : null,
      hexBinaryValue: json['hexBinaryValue'],
      uriValue: json['uriValue'],
      minValue: json['minValue'] != null ? double.tryParse(json['minValue'].toString()) : null,
      maxValue: json['maxValue'] != null ? double.tryParse(json['maxValue'].toString()) : null,
      meanValue: json['meanValue'] != null ? double.tryParse(json['meanValue'].toString()) : null,
      standardDeviation: json['standardDeviation'] != null ? 
        double.tryParse(json['standardDeviation'].toString()) : null,
      perceptionAccuracy: json['perceptionAccuracy'] != null ? 
        double.tryParse(json['perceptionAccuracy'].toString()) : null,
      measurementTime: json['measurementTime'] != null ? 
        DateTime.tryParse(json['measurementTime'].toString()) : null,
      microorganism: json['microorganism'],
      chemistryValue: json['chemistryValue'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    data['type'] = type;
    if (value != null) data['value'] = value;
    if (unitOfMeasure != null) data['unitOfMeasure'] = unitOfMeasure;
    if (component != null) data['component'] = component;
    if (stringValue != null) data['stringValue'] = stringValue;
    if (booleanValue != null) data['booleanValue'] = booleanValue;
    if (hexBinaryValue != null) data['hexBinaryValue'] = hexBinaryValue;
    if (uriValue != null) data['uriValue'] = uriValue;
    if (minValue != null) data['minValue'] = minValue;
    if (maxValue != null) data['maxValue'] = maxValue;
    if (meanValue != null) data['meanValue'] = meanValue;
    if (standardDeviation != null) data['standardDeviation'] = standardDeviation;
    if (perceptionAccuracy != null) data['perceptionAccuracy'] = perceptionAccuracy;
    if (measurementTime != null) data['measurementTime'] = measurementTime!.toIso8601String();
    if (microorganism != null) data['microorganism'] = microorganism;
    if (chemistryValue != null) data['chemistryValue'] = chemistryValue;
    
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (value != null) 'value': value,
      if (unitOfMeasure != null) 'unitOfMeasure': unitOfMeasure,
      if (component != null) 'component': component,
      if (stringValue != null) 'stringValue': stringValue,
      if (booleanValue != null) 'booleanValue': booleanValue,
      if (hexBinaryValue != null) 'hexBinaryValue': hexBinaryValue,
      if (uriValue != null) 'uriValue': uriValue,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (meanValue != null) 'meanValue': meanValue,
      if (standardDeviation != null) 'sdValue': standardDeviation,
      if (perceptionAccuracy != null) 'percValue': perceptionAccuracy,
      if (chemistryValue != null) 'chemicalSubstance': chemistryValue,
      if (microorganism != null) 'microorganism': microorganism,
    };
  }
  
  static SensorMeasurement fromMap(Map<String, dynamic> map) {
    return SensorMeasurement(
      type: map['type'],
      value: map['value']?.toDouble(),
      unitOfMeasure: map['unitOfMeasure'],
      component: map['component'],
      stringValue: map['stringValue'],
      booleanValue: map['booleanValue'],
      hexBinaryValue: map['hexBinaryValue'],
      uriValue: map['uriValue'],
      minValue: map['minValue']?.toDouble(),
      maxValue: map['maxValue']?.toDouble(),
      meanValue: map['meanValue']?.toDouble(),
      standardDeviation: map['sdValue']?.toDouble(),
      perceptionAccuracy: map['percValue'],
      chemistryValue: map['chemicalSubstance'],
      microorganism: map['microorganism'],
    );
  }

  @override
  List<Object?> get props => [
    type, value, unitOfMeasure, component, stringValue, 
    booleanValue, hexBinaryValue, uriValue, minValue, maxValue, 
    meanValue, standardDeviation, perceptionAccuracy,
    measurementTime, microorganism, chemistryValue
  ];
}

class SensorElement extends Equatable {
  final String? deviceId;
  
  final String? deviceMetadata;
  
  final String? rawData;
  
  final DateTime? time;
  
  final DateTime? startTime;
  
  final DateTime? endTime;
  
  final String? dataProcessingMethod;
  
  final String? businessRules;
  
  final List<SensorMeasurement> measurements;

  const SensorElement({
    this.deviceId,
    this.deviceMetadata,
    this.rawData,
    this.time,
    this.startTime,
    this.endTime,
    this.dataProcessingMethod,
    this.businessRules,
    required this.measurements,
  });

  SensorElement copyWith({
    String? deviceId,
    String? deviceMetadata,
    String? rawData,
    DateTime? time,
    DateTime? startTime,
    DateTime? endTime,
    String? dataProcessingMethod,
    String? businessRules,
    List<SensorMeasurement>? measurements,
  }) {
    return SensorElement(
      deviceId: deviceId ?? this.deviceId,
      deviceMetadata: deviceMetadata ?? this.deviceMetadata,
      rawData: rawData ?? this.rawData,
      time: time ?? this.time,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dataProcessingMethod: dataProcessingMethod ?? this.dataProcessingMethod,
      businessRules: businessRules ?? this.businessRules,
      measurements: measurements ?? this.measurements,
    );
  }

  factory SensorElement.fromJson(Map<String, dynamic> json) {
    List<SensorMeasurement> measurements = [];
    
    if (json['measurements'] != null) {
      try {
        final measurementsList = json['measurements'] as List;
        measurements = measurementsList.map<SensorMeasurement>((measurement) {
          if (measurement is Map<String, dynamic>) {
            return SensorMeasurement.fromJson(measurement);
          } else if (measurement is Map) {
            return SensorMeasurement.fromJson(Map<String, dynamic>.from(measurement));
          } else {
            return SensorMeasurement(type: 'unknown');
          }
        }).toList();
      } catch (error) {
        print("Error processing measurements: $error");
        measurements = [];
      }
    }

    return SensorElement(
      deviceId: json['deviceId'],
      deviceMetadata: json['deviceMetadata'],
      rawData: json['rawData'],
      time: json['time'] != null ? DateTime.tryParse(json['time'].toString()) : null,
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime'].toString()) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'].toString()) : null,
      dataProcessingMethod: json['dataProcessingMethod'],
      businessRules: json['businessRules'],
      measurements: measurements,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    if (deviceId != null) data['deviceId'] = deviceId;
    if (deviceMetadata != null) data['deviceMetadata'] = deviceMetadata;
    if (rawData != null) data['rawData'] = rawData;
    if (time != null) data['time'] = time!.toIso8601String();
    if (startTime != null) data['startTime'] = startTime!.toIso8601String();
    if (endTime != null) data['endTime'] = endTime!.toIso8601String();
    if (dataProcessingMethod != null) data['dataProcessingMethod'] = dataProcessingMethod;
    if (businessRules != null) data['businessRules'] = businessRules;
    
    data['measurements'] = measurements.map((measurement) => measurement.toJson()).toList();
    
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': 'Sensor',
      if (deviceId != null) 'deviceID': deviceId,
      if (deviceMetadata != null) 'deviceMetadata': deviceMetadata,
      if (rawData != null) 'rawData': rawData,
      if (time != null) 'time': time!.toIso8601String(),
      'measurements': measurements.map((m) => m.toMap()).toList(),
    };
  }
  
  static SensorElement fromMap(Map<String, dynamic> map) {
    List<SensorMeasurement> measurements = [];
    
    if (map['measurements'] != null) {
      try {
        final measurementsList = map['measurements'] as List;
        measurements = measurementsList.map<SensorMeasurement>((measurement) {
          if (measurement is Map<String, dynamic>) {
            return SensorMeasurement.fromMap(measurement);
          } else if (measurement is Map) {
            return SensorMeasurement.fromMap(Map<String, dynamic>.from(measurement));
          } else {
            return SensorMeasurement(type: 'unknown');
          }
        }).toList();
      } catch (error) {
        print("Error processing measurements from map: $error");
        measurements = [];
      }
    }

    return SensorElement(
      deviceId: map['deviceID'] as String?,
      deviceMetadata: map['deviceMetadata'] as String?,
      rawData: map['rawData'] as String?,
      time: map['time'] != null ? DateTime.tryParse(map['time']) : null,
      startTime: map['startTime'] != null ? DateTime.tryParse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.tryParse(map['endTime']) : null,
      dataProcessingMethod: map['dataProcessingMethod'] as String?,
      businessRules: map['businessRules'] as String?,
      measurements: measurements,
    );
  }

  @override
  List<Object?> get props => [
    deviceId, deviceMetadata, rawData, time, 
    startTime, endTime, dataProcessingMethod, 
    businessRules, measurements
  ];
}
