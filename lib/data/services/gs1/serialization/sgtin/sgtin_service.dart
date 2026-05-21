import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'sgtin_service_constants.dart';


/// Implementation of SGTINService interface for managing SGTINs
class SGTINService {
  final DioService _dioService;

  /// Creates a new SGTINServiceImpl instance
  SGTINService({required DioService dioService}) : _dioService = dioService;

  Future<SGTIN> getSGTINById(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathById(id)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errLoadById}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> getSGTINBySerialNumber(String serialNumber) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathBySerial(serialNumber)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errLoadBySerial}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> getAllSGTINs({
    int page = SgtinServiceConstants.defaultPage,
    int size = SgtinServiceConstants.defaultSize,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathBase}',
      queryParameters: {SgtinServiceConstants.qPage: page, SgtinServiceConstants.qSize: size},
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      if (data[SgtinServiceConstants.rContent] != null) {
        return (data[SgtinServiceConstants.rContent] as List)
            .map((item) => SGTIN.fromJson(item))
            .toList();
      }
      return [];
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errLoadAll}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> createSGTIN(SGTIN sgtin) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final jsonData = sgtin.toJson();
    print('Creating SGTIN with JSON: $jsonData');
    print('currentLocation in SGTIN object: ${sgtin.currentLocation}');
    print('currentLocation GLN code: ${sgtin.currentLocation?.glnCode}');

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathBase}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode(jsonData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusCreated) {
      return SGTIN.fromJson(json.decode(response.data));
    }

    Map<String, dynamic>? errorBody;
    try {
      errorBody = json.decode(response.data) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode == SgtinServiceConstants.statusNotFound &&
        errorBody != null &&
        errorBody[SgtinServiceConstants.rMessage]?.toString().contains('GTIN not found') == true) {
      throw ApiException(
          statusCode: response.statusCode, message: SgtinServiceConstants.errGtinNotFound);
    } else if (response.statusCode == SgtinServiceConstants.statusConflict) {
      throw ApiException(
          statusCode: response.statusCode, message: SgtinServiceConstants.errDuplicateSerial);
    } else if (response.statusCode == SgtinServiceConstants.statusBadRequest && errorBody != null) {
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody[SgtinServiceConstants.rMessage] ?? SgtinServiceConstants.errInvalidData,
      );
    }
    throw ApiException(
      statusCode: response.statusCode,
      message:
          errorBody?[SgtinServiceConstants.rMessage] ?? '${SgtinServiceConstants.errCreate}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> updateSGTIN(String id, SGTIN sgtin) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.put(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathById(id)}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode(sgtin.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errUpdate}: ${response.statusMessage}',
    );
  }

  Future<void> deleteSGTIN(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.delete(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathById(id)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != SgtinServiceConstants.statusNoContent) {
      throw ApiException(
        statusCode: response.statusCode,
        message: '${SgtinServiceConstants.errDelete}: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsByGTIN(String gtinCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathByGtin(gtinCode)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindByGtin}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> findSGTINsByBatchLotNumber(String batchLotNumber) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathBatch}',
      queryParameters: {SgtinServiceConstants.qBatchLotNumber: batchLotNumber},
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindByBatch}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> findSGTINsByStatus(ItemStatus status) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathStatus}',
      queryParameters: {SgtinServiceConstants.qStatus: status.name},
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindByStatus}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> findSGTINsByLocation(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathByLocation(glnCode)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindByLocation}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> findSGTINsBySSCC(String ssccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathBySscc(ssccCode)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindBySscc}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> findSGTINsExpiringBefore(DateTime date) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathExpiring}',
      queryParameters: {SgtinServiceConstants.qDate: dateStr},
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindExpiring}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> findSGTINsByRegulatoryMarket(
    String regulatoryMarket,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathMarket}',
      queryParameters: {SgtinServiceConstants.qMarket: regulatoryMarket},
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errFindByMarket}: ${response.statusMessage}',
    );
  }

  Future<List<SGTIN>> searchSGTINs({
    int? gtinId,
    String? batchLotNumber,
    ItemStatus? status,
    int? locationId,
    int page = SgtinServiceConstants.defaultPage,
    int size = SgtinServiceConstants.defaultSize,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final queryParams = <String, dynamic>{
      SgtinServiceConstants.qPage:           page,
      SgtinServiceConstants.qSize:           size,
      SgtinServiceConstants.qGtinId:         ?gtinId,
      SgtinServiceConstants.qBatchLotNumber: ?batchLotNumber,
      if (status != null) SgtinServiceConstants.qStatus: status.name,
      SgtinServiceConstants.qLocationId:     ?locationId,
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathSearch}',
      queryParameters: queryParams,
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      if (data[SgtinServiceConstants.rContent] != null) {
        return (data[SgtinServiceConstants.rContent] as List)
            .map((item) => SGTIN.fromJson(item))
            .toList();
      }
      return [];
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errSearch}: ${response.statusMessage}',
    );
  }

  Future<Map<String, dynamic>> searchSGTINsAdvanced({
    String? gtinCode,
    String? serialNumber,
    String? batchLotNumber,
    ItemStatus? status,
    String? locationName,
    int page = SgtinServiceConstants.defaultPage,
    int size = SgtinServiceConstants.defaultSize,
    String sortBy = SgtinServiceConstants.defaultSortBy,
    String sortDirection = SgtinServiceConstants.defaultSortDirection,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final queryParams = <String, dynamic>{
      SgtinServiceConstants.qPage:      page,
      SgtinServiceConstants.qSize:      size,
      SgtinServiceConstants.qSortBy:    sortBy,
      SgtinServiceConstants.qDirection: sortDirection,
      if (gtinCode != null && gtinCode.isNotEmpty)
        SgtinServiceConstants.qGtinCode: gtinCode,
      if (serialNumber != null && serialNumber.isNotEmpty)
        SgtinServiceConstants.qSerialNumber: serialNumber,
      if (batchLotNumber != null && batchLotNumber.isNotEmpty)
        SgtinServiceConstants.qBatchLotNumber: batchLotNumber,
      if (status != null) SgtinServiceConstants.qStatus: status.name,
      if (locationName != null && locationName.isNotEmpty)
        SgtinServiceConstants.qLocationName: locationName,
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathSearchAdvanced}',
      queryParameters: queryParams,
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      return {
        SgtinServiceConstants.rContent:       (data[SgtinServiceConstants.rContent] as List?)
                               ?.map((item) => SGTIN.fromJson(item))
                               .toList() ??
                           [],
        SgtinServiceConstants.rTotalElements: data[SgtinServiceConstants.rTotalElements] ?? 0,
        SgtinServiceConstants.rTotalPages:    data[SgtinServiceConstants.rTotalPages] ?? 0,
        SgtinServiceConstants.rNumber:        data[SgtinServiceConstants.rNumber] ?? 0,
        SgtinServiceConstants.rSize:          data[SgtinServiceConstants.rSize] ?? size,
        SgtinServiceConstants.rFirst:         data[SgtinServiceConstants.rFirst] ?? true,
        SgtinServiceConstants.rLast:          data[SgtinServiceConstants.rLast] ?? true,
      };
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errSearch}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> updateSGTINStatus(
    String serialNumber,
    ItemStatus newStatus,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.put(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathItemStatus(serialNumber)}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode({SgtinServiceConstants.bStatus: newStatus.name}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errUpdateStatus}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> assignSGTINToLocation(
    String serialNumber,
    String glnCode,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.put(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathItemLocation(serialNumber)}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode({SgtinServiceConstants.bGlnCode: glnCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errAssignLocation}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> packSGTINIntoSSCC(String serialNumber, String ssccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.put(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathItemPack(serialNumber)}',
      headers: SgtinServiceConstants.authHeaders(token),
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
    );
  }

  Future<String> generateSerialNumber(
    String gtinCode, {
    bool randomized = true,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathGenerateSerial(gtinCode)}',
      queryParameters: {SgtinServiceConstants.qRandomized: randomized.toString()},
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final data = json.decode(response.data);
      return data[SgtinServiceConstants.rSerialNumber] ?? '';
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errGenSerial}: ${response.statusMessage}',
    );
  }

  Future<bool> validateSGTIN(String gtinCode, String serialNumber) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathValidate}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode({
        SgtinServiceConstants.bGtinCode:    gtinCode,
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
      message: '${SgtinServiceConstants.errValidate}: ${response.statusMessage}',
    );
  }

  Future<int> countSGTINsByGTINAndStatus(
    String gtinCode,
    ItemStatus status,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathCount(gtinCode)}',
      queryParameters: {SgtinServiceConstants.qStatus: status.name},
      headers: SgtinServiceConstants.authHeaders(token),
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
    );
  }

  Future<List<SGTIN>> commissionMultipleSGTINs({
    required String gtinCode,
    required int quantity,
    required String batchLotNumber,
    required DateTime expiryDate,
    String? currentLocation,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final expiryDateStr = DateFormat('yyyy-MM-dd').format(expiryDate);

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathCommission}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode({
        SgtinServiceConstants.bGtinCode:        gtinCode,
        SgtinServiceConstants.bQuantity:        quantity,
        SgtinServiceConstants.bBatchLotNumber:  batchLotNumber,
        SgtinServiceConstants.bExpiryDate:      expiryDateStr,
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
      message: '${SgtinServiceConstants.errCommission}: ${response.statusMessage}',
    );
  }

  Future<SGTIN> decommissionSGTIN(String serialNumber, String reason) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.put(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathItemDecommission(serialNumber)}',
      headers: SgtinServiceConstants.authHeaders(token),
      data: json.encode({SgtinServiceConstants.bReason: reason}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      return SGTIN.fromJson(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errDecommission}: ${response.statusMessage}',
    );
  }

  /// Returns the list of status names that the SGTIN with the given [id] may
  /// legally transition to from its current status.
  ///
  /// Calls `GET /identifiers/sgtins/{id}/transitions`.
  Future<List<String>> getAvailableTransitions(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) throw ApiException(message: SgtinServiceConstants.errNoToken);

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SgtinServiceConstants.pathItemTransitions(id)}',
      headers: SgtinServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SgtinServiceConstants.statusOk) {
      final body = json.decode(response.data) as Map<String, dynamic>;
      return List<String>.from(body['availableTransitions'] as List);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: '${SgtinServiceConstants.errGetTransitions}: ${response.statusMessage}',
    );
  }
}