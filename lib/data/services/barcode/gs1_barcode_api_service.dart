import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class GS1BarcodeApiService {
  final DioService _dioService;
  late final String _baseUrl;

  GS1BarcodeApiService({
    required DioService dioService,
  }) : _dioService = dioService {
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

  Future<Map<String, dynamic>> verifyGS1Barcode(String gs1ElementString) async {
    final headers = await _getHeaders();
    // Backend maps both /barcodes/gs1/verify and /barcodes/verify to the same handler.
    final queryParameters = {'data': gs1ElementString};

    debugPrint(
      'Calling GS1 barcode verification API: $_baseUrl/barcodes/gs1/verify',
    );

    try {
      final response = await _dioService.get(
        '$_baseUrl/barcodes/gs1/verify',
        headers: headers,
        queryParameters: queryParameters,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      debugPrint(
        'GS1 barcode verification response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.data);
        debugPrint('GS1 barcode verification successful: ${result.toString()}');
        return result;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              _parseErrorMessage(response.data.toString()) ??
              'Failed to verify GS1 barcode: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error during barcode verification: $e');
      rethrow;
    }
  }

  String? _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorResponse = json.decode(responseBody);
      return errorResponse['message'] ?? errorResponse['error'] ?? responseBody;
    } catch (e) {
      return null;
    }
  }
}
