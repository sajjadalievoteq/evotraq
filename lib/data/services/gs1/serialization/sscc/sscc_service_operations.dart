part of 'sscc_service.dart';

extension SsccServiceOperations on SSCCService {
  Future<String> generateSSCCCode(
    String gs1CompanyPrefix,
    String extensionDigit,
  ) async {
    final Map<String, String> requestBody = {
      'companyPrefix': gs1CompanyPrefix,
      'containerType': 'PALLET',
    };
    if (extensionDigit.isNotEmpty) {
      requestBody['extensionDigit'] = extensionDigit;
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathGenerate}',
      headers: SSCCService._headers,
      data: json.encode(requestBody),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);

      String? ssccCode;
      if (responseData.containsKey('sscc') && responseData['sscc'] != null) {
        ssccCode = responseData['sscc'].toString();
      } else if (responseData.containsKey('ssccCode') &&
          responseData['ssccCode'] != null) {
        ssccCode = responseData['ssccCode'].toString();
      } else if (responseData.containsKey('id')) {
        try {
          ssccCode = SSCC.fromJson(responseData).ssccCode;
        } catch (_) {}
      }

      if (ssccCode != null) {
        final validatedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
        if (validatedSSCC != null) {
          return validatedSSCC;
        }
        try {
          return GS1Utils.generateSSCC(gs1CompanyPrefix, extensionDigit);
        } catch (e) {
          throw ApiException(
            message:
                'Invalid SSCC format from API and local generation failed: $e',
          );
        }
      }
      throw ApiException(
        message:
            'Invalid response format: SSCC code not found in response: $responseData',
      );
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to generate SSCC code: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<bool> validateSSCCCode(String ssccCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathValidate}',
      queryParameters: {'ssccCode': ssccCode},
      headers: SSCCService._headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      return data[SsccServiceConstants.rIsValid] as bool;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate SSCC code: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SsccAggregationLink>> getAggregationLinksByCode(
    String ssccCode,
  ) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathAggregationByCode}',
      queryParameters: {SsccServiceConstants.qSsccCode: ssccCode},
      headers: SSCCService._headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusOk) {
      final List<dynamic> data = json.decode(response.data);
      return data
          .map(
            (item) =>
                SsccAggregationLink.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load aggregation links: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<SsccAggregationLink> addAggregationLink(
    String ssccId, {
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathAggregation(ssccId)}',
      headers: SSCCService._headers,
      data: json.encode({
        'childEpc': childEpc,
        'childKind': childKind,
        'aggregationEventId': aggregationEventId,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusCreated ||
        response.statusCode == SsccServiceConstants.statusOk) {
      return SsccAggregationLink.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to add aggregation link: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<SsccAggregationLink> disaggregateLink(
    int linkId, {
    required String disaggregationEventId,
  }) async {
    final response = await _dioService.patch(
      '${_dioService.baseUrl}${SsccServiceConstants.pathDisaggregate(linkId)}',
      headers: SSCCService._headers,
      data: json.encode({'disaggregationEventId': disaggregationEventId}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusOk) {
      return SsccAggregationLink.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to disaggregate link: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<String> extractCompanyPrefixFromGLN(String glnInput) async {
    if (glnInput.isEmpty) {
      throw ApiException(message: 'GLN input cannot be empty');
    }

    final urnPrefixRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\..*');
    final urnPrefixMatch = urnPrefixRegex.firstMatch(glnInput);
    if (urnPrefixMatch != null && urnPrefixMatch.group(1) != null) {
      return urnPrefixMatch.group(1)!;
    }

    String? glnCode;
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      glnCode = glnInput;
    } else {
      try {
        glnCode = await _parseGLNFromFormat(glnInput);
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse GLN from input: ${e.toString()}',
        );
      }
    }

    if (glnCode == null || glnCode.isEmpty) {
      throw ApiException(
        message:
            'Invalid GLN format. GLN must be in one of these formats: '
            '13 digits, (414)nnnnnnnnnnnn, or urn:epc:id:sgln:prefix.reference.0',
      );
    }
    if (glnCode.length != 13 || !RegExp(r'^\d{13}$').hasMatch(glnCode)) {
      throw ApiException(message: 'Invalid GLN format. GLN must be 13 digits');
    }

    return glnCode.substring(0, 7);
  }

  Future<String?> _parseGLNFromFormat(String input) async {
    try {
      final result = GS1Utils.extractGLNCode(input);
      if (result != null && result.isNotEmpty) return result;
    } catch (_) {}

    final barcodeMatch = RegExp(r'\(414\)(\d{13})').firstMatch(input);
    if (barcodeMatch?.group(1) != null) {
      return barcodeMatch!.group(1);
    }

    final urnMatch = RegExp(
      r'urn:epc:id:sgln:(\d{7,10})\.(\d{1,5})\.(\d)',
    ).firstMatch(input);
    if (urnMatch != null) {
      final companyPrefix = urnMatch.group(1);
      final locationReference = urnMatch.group(2)?.padLeft(5, '0');
      if (companyPrefix != null && locationReference != null) {
        final glnWithoutCheck = companyPrefix + locationReference;
        return glnWithoutCheck + _calculateGS1CheckDigit(glnWithoutCheck);
      }
    }

    if (input.length == 13 && RegExp(r'^\d{13}$').hasMatch(input)) return input;
    return null;
  }

  String _calculateGS1CheckDigit(String digits) {
    return CheckDigitUtils.calculateMod10String(digits);
  }

  static void _normalizeFields(Map<String, dynamic> data) {
    if (data.containsKey('sscc') && !data.containsKey('ssccCode')) {
      data['ssccCode'] = data['sscc'];
    }
    if (!data.containsKey('createdAt') && data.containsKey('statusDate')) {
      data['createdAt'] = data['statusDate'];
    }
    if (!data.containsKey('updatedAt') && data.containsKey('statusDate')) {
      data['updatedAt'] = data['statusDate'];
    }
  }
}
