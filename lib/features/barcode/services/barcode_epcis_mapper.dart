//import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' show BarcodeFormat;
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:uuid/uuid.dart';

/// Service that maps barcode data to EPCIS events
class BarcodeToEPCISMapper {  final Uuid _uuid = Uuid();
  /// Maps a barcode to the appropriate EPCIS event
  Future<EPCISEvent?> mapBarcodeToEPCISEvent(
    dynamic barcode, 
    String bizStep, 
    String disposition,
    String readPointStr,
    String bizLocationStr,
  ) async {
    final value = barcode.rawValue as String?;
    if (value == null || value.isEmpty) {
      return null;
    }

    // Create GLN objects for locations
    final readPoint = _createGLN(readPointStr);
    final bizLocation = _createGLN(bizLocationStr);

    // Determine if this is a GS1 formatted barcode
    if (_isGS1Format(value)) {
      // Parse GS1 element strings from barcode
      final Map<String, String> elementStrings = _parseGS1ElementStrings(value);
      return _createEPCISEventFromGS1Elements(
        elementStrings,
        bizStep,
        disposition,
        readPoint,
        bizLocation,
      );
    } else if (value.startsWith('urn:epc:')) {
      // Handle direct EPC format
      return _createEPCISEventFromEPC(
        value,
        bizStep,
        disposition,
        readPoint,
        bizLocation,
      );
    }

    // For non-GS1 formats, create a basic object event
    final now = DateTime.now();
    return ObjectEvent(
      eventId: _uuid.v4(), 
      eventTime: now,
      recordTime: now,
      eventTimeZone: now.timeZoneOffset.toString(),
      businessStep: bizStep,
      disposition: disposition,
      readPoint: readPoint,
      businessLocation: bizLocation,
      action: 'OBSERVE',
      epcList: [value],
      bizData: {
        'barcodeType': barcode.format.name,
        'barcodeValue': value,
        'scannedTime': now.toIso8601String(),
      },
    );
  }

  /// Check if a string is in GS1 format (has AIs in parentheses)
  bool _isGS1Format(String code) {
    // Simple check for GS1 format - has AI in parentheses like (01)12345678901234
    return RegExp(r'\(\d{2,4}\)').hasMatch(code);
  }

  /// Parse GS1 element strings from a barcode
  Map<String, String> _parseGS1ElementStrings(String code) {
    final Map<String, String> result = {};
    
    // Find all application identifiers and their values
    RegExp aiRegex = RegExp(r'\((\d{2,4})\)([^\(]+)');
    final matches = aiRegex.allMatches(code);
    
    for (final match in matches) {
      final ai = match.group(1)!;
      final value = match.group(2)!;
      result[ai] = value;
    }
    
    return result;
  }

  /// Creates an EPCIS event from GS1 element strings
  EPCISEvent _createEPCISEventFromGS1Elements(
    Map<String, String> elementStrings,
    String bizStep,
    String disposition,
    GLN readPoint,
    GLN bizLocation,
  ) {
    final now = DateTime.now();
    
    // SGTIN case (product identifier)
    if (elementStrings.containsKey('01') && elementStrings.containsKey('21')) {
      final gtin = elementStrings['01']!;
      final serialNumber = elementStrings['21']!;
      final epc = _convertSGTINToEPC(gtin, serialNumber);
      
      return ObjectEvent(
        eventId: _uuid.v4(),
        eventTime: now,
        recordTime: now,
        eventTimeZone: now.timeZoneOffset.toString(),
        businessStep: bizStep,
        disposition: disposition,
        readPoint: readPoint,
        businessLocation: bizLocation,
        epcList: [epc],
        action: 'OBSERVE',
        bizData: _extractBizData(elementStrings),
      );
    } 
    
    // SSCC case (logistics unit identifier)
    else if (elementStrings.containsKey('00')) {
      final sscc = elementStrings['00']!;
      final epc = _convertSSCCToEPC(sscc);
      
      // If we have content (contained items), this could be an aggregation event
      if (elementStrings.containsKey('02') && elementStrings.containsKey('37')) {
        final contentGTIN = elementStrings['02']!;
        final contentCount = int.tryParse(elementStrings['37']!) ?? 0;
        
        // Create class-level identifier for the content
        final contentEPCClass = _convertGTINToClassEPC(contentGTIN);
          return AggregationEvent(
          eventId: _uuid.v4(),
          eventTime: now,
          recordTime: now,
          eventTimeZone: now.timeZoneOffset.toString(),
          businessStep: bizStep,
          disposition: disposition,
          readPoint: readPoint,
          businessLocation: bizLocation,
          action: 'OBSERVE',
          parentID: epc,
          childEPCs: [],
          childQuantityList: [{
            'epcClass': contentEPCClass,
            'quantity': contentCount,
            'uom': 'EA'
          }],
          bizData: _extractBizData(elementStrings),
        );
      }
      
      // Otherwise it's a simple object event with SSCC
      return ObjectEvent(
        eventId: _uuid.v4(),
        eventTime: now,
        recordTime: now,
        eventTimeZone: now.timeZoneOffset.toString(),
        businessStep: bizStep, 
        disposition: disposition,
        readPoint: readPoint,
        businessLocation: bizLocation,
        epcList: [epc],
        action: 'OBSERVE',
        bizData: _extractBizData(elementStrings),
      );
    }
    
    // GLN case (location identifier)
    else if (elementStrings.containsKey('414')) {
      final gln = elementStrings['414']!;
      final extension = elementStrings['254'] ?? '';
      final epc = _convertGLNToEPC(gln, extension);
      
      return ObjectEvent(
        eventId: _uuid.v4(),
        eventTime: now,
        recordTime: now,
        eventTimeZone: now.timeZoneOffset.toString(),
        businessStep: bizStep,
        disposition: disposition,
        readPoint: readPoint, 
        businessLocation: bizLocation,
        epcList: [epc],
        action: 'OBSERVE',
        bizData: _extractBizData(elementStrings),
      );
    }
    
    // Transaction reference (invoice, PO, etc.)
    else if (elementStrings.containsKey('400') || 
             elementStrings.containsKey('401') ||
             elementStrings.containsKey('402')) {
      
      String transactionType = 'po';
      String transactionId = '';
      
      if (elementStrings.containsKey('400')) {
        transactionType = 'po';
        transactionId = elementStrings['400']!;
      } else if (elementStrings.containsKey('401')) {
        transactionType = 'inv';
        transactionId = elementStrings['401']!;
      } else if (elementStrings.containsKey('402')) {
        transactionType = 'ship';
        transactionId = elementStrings['402']!;
      }      // Use the updated TransactionEvent model
      return TransactionEvent(
        eventId: _uuid.v4(),
        eventTime: now,
        recordTime: now,
        eventTimeZoneOffset: now.timeZoneOffset.toString(), // This is correct for TransactionEvent
        bizStep: bizStep,
        disposition: disposition,
        readPoint: readPoint, // Converting GLN object to string as required by TransactionEvent
        bizLocation: bizLocation, // Converting GLN object to string as required by TransactionEvent
        action: 'OBSERVE',
        bizTransactionList: {
          transactionType: transactionId, 
        },
        bizData: _extractBizData(elementStrings),
      );
    }
    
    // Generic case
    return ObjectEvent(
      eventId: _uuid.v4(),
      eventTime: now,
      recordTime: now,
      eventTimeZone: now.timeZoneOffset.toString(),
      businessStep: bizStep,
      disposition: disposition,
      readPoint: readPoint,
      businessLocation: bizLocation,
      bizData: _extractBizData(elementStrings),
      action: 'OBSERVE',
    );
  }

  /// Creates an EPCIS event from an EPC URI
  EPCISEvent _createEPCISEventFromEPC(
    String epc,
    String bizStep,
    String disposition,
    GLN readPoint,
    GLN bizLocation,
  ) {
    final now = DateTime.now();
    
    // Basic object event with the EPC
    return ObjectEvent(
      eventId: _uuid.v4(),
      eventTime: now,
      recordTime: now,
      eventTimeZone: now.timeZoneOffset.toString(),
      businessStep: bizStep,
      disposition: disposition,
      readPoint: readPoint,
      businessLocation: bizLocation,
      epcList: [epc],
      action: 'OBSERVE',
      bizData: {
        'epcType': _getEPCType(epc),
        'scanSource': 'barcode',
        'scannedTime': now.toIso8601String(),
      },
    );
  }
  
