import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

class ProductJourneyService {
  ProductJourneyService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => _dioService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ProductJourney?> getJourneyByEpc(String epcUri) async {
    try {
      final headers = await _getHeaders();
      final canonicalEpc = await _resolveCanonicalEpc(epcUri, headers);

      // Query param (not path): Digital Links like https://id.gs1.org/00/... contain
      // '/' which breaks Flutter web XMLHttpRequest when placed in the URL path.
      final response = await _dioService.get(
        '$_baseUrl/product-journey/epc',
        queryParameters: {'epc': canonicalEpc},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = decodeApiResponseBody(response.data);
        if (data is Map<String, dynamic>) {
          return ProductJourney.fromBackendJson(data);
        }
      }
      if (response.statusCode == 404) return null;
      return null;
    } catch (e) {
      debugPrint('ProductJourneyService: getJourneyByEpc error: $e');
      return null;
    }
  }

  Future<ProductJourney?> getJourneyByGtinSerial(
    String gtin,
    String serialNumber,
  ) async {
    try {
      final headers = await _getHeaders();

      // Search by serial number to retrieve the canonical EPC stored by the
      // backend. This avoids GCP-length guessing and replaces the old
      // /identifiers/sgtins/search endpoint (which does not exist).
      final searchResponse = await _dioService.get(
        '$_baseUrl/product-journey/search',
        queryParameters: {'q': serialNumber, 'size': '5'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (searchResponse.statusCode == 200) {
        final data = decodeApiResponseBody(searchResponse.data);
        final List<dynamic> items = data is List ? data : const [];
        final gtin14 = gtin.padLeft(14, '0');

        for (final item in items) {
          final candidate = Map<String, dynamic>.from(item as Map);
          final candidateSerial = candidate['serialNumber']?.toString();
          final candidateGtin =
              candidate['gtin']?.toString().padLeft(14, '0');
          if (candidateSerial == serialNumber &&
              (candidateGtin == null || candidateGtin == gtin14)) {
            final identifier = candidate['identifier']?.toString();
            if (identifier != null && identifier.isNotEmpty) {
              return getJourneyByEpc(identifier);
            }
          }
        }
      }

      // Fallback: construct EPC directly using the converter (correct GCP split).
      final epcUri =
          EPCURIConverter.convertGTINSerialToEPCUri(gtin, serialNumber);
      if (epcUri != null) return getJourneyByEpc(epcUri);
      return null;
    } catch (e) {
      debugPrint(
        'ProductJourneyService: Error getting journey by GTIN/serial: $e',
      );
      return null;
    }
  }

  Future<ProductJourney?> getJourneyBySscc(String sscc) async {
    final trimmed = sscc.trim();
    if (trimmed.isEmpty) return null;
    final canonical = Gs1CanonicalIdentifier.forStorage(trimmed);
    return getJourneyByEpc(canonical);
  }

  /// Resolves SGTIN, SSCC, GS1 barcodes, EPC URNs, or plain serial via [parseToEPC].
  Future<ProductJourney?> getJourneyByIdentifier(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    try {
      final parsed = parseToEPC(trimmed);
      return _journeyForParsed(parsed);
    } on EPCParseException catch (e) {
      debugPrint('ProductJourneyService: parse failed ($trimmed): $e');
      return _journeyForUnparsed(trimmed);
    }
  }

  Future<ProductJourney?> _journeyForParsed(EPCParseResult parsed) async {
    switch (parsed.type) {
      case EPCType.sgtin:
        final gtin = parsed.gtin;
        final serial = parsed.serial;
        if (gtin != null && serial != null && serial.isNotEmpty) {
          final viaGtinSerial = await getJourneyByGtinSerial(gtin, serial);
          if (viaGtinSerial != null) return viaGtinSerial;
        }
        return getJourneyByEpc(parsed.epc);
      case EPCType.sscc:
        return getJourneyBySscc(parsed.sscc ?? parsed.epc);
      case EPCType.gtin:
      case EPCType.unknown:
        return getJourneyByEpc(parsed.epc);
    }
  }

  Future<ProductJourney?> _journeyForUnparsed(String trimmed) async {
    if (Gs1CanonicalIdentifier.isSerializedInstance(trimmed) ||
        Gs1CanonicalIdentifier.isValid(trimmed)) {
      return getJourneyByEpc(trimmed);
    }

    // Safety net: if AI notation somehow reached here, normalize it.
    if (trimmed.contains('(') && trimmed.contains(')')) {
      final normalized = gs1AiToEpcUri(trimmed);
      if (normalized != null) return getJourneyByEpc(normalized);
    }

    final results = await searchProducts(trimmed);
    if (results.length == 1) {
      return getJourneyByEpc(results.first.identifier);
    }
    if (results.length > 1) {
      final lowered = trimmed.toLowerCase();
      final exact = results.where((r) {
        final serial = r.serialNumber?.toLowerCase();
        final display = r.displayName.toLowerCase();
        return serial == lowered || display == lowered;
      }).toList();
      if (exact.length == 1) {
        return getJourneyByEpc(exact.first.identifier);
      }
    }

    return getJourneyByEpc(trimmed);
  }

  Future<List<ProductSearchResult>> searchProducts(String query) async {
    final trimmed = query.trim();

    // Pure EPC identity — show as a direct trace suggestion without hitting the API.
    if (Gs1CanonicalIdentifier.isSerializedInstance(trimmed) ||
        Gs1CanonicalIdentifier.isValid(trimmed)) {
      try {
        final parsed = parseToEPC(trimmed);
        final displayId =
            parsed.serial ?? parsed.sscc ?? trimmed.split('.').lastOrNull ?? trimmed;
        return [
          ProductSearchResult(
            identifier: parsed.epc,
            displayName: displayId,
            type: _inferIdentifierType(parsed.epc),
            description: 'Trace this EPC directly',
          ),
        ];
      } on EPCParseException catch (_) {
        final serial = trimmed.split('.').lastOrNull ?? trimmed;
        return [
          ProductSearchResult(
            identifier: trimmed,
            displayName: serial,
            type: _inferIdentifierType(trimmed),
            description: 'Trace this EPC directly',
          ),
        ];
      }
    }

    // GS1 AI notation e.g. (01)00629...(21)SERIAL — parse and show the
    // resolved EPC as a suggestion; use the serial for the backend search.
    if (trimmed.contains('(') && trimmed.contains(')')) {
      try {
        final parsed = parseToEPC(trimmed);
        final displayId = parsed.serial ?? parsed.gtin ?? trimmed;
        // Show the resolved EPC as a direct suggestion.
        final suggestion = ProductSearchResult(
          identifier: parsed.epc,
          displayName: displayId,
          type: _inferIdentifierType(parsed.epc),
          description: 'Trace by GS1 barcode',
        );
        // Also search the backend by serial for additional matches.
        if (parsed.serial != null) {
          final extra = await _backendSearch(parsed.serial!, size: 9);
          return [suggestion, ...extra.where((r) => r.identifier != parsed.epc)];
        }
        return [suggestion];
      } on EPCParseException catch (_) {
        // Fall through to raw backend search.
      }
    }

    return _backendSearch(trimmed);
  }

  Future<List<ProductSearchResult>> _backendSearch(
    String query, {
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dioService.get(
        '$_baseUrl/product-journey/search',
        queryParameters: {'q': query, 'size': '$size'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = decodeApiResponseBody(response.data);
        final List<dynamic> items = data is List ? data : const [];
        return items
            .whereType<Map>()
            .map((item) => ProductSearchResult.fromBackendJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('ProductJourneyService: Error searching products: $e');
      return [];
    }
  }

  Future<String> _resolveCanonicalEpc(
    String epcUri,
    Map<String, String> headers,
  ) async {
    final normalized = Gs1CanonicalIdentifier.forStorage(epcUri);
    if (!Gs1CanonicalIdentifier.isSgtin(normalized) &&
        !Gs1CanonicalIdentifier.isSscc(normalized)) {
      return normalized;
    }
    try {
      final serialOrSscc = Gs1CanonicalIdentifier.extractSerial(normalized) ??
          Gs1CanonicalIdentifier.extractSscc18(normalized) ??
          '';
      if (serialOrSscc.isEmpty) return normalized;

      final response = await _dioService.get(
        '$_baseUrl/product-journey/search',
        queryParameters: {'q': serialOrSscc, 'size': '5'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = decodeApiResponseBody(response.data);
        final List<dynamic> items = data is List ? data : const [];
        for (final item in items) {
          final candidate = Map<String, dynamic>.from(item as Map);
          final identifier = candidate['identifier']?.toString();
          if (identifier == null || identifier.isEmpty) continue;
          final candidateSerial = candidate['serialNumber']?.toString();
          final displayName = candidate['displayName']?.toString();
          final type = candidate['type']?.toString();
          final matchesSgtin = (type == 'SGTIN') &&
              (candidateSerial == serialOrSscc || displayName == serialOrSscc);
          final matchesSscc = (type == 'SSCC') &&
              (displayName == serialOrSscc ||
                  identifier.endsWith(serialOrSscc) ||
                  identifier.contains(serialOrSscc));
          if (matchesSgtin || matchesSscc) {
            debugPrint(
              'ProductJourneyService: Resolved canonical EPC '
              '$epcUri → $identifier',
            );
            return identifier;
          }
        }
      }
    } catch (e) {
      debugPrint('ProductJourneyService: EPC normalization failed: $e');
    }
    return normalized;
  }

  String _inferIdentifierType(String identifier) {
    return switch (Gs1CanonicalIdentifier.classify(identifier)) {
      Gs1CanonicalKind.sgtin => 'SGTIN',
      Gs1CanonicalKind.sscc => 'SSCC',
      Gs1CanonicalKind.lgtin || Gs1CanonicalKind.classGtin => 'GTIN',
      _ => 'EPC',
    };
  }

}
