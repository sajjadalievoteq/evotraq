import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

class CommissioningOperationService {
  final DioService _dioService;

  CommissioningOperationService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => _dioService.baseUrl;

  static const _headers = {'Content-Type': 'application/json'};

  Future<CommissioningResponse> createCommissioningOperation(
    CommissioningRequest request,
  ) async {
    final startTime = DateTime.now();
    final operationId = 'comm_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint(
      'CommissioningService: Starting bulk commissioning for ${request.serialNumbers.length} items',
    );

    try {
      final response = await _dioService.post(
        '$_baseUrl/commissioning/bulk',
        headers: _headers,
        data: jsonEncode(request.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      final processingTimeMs =
          DateTime.now().difference(startTime).inMilliseconds;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;

        final rawItems = data['itemResults'] as List<dynamic>? ?? [];
        final itemResults = rawItems.map((item) {
          final m = item as Map<String, dynamic>;
          return CommissioningItemResult(
            serialNumber: m['serialNumber'] as String? ?? '',
            sgtinId: m['sgtinId']?.toString(),
            epcUri: m['epcUri'] as String?,
            success: m['success'] as bool? ?? false,
            errorMessage: m['errorMessage'] as String?,
          );
        }).toList();

        final epcisEventId = data['epcisEventId'] as String?;

        CommissioningStatus status;
        final rawStatus = data['status'] as String?;
        switch (rawStatus) {
          case 'SUCCESS':
            status = CommissioningStatus.success;
          case 'PARTIAL_SUCCESS':
            status = CommissioningStatus.partialSuccess;
          case 'FAILED':
            status = CommissioningStatus.failed;
          default:
            status = CommissioningStatus.partialSuccess;
        }

        debugPrint(
          'CommissioningService: Bulk commissioning complete — '
          'event=$epcisEventId status=$rawStatus '
          'commissioned=${data['totalCommissioned']} '
          'failed=${data['totalFailed']}',
        );

        return CommissioningResponse(
          commissioningOperationId:
              data['batchId'] as String? ?? operationId,
          commissioningReference:
              data['commissioningReference'] as String?,
          eventIds:
              epcisEventId != null ? [epcisEventId] : const [],
          createdSgtinIds: (data['commissionedEpcs'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
          commissionedCount: data['totalCommissioned'] as int? ?? 0,
          failedCount: data['totalFailed'] as int? ?? 0,
          status: status,
          processedAt: DateTime.now(),
          gtinCode: data['gtinCode'] as String?,
          batchLotNumber: data['batchLotNumber'] as String?,
          commissioningLocationGLN:
              data['commissioningLocationGLN'] as String?,
          messages: (data['messages'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          itemResults: itemResults,
          processingTimeMs: processingTimeMs,
          metadata: {
            'batch_id': data['batchId'],
            'epcis_event_id': epcisEventId,
            'total_items': request.serialNumbers.length,
          },
        );
      } else {
        String errorMsg;
        try {
          final errorData = jsonDecode(response.data) as Map<String, dynamic>;
          errorMsg = errorData['message'] as String? ??
              errorData['error'] as String? ??
              'Commissioning failed (HTTP ${response.statusCode})';
        } catch (_) {
          errorMsg = 'Commissioning failed (HTTP ${response.statusCode})';
        }
        throw ApiException(
          message: errorMsg,
          statusCode: response.statusCode,
          responseBody: response.data is String ? response.data as String : null,
        );
      }
    } catch (e) {
      debugPrint(
        'CommissioningService: Critical error during commissioning: $e',
      );
      return CommissioningResponse(
        commissioningOperationId: operationId,
        commissioningReference: request.commissioningReference,
        status: CommissioningStatus.failed,
        processedAt: DateTime.now(),
        messages: ['Commissioning failed: $e'],
        commissionedCount: 0,
        failedCount: request.serialNumbers.length,
        itemResults: const [],
      );
    }
  }

  Future<({List<CommissioningBatch> batches, bool isLast})> listBatches({
    String? gtin,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDir': sortDir,
        if (gtin != null) 'gtin': gtin,
      };
      final response = await _dioService.get(
        '$_baseUrl/commissioning/batches',
        queryParameters: queryParameters,
        headers: _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>? ?? [];
        final isLast = data['last'] as bool? ?? true;
        final batches = content
            .map((e) => CommissioningBatch.fromJson(e as Map<String, dynamic>))
            .toList();
        return (batches: batches, isLast: isLast);
      }
      return (batches: <CommissioningBatch>[], isLast: true);
    } catch (e) {
      debugPrint('CommissioningService: Error fetching batches: $e');
      return (batches: <CommissioningBatch>[], isLast: true);
    }
  }

  Future<List<CommissioningResponse>> getCommissioningOperations() async {
    const bizStep = 'urn:epcglobal:cbv:bizstep:commissioning';
    try {
      final response = await _dioService.get(
        '$_baseUrl/events/object/business-step/$bizStep',
        headers: _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        final List<dynamic> content = data is List ? data : (data['content'] ?? []);

        return content
            .map((event) => _parseObjectEventToCommissioningResponse(event))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('CommissioningService: Error fetching operations: $e');
      return [];
    }
  }

  Future<CommissioningResponse?> getCommissioningOperation(
    String operationId,
  ) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/events/object/$operationId',
        headers: _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final event = jsonDecode(response.data);
        return _parseObjectEventToCommissioningResponse(event);
      }
      return null;
    } catch (e) {
      debugPrint('CommissioningService: Error fetching operation: $e');
      return null;
    }
  }

  CommissioningResponse _parseObjectEventToCommissioningResponse(
    Map<String, dynamic> event,
  ) {
    final epcList = event['epcList'] as List<dynamic>? ?? [];
    final ilmd = event['ilmd'] as Map<String, dynamic>?;

    String? gtinCode;
    String? batchLotNumber;
    String? itemDescription;
    DateTime? productionDate;
    DateTime? expiryDate;
    DateTime? bestBeforeDate;

    if (ilmd != null) {
      gtinCode = (ilmd['traqtrace:gtin'] ?? ilmd['gtin']) as String?;
      batchLotNumber = (ilmd['cbvmda:lotNumber'] ?? ilmd['lotNumber']) as String?;
      itemDescription = (ilmd['cbvmda:itemDescription'] ?? ilmd['itemDescription']) as String?;

      if (ilmd['cbvmda:productionDate'] ?? ilmd['productionDate'] ?? ilmd['manufacturingDate'] != null) {
        productionDate = _parseDate(
            ilmd['cbvmda:productionDate'] ?? ilmd['productionDate'] ?? ilmd['manufacturingDate']);
      }
      if ((ilmd['cbvmda:itemExpirationDate'] ?? ilmd['itemExpirationDate']) != null) {
        expiryDate = _parseDate(ilmd['cbvmda:itemExpirationDate'] ?? ilmd['itemExpirationDate']);
      }
      if ((ilmd['cbvmda:bestBeforeDate'] ?? ilmd['bestBeforeDate']) != null) {
        bestBeforeDate = _parseDate(ilmd['cbvmda:bestBeforeDate'] ?? ilmd['bestBeforeDate']);
      }
    }

    final itemResults = epcList.map((epc) {
      final epcUri = epc.toString();
      String serialNumber = epcUri;
      if (epcUri.contains('sgtin:')) {
        final parts = epcUri.split('.');
        if (parts.length >= 3) {
          serialNumber = parts.last;
        }
      }
      return CommissioningItemResult(
        serialNumber: serialNumber,
        epcUri: epcUri,
        success: true,
      );
    }).toList();

    return CommissioningResponse(
      commissioningOperationId: event['eventId'],
      eventIds: [event['eventId']],
      commissionedCount: epcList.length,
      failedCount: 0,
      status: CommissioningStatus.success,
      eventTime: event['eventTime'] != null
          ? DateTime.tryParse(event['eventTime'])
          : null,
      processedAt: event['recordTime'] != null
          ? DateTime.tryParse(event['recordTime'])
          : null,
      commissioningLocationGLN: event['businessLocation']?.toString(),
      readPointGLN: event['readPoint']?.toString(),
      gtinCode: gtinCode,
      batchLotNumber: batchLotNumber,
      itemDescription: itemDescription,
      productionDate: productionDate,
      expiryDate: expiryDate,
      bestBeforeDate: bestBeforeDate,
      epcList: epcList.map((e) => e.toString()).toList(),
      businessStep: event['businessStep']?.toString(),
      disposition: event['disposition']?.toString(),
      persistentDisposition: event['persistentDisposition']?.toString(),
      bizTransactionList: event['bizTransactionList'] != null
          ? (event['bizTransactionList'] as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList()
          : null,
      action: event['action']?.toString(),
      itemResults: itemResults,
    );
  }

  Future<CommissioningBatch?> getBatch(String batchId) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/commissioning/batches/$batchId',
        headers: _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as Map<String, dynamic>;
        return CommissioningBatch.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('CommissioningService: Error fetching batch $batchId: $e');
      return null;
    }
  }

  Future<List<CommissioningBatchItem>> getBatchItems(String batchId) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/commissioning/batches/$batchId/items',
        headers: _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.data) as List<dynamic>;
        return data
            .map((e) => CommissioningBatchItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('CommissioningService: Error fetching batch items $batchId: $e');
      return [];
    }
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    final dateStr = dateValue.toString();
    try {
      if (dateStr.length == 10 && dateStr.contains('-')) {
        return DateTime.parse('${dateStr}T00:00:00Z');
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('CommissioningService: Error parsing date $dateStr: $e');
      return null;
    }
  }
}
