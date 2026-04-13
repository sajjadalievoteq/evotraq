// A service for handling wired scanner input
import 'package:uuid/uuid.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/data/services/barcode_api_service.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:http/http.dart' as http;

class WiredScannerService {
  final Uuid _uuid = Uuid();
  BarcodeApiService? _barcodeApiService;
  
  // Initialize API service if needed
  void initApiService(AppConfig appConfig, TokenManager tokenManager) {
    _barcodeApiService ??= BarcodeApiService(
      client: http.Client(),
      tokenManager: tokenManager,
      appConfig: appConfig,
    );
  }
    // Process raw barcode data from a wired scanner
  Future<EPCISEvent> processWiredScannerInput(
    String barcodeValue,
    String bizStep,
    String disposition,
    String readPointStr,
    String bizLocationStr,
    {AppConfig? appConfig, TokenManager? tokenManager}
  ) async {
    // Initialize API service if provided configs
    if (appConfig != null && tokenManager != null) {
      initApiService(appConfig, tokenManager);
    }

    // Use the simple factory constructor for GLN to handle locations
    final readPoint = GLN.fromCode(readPointStr);
    final bizLocation = GLN.fromCode(bizLocationStr);
    
    Map<String, dynamic> extractedData = {};
    String barcodeType = 'UNKNOWN';    // Try to extract GS1 data if API service is available
    if (_barcodeApiService != null) {
      try {
        // Verify and extract GS1 data
        final verificationResult = await _barcodeApiService!.verifyBarcode(barcodeValue)
          .catchError((e) {
            print('Barcode validation error, continuing with basic processing: $e');
            return {'isValid': false, 'message': e.toString()};
          });

        if (verificationResult['isValid'] == true) {
          try {
            extractedData = await _barcodeApiService!.extractBarcodeData(barcodeValue);
            barcodeType = extractedData['barcodeType'] ?? 'GS1';
            print('Successfully extracted GS1 data: $extractedData');
          } catch (e) {
            print('Error extracting GS1 data: $e');
          }
        } else {
          print('Barcode validation failed: ${verificationResult['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        print('API error during barcode verification or extraction: $e');
        // Continue with basic processing if API fails
      }
    }// Create a basic EPCIS Object event
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
      epcList: [barcodeValue],
      bizData: {
        'barcodeType': barcodeType,
        'barcodeValue': barcodeValue,
        'scannedTime': now.toIso8601String(),
        'scanSource': 'WIRED_SCANNER',
        // Include all extracted GS1 data as JSON string if available
        if (extractedData.isNotEmpty) 'gs1Data': extractedData.toString(),
      },
    );
  }
}
