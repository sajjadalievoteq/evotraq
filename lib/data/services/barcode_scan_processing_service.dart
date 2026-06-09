import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/services/barcode_api_service.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

class BarcodeScanProcessingService {
  final BarcodeApiService _barcodeApiService;
  
  BarcodeScanProcessingService({
    required DioService dioService,
  }) : _barcodeApiService = BarcodeApiService(dioService: dioService);
  
  Future<Map<String, dynamic>> processBarcodeScan({
    required String barcodeData,
    required String locationGLN,
    required String businessStep,
    required String disposition,
  }) async {
    try {
      final verificationResult = await _barcodeApiService.verifyBarcode(barcodeData);
      
      Map<String, dynamic> extractedData = {};
      
      if (verificationResult['isValid'] == true) {
        extractedData = await _barcodeApiService.extractBarcodeData(barcodeData);
        
        debugPrint('Extracted GS1 data: $extractedData');
        
        final epcisEvent = await _barcodeApiService.createObjectEvent(
          gs1ElementString: barcodeData,
          locationGLN: locationGLN,
          businessStep: businessStep,
          disposition: disposition,
        );
        
        return {
          'success': true,
          'event': epcisEvent,
          'extractedData': extractedData,
          'barcodeType': extractedData['barcodeType'] ?? 'UNKNOWN',
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid barcode format: ${verificationResult['message'] ?? 'Unknown error'}',
          'rawData': barcodeData,
        };
      }
    } catch (e) {
      debugPrint('Error in processBarcodeScan: $e');
      
      try {
        final readPoint = GLN.fromCode(locationGLN);
        final bizLocation = GLN.fromCode(locationGLN);
        
        final now = DateTime.now();
        final uuid = const Uuid().v4();
        
        final epcisEvent = ObjectEvent(
          eventId: uuid, 
          eventTime: now,
          recordTime: now,
          eventTimeZone: now.timeZoneOffset.toString(),
          businessStep: businessStep,
          disposition: disposition,
          readPoint: readPoint,
          businessLocation: bizLocation,
          action: 'OBSERVE',
          epcList: [barcodeData],          bizData: {
            'barcodeType': 'UNKNOWN',
            'barcodeValue': barcodeData,
            'scannedTime': now.toIso8601String(),
            'scanSource': 'BARCODE_SCANNER',
            'errorProcessing': 'true',
            'errorMessage': e.toString(),
          },
        );
        
        return {
          'success': true,
          'event': {
            'id': uuid,
            'eventTime': now.toIso8601String(),
          },
          'extractedData': {
            'rawData': barcodeData,
          },
          'barcodeType': 'UNKNOWN',
          'apiError': e.toString(),
        };
      } catch (fallbackError) {
        return {
          'success': false,
          'message': 'Error processing barcode: $e\nFallback error: $fallbackError',
          'rawData': barcodeData,
        };
      }
    }
  }
  
  Future<Map<String, dynamic>> processAggregationScan({
    required String parentBarcode,
    required List<String> childBarcodes,
    required String locationGLN,
    required String businessStep,
    required String disposition,
  }) async {
    try {
      final epcisEvent = await _barcodeApiService.createAggregationEvent(
        parentBarcode: parentBarcode,
        childBarcodes: childBarcodes,
        locationGLN: locationGLN,
        businessStep: businessStep,
        disposition: disposition,
      );
      
      return {
        'success': true,
        'event': epcisEvent,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing aggregation: $e',
      };
    }
  }
  Future<Map<String, dynamic>> processTransactionScan({
    required List<String> barcodes,
    required String bizTransactionType,
    required String bizTransactionId,
    required String locationGLN,
    required String businessStep,
    required String disposition,
  }) async {
    try {
      final epcisEvents = await _barcodeApiService.createTransactionEvent(
        gs1ElementStrings: barcodes,
        bizTransactionType: bizTransactionType,
        bizTransactionId: bizTransactionId,
        locationGLN: locationGLN,
        businessStep: businessStep,
        disposition: disposition,
      );
      
      return {
        'success': true,
        'events': epcisEvents,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing transaction event: $e',
      };
    }
  }
  
  Map<String, String> parseGS1Data(Map<String, dynamic> extractedData) {
    final result = <String, String>{};
    
    try {
      if (extractedData.containsKey('GTIN')) {
        result['Product Code (GTIN)'] = extractedData['GTIN'].toString();
      }
      
      if (extractedData.containsKey('serialNumber')) {
        result['Serial Number'] = extractedData['serialNumber'].toString();
      }
      
      if (extractedData.containsKey('expiryDate')) {
        final expiry = DateTime.parse(extractedData['expiryDate'].toString());
        result['Expiry Date'] = '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';
      }
      
      if (extractedData.containsKey('batchNumber') || extractedData.containsKey('lotNumber')) {
        result['Batch/Lot Number'] = (extractedData['batchNumber'] ?? extractedData['lotNumber'] ?? '').toString();
      }
      
      if (extractedData.containsKey('productionDate')) {
        final prodDate = DateTime.parse(extractedData['productionDate'].toString());
        result['Production Date'] = '${prodDate.year}-${prodDate.month.toString().padLeft(2, '0')}-${prodDate.day.toString().padLeft(2, '0')}';
      }
      
      extractedData.forEach((key, value) {
        if (!result.containsKey(key) && key != 'barcodeType' && key != 'rawData') {
          result[key] = value.toString();
        }
      });
      
    } catch (e) {
      result['Error'] = 'Failed to parse GS1 data: $e';
    }
    
    return result;
  }
}

class Uuid {
  const Uuid();
  
  String v4() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'xxxx-xxxx-4xxx-yxxx-xxxx'.replaceAllMapped(
      RegExp(r'[xy]'),
      (match) {
        final r = (random + match.start) % 16 | 0;
        final v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
        return v.toRadixString(16);
      },
    );
  }
}
