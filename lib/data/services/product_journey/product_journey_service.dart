import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/models/product_journey/product_search_result.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';

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
      // Normalize SGTIN URIs: company-prefix format can vary between what the
      // user scans and what the DB stores (e.g. 062920.0007000 vs 0629200.001000).
      final canonicalEpc = await _resolveCanonicalEpc(epcUri, headers);
      final events = await _fetchEventsForEpc(canonicalEpc, headers);

      if (events.isEmpty) return null;

      events.sort((a, b) {
        final timeA = DateTime.tryParse(a['eventTime']?.toString() ?? '') ??
            DateTime.now();
        final timeB = DateTime.tryParse(b['eventTime']?.toString() ?? '') ??
            DateTime.now();
        return timeA.compareTo(timeB);
      });

      final steps = events.map(JourneyStep.fromEventJson).toList();

      ProductInfo? productInfo;
      for (final step in steps) {
        if (step.businessStep.contains('commissioning') && step.ilmd != null) {
          productInfo = ProductInfo.fromILMD(step.ilmd);
          break;
        }
      }

      await _enrichStepsWithLocationData(steps, headers);

      return ProductJourney(
        identifier: canonicalEpc,
        identifierType: _inferIdentifierType(canonicalEpc),
        steps: steps,
        productInfo: productInfo,
        firstEventTime: steps.isNotEmpty ? steps.first.eventTime : null,
        lastEventTime: steps.isNotEmpty ? steps.last.eventTime : null,
        currentLocation: steps.isNotEmpty
            ? steps.last.locationName ?? steps.last.locationGLN
            : null,
        currentDisposition:
            steps.isNotEmpty ? steps.last.dispositionLabel : null,
      );
    } catch (e) {
      debugPrint('ProductJourneyService: Error getting journey: $e');
      return null;
    }
  }

  Future<ProductJourney?> getJourneyByGtinSerial(
    String gtin,
    String serialNumber,
  ) async {
    try {
      final headers = await _getHeaders();

      final sgtinResponse = await _dioService.get(
        '$_baseUrl/identifiers/sgtins/search',
        queryParameters: {'gtin': gtin, 'serialNumber': serialNumber},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (sgtinResponse.statusCode == 200) {
        final sgtinData = decodeApiResponseBody(sgtinResponse.data);
        final List<dynamic> sgtins =
            sgtinData is List ? sgtinData : (sgtinData['content'] ?? []);

        if (sgtins.isNotEmpty) {
          final sgtinUri = sgtins.first['sgtinUri'] as String?;
          if (sgtinUri != null) {
            return getJourneyByEpc(sgtinUri);
          }
        }
      }

      final epcUri =
          'urn:epc:id:sgtin:${_formatGtinForEpc(gtin)}.$serialNumber';
      return getJourneyByEpc(epcUri);
    } catch (e) {
      debugPrint(
        'ProductJourneyService: Error getting journey by GTIN/serial: $e',
      );
      return null;
    }
  }

  Future<ProductJourney?> getJourneyBySscc(String sscc) async {
    final ssccUri = sscc.startsWith('urn:') ? sscc : 'urn:epc:id:sscc:$sscc';
    return getJourneyByEpc(ssccUri);
  }

  Future<List<ProductSearchResult>> searchProducts(String query) async {
    final trimmed = query.trim();

    // If the user typed a complete EPC URI, skip the text search entirely
    // and return it directly as a traceable suggestion.
    if (trimmed.toLowerCase().startsWith('urn:epc:id:')) {
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

    try {
      final headers = await _getHeaders();
      final results = <ProductSearchResult>[];

      final sgtinResponse = await _dioService.get(
        '$_baseUrl/identifiers/sgtins',
        queryParameters: {'search': trimmed, 'size': '10'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (sgtinResponse.statusCode == 200) {
        final data = decodeApiResponseBody(sgtinResponse.data);
        final List<dynamic> sgtins =
            data is List ? data : (data['content'] ?? []);

        for (final sgtin in sgtins) {
          results.add(ProductSearchResult(
            identifier: sgtin['sgtinUri'] ?? sgtin['id']?.toString() ?? '',
            displayName: sgtin['serialNumber'] ?? 'Unknown Serial',
            type: 'SGTIN',
            gtin: sgtin['gtin'],
            serialNumber: sgtin['serialNumber'],
            description: sgtin['productDescription'],
          ));
        }
      }

      final ssccResponse = await _dioService.get(
        '$_baseUrl${SsccServiceConstants.pathBase}',
        queryParameters: {'search': trimmed, 'size': '5'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (ssccResponse.statusCode == 200) {
        final data = decodeApiResponseBody(ssccResponse.data);
        final List<dynamic> ssccs =
            data is List ? data : (data['content'] ?? []);

        for (final sscc in ssccs) {
          results.add(ProductSearchResult(
            identifier: sscc['ssccUri'] ?? sscc['sscc'] ?? '',
            displayName: sscc['sscc'] ?? 'Unknown SSCC',
            type: 'SSCC',
            description: sscc['description'] ?? 'Container/Pallet',
          ));
        }
      }

      return results;
    } catch (e) {
      debugPrint('ProductJourneyService: Error searching products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEventsForEpc(
    String epcUri,
    Map<String, String> headers,
  ) async {
    final allEvents = <Map<String, dynamic>>[];
    final encodedEpc = Uri.encodeComponent(epcUri);

    try {
      final objectResponse = await _dioService.get(
        '$_baseUrl/events/object/epc/$encodedEpc',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (objectResponse.statusCode == 200) {
        final data = decodeApiResponseBody(objectResponse.data);
        final List<dynamic> events =
            data is List ? data : (data['content'] ?? [data]);
        for (final event in events) {
          if (event is Map) {
            final eventMap = Map<String, dynamic>.from(event);
            eventMap['_eventType'] = 'ObjectEvent';
            allEvents.add(eventMap);
          }
        }
      }
    } catch (e) {
      debugPrint('ProductJourneyService: Error fetching object events: $e');
    }

    try {
      final aggResponse = await _dioService.get(
        '$_baseUrl/events/aggregation/child/$encodedEpc',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (aggResponse.statusCode == 200) {
        final data = decodeApiResponseBody(aggResponse.data);
        final List<dynamic> events =
            data is List ? data : (data['content'] ?? [data]);
        for (final event in events) {
          if (event is Map) {
            final eventMap = Map<String, dynamic>.from(event);
            eventMap['_eventType'] = 'AggregationEvent';
            eventMap['_role'] = 'child';
            allEvents.add(eventMap);
          }
        }
      }
    } catch (e) {
      debugPrint(
        'ProductJourneyService: Error fetching aggregation events (as child): $e',
      );
    }

    try {
      final aggParentResponse = await _dioService.get(
        '$_baseUrl/events/aggregation/parent/$encodedEpc',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (aggParentResponse.statusCode == 200) {
        final data = decodeApiResponseBody(aggParentResponse.data);
        final List<dynamic> events =
            data is List ? data : (data['content'] ?? [data]);
        for (final event in events) {
          if (event is Map) {
            final eventMap = Map<String, dynamic>.from(event);
            eventMap['_eventType'] = 'AggregationEvent';
            eventMap['_role'] = 'parent';
            allEvents.add(eventMap);
          }
        }
      }
    } catch (e) {
      debugPrint(
        'ProductJourneyService: Error fetching aggregation events (as parent): $e',
      );
    }

    try {
      final txnResponse = await _dioService.get(
        '$_baseUrl/events/transaction/epc/$encodedEpc',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (txnResponse.statusCode == 200) {
        final data = decodeApiResponseBody(txnResponse.data);
        final List<dynamic> events =
            data is List ? data : (data['content'] ?? [data]);
        for (final event in events) {
          if (event is Map) {
            final eventMap = Map<String, dynamic>.from(event);
            eventMap['_eventType'] = 'TransactionEvent';
            allEvents.add(eventMap);
          }
        }
      }
    } catch (e) {
      debugPrint('ProductJourneyService: Error fetching transaction events: $e');
    }

    return allEvents;
  }

  Future<void> _enrichStepsWithLocationData(
    List<JourneyStep> steps,
    Map<String, String> headers,
  ) async {
    final locationCache =
        <String, ({String name, String address, GeospatialCoordinates? coords})>{};

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.locationGLN == null) continue;
      if (step.locationName != null && step.coordinates != null) continue;

      if (!locationCache.containsKey(step.locationGLN)) {
        try {
          final response = await _dioService.get(
            '$_baseUrl/master-data/glns/code/${step.locationGLN}',
            headers: headers,
            responseType: ResponseType.plain,
            acceptAllStatusCodes: true,
          );
          if (response.statusCode == 200) {
            final glnData = decodeApiResponseMap(response.data);
            final gln = GLN.fromJson(glnData);
            locationCache[step.locationGLN!] = (
              name: gln.locationName,
              address: '${gln.addressLine1}, ${gln.city}'.trim(),
              coords: gln.coordinates,
            );
          }
        } catch (_) {}
      }

      final cached = locationCache[step.locationGLN];
      if (cached != null) {
        steps[i] = step.copyWith(
          locationName: cached.name,
          locationAddress: cached.address,
          coordinates: cached.coords,
        );
      }
    }
  }

  /// Resolves the canonical EPC URI stored in the identifier registry.
  ///
  /// SGTIN URIs can differ in company-prefix format between what a scanner
  /// produces and what the DB stores (e.g. 062920.0007000 vs 0629200.001000).
  /// This method extracts the serial number, queries the registry, verifies the
  /// match, and returns the canonical URI so event lookups use the correct key.
  Future<String> _resolveCanonicalEpc(
    String epcUri,
    Map<String, String> headers,
  ) async {
    if (!epcUri.toLowerCase().contains('sgtin')) return epcUri;
    try {
      final serial = epcUri.split('.').lastOrNull ?? '';
      if (serial.isEmpty) return epcUri;

      final response = await _dioService.get(
        '$_baseUrl/identifiers/sgtins',
        queryParameters: {'search': serial, 'size': '1'},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final data = decodeApiResponseBody(response.data);
        final List<dynamic> items =
            data is List ? data : (data['content'] ?? []);
        if (items.isNotEmpty) {
          final candidate = items.first as Map<String, dynamic>;
          // Verify serial matches exactly — search may return partial matches.
          if (candidate['serialNumber']?.toString() == serial) {
            final canonical = candidate['sgtinUri']?.toString() ??
                candidate['epcUri']?.toString();
            if (canonical != null && canonical.isNotEmpty) {
              debugPrint(
                'ProductJourneyService: Resolved canonical EPC '
                '$epcUri → $canonical',
              );
              return canonical;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('ProductJourneyService: EPC normalization failed: $e');
    }
    return epcUri; // Fall back to the original URI
  }

  String _inferIdentifierType(String identifier) {
    if (identifier.contains('sgtin')) return 'SGTIN';
    if (identifier.contains('sscc')) return 'SSCC';
    if (identifier.contains('gtin')) return 'GTIN';
    return 'EPC';
  }

  String _formatGtinForEpc(String gtin) {
    return gtin.replaceFirst(RegExp('^0+'), '');
  }
}
