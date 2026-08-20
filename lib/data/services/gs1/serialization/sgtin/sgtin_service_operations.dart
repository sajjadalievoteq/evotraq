import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'sgtin_service_constants.dart';

extension SgtinServiceOperations on SGTINService {
  Future<SGTIN> updateSGTINStatus(
    String serialNumber,
    ItemStatus newStatus,
  ) async {
    final response = await dioService.put(
      '${dioService.baseUrl}${SgtinServiceConstants.pathItemStatus}',
      queryParameters: {SgtinServiceConstants.qSerialNumber: serialNumber},
      headers: SGTINService.headers,
      data: json.encode({SgtinServiceConstants.bStatus: newStatus.name}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errUpdateStatus}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<SGTIN> assignSGTINToLocation(
    String serialNumber,
    String glnCode,
  ) async {
    final response = await dioService.put(
      '${dioService.baseUrl}${SgtinServiceConstants.pathItemLocation(serialNumber)}',
      headers: SGTINService.headers,
      data: json.encode({SgtinServiceConstants.bGlnCode: glnCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errAssignLocation}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<SGTIN> packSGTINIntoSSCC(String serialNumber, String ssccCode) async {
    final response = await dioService.put(
      '${dioService.baseUrl}${SgtinServiceConstants.pathItemPack(serialNumber)}',
      headers: SGTINService.headers,
      data: json.encode({SgtinServiceConstants.bSsccCode: ssccCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errPack}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<String> generateSerialNumber(
    String gtinCode, {
    bool randomized = true,
  }) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SgtinServiceConstants.pathGenerateSerial(gtinCode)}',
      queryParameters: {
        SgtinServiceConstants.qRandomized: randomized.toString(),
      },
      headers: SGTINService.headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      return data[SgtinServiceConstants.rSerialNumber] ?? '';
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errGenSerial}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<bool> validateSGTIN(String gtinCode, String serialNumber) async {
    final response = await dioService.post(
      '${dioService.baseUrl}${SgtinServiceConstants.pathValidate}',
      headers: SGTINService.headers,
      data: json.encode({
        SgtinServiceConstants.bGtinCode: gtinCode,
        SgtinServiceConstants.bSerialNumber: serialNumber,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      return data[SgtinServiceConstants.rValid] ?? false;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errValidate}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<int> countSGTINsByGTINAndStatus(
    String gtinCode,
    ItemStatus status,
  ) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SgtinServiceConstants.pathCount(gtinCode)}',
      queryParameters: {SgtinServiceConstants.qStatus: status.name},
      headers: SGTINService.headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      return data[SgtinServiceConstants.rCount] ?? 0;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errCount}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<List<SGTIN>> commissionMultipleSGTINs({
    required String gtinCode,
    required int quantity,
    required String batchLotNumber,
    required DateTime expiryDate,
    String? currentLocation,
  }) async {
    final expiryDateStr = DateFormat('yyyy-MM-dd').format(expiryDate);

    final response = await dioService.post(
      '${dioService.baseUrl}${SgtinServiceConstants.pathCommission}',
      headers: SGTINService.headers,
      data: json.encode({
        SgtinServiceConstants.bGtinCode: gtinCode,
        SgtinServiceConstants.bQuantity: quantity,
        SgtinServiceConstants.bBatchLotNumber: batchLotNumber,
        SgtinServiceConstants.bExpiryDate: expiryDateStr,
        SgtinServiceConstants.bCurrentLocation: ?currentLocation,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusCreated) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errCommission}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<SGTIN> decommissionSGTIN(String serialNumber, String reason) async {
    final response = await dioService.post(
      '${dioService.baseUrl}${SgtinServiceConstants.pathItemDecommission}',
      queryParameters: {SgtinServiceConstants.qSerialNumber: serialNumber},
      headers: SGTINService.headers,
      data: json.encode({SgtinServiceConstants.bReason: reason}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errDecommission}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<List<String>> getAvailableTransitions(String id) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SgtinServiceConstants.pathItemTransitions(id)}',
      headers: SGTINService.headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final body = json.decode(response.data) as Map<String, dynamic>;
      return List<String>.from(body['availableTransitions'] as List);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          '${SgtinServiceConstants.errGetTransitions}: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }
}
