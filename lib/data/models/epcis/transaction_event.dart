import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:uuid/uuid.dart';

class TransactionEvent extends EPCISEvent {
  final String eventType = "TransactionEvent";
  
  final String action;
  
  final String? parentID;
  
  final List<String>? epcList;
  
  final Map<String, String> bizTransactionList;
  
  final List<QuantityElement>? quantityList;
  
  final Map<String, String>? sourceList;
  final Map<String, String>? destinationList;
  TransactionEvent({
    String? id,
    String? eventId,
    required DateTime eventTime,
    DateTime? recordTime,
    String? eventTimeZoneOffset,
    EPCISVersion? epcisVersion,
    String? bizStep,
    String? disposition,
    GLN? readPoint,
    GLN? bizLocation,
    required this.action,
    this.parentID,
    this.epcList,
    Map<String, String>? bizTransactionList,
    this.quantityList,
    this.sourceList,
    this.destinationList,
    Map<String, String>? bizData,
    Map<String, String>? extensions,
    DateTime? createdAt,
  }) : bizTransactionList = bizTransactionList ?? {},       super(
         id: id,
         eventId: eventId ?? 'urn:epcglobal:cbv:epcis:event:${Uuid().v4()}',
         eventTime: eventTime,
         recordTime: recordTime ?? DateTime.now(),
         eventTimeZone: _generateTimezoneOffset(eventTimeZoneOffset, eventTime),
         epcisVersion: epcisVersion,
         disposition: disposition,
         businessStep: bizStep,
         readPoint: readPoint,
         businessLocation: bizLocation,
         bizData: bizData,
         extensions: extensions,
         createdAt: createdAt,
       );
       
  static String _generateTimezoneOffset(String? providedOffset, DateTime dateTime) {
    if (providedOffset != null && providedOffset.isNotEmpty) {
      return providedOffset;
    }
    
    final offset = dateTime.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    
    json['eventType'] = eventType;
    json['action'] = action;
    
    if (parentID != null && parentID!.isNotEmpty) {
      json['parentID'] = parentID;
    }
    if (epcList != null) json['epcList'] = epcList;
    
    if (bizTransactionList.isNotEmpty) {
      final bizTransList = <Map<String, String>>[];
      bizTransactionList.forEach((key, value) {
        bizTransList.add({
          'type': key,
          'id': value,
        });
      });
      json['bizTransactionList'] = bizTransList;
    }
    
    if (quantityList != null && quantityList!.isNotEmpty) {
      json['quantityList'] = quantityList!.map((q) => q.toJson()).toList();
    }
    
    if (sourceList != null && sourceList!.isNotEmpty) {
      final sourceListArray = <Map<String, String>>[];
      sourceList!.forEach((key, value) {
        sourceListArray.add({
          'type': key,
          'id': value,
        });
      });
      json['sourceList'] = sourceListArray;
    }
    
    if (destinationList != null && destinationList!.isNotEmpty) {
      final destListArray = <Map<String, String>>[];
      destinationList!.forEach((key, value) {
        destListArray.add({
          'type': key,
          'id': value,
        });
      });
      json['destinationList'] = destListArray;
    }
    
    return json;
  }

