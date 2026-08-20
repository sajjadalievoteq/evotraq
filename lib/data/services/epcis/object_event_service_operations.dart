import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_api_constants.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_service.dart';

extension ObjectEventServiceOperations on ObjectEventService {
  Future<Map<String, dynamic>> validateObjectEvent(ObjectEvent event) async {
    final headers = await getHeaders();
    try {
      final response = await dioService.post(
        '$baseUrl/${ObjectEventApiConstants.segmentValidate}',
        headers: headers,
        data: json.encode(event.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      final responseData = json.decode(response.data) as Map<String, dynamic>;

      return responseData;
    } catch (e) {
      return {
        'valid': false,
        'error': 'Failed to validate object event: $e',
        'validationErrors': [],
      };
    }
  }

  Future<List<ObjectEvent>> createObjectEventsBatch(
    List<ObjectEvent> events,
  ) async {
    final headers = await getHeaders();
    final response = await dioService.post(
      '$baseUrl/${ObjectEventApiConstants.segmentBatch}',
      headers: headers,
      data: json.encode(events.map((e) => e.toJson()).toList()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      final List<dynamic> eventsData = data['events'];
      return eventsData.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to create object events batch: ${response.data}');
    }
  }

  Future<ObjectEvent> updateObjectEvent(String id, ObjectEvent event) async {
    final headers = await getHeaders();
    final response = await dioService.put(
      '$baseUrl/$id',
      headers: headers,
      data: json.encode(event.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to update object event: ${response.statusCode}');
    }
  }

  Future<void> deleteObjectEvent(String id) async {
    final headers = await getHeaders();
    final response = await dioService.delete(
      '$baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete object event: ${response.statusCode}');
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByAction(String action) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentAction}/$action',
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByEPC(String epc) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentEpc}',
      queryParameters: {ObjectEventApiConstants.queryEpc: epc},
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByEPCs(List<String> epcs) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentEpcs}',
      queryParameters: {ObjectEventApiConstants.queryEpcs: epcs.join(',')},
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByEPCClass(String epcClass) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentEpcClass}',
      queryParameters: {ObjectEventApiConstants.queryEpcClass: epcClass},
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByILMD(
    String property,
    String value,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentIlmd}',
      queryParameters: {
        ObjectEventApiConstants.queryProperty: property,
        ObjectEventApiConstants.queryValue: value,
      },
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByQuantity(
    String epcClass,
    double minQuantity,
    double maxQuantity,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentQuantity}',
      queryParameters: {
        ObjectEventApiConstants.queryEpcClass: epcClass,
        ObjectEventApiConstants.queryMin: minQuantity.toString(),
        ObjectEventApiConstants.queryMax: maxQuantity.toString(),
      },
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByBusinessStep(
    String businessStep,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentBusinessStep}/$businessStep',
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByDisposition(
    String disposition,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentDisposition}/$disposition',
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByLocation(
    String locationGLN,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentLocation}',
      queryParameters: {ObjectEventApiConstants.queryLocationGln: locationGLN},
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByTimeWindow(
    DateTime startTime,
    DateTime endTime,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentTimeRange}',
      queryParameters: {
        ObjectEventApiConstants.queryStartTime: startTime
            .toUtc()
            .toIso8601String(),
        ObjectEventApiConstants.queryEndTime: endTime.toUtc().toIso8601String(),
      },
    );
  }

  Future<List<ObjectEvent>> findObjectEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    return fetchAllObjectEvents(
      '$baseUrl/${ObjectEventApiConstants.segmentLocation}/${ObjectEventApiConstants.segmentTimeRange}',
      queryParameters: {
        ObjectEventApiConstants.queryLocationGln: locationGLN,
        ObjectEventApiConstants.queryStartTime: startTime
            .toUtc()
            .toIso8601String(),
        ObjectEventApiConstants.queryEndTime: endTime.toUtc().toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>> getEventStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final headers = await getHeaders();

    final queryParams = <String, String>{};
    if (startTime != null) {
      queryParams[ObjectEventApiConstants.queryStartTime] = startTime
          .toIso8601String();
    }
    if (endTime != null) {
      queryParams[ObjectEventApiConstants.queryEndTime] = endTime
          .toIso8601String();
    }

    final uri = Uri.parse(
      '$baseUrl/${ObjectEventApiConstants.segmentStatistics}',
    ).replace(queryParameters: queryParams);
    final response = await dioService.get(
      uri.toString(),
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);

      Map<String, dynamic> transformedData = {
        'totalEvents': data['totalEvents'] ?? 0,
        'recentEvents': data['recentEvents'] ?? 0,
      };

      if (data['eventsByAction'] != null) {
        transformedData['actionCounts'] = data['eventsByAction'];
      }

      if (data['topBusinessSteps'] != null) {
        transformedData['businessStepCounts'] = data['topBusinessSteps'];
      }

      if (data['topDispositions'] != null) {
        transformedData['dispositionCounts'] = data['topDispositions'];
      } else {
        transformedData['dispositionCounts'] = <String, int>{};
      }

      return transformedData;
    } else {
      throw Exception('Failed to fetch event statistics: ${response.data}');
    }
  }

  Future<List<ObjectEvent>> findEPCHistory(String epc) async {
    return findObjectEventsByEPC(epc);
  }

  Future<ObjectEvent> getCurrentStatusOfEPC(String epc) async {
    final history = await findEPCHistory(epc);
    if (history.isEmpty) {
      throw Exception('No events found for EPC: $epc');
    }
    return history.first;
  }
}
