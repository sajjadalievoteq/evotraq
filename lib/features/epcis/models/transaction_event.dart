// Importing necessary packages and models
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:uuid/uuid.dart';

/// TransactionEvent model based on EPCIS standard
class TransactionEvent extends EPCISEvent {
  /// Type of event - always "TransactionEvent" for transaction events
  final String eventType = "TransactionEvent";
  
  /// Action type - ADD, OBSERVE, or DELETE
  final String action;
  
  /// Parent identifier for hierarchy
  final String? parentID;
  
  /// List of EPCs involved in the transaction
  final List<String>? epcList;
  
  /// List of business transactions involved
  final Map<String, String> bizTransactionList;
  
  /// Quantity list for class-level identification
  final List<QuantityElement>? quantityList;
  
  /// Source and destination for products in the transaction
  final Map<String, String>? sourceList;
  final Map<String, String>? destinationList;
    /// Constructor
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
         eventId: eventId ?? 'urn:epcglobal:cbv:epcis:event:${Uuid().v4()}', // Default unique identifier using UUID
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
       
  /// Generate timezone offset string if not provided
  static String _generateTimezoneOffset(String? providedOffset, DateTime dateTime) {
    if (providedOffset != null && providedOffset.isNotEmpty) {
      return providedOffset;
    }
    
    // Generate offset from datetime
    final offset = dateTime.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  
  @override
  Map<String, dynamic> toJson() {
    // Start with the base class fields
    final json = super.toJson();
    
    // Add TransactionEvent specific fields
    json['eventType'] = eventType;
    json['action'] = action;
    
    // Only include parentID if it's not null and not empty
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

  /// Create a TransactionEvent object from JSON
  factory TransactionEvent.fromJson(Map<String, dynamic> json) {
    // Parse bizTransactionList
    Map<String, String> bizTransMap = {};
    if (json['bizTransactionList'] != null) {
      for (var transaction in json['bizTransactionList']) {
        if (transaction is Map && transaction.containsKey('type') && transaction.containsKey('id')) {
          bizTransMap[transaction['type']] = transaction['id'];
        }
      }
    }
    
    // Parse quantityList
    List<QuantityElement>? quantities;
    if (json['quantityList'] != null) {
      quantities = (json['quantityList'] as List)
          .map((q) => QuantityElement.fromJson(q))
          .toList();
    }
    
    // Parse source list
    Map<String, String>? sourceMap;
    if (json['sourceList'] != null) {
      sourceMap = {};
      for (var source in json['sourceList']) {
        if (source is Map && source.containsKey('type') && source.containsKey('id')) {
          sourceMap[source['type']] = source['id'];
        }
      }
    }
    
    // Parse destination list
    Map<String, String>? destMap;
    if (json['destinationList'] != null) {
      destMap = {};
      for (var dest in json['destinationList']) {
        if (dest is Map && dest.containsKey('type') && dest.containsKey('id')) {
          destMap[dest['type']] = dest['id'];
        }
      }
    }

    // Handle GLN objects for locations
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

  /// Create a copy of this TransactionEvent with the given fields replaced
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
      eventTimeZoneOffset: eventTimeZoneOffset ?? this.eventTimeZone,
      epcisVersion: epcisVersion ?? this.epcisVersion,
      bizStep: bizStep ?? this.businessStep,
      disposition: disposition ?? this.disposition,
      readPoint: readPoint ?? this.readPoint,
      bizLocation: bizLocation ?? this.businessLocation,
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

/// Quantity element for transaction event
class QuantityElement {
  /// EPC class
  final String? epcClass;
  
  /// Quantity
  final double? quantity;
  
  /// Unit of measure
  final String? uom;
  
  /// Constructor
  QuantityElement({
    this.epcClass,
    this.quantity,
    this.uom,
  });
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (epcClass != null) json['epcClass'] = epcClass;
    if (quantity != null) json['quantity'] = quantity;
    if (uom != null) json['uom'] = uom;
    
    return json;
  }
  
  /// Create from JSON
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