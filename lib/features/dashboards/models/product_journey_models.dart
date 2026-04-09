/// Models for Product Journey Dashboard

/// Represents a single step in the product journey
class JourneyStep {
  final String eventId;
  final String eventType;
  final String businessStep;
  final String businessStepLabel;
  final String disposition;
  final String dispositionLabel;
  final DateTime eventTime;
  final DateTime? recordTime;
  final String? locationGLN;
  final String? locationName;
  final String? locationAddress;
  final String? action;
  final String? parentId; // For aggregation events (SSCC)
  final List<String>? childEpcs; // For packing/aggregation
  final Map<String, dynamic>? ilmd; // Instance/Lot Master Data
  final JourneyStepStatus status;

  JourneyStep({
    required this.eventId,
    required this.eventType,
    required this.businessStep,
    required this.businessStepLabel,
    required this.disposition,
    required this.dispositionLabel,
    required this.eventTime,
    this.recordTime,
    this.locationGLN,
    this.locationName,
    this.locationAddress,
    this.action,
    this.parentId,
    this.childEpcs,
    this.ilmd,
    this.status = JourneyStepStatus.completed,
  });

  factory JourneyStep.fromEventJson(Map<String, dynamic> json) {
    return JourneyStep(
      eventId: json['eventId'] ?? json['id'] ?? '',
      eventType: json['eventType'] ?? _inferEventType(json),
      businessStep: json['businessStep'] ?? '',
      businessStepLabel: _parseBusinessStep(json['businessStep']),
      disposition: json['disposition'] ?? '',
      dispositionLabel: _parseDisposition(json['disposition']),
      eventTime: json['eventTime'] != null 
          ? DateTime.parse(json['eventTime']) 
          : DateTime.now(),
      recordTime: json['recordTime'] != null 
          ? DateTime.parse(json['recordTime']) 
          : null,
      locationGLN: json['businessLocation']?.toString(),
      locationName: json['businessLocationName'],
      locationAddress: json['businessLocationAddress'],
      action: json['action'],
      parentId: json['parentID'],
      childEpcs: json['childEPCs'] != null 
          ? List<String>.from(json['childEPCs']) 
          : null,
      ilmd: json['ilmd'] as Map<String, dynamic>?,
      status: JourneyStepStatus.completed,
    );
  }

  static String _inferEventType(Map<String, dynamic> json) {
    if (json['parentID'] != null || json['childEPCs'] != null) {
      return 'AggregationEvent';
    }
    if (json['inputEPCList'] != null || json['outputEPCList'] != null) {
      return 'TransformationEvent';
    }
    if (json['bizTransactionList'] != null) {
      return 'TransactionEvent';
    }
    return 'ObjectEvent';
  }

  static String _parseBusinessStep(String? bizStep) {
    if (bizStep == null) return 'Unknown';
    
    // Parse URN format: urn:epcglobal:cbv:bizstep:commissioning
    if (bizStep.contains(':')) {
      final parts = bizStep.split(':');
      final name = parts.last;
      // Capitalize first letter and add spaces before capitals
      return name.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      ).replaceFirst(name[0], name[0].toUpperCase());
    }
    return bizStep;
  }

  static String _parseDisposition(String? disp) {
    if (disp == null) return 'Unknown';
    
    if (disp.contains(':')) {
      final parts = disp.split(':');
      final name = parts.last;
      return name.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      ).replaceFirst(name[0], name[0].toUpperCase());
    }
    return disp;
  }
}

enum JourneyStepStatus {
  completed,
  inProgress,
  pending,
  failed,
}

/// Complete product journey containing all steps
class ProductJourney {
  final String identifier; // SGTIN, SSCC, etc.
  final String identifierType; // 'SGTIN', 'SSCC', 'GTIN+Serial'
  final List<JourneyStep> steps;
  final ProductInfo? productInfo;
  final DateTime? firstEventTime;
  final DateTime? lastEventTime;
  final String? currentLocation;
  final String? currentDisposition;

  ProductJourney({
    required this.identifier,
    required this.identifierType,
    required this.steps,
    this.productInfo,
    this.firstEventTime,
    this.lastEventTime,
    this.currentLocation,
    this.currentDisposition,
  });

  /// Calculate journey statistics
  int get totalSteps => steps.length;
  
  Duration? get journeyDuration {
    if (firstEventTime != null && lastEventTime != null) {
      return lastEventTime!.difference(firstEventTime!);
    }
    return null;
  }

  int get locationsVisited {
    return steps.map((s) => s.locationGLN).where((g) => g != null).toSet().length;
  }
}

/// Product information extracted from ILMD or master data
class ProductInfo {
  final String? gtin;
  final String? description;
  final String? batchLotNumber;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final String? manufacturer;

  ProductInfo({
    this.gtin,
    this.description,
    this.batchLotNumber,
    this.manufacturingDate,
    this.expiryDate,
    this.bestBeforeDate,
    this.manufacturer,
  });

  factory ProductInfo.fromILMD(Map<String, dynamic>? ilmd) {
    if (ilmd == null) return ProductInfo();
    
    return ProductInfo(
      gtin: ilmd['gtin'] as String?,
      description: ilmd['itemDescription'] as String?,
      batchLotNumber: ilmd['lotNumber'] as String?,
      manufacturingDate: ilmd['manufacturingDate'] != null 
          ? _parseDate(ilmd['manufacturingDate']) 
          : null,
      expiryDate: ilmd['itemExpirationDate'] != null 
          ? _parseDate(ilmd['itemExpirationDate']) 
          : null,
      bestBeforeDate: ilmd['bestBeforeDate'] != null 
          ? _parseDate(ilmd['bestBeforeDate']) 
          : null,
    );
  }

  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    final dateStr = dateValue.toString();
    try {
      if (dateStr.length == 10 && dateStr.contains('-')) {
        return DateTime.parse('${dateStr}T00:00:00Z');
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
