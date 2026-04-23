import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_api_consts.dart';

/// GTIN (Global Trade Item Number) master-data API client.
class GTINService {
  final DioService _dioService;

  GTINService({
    required DioService dioService,
  }) : _dioService = dioService;

  String get _base => '${_dioService.baseUrl}${GtinApiConsts.masterDataGtinsPath}';

  void _log(String op, Object error, {int? statusCode, String? path, String? body}) {
    final parts = <String>[
      '[GTINService]',
      op,
      error is ApiException
          ? 'status=${error.statusCode} msg=${error.message}'
          : error.toString(),
    ];
    if (path != null) parts.add(path);
    if (statusCode != null) parts.add('http=$statusCode');
    debugPrint(parts.join(' | '));
    if (error is ApiException) {
      final b = body ?? error.responseBody;
      if (b != null && b.isNotEmpty) {
        final s = b.length > 400 ? '${b.substring(0, 400)}…' : b;
        debugPrint('[GTINService] $op response body: $s');
      }
    } else if (body != null && body.isNotEmpty) {
      final s = body.length > 400 ? '${body.substring(0, 400)}…' : body;
      debugPrint('[GTINService] $op body: $s');
    }
    if (error is Error && error.stackTrace != null) {
      debugPrint(error.stackTrace.toString());
    }
  }

  Future<GTIN> getGTIN(String gtinCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('getGTIN', ex, path: '$_base/code/$gtinCode');
      throw ex;
    }