  factory TransactionEvent.fromJson(Map<String, dynamic> json) {
    Map<String, String> bizTransMap = {};
    if (json['bizTransactionList'] != null) {
      for (var transaction in json['bizTransactionList']) {
        if (transaction is Map && transaction.containsKey('type') && transaction.containsKey('id')) {
          bizTransMap[transaction['type']] = transaction['id'];
        }
      }
    }
    
    List<QuantityElement>? quantities;
    if (json['quantityList'] != null) {
      quantities = (json['quantityList'] as List)
          .map((q) => QuantityElement.fromJson(q))
          .toList();
    }
    
    Map<String, String>? sourceMap;
    if (json['sourceList'] != null) {
      sourceMap = {};
      for (var source in json['sourceList']) {
        if (source is Map && source.containsKey('type') && source.containsKey('id')) {
          sourceMap[source['type']] = source['id'];
        }
      }
    }
    
    Map<String, String>? destMap;
    if (json['destinationList'] != null) {
      destMap = {};
      for (var dest in json['destinationList']) {
        if (dest is Map && dest.containsKey('type') && dest.containsKey('id')) {
          destMap[dest['type']] = dest['id'];
        }
      }
    }

    GLN? readPointGln;
    if (json['readPoint'] != null) {
      readPointGln = json['readPoint'] is String 
          ? GLN.fromCode(json['readPoint']) 
          : GLN.fromJson(json['readPoint']);
    }
    
    GLN? businessLocationGln;
    if (json['businessLocation'] != null || json['bizLocation'] != null) {
      var locationData = json['businessLocation'] ?? json['bizLocation'];
      businessLocationGln = locationData is String 
          ? GLN.fromCode(locationData) 
          : GLN.fromJson(locationData);
    }

    return TransactionEvent(
      id: json['id']?.toString(),
      eventId: json['eventId'],
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : DateTime.now(),
      recordTime: json['recordTime'] != null ? DateTime.parse(json['recordTime']) : DateTime.now(),
      eventTimeZoneOffset: json['eventTimeZoneOffset'] ?? json['eventTimeZone'] ?? '+00:00',      epcisVersion: json['epcisVersion'] != null 
          ? EPCISVersion.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == 
                    json['epcisVersion'].toString().toUpperCase(),
              orElse: () => EPCISVersion.v2_0)
          : null,
      bizStep: json['businessStep'] ?? json['bizStep'],
      disposition: json['disposition'],
      readPoint: readPointGln,
      bizLocation: businessLocationGln,
      action: json['action'],
      parentID: json['parentID'],
      epcList: json['epcList'] != null ? List<String>.from(json['epcList']) : null,
      bizTransactionList: bizTransMap,
      quantityList: quantities,
      sourceList: sourceMap,
      destinationList: destMap,
      bizData: json['bizData'] != null ? Map<String, String>.from(json['bizData']) : null,
      extensions: json['extensions'] != null ? Map<String, String>.from(json['extensions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  TransactionEvent copyWith({
    String? id,
    String? eventId,
    DateTime? eventTime,
    DateTime? recordTime,
    String? eventTimeZoneOffset,
    EPCISVersion? epcisVersion,
    String? bizStep,
    String? disposition,
    GLN? readPoint,
    GLN? bizLocation,
    String? eventHash,
    Map<String, String>? bizData,
    Map<String, String>? extensions,
    DateTime? createdAt,
    String? action,
    String? parentID,
    List<String>? epcList,
    Map<String, String>? bizTransactionList,
    List<QuantityElement>? quantityList,
    Map<String, String>? sourceList,
    Map<String, String>? destinationList,
  }) {
    return TransactionEvent(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTime: eventTime ?? this.eventTime,
      recordTime: recordTime ?? this.recordTime,
      eventTimeZoneOffset: eventTimeZoneOffset ?? eventTimeZone,
      epcisVersion: epcisVersion ?? this.epcisVersion,
      bizStep: bizStep ?? businessStep,
      disposition: disposition ?? this.disposition,
      readPoint: readPoint ?? this.readPoint,
      bizLocation: bizLocation ?? businessLocation,
      bizData: bizData ?? this.bizData,
      extensions: extensions ?? this.extensions,
      createdAt: createdAt ?? this.createdAt,
      action: action ?? this.action,
      parentID: parentID ?? this.parentID,
      epcList: epcList ?? this.epcList,
      bizTransactionList: bizTransactionList ?? this.bizTransactionList,
      quantityList: quantityList ?? this.quantityList,
      sourceList: sourceList ?? this.sourceList,
      destinationList: destinationList ?? this.destinationList,
    );
  }
}

class QuantityElement {
  final String? epcClass;
  
  final double? quantity;
  
  final String? uom;
  
  QuantityElement({
    this.epcClass,
    this.quantity,
    this.uom,
  });
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (epcClass != null) json['epcClass'] = epcClass;
    if (quantity != null) json['quantity'] = quantity;
    if (uom != null) json['uom'] = uom;
    
    return json;
  }
  
  factory QuantityElement.fromJson(Map<String, dynamic> json) {
    return QuantityElement(
      epcClass: json['epcClass'],
      quantity: json['quantity'] != null 
          ? (json['quantity'] is String 
              ? double.tryParse(json['quantity']) 
              : (json['quantity'] as num).toDouble()) 
          : null,
      uom: json['uom'],
    );
  }
}