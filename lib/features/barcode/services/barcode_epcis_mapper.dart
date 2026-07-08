//import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' show BarcodeFormat;
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:uuid/uuid.dart';

class BarcodeToEPCISMapper {  final Uuid _uuid = Uuid();
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

    final readPoint = _createGLN(readPointStr);
    final bizLocation = _createGLN(bizLocationStr);

    if (_isGS1Format(value)) {
      final Map<String, String> elementStrings = _parseGS1ElementStrings(value);
      return _createEPCISEventFromGS1Elements(
        elementStrings,
        bizStep,
        disposition,
        readPoint,
        bizLocation,
      );
    } else if (value.startsWith('urn:epc:')) {
      return _createEPCISEventFromEPC(
        value,
        bizStep,
        disposition,
        readPoint,
        bizLocation,
      );
    }

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

  bool _isGS1Format(String code) {
    return RegExp(r'\(\d{2,4}\)').hasMatch(code);
  }

  Map<String, String> _parseGS1ElementStrings(String code) {
    final Map<String, String> result = {};
    
    RegExp aiRegex = RegExp(r'\((\d{2,4})\)([^\(]+)');
    final matches = aiRegex.allMatches(code);
    
    for (final match in matches) {
      final ai = match.group(1)!;
      final value = match.group(2)!;
      result[ai] = value;
    }
    
    return result;
  }

  EPCISEvent _createEPCISEventFromGS1Elements(
    Map<String, String> elementStrings,
    String bizStep,
    String disposition,
    GLN readPoint,
    GLN bizLocation,
  ) {
    final now = DateTime.now();
    
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
    
    else if (elementStrings.containsKey('00')) {
      final sscc = elementStrings['00']!;
      final epc = _convertSSCCToEPC(sscc);
      
      if (elementStrings.containsKey('02') && elementStrings.containsKey('37')) {
        final contentGTIN = elementStrings['02']!;
        final contentCount = int.tryParse(elementStrings['37']!) ?? 0;
        
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
      }
      return TransactionEvent(
        eventId: _uuid.v4(),
        eventTime: now,
        recordTime: now,
        eventTimeZoneOffset: now.timeZoneOffset.toString(),
        bizStep: bizStep,
        disposition: disposition,
        readPoint: readPoint,
        bizLocation: bizLocation,
        action: 'OBSERVE',
        bizTransactionList: {
          transactionType: transactionId, 
        },
        bizData: _extractBizData(elementStrings),
      );
    }
    
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

  EPCISEvent _createEPCISEventFromEPC(
    String epc,
    String bizStep,
    String disposition,
    GLN readPoint,
    GLN bizLocation,
  ) {
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
      epcList: [epc],
      action: 'OBSERVE',
      bizData: {
        'epcType': _getEPCType(epc),
        'scanSource': 'barcode',
        'scannedTime': now.toIso8601String(),
      },
    );
  }
  
  String _getEPCType(String epc) {
    if (epc.contains(':sgtin:')) return 'SGTIN';
    if (epc.contains(':sscc:')) return 'SSCC';
    if (epc.contains(':sgln:')) return 'SGLN';
    if (epc.contains(':grai:')) return 'GRAI';
    if (epc.contains(':giai:')) return 'GIAI';
    if (epc.contains(':gsrn:')) return 'GSRN';
    return 'UNKNOWN';
  }
  
  String _convertSGTINToEPC(String gtin, String serialNumber) {
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }
    
    final companyPrefix = gtin.substring(1, 8);
    
    final itemReference = gtin.substring(8, 13);
    
    return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
  }
  
  String _convertSSCCToEPC(String sscc) {
    if (sscc.length < 18) {
      sscc = sscc.padLeft(18, '0');
    }
    
    final extensionDigit = sscc.substring(0, 1);
    final companyPrefix = sscc.substring(1, 8);
    
    final serialReference = sscc.substring(8, 17);
    
    return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialReference';
  }
  
  String _convertGLNToEPC(String gln, String extension) {
    if (gln.length < 13) {
      gln = gln.padLeft(13, '0');
    }
    
    final companyPrefix = gln.substring(0, 7);
    
    final locationReference = gln.substring(7, 12);
    
    return 'urn:epc:id:sgln:$companyPrefix.$locationReference.$extension';
  }
  
  String _convertGTINToClassEPC(String gtin) {
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }
    
    final companyPrefix = gtin.substring(1, 8);
    
    final itemReference = gtin.substring(8, 13);
    
    return 'urn:epc:idpat:sgtin:$companyPrefix.$itemReference.*';
  }

  GLN _createGLN(String glnStr) {
    return GLN(
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

  Map<String, String> _extractBizData(Map<String, String> elementStrings) {
    final bizData = <String, String>{
      'scanSource': 'gs1_barcode',
      'scannedTime': DateTime.now().toIso8601String(),
    };
    
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
    
    aiMappings.forEach((ai, bizKey) {
      if (elementStrings.containsKey(ai)) {
        bizData[bizKey] = elementStrings[ai]!;
      }
    });
    
    for (final dateAI in ['11', '15', '17']) {
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
            bizData[aiMappings[dateAI]!] = yymmdd;
          }
        }
      }
    }
    
    return bizData;
  }
}