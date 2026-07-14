import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
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
    } else if (Gs1CanonicalIdentifier.isValid(value)) {
      final canonical = Gs1CanonicalIdentifier.forStorage(value);
      return _createEPCISEventFromEPC(
        canonical,
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
    final type = Gs1CanonicalIdentifier.typeOf(epc);
    if (type != null) return type;

    return switch (Gs1CanonicalIdentifier.classify(epc)) {
      Gs1CanonicalKind.sgtin => 'SGTIN',
      Gs1CanonicalKind.sscc => 'SSCC',
      Gs1CanonicalKind.sgln => 'SGLN',
      Gs1CanonicalKind.pgln => 'PGLN',
      Gs1CanonicalKind.lgtin => 'LGTIN',
      Gs1CanonicalKind.classGtin => 'SGTIN-CLASS',
      Gs1CanonicalKind.unknown => 'UNKNOWN',
    };
  }
  
  String _convertSGTINToEPC(String gtin, String serialNumber) {
    return Gs1Converter.gtinSerialToEpc(gtin, serialNumber) ??
        'https://id.gs1.org/01/${gtin.padLeft(14, '0')}/21/$serialNumber';
  }
  
  String _convertSSCCToEPC(String sscc) {
    final padded = sscc.padLeft(18, '0');
    return Gs1Converter.ssccToEpc(padded) ?? 'https://id.gs1.org/00/$padded';
  }
  
  String _convertGLNToEPC(String gln, String extension) {
    return Gs1Converter.glnToEpc(gln, extension: extension) ??
        'https://id.gs1.org/414/${gln.padLeft(13, '0')}';
  }
  
  String _convertGTINToClassEPC(String gtin) {
    return Gs1Converter.gtinToClassEpc(gtin) ??
        'https://id.gs1.org/01/${gtin.padLeft(14, '0')}';
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