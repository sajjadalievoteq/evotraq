part of 'object_event_service.dart';

extension ObjectEventServiceConvenienceOperations on ObjectEventService {
  Future<ObjectEvent> createAddEvent(
    String epc,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, dynamic> ilmd,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    final eventData = {
      ObjectEventApiConstants.jsonKeyAction: ObjectEventApiConstants.actionAdd,
      ObjectEventApiConstants.jsonKeyEpcList: [epc],
      ObjectEventApiConstants.jsonKeyBusinessLocation: locationGLN,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyIlmd: ilmd,
      ObjectEventApiConstants.jsonKeyBizData: bizData,
      ObjectEventApiConstants.jsonKeyEventTime: DateTime.now()
          .toIso8601String(),
      ObjectEventApiConstants.jsonKeyEventTimeZoneOffset:
          _localTimezoneOffset(),
    };

    final response = await _dioService.post(
      '$_baseUrl/${ObjectEventApiConstants.segmentAdd}',
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create ADD event: ${response.data}');
    }
  }

  Future<ObjectEvent> createObserveEvent(
    String epc,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    final eventData = {
      ObjectEventApiConstants.jsonKeyAction:
          ObjectEventApiConstants.actionObserve,
      ObjectEventApiConstants.jsonKeyEpcList: [epc],
      ObjectEventApiConstants.jsonKeyBusinessLocation: locationGLN,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyBizData: bizData,
      ObjectEventApiConstants.jsonKeyEventTime: DateTime.now()
          .toIso8601String(),
      ObjectEventApiConstants.jsonKeyEventTimeZoneOffset:
          _localTimezoneOffset(),
    };

    final response = await _dioService.post(
      '$_baseUrl/${ObjectEventApiConstants.segmentObserve}',
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create OBSERVE event: ${response.data}');
    }
  }

  Future<ObjectEvent> createDeleteEvent(
    String epc,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    final eventData = {
      ObjectEventApiConstants.jsonKeyAction:
          ObjectEventApiConstants.actionDelete,
      ObjectEventApiConstants.jsonKeyEpcList: [epc],
      ObjectEventApiConstants.jsonKeyBusinessLocation: locationGLN,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyBizData: bizData,
      ObjectEventApiConstants.jsonKeyEventTime: DateTime.now()
          .toIso8601String(),
      ObjectEventApiConstants.jsonKeyEventTimeZoneOffset:
          _localTimezoneOffset(),
    };

    final response = await _dioService.post(
      '$_baseUrl/${ObjectEventApiConstants.segmentDelete}',
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create DELETE event: ${response.data}');
    }
  }

  Future<List<ObjectEvent>> findObjectEventsWithSensorData(
    Map<String, dynamic> sensorCriteria,
  ) async {
    final all = await _fetchAllObjectEvents(_baseUrl);
    return all
        .where(
          (event) =>
              event.sensorElementList != null &&
              event.sensorElementList!.isNotEmpty,
        )
        .toList();
  }

  Future<bool> validateEPC(String epc) async {
    final normalized = Gs1Converter.normalizeForStorage(epc);
    return normalized.startsWith('https://id.gs1.org/01/') ||
        normalized.startsWith('https://id.gs1.org/00/') ||
        normalized.startsWith('https://id.gs1.org/414/') ||
        RegExp(
          r'^urn:epc:id:(sgtin|sscc|sgln):',
          caseSensitive: false,
        ).hasMatch(epc);
  }

  Future<String> convertGS1ElementStringToEPC(String gs1ElementString) async {
    final converted = Gs1Converter.barcodeToEpc(gs1ElementString);
    if (converted != null) return converted;

    if (gs1ElementString.startsWith('01') && gs1ElementString.contains('21')) {
      final gtin = gs1ElementString.substring(2, 16);
      final serial = gs1ElementString.substring(
        gs1ElementString.indexOf('21') + 2,
      );
      return Gs1Converter.gtinSerialToEpc(gtin, serial) ??
          'https://id.gs1.org/01/${gtin.padLeft(14, '0')}/21/$serial';
    }

    if (gs1ElementString.startsWith('00')) {
      final sscc = gs1ElementString.substring(2, 20);
      return Gs1Converter.ssccToEpc(sscc) ?? 'https://id.gs1.org/00/$sscc';
    }

    throw Exception('Unsupported GS1 element string format');
  }

  Future<List<ObjectEvent>> findObjectEventsByBusinessStepAndEPC(
    String businessStep,
    String epc,
  ) async {
    return _fetchAllObjectEvents(
      '$_baseUrl/${ObjectEventApiConstants.segmentBusinessStep}/$businessStep/${ObjectEventApiConstants.segmentEpc}',
      queryParameters: {ObjectEventApiConstants.queryEpc: epc},
    );
  }

  Future<Map<String, dynamic>> searchObjectEvents({
    String? action,
    String? bizStep,
    String? disposition,
    String? locationGLN,
    String? searchText,
    DateTime? startTime,
    DateTime? endTime,
    int page = 0,
    int size = 20,
    String direction = 'DESC',
  }) async {
    final headers = await _getHeaders();
    final params = <String, String>{
      ObjectEventApiConstants.queryPage: page.toString(),
      ObjectEventApiConstants.querySize: size.toString(),
      ObjectEventApiConstants.queryDirection: direction,
    };
    if (action != null) {
      params[ObjectEventApiConstants.queryAction] = action;
    }
    if (bizStep != null) {
      params[ObjectEventApiConstants.queryBizStep] = bizStep;
    }
    if (disposition != null) {
      params[ObjectEventApiConstants.queryDisposition] = disposition;
    }
    if (locationGLN != null) {
      params[ObjectEventApiConstants.queryLocationGln] = locationGLN;
    }
    if (searchText != null) {
      params[ObjectEventApiConstants.querySearchText] = searchText;
    }
    if (startTime != null) {
      params[ObjectEventApiConstants.queryStartTime] = startTime
          .toUtc()
          .toIso8601String();
    }
    if (endTime != null) {
      params[ObjectEventApiConstants.queryEndTime] = endTime
          .toUtc()
          .toIso8601String();
    }

    final response = await _dioService.get(
      '$_baseUrl/${ObjectEventApiConstants.segmentSearch}',
      queryParameters: params,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final raw = PageResponseUtils.normalizeBody(json.decode(response.data));
      final content = PageResponseUtils.contentList(
        raw,
      ).map((e) => ObjectEvent.fromJson(e as Map<String, dynamic>)).toList();
      return PageResponseUtils.toResultMap(content: content, raw: raw);
    } else {
      throw Exception('Failed to search object events: ${response.statusCode}');
    }
  }

  Future<List<ObjectEvent>> getEpcHistory(String epc) async {
    return _fetchAllObjectEvents(
      '$_baseUrl/${ObjectEventApiConstants.segmentEpc}/${ObjectEventApiConstants.segmentHistory}',
      queryParameters: {ObjectEventApiConstants.queryEpc: epc},
    );
  }

  String _localTimezoneOffset() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    return '$sign$hours:$minutes';
  }
}
