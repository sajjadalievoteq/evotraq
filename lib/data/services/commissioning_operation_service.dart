import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/operations/commissioning_models.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

class CommissioningOperationService {
  final DioService _dioService;

  CommissioningOperationService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => _dioService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<CommissioningResponse> createCommissioningOperation(
    CommissioningRequest request,
  ) async {
    final startTime = DateTime.now();
    final operationId = 'comm_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint(
      'CommissioningService: Starting bulk commissioning for ${request.serialNumbers.length} items',
    );

    final List<String> eventIds = [];
    final List<String> createdSgtinIds = [];
    final List<CommissioningItemResult> itemResults = [];
    final List<String> messages = [];
    int successCount = 0;
    int failCount = 0;

    try {
      final headers = await _getHeaders();

      // Process each serial number - create SGTIN (which auto-creates commissioning event)
      for (int i = 0; i < request.serialNumbers.length; i++) {
        final serialNumber = request.serialNumbers[i];

        try {
          debugPrint(
            'CommissioningService: Processing serial $serialNumber (${i + 1}/${request.serialNumbers.length})',
          );

          // Create SGTIN - the backend will automatically create the commissioning ObjectEvent
          final sgtinData = {
            'gtin': request.gtinCode,
            'serialNumber': serialNumber,
            'batchLotNumber': request.batchLotNumber,
            'currentLocationGLN': request.commissioningLocationGLN,
            'status': 'COMMISSIONED',
            if (request.expiryDate != null)
              'expiryDate': request.expiryDate!.toUtc().toIso8601String(),
            if (request.productionDate != null)
              'productionDate': request.productionDate!
                  .toUtc()
                  .toIso8601String(),
            if (request.bestBeforeDate != null)
              'bestBeforeDate': request.bestBeforeDate!
                  .toUtc()
                  .toIso8601String(),
            if (request.regulatoryMarket != null)
              'regulatoryMarket': request.regulatoryMarket,
            if (request.regulatoryStatus != null)
              'regulatoryStatus': request.regulatoryStatus,
          };

          final response = await _dioService.post(
            '$_baseUrl/identifiers/sgtins',
            headers: headers,
            data: jsonEncode(sgtinData),
            responseType: ResponseType.plain,
            acceptAllStatusCodes: true,
          );

          if (response.statusCode == 201) {
            final responseData = jsonDecode(response.data);
            final sgtinId = responseData['id']?.toString();
            final sgtinUri = responseData['sgtinUri'];

            createdSgtinIds.add(sgtinId ?? serialNumber);
            successCount++;

            itemResults.add(
              CommissioningItemResult(
                serialNumber: serialNumber,
                sgtinId: sgtinId,
                epcUri: sgtinUri,
                success: true,
              ),
            );

            debugPrint(
              'CommissioningService: Successfully commissioned $serialNumber -> $sgtinUri',
            );
          } else {
            failCount++;
            String errorMsg;
            try {
              final errorData = jsonDecode(response.data);
              errorMsg = errorData['message'] ?? 'Failed to create SGTIN';
            } catch (_) {
              errorMsg = 'Failed to create SGTIN: ${response.statusMessage}';
            }

            itemResults.add(
              CommissioningItemResult(
                serialNumber: serialNumber,
                success: false,
                errorMessage: errorMsg,
              ),
            );
            messages.add('Failed to commission $serialNumber: $errorMsg');

            debugPrint(
              'CommissioningService: Failed to commission $serialNumber: $errorMsg',
            );
          }
        } catch (e) {
          failCount++;
          itemResults.add(
            CommissioningItemResult(
              serialNumber: serialNumber,
              success: false,
              errorMessage: e.toString(),
            ),
          );
          messages.add('Error commissioning $serialNumber: $e');
          debugPrint(
            'CommissioningService: Error commissioning $serialNumber: $e',
          );
        }
      }

      final processingTime = DateTime.now()
          .difference(startTime)
          .inMilliseconds;

      // Determine overall status
      CommissioningStatus status;
      if (failCount == 0) {
        status = CommissioningStatus.success;
      } else if (successCount == 0) {
        status = CommissioningStatus.failed;
      } else {
        status = CommissioningStatus.partialSuccess;
      }

      return CommissioningResponse(
        commissioningOperationId: operationId,
        commissioningReference: request.commissioningReference,
        eventIds: eventIds,
        createdSgtinIds: createdSgtinIds,
        commissionedCount: successCount,
        failedCount: failCount,
        status: status,
        processedAt: DateTime.now(),
        gtinCode: request.gtinCode,
        batchLotNumber: request.batchLotNumber,
        commissioningLocationGLN: request.commissioningLocationGLN,
        messages: messages.isEmpty
            ? ['Successfully commissioned $successCount items']
            : messages,
        itemResults: itemResults,
        processingTimeMs: processingTime,
        metadata: {
          'operation_id': operationId,
          'total_items': request.serialNumbers.length,
          'success_count': successCount,
          'fail_count': failCount,
        },
      );
    } catch (e) {
      debugPrint(
        'CommissioningService: Critical error during commissioning: $e',
      );
      return CommissioningResponse(
        commissioningOperationId: operationId,
        commissioningReference: request.commissioningReference,
        status: CommissioningStatus.failed,
        processedAt: DateTime.now(),
        messages: ['Critical error during commissioning: $e'],
        commissionedCount: successCount,
        failedCount: request.serialNumbers.length - successCount,
        itemResults: itemResults,
      );
    }
  }

  Future<List<CommissioningResponse>> getCommissioningOperations() async {
    // For now, we'll fetch recent commissioning events from the events API
    // In the future, this could be enhanced with a dedicated endpoint
    try {
      final headers = await _getHeaders();
      final response = await _dioService.get(
        '$_baseUrl/events/object',
        queryParameters: {'bizStep': 'commissioning', 'size': '50'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        final List<dynamic> content = data['content'] ?? data;

        // Group events by commissioning reference if available
        // For now, return each event as a separate operation
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
      final headers = await _getHeaders();
      final response = await _dioService.get(
        '$_baseUrl/events/object/$operationId',
        headers: headers,
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

  /// Parse an ObjectEvent response to CommissioningResponse model
  CommissioningResponse _parseObjectEventToCommissioningResponse(
    Map<String, dynamic> event,
  ) {
    final epcList = event['epcList'] as List<dynamic>? ?? [];
    final ilmd = event['ilmd'] as Map<String, dynamic>?;

    // Parse ILMD (Instance/Lot Master Data) fields
    String? gtinCode;
    String? batchLotNumber;
    String? itemDescription;
    DateTime? productionDate;
    DateTime? expiryDate;
    DateTime? bestBeforeDate;

    if (ilmd != null) {
      gtinCode = ilmd['gtin'] as String?;
      batchLotNumber = ilmd['lotNumber'] as String?;
      itemDescription = ilmd['itemDescription'] as String?;

      // Parse dates - can be in various formats
      if (ilmd['manufacturingDate'] != null) {
        productionDate = _parseDate(ilmd['manufacturingDate']);
      }
      if (ilmd['itemExpirationDate'] != null) {
        expiryDate = _parseDate(ilmd['itemExpirationDate']);
      }
      if (ilmd['bestBeforeDate'] != null) {
        bestBeforeDate = _parseDate(ilmd['bestBeforeDate']);
      }
    }

    // Create item results from epcList
    final itemResults = epcList.map((epc) {
      final epcUri = epc.toString();
      // Extract serial number from EPC URI: urn:epc:id:sgtin:6290000.50003.asdasdas123123123ddd
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
      action: event['action']?.toString(),
      itemResults: itemResults,
    );
  }

  /// Parse date from various formats (ISO date, ISO datetime, etc.)
  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    final dateStr = dateValue.toString();
    try {
      // Try parsing as ISO date (YYYY-MM-DD)
      if (dateStr.length == 10 && dateStr.contains('-')) {
        return DateTime.parse('${dateStr}T00:00:00Z');
      }
      // Try parsing as full ISO datetime
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('CommissioningService: Error parsing date $dateStr: $e');
      return null;
    }
  }
}