    final response = await _dioService.get(
      '$_base/code/$gtinCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.data);
        return GTIN.fromJson(jsonData);
      } catch (e) {
        final ex = ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data is String ? response.data as String? : null,
        );
        _log('getGTIN:fromJson', ex, path: '$_base/code/$gtinCode', body: ex.responseBody);
        throw ex;
      }
    } else {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GTIN: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('getGTIN', ex,
          path: '$_base/code/$gtinCode', statusCode: response.statusCode, body: ex.responseBody);
      throw ex;
    }
  }

  Future<List<GTIN>> getGTINs({
    String? manufacturer,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('getGTINs', ex, path: _base);
      throw ex;
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (status != null) 'status': status,
    };

    final response = await _dioService.get(
      _base,
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.data);
        if (data['content'] != null) {
          return (data['content'] as List)
              .map((item) => GTIN.fromJson(item))
              .toList();
        }
        return [];
      } catch (e) {
        final ex = ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data is String ? response.data as String? : null,
        );
        _log('getGTINs:fromJson', ex, path: _base, body: ex.responseBody);
        throw ex;
      }
    } else if (response.statusCode == 403) {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('getGTINs', ex, path: _base, statusCode: 403, body: ex.responseBody);
      throw ex;
    } else {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GTINs: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('getGTINs', ex,
          path: _base, statusCode: response.statusCode, body: ex.responseBody);
      throw ex;
    }
  }

  Future<Map<String, dynamic>> searchGTINsAdvanced({
    String? search,
    String? productName,
    String? gtinCode,
    String? manufacturer,
    String? status,
    String? packagingLevel,
    String? registrationDateFrom,
    String? registrationDateTo,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('searchGTINsAdvanced', ex, path: '$_base/search');
      throw ex;
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (search != null && search.isNotEmpty) 'search': search,
      if (productName != null && productName.isNotEmpty)
        'productName': productName,
      if (gtinCode != null && gtinCode.isNotEmpty) 'gtinCode': gtinCode,
      if (manufacturer != null && manufacturer.isNotEmpty)
        'manufacturer': manufacturer,
      if (status != null &&
          status.isNotEmpty &&
          status != GtinApiConsts.allFilterSentinel)
        'status': status,
      if (packagingLevel != null &&
          packagingLevel.isNotEmpty &&
          packagingLevel != GtinApiConsts.allFilterSentinel)
        'packagingLevel': packagingLevel,
      if (registrationDateFrom != null && registrationDateFrom.isNotEmpty)
        'registrationDateFrom': registrationDateFrom,
      if (registrationDateTo != null && registrationDateTo.isNotEmpty)
        'registrationDateTo': registrationDateTo,
    };

    final response = await _dioService.get(
      '$_base/search',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.data);
        // Backend may respond either with Spring's Page JSON (number/size/last)
        // or our `PageResponse` DTO (pageNumber/pageSize/last). Support both.
        final content = data is Map<String, dynamic> ? data['content'] : null;
        final gtins = (content as List?)
                ?.map((item) => GTIN.fromJson(item))
                .toList() ??
            [];

        final int currentPage =
            (data['pageNumber'] ?? data['number'] ?? 0) as int;
        final int resolvedPageSize =
            (data['pageSize'] ?? data['size'] ?? size) as int;
        final bool isLast = (data['last'] ?? true) as bool;

        return {
          'gtins': gtins,
          'totalElements': data['totalElements'] ?? 0,
          'totalPages': data['totalPages'] ?? 0,
          'currentPage': currentPage,
          'pageSize': resolvedPageSize,
          'hasMoreData': !isLast,
        };
      } catch (e) {
        final ex = ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data is String ? response.data as String? : null,
        );
        _log('searchGTINsAdvanced:fromJson', ex,
            path: '$_base/search', body: ex.responseBody);
        throw ex;
      }
    } else if (response.statusCode == 403) {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('searchGTINsAdvanced', ex, path: '$_base/search', body: ex.responseBody);
      throw ex;
    } else {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GTINs: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('searchGTINsAdvanced', ex,
          path: '$_base/search', statusCode: response.statusCode, body: ex.responseBody);
      throw ex;
    }
  }

  Future<GTIN> createGTIN(GTIN gtin) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('createGTIN', ex, path: _base);
      throw ex;
    }

    final jsonPayload = gtin.toJson();

    final response = await _dioService.post(
      _base,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(jsonPayload),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      try {
        return GTIN.fromJson(json.decode(response.data));
      } catch (e) {
        final ex = ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data is String ? response.data as String? : null,
        );
        _log('createGTIN:fromJson', ex, path: _base, body: ex.responseBody);
        throw ex;
      }
    } else {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create GTIN: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('createGTIN', ex,
          path: _base, statusCode: response.statusCode, body: ex.responseBody);
      throw ex;
    }
  }

  Future<GTIN> updateGTIN(GTIN gtin) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('updateGTIN', ex, path: '$_base/${gtin.gtinCode}');
      throw ex;
    }

    final response = await _dioService.put(
      '$_base/${gtin.gtinCode}',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(gtin.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        return GTIN.fromJson(json.decode(response.data));
      } catch (e) {
        final ex = ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data is String ? response.data as String? : null,
        );
        _log('updateGTIN:fromJson', ex,
            path: '$_base/${gtin.gtinCode}', body: ex.responseBody);
        throw ex;
      }
    } else {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GTIN: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('updateGTIN', ex,
          path: '$_base/${gtin.gtinCode}',
          statusCode: response.statusCode,
          body: ex.responseBody);
      throw ex;
    }
  }

  Future<void> updateGTINStatus(String gtinCode, String status) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('updateGTINStatus', ex, path: '$_base/$gtinCode/status');
      throw ex;
    }

    final response = await _dioService.put(
      '$_base/$gtinCode/status',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'status': status}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GTIN status: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('updateGTINStatus', ex,
          path: '$_base/$gtinCode/status',
          statusCode: response.statusCode,
          body: ex.responseBody);
      throw ex;
    }
  }

  Future<bool> validateGTIN(String gtinCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      final ex = ApiException(message: 'No authentication token found');
      _log('validateGTIN', ex, path: '$_base/validate?gtinCode=$gtinCode');
      throw ex;
    }

    final response = await _dioService.get(
      '$_base/validate',
      queryParameters: {'gtinCode': gtinCode},
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.data);
        return data['isValid'] ?? false;
      } catch (e) {
        final ex = ApiException(
          statusCode: response.statusCode,
          message: 'Error processing validation response: $e',
          originalException: e,
          responseBody: response.data is String ? response.data as String? : null,
        );
        _log('validateGTIN:parse', ex, path: '$_base/validate', body: ex.responseBody);
        throw ex;
      }
    } else {
      final ex = ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate GTIN: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
      _log('validateGTIN', ex,
          path: '$_base/validate', statusCode: response.statusCode, body: ex.responseBody);
      throw ex;
    }
  }
}
