import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/services/epcis/aggregation_event_service.dart';

extension AggregationEventServiceOperations on AggregationEventService {
  /// @Deprecated Prefer [PackingOperationService.createPackingOperation]
  /// (`POST /operations/packing`). Kept for non-UI callers only.
  @Deprecated('Use PackingOperationService.createPackingOperation instead')
  Future<AggregationEvent> createPackEvent(
    String parentEPC,
    List<String> childEPCs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData, {
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    final headers = await getHeaders();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    final String eventTimeZone =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final eventTime = '${now.toIso8601String().split('.')[0]}$eventTimeZone';

    final Map<String, dynamic> requestData = {
      'eventType': 'AggregationEvent',
      'action': 'ADD',
      'eventId': 'pack-${DateTime.now().millisecondsSinceEpoch}',
      'recordTime': now.toIso8601String(),
      'epcisVersion': '2.0',
      'certificationInfo': [],
      'parentID': parentEPC,
      'childEPCs': childEPCs,
      'childQuantityList': [],
      'readPoint': locationGLN,
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTimeZoneOffset': eventTimeZone,
      'eventTimeZone': eventTimeZone,
      'eventTime': eventTime,
    };

    if (sourceList != null && sourceList.isNotEmpty) {
      requestData['sourceList'] = sourceList;
    }

    if (destinationList != null && destinationList.isNotEmpty) {
      requestData['destinationList'] = destinationList;
    }

    final body = json.encode(requestData);

    final response = await dioService.post(
      baseUrl,
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(getDetailedErrorMessage(response));
    }
  }

  /// @Deprecated Prefer [UnpackingOperationService.createUnpackingOperation]
  /// (`POST /operations/unpacking`). Kept for non-UI callers only.
  @Deprecated('Use UnpackingOperationService.createUnpackingOperation instead')
  Future<AggregationEvent> createUnpackEvent(
    String parentEPC,
    List<String>? childEPCs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData, {
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    final headers = await getHeaders();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    final String eventTimeZone =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final eventTime = '${now.toIso8601String().split('.')[0]}$eventTimeZone';

    final Map<String, dynamic> requestData = {
      'eventType': 'AggregationEvent',
      'action': 'DELETE',
      'eventId': 'unpack-${DateTime.now().millisecondsSinceEpoch}',
      'recordTime': now.toIso8601String(),
      'epcisVersion': '2.0',
      'certificationInfo': [],
      'parentID': parentEPC,
      'childEPCs': childEPCs,
      'childQuantityList': [],
      'readPoint': locationGLN,
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTimeZoneOffset': eventTimeZone,
      'eventTimeZone': eventTimeZone,
      'eventTime': eventTime,
    };

    if (sourceList != null && sourceList.isNotEmpty) {
      requestData['sourceList'] = sourceList;
    }

    if (destinationList != null && destinationList.isNotEmpty) {
      requestData['destinationList'] = destinationList;
    }

    final body = json.encode(requestData);

    final response = await dioService.post(
      baseUrl,
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(getDetailedErrorMessage(response));
    }
  }

  String getDetailedErrorMessage(Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.data);
      final String message = errorData['message'] ?? 'Unknown error';

      if (errorData.containsKey('errors') && errorData['errors'] is List) {
        List<dynamic> errors = errorData['errors'];

        if (errors.isNotEmpty) {
          List<String> parentErrors = [];
          List<String> childErrors = [];
          List<String> otherErrors = [];

          for (String error in errors) {
            if (error.startsWith('Parent EPC not commissioned')) {
              parentErrors.add(
                error.substring('Parent EPC not commissioned: '.length),
              );
            } else if (error.startsWith('Child EPC not commissioned')) {
              childErrors.add(
                error.substring('Child EPC not commissioned: '.length),
              );
            } else {
              otherErrors.add(error);
            }
          }

          StringBuffer friendlyMessage = StringBuffer('Validation Error:\n');

          if (parentErrors.isNotEmpty) {
            friendlyMessage.write(
              '\nParent container not found in the system. Please create or commission the following container first:\n',
            );
            friendlyMessage.write('• ${parentErrors.join('\n• ')}\n');
          }

          if (childErrors.isNotEmpty) {
            friendlyMessage.write(
              '\nThe following items have not been commissioned in the system:\n',
            );
            friendlyMessage.write('• ${childErrors.join('\n• ')}\n');
            friendlyMessage.write(
              '\nPlease create a commissioning event for these items first.\n',
            );
          }

          if (otherErrors.isNotEmpty) {
            friendlyMessage.write('\nOther issues:\n');
            friendlyMessage.write('• ${otherErrors.join('\n• ')}\n');
          }

          return friendlyMessage.toString();
        }
      }

      return 'Error: $message';
    } catch (_) {
      return 'Error: Unable to process the request. Please check your input and try again.';
    }
  }

  /// Direct children of [parentEPC] via the canonical hierarchy children API
  /// (`GET /events/aggregation/children`). Prefer this over traversal
  /// `contained-items` for product/ops UIs.
  Future<List<String>> findContainerContents(String parentEPC) async {
    final headers = await getHeaders();
    const pageSize = 200;
    final all = <String>[];
    var page = 0;

    try {
      while (true) {
        final response = await dioService.get(
          '$baseUrl/children',
          queryParameters: {
            'parentEPC': parentEPC,
            'page': page.toString(),
            'size': pageSize.toString(),
          },
          headers: headers,
          responseType: ResponseType.plain,
          acceptAllStatusCodes: true,
        );

        if (response.statusCode != 200) {
          throw Exception(getDetailedErrorMessage(response));
        }

        final data = json.decode(response.data) as Map<String, dynamic>;
        final children = data['children'] as List<dynamic>? ?? const [];
        for (final raw in children) {
          if (raw is! Map<String, dynamic>) continue;
          final epc = raw['epc']?.toString().trim();
          if (epc != null && epc.isNotEmpty) all.add(epc);
        }

        final hasMore = data['hasMore'] as bool? ?? false;
        final totalPages = (data['totalPages'] as num?)?.toInt() ?? (page + 1);
        if (!hasMore || page + 1 >= totalPages) break;
        page++;
      }
      return all;
    } catch (e) {
      rethrow;
    }
  }

  /// Integrity check using the same children/container APIs as the hierarchy UI
  /// (no separate traversal `contained-items` round-trip).
  Future<bool> verifyHierarchy(String epc) async {
    try {
      await findContainerContents(epc);
      return true;
    } catch (_) {
      try {
        final headers = await getHeaders();
        final containerResponse = await dioService.get(
          '$baseUrl/container',
          queryParameters: {'childEPC': epc},
          headers: headers,
          responseType: ResponseType.plain,
          acceptAllStatusCodes: true,
        );
        return containerResponse.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }
}
