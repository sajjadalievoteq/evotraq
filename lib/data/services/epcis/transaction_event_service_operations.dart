part of 'transaction_event_service.dart';

extension TransactionEventServiceOperations on TransactionEventService {
  Future<TransactionEvent> createAddTransactionEvent(
    String bizTransactionType,
    String bizTransactionId,
    List<String> epcs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
    DateTime eventTime,
  ) async {
    final headers = await _getHeaders();

    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';
    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': _formatDateForBackend(DateTime.now()),
      'eventTimeZoneOffset': eventTimeZoneOffset,
      'eventType': 'TransactionEvent',
      'epcisVersion': '2.0',
      'certificationInfo': <String>[],
      'bizTransactionList': bizTransactionList,
      'epcList': epcs,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'action': 'ADD',
      'parentID':
          'https://id.gs1.org/00/${(DateTime.now().millisecondsSinceEpoch % 100000000000000000).toString().padLeft(18, '0')}',
      'quantityList': <Map<String, dynamic>>[],
    };

    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] = locationGLN;
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

    final response = await _dioService.post(
      '$_baseUrl/add',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      final errorBody = response.data;
      try {
        final errorJson = json.decode(errorBody);
        final message =
            errorJson['message'] ?? 'Failed to create ADD transaction event';
        throw Exception('$message (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception(
          'Failed to create ADD transaction event: ${response.statusCode} - $errorBody',
        );
      }
    }
  }

  Future<TransactionEvent> createDeleteTransactionEvent(
    String bizTransactionType,
    String bizTransactionId,
    List<String> epcs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
    DateTime eventTime,
  ) async {
    final headers = await _getHeaders();

    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';
    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': _formatDateForBackend(DateTime.now()),
      'eventTimeZoneOffset': eventTimeZoneOffset,
      'eventType': 'TransactionEvent',
      'epcisVersion': '2.0',
      'certificationInfo': <String>[],
      'bizTransactionList': bizTransactionList,
      'epcList': epcs,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'action': 'DELETE',
      'parentID':
          'https://id.gs1.org/00/${(DateTime.now().millisecondsSinceEpoch % 100000000000000000).toString().padLeft(18, '0')}',
      'quantityList': <Map<String, dynamic>>[],
    };

    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] = locationGLN;
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

    final response = await _dioService.post(
      '$_baseUrl/delete',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      final errorBody = response.data;
      try {
        final errorJson = json.decode(errorBody);
        final message =
            errorJson['message'] ?? 'Failed to create DELETE transaction event';
        throw Exception('$message (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception(
          'Failed to create DELETE transaction event: ${response.statusCode} - $errorBody',
        );
      }
    }
  }

  Future<TransactionEvent> createObserveTransactionEvent(
    String bizTransactionType,
    String bizTransactionId,
    List<String> epcs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
    DateTime eventTime,
  ) async {
    final headers = await _getHeaders();

    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';

    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': _formatDateForBackend(DateTime.now()),
      'eventTimeZoneOffset': eventTimeZoneOffset,
      'eventType': 'TransactionEvent',
      'epcisVersion': '2.0',
      'certificationInfo': <String>[],
      'bizTransactionList': bizTransactionList,
      'epcList': epcs,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'action': 'OBSERVE',
      'parentID':
          'https://id.gs1.org/00/${(DateTime.now().millisecondsSinceEpoch % 100000000000000000).toString().padLeft(18, '0')}',
      'quantityList': <Map<String, dynamic>>[],
    };

    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] = locationGLN;
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      final errorBody = response.data;
      try {
        final errorJson = json.decode(errorBody);
        final message =
            errorJson['message'] ??
            'Failed to create OBSERVE transaction event';
        throw Exception('$message (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception(
          'Failed to create OBSERVE transaction event: ${response.statusCode} - $errorBody',
        );
      }
    }
  }

  String _formatDateForBackend(DateTime dateTime) {
    final utcDateTime = dateTime.toUtc().subtract(const Duration(seconds: 30));
    String isoString = utcDateTime.toIso8601String();

    if (isoString.endsWith('Z') ||
        isoString.contains('+') ||
        isoString.contains('-', isoString.length - 6)) {
      return isoString;
    }

    return '${isoString}Z';
  }

  String _getTimezoneOffset() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
