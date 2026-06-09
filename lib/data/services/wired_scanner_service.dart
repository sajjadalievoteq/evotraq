import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:uuid/uuid.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/barcode_api_service.dart';

class WiredScannerService {
  final Uuid _uuid = Uuid();
  BarcodeApiService? _barcodeApiService;
  
  void initApiService() {
    _barcodeApiService ??= BarcodeApiService(
     dioService: getIt<DioService>(),
    );
  }
  Future<EPCISEvent> processWiredScannerInput(
    String barcodeValue,
    String bizStep,
    String disposition,
    String readPointStr,
    String bizLocationStr,
  ) async {
    initApiService();

    final readPoint = GLN.fromCode(readPointStr);
    final bizLocation = GLN.fromCode(bizLocationStr);
    
    Map<String, dynamic> extractedData = {};
    String barcodeType = 'UNKNOWN';
    if (_barcodeApiService != null) {
      try {
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
      }
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
      epcList: [barcodeValue],
      bizData: {
        'barcodeType': barcodeType,
        'barcodeValue': barcodeValue,
        'scannedTime': now.toIso8601String(),
        'scanSource': 'WIRED_SCANNER',
        if (extractedData.isNotEmpty) 'gs1Data': extractedData.toString(),
      },
    );
  }
}