  /// Get the type of an EPC URI
  String _getEPCType(String epc) {
    if (epc.contains(':sgtin:')) return 'SGTIN';
    if (epc.contains(':sscc:')) return 'SSCC';
    if (epc.contains(':sgln:')) return 'SGLN';
    if (epc.contains(':grai:')) return 'GRAI';
    if (epc.contains(':giai:')) return 'GIAI';
    if (epc.contains(':gsrn:')) return 'GSRN';
    return 'UNKNOWN';
  }
  
  /// Convert GTIN and serial to SGTIN EPC URI
  String _convertSGTINToEPC(String gtin, String serialNumber) {
    // Ensure GTIN is 14 digits
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }
    
    // Extract company prefix (assume first 7 digits)
    final companyPrefix = gtin.substring(1, 8);
    
    // Extract item reference
    final itemReference = gtin.substring(8, 13);
    
    return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
  }
  
  /// Convert SSCC to EPC URI
  String _convertSSCCToEPC(String sscc) {
    // Ensure SSCC is 18 digits
    if (sscc.length < 18) {
      sscc = sscc.padLeft(18, '0');
    }
    
    // Extract extension digit and company prefix
    final extensionDigit = sscc.substring(0, 1);
    final companyPrefix = sscc.substring(1, 8);
    
    // Extract serial reference (exclude check digit)
    final serialReference = sscc.substring(8, 17);
    
    return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialReference';
  }
  
  /// Convert GLN to EPC URI
  String _convertGLNToEPC(String gln, String extension) {
    // Ensure GLN is 13 digits
    if (gln.length < 13) {
      gln = gln.padLeft(13, '0');
    }
    
    // Extract company prefix
    final companyPrefix = gln.substring(0, 7);
    
    // Extract location reference (without check digit)
    final locationReference = gln.substring(7, 12);
    
    return 'urn:epc:id:sgln:$companyPrefix.$locationReference.$extension';
  }
  
  /// Convert GTIN to class-level EPC
  String _convertGTINToClassEPC(String gtin) {
    // Ensure GTIN is 14 digits
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }
    
    // Extract company prefix
    final companyPrefix = gtin.substring(1, 8);
    
    // Extract item reference
    final itemReference = gtin.substring(8, 13);
    
    return 'urn:epc:idpat:sgtin:$companyPrefix.$itemReference.*';
  }

  /// Helper to create a GLN object from a string GLN
  GLN _createGLN(String glnStr) {
    return GLN(
      //id: _uuid.v4(),
      glnCode: glnStr,
      locationName: 'Location $glnStr',
      addressLine1: 'Address for $glnStr',
      city: 'City',
      stateProvince: 'State',
      postalCode: '00000',
      country: 'Country',
      locationType: LocationType.other,
      active: true
    );
  }

  /// Extracts business data from GS1 element strings
  Map<String, String> _extractBizData(Map<String, String> elementStrings) {
    final bizData = <String, String>{
      'scanSource': 'gs1_barcode',
      'scannedTime': DateTime.now().toIso8601String(),
    };
    
    // Map common GS1 AIs to business data
    final aiMappings = {
      '10': 'batchLot',
      '11': 'productionDate',
      '13': 'packagingDate',
      '15': 'bestBeforeDate',
      '17': 'expirationDate',
      '30': 'count',
      '310': 'netWeightKg',
      '400': 'orderNumber',
      '401': 'shipToPoNumber',
      '402': 'shipmentNumber',
      '91': 'companyInformation',
      '92': 'companyInformation',
      '93': 'companyInformation',
    };
    
    // Copy relevant AIs to business data
    aiMappings.forEach((ai, bizKey) {
      if (elementStrings.containsKey(ai)) {
        bizData[bizKey] = elementStrings[ai]!;
      }
    });
    
    // Handle dates - convert from YYMMDD format to ISO format
    ['11', '15', '17'].forEach((dateAI) {
      if (elementStrings.containsKey(dateAI)) {
        final yymmdd = elementStrings[dateAI]!;
        if (yymmdd.length == 6) {
          try {
            final year = 2000 + int.parse(yymmdd.substring(0, 2));
            final month = int.parse(yymmdd.substring(2, 4));
            final day = int.parse(yymmdd.substring(4, 6));
            final date = DateTime(year, month, day);
            bizData[aiMappings[dateAI]!] = date.toIso8601String().split('T')[0];
          } catch (_) {
            // If date parsing fails, use the original value
            bizData[aiMappings[dateAI]!] = yymmdd;
          }
        }
      }
    });
    
    return bizData;
  }
}