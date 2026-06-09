import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class BarcodeApiService {
  final DioService _dioService;
  late final String _baseUrl;

  BarcodeApiService({required DioService dioService}) : _dioService = dioService {
    _baseUrl = _dioService.baseUrl;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> verifyBarcode(String barcodeData) async {
    final headers = await _getHeaders();

    final queryParameters = {
      'data': barcodeData,
      'type': 'DATAMATRIX',
    };

    debugPrint('Calling barcode validation API: $_baseUrl/barcodes/validate');

    try {
      final response = await _dioService.get(
        '$_baseUrl/barcodes/validate',
        headers: headers,
        queryParameters: queryParameters,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      debugPrint('Barcode validation response status: ${response.statusCode}');
      debugPrint('Barcode validation response body: ${response.data}');

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else if (response.statusCode == 404) {
        debugPrint('First endpoint not found, trying alternative GS1 validation endpoint');
        return _tryAlternativeGS1Validation(barcodeData, headers);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              _parseErrorMessage(response.data.toString()) ??
              'Failed to verify barcode: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error during barcode validation: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _tryAlternativeGS1Validation(String barcodeData, Map<String, String> headers) async {
    debugPrint(
      'Trying alternative validation API: $_baseUrl/barcode/verify/gs1-element-string',
    );

    final response = await _dioService.get(
      '$_baseUrl/barcode/verify/gs1-element-string',
      headers: headers,
      queryParameters: {'gs1ElementString': barcodeData},
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    debugPrint('Alternative validation response status: ${response.statusCode}');
    debugPrint('Alternative validation response body: ${response.data}');

    if (response.statusCode == 200) {
      final result = jsonDecode(response.data);
      return {
        'isValid': result['valid'] ?? false,
        'message': result['valid'] == true ? 'Valid GS1 barcode' : 'Invalid GS1 barcode format',
        'data': barcodeData,
        'validationResults': result['validationResults'],
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data.toString()) ??
            'Failed to verify barcode: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> checkBarcodeQuality(List<int> barcodeImage) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');

    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        barcodeImage,
        filename: 'barcode.png',
      ),
    });

    final response = await _dioService.post(
      '$_baseUrl/barcodes/quality',
      headers: headers,
      data: formData,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data.toString()) ??
            'Failed to check barcode quality',
      );
    }
  }

  Future<Map<String, dynamic>> extractBarcodeData(String barcodeData) async {
    final headers = await _getHeaders();

    final queryParameters = {'elementString': barcodeData};

    debugPrint('Calling parse-gs1 API: $_baseUrl/barcodes/parse-gs1');

    try {
      final response = await _dioService.get(
        '$_baseUrl/barcodes/parse-gs1',
        headers: headers,
        queryParameters: queryParameters,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      debugPrint('Parse-gs1 response status: ${response.statusCode}');
      debugPrint('Parse-gs1 response body: ${response.data}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.data);
        if (!result.containsKey('barcodeType')) {
          result['barcodeType'] = 'GS1';
        }
        return result;
      } else if (response.statusCode == 404) {
        debugPrint('GS1 parse endpoint not found, trying alternative approach');
        return _extractBasicGS1Data(barcodeData);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              _parseErrorMessage(response.data.toString()) ??
              'Failed to extract barcode data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error during barcode data extraction: $e');
      return _extractBasicGS1Data(barcodeData);
    }
  }

  Map<String, dynamic> _extractBasicGS1Data(String data) {
    final result = <String, dynamic>{
      'elementString': data,
      'barcodeType': 'GS1',
      'rawData': data,
      'isValid': true,
    };

    Map<String, String> parsedData = {};

    try {
      final gtinRegex = RegExp(r'\(01\)(\d{14})');
      final gtinMatch = gtinRegex.firstMatch(data);
      if (gtinMatch != null) {
        parsedData['GTIN'] = gtinMatch.group(1)!;
      }

      final snRegex = RegExp(r'\(21\)([^\(]+)');
      final snMatch = snRegex.firstMatch(data);
      if (snMatch != null) {
        parsedData['serialNumber'] = snMatch.group(1)!;
      }

      final lotRegex = RegExp(r'\(10\)([^\(]+)');
      final lotMatch = lotRegex.firstMatch(data);
      if (lotMatch != null) {
        parsedData['batchNumber'] = lotMatch.group(1)!;
      }

      final expRegex = RegExp(r'\(17\)(\d{6})');
      final expMatch = expRegex.firstMatch(data);
      if (expMatch != null) {
        parsedData['expiryDate'] = expMatch.group(1)!;
      }

      result['parsed'] = parsedData;
    } catch (e) {
      debugPrint('Error during basic GS1 parsing: $e');
      result['isValid'] = false;
      result['message'] = 'Failed to parse GS1 data: $e';
    }

    return result;
  }

  Future<Map<String, dynamic>> createObjectEvent({
    required String gs1ElementString,
    required String locationGLN,
    String businessStep = 'urn:epcglobal:cbv:bizstep:observing',
    String disposition = 'urn:epcglobal:cbv:disp:active',
  }) async {
    final headers = await _getHeaders();
    final params = {
      'gs1ElementString': gs1ElementString,
      'locationGLN': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
    };

    final response = await _dioService.post(
      '$_baseUrl/barcode-epcis/object-event',
      headers: headers,
      queryParameters: params,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data.toString()) ??
            'Failed to create object event',
      );
    }
  }

  Future<Map<String, dynamic>> createAggregationEvent({
    required String parentBarcode,
    required List<String> childBarcodes,
    required String locationGLN,
    String businessStep = 'urn:epcglobal:cbv:bizstep:packing',
    String disposition = 'urn:epcglobal:cbv:disp:in_progress',
    String action = 'ADD',
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'parentBarcode': parentBarcode,
      'locationGLN': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'action': action,
    };

    for (int i = 0; i < childBarcodes.length; i++) {
      queryParams['childBarcodes[$i]'] = childBarcodes[i];
    }

    final response = await _dioService.post(
      '$_baseUrl/barcode-epcis/aggregation-event',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data.toString()) ??
            'Failed to create aggregation event',
      );
    }
  }

  Future<List<Map<String, dynamic>>> createTransactionEvent({
    required List<String> gs1ElementStrings,
    required String bizTransactionType,
    required String bizTransactionId,
    required String locationGLN,
    String businessStep = 'urn:epcglobal:cbv:bizstep:shipping',
    String disposition = 'urn:epcglobal:cbv:disp:in_transit',
    String action = 'ADD',
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'bizTransactionType': bizTransactionType,
      'bizTransactionId': bizTransactionId,
      'locationGLN': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'action': action,
    };

    for (int i = 0; i < gs1ElementStrings.length; i++) {
      queryParams['gs1ElementStrings[$i]'] = gs1ElementStrings[i];
    }

    final response = await _dioService.post(
      '$_baseUrl/barcode-epcis/transaction-event',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = jsonDecode(response.data);
      return eventList.cast<Map<String, dynamic>>();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data.toString()) ??
            'Failed to create transaction event',
      );
    }
  }

  String? _parseErrorMessage(String responseBody) {
    try {
      final jsonBody = json.decode(responseBody);
      return jsonBody['message'] ?? jsonBody['error'];
    } catch (_) {
      return null;
    }
  }
}
