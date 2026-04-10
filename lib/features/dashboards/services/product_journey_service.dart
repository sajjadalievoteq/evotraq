import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/dashboards/models/product_journey_models.dart';

/// Service for fetching and building product journey timelines
abstract class ProductJourneyService {
  /// Get complete journey for an EPC identifier (SGTIN URI or serial)
  Future<ProductJourney?> getJourneyByEpc(String epcUri);
  
  /// Get journey by GTIN + Serial Number
  Future<ProductJourney?> getJourneyByGtinSerial(String gtin, String serialNumber);
  
  /// Get journey for SSCC (container/pallet)
  Future<ProductJourney?> getJourneyBySscc(String sscc);
  
  /// Search for products to show journey
  Future<List<ProductSearchResult>> searchProducts(String query);
}

class ProductJourneyServiceImpl implements ProductJourneyService {
  final http.Client _client;
  final AppConfig _appConfig;
  final TokenManager _tokenManager;

  ProductJourneyServiceImpl({
    required http.Client client,
    required AppConfig appConfig,
    required TokenManager tokenManager,
  })  : _client = client,
        _appConfig = appConfig,
        _tokenManager = tokenManager;

  String get _baseUrl => _appConfig.apiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<ProductJourney?> getJourneyByEpc(String epcUri) async {
    try {
      final headers = await _getHeaders();

      // Fetch all events for this EPC
      final events = await _fetchEventsForEpc(epcUri, headers);
      
      if (events.isEmpty) {
        return null;
      }

      // Sort by event time
      events.sort((a, b) {
        final timeA = DateTime.tryParse(a['eventTime'] ?? '') ?? DateTime.now();
        final timeB = DateTime.tryParse(b['eventTime'] ?? '') ?? DateTime.now();
        return timeA.compareTo(timeB);
      });

      // Convert to journey steps
      final steps = events.map((e) => JourneyStep.fromEventJson(e)).toList();

      // Extract product info from first commissioning event's ILMD
      ProductInfo? productInfo;
      for (final step in steps) {
        if (step.businessStep.contains('commissioning') && step.ilmd != null) {
          productInfo = ProductInfo.fromILMD(step.ilmd);
          break;
        }
      }

      // Enrich steps with location names
      await _enrichStepsWithLocationData(steps, headers);

      return ProductJourney(
        identifier: epcUri,
        identifierType: _inferIdentifierType(epcUri),
        steps: steps,
        productInfo: productInfo,
        firstEventTime: steps.isNotEmpty ? steps.first.eventTime : null,
        lastEventTime: steps.isNotEmpty ? steps.last.eventTime : null,
        currentLocation: steps.isNotEmpty ? steps.last.locationName ?? steps.last.locationGLN : null,
        currentDisposition: steps.isNotEmpty ? steps.last.dispositionLabel : null,
      );
    } catch (e) {
      debugPrint('ProductJourneyService: Error getting journey: $e');
      return null;
    }
  }

  @override
  Future<ProductJourney?> getJourneyByGtinSerial(String gtin, String serialNumber) async {
    // Build EPC URI format: urn:epc:id:sgtin:CompanyPrefix.ItemRef.Serial
    // For now, search by serial and filter by GTIN
    try {
      final headers = await _getHeaders();

      // First, try to find SGTIN by GTIN and serial
      final sgtinResponse = await _client.get(
        Uri.parse('$_baseUrl/identifiers/sgtins/search?gtin=$gtin&serialNumber=$serialNumber'),
        headers: headers,
      );

      if (sgtinResponse.statusCode == 200) {
        final sgtinData = jsonDecode(sgtinResponse.body);
        final List<dynamic> sgtins = sgtinData is List ? sgtinData : (sgtinData['content'] ?? []);
        
        if (sgtins.isNotEmpty) {
          final sgtinUri = sgtins.first['sgtinUri'] as String?;
          if (sgtinUri != null) {
            return getJourneyByEpc(sgtinUri);
          }
        }
      }

      // Fallback: construct URI and search
      final epcUri = 'urn:epc:id:sgtin:${_formatGtinForEpc(gtin)}.$serialNumber';
      return getJourneyByEpc(epcUri);
    } catch (e) {
      debugPrint('ProductJourneyService: Error getting journey by GTIN/serial: $e');
      return null;
    }
  }

  @override
  Future<ProductJourney?> getJourneyBySscc(String sscc) async {
    final ssccUri = sscc.startsWith('urn:') ? sscc : 'urn:epc:id:sscc:$sscc';
    return getJourneyByEpc(ssccUri);
  }

  @override
  Future<List<ProductSearchResult>> searchProducts(String query) async {
    try {
      final headers = await _getHeaders();
      final results = <ProductSearchResult>[];

      // Search SGTINs
      final sgtinResponse = await _client.get(
        Uri.parse('$_baseUrl/identifiers/sgtins?search=$query&size=10'),
        headers: headers,
      );

      if (sgtinResponse.statusCode == 200) {
        final data = jsonDecode(sgtinResponse.body);
        final List<dynamic> sgtins = data is List ? data : (data['content'] ?? []);
        
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

      // Search SSCCs
      final ssccResponse = await _client.get(
        Uri.parse('$_baseUrl/identifiers/sscc?search=$query&size=5'),
        headers: headers,
      );

      if (ssccResponse.statusCode == 200) {
        final data = jsonDecode(ssccResponse.body);
        final List<dynamic> ssccs = data is List ? data : (data['content'] ?? []);
        
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
    Map<String, String> headers
  ) async {
    final allEvents = <Map<String, dynamic>>[];

    // Encode the EPC URI for URL path (replace special chars)
    final encodedEpc = Uri.encodeComponent(epcUri);

    // Fetch ObjectEvents by EPC - uses path parameter /events/object/epc/{epc}
    try {
      final objectResponse = await _client.get(
        Uri.parse('$_baseUrl/events/object/epc/$encodedEpc'),
        headers: headers,
      );

      if (objectResponse.statusCode == 200) {
        final data = jsonDecode(objectResponse.body);
        final List<dynamic> events = data is List ? data : (data['content'] ?? [data]);
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

    // Fetch AggregationEvents (where this EPC is a child) - uses path parameter /events/aggregation/child/{childEPC}
    try {
      final aggResponse = await _client.get(
        Uri.parse('$_baseUrl/events/aggregation/child/$encodedEpc'),
        headers: headers,
      );

      if (aggResponse.statusCode == 200) {
        final data = jsonDecode(aggResponse.body);
        final List<dynamic> events = data is List ? data : (data['content'] ?? [data]);
        for (final event in events) {
          if (event is Map) {
            final eventMap = Map<String, dynamic>.from(event);
            eventMap['_eventType'] = 'AggregationEvent';
            eventMap['_role'] = 'child'; // This EPC was packed into a container
            allEvents.add(eventMap);
          }
        }
      }
    } catch (e) {
      debugPrint('ProductJourneyService: Error fetching aggregation events (as child): $e');
    }

    // Fetch AggregationEvents (where this EPC is the parent/container) - for SSCC journey tracking
    // Uses path parameter /events/aggregation/parent/{parentEPC}
    try {
      final aggParentResponse = await _client.get(
        Uri.parse('$_baseUrl/events/aggregation/parent/$encodedEpc'),
        headers: headers,
      );

      if (aggParentResponse.statusCode == 200) {
        final data = jsonDecode(aggParentResponse.body);
        final List<dynamic> events = data is List ? data : (data['content'] ?? [data]);
        for (final event in events) {
          if (event is Map) {
            final eventMap = Map<String, dynamic>.from(event);
            eventMap['_eventType'] = 'AggregationEvent';
            eventMap['_role'] = 'parent'; // This EPC is a container holding items
            allEvents.add(eventMap);
          }
        }
      }
    } catch (e) {
      debugPrint('ProductJourneyService: Error fetching aggregation events (as parent): $e');
    }

    // Fetch TransactionEvents by EPC - uses path parameter /events/transaction/epc/{epc}
    try {
      final txnResponse = await _client.get(
        Uri.parse('$_baseUrl/events/transaction/epc/$encodedEpc'),
        headers: headers,
      );

      if (txnResponse.statusCode == 200) {
        final data = jsonDecode(txnResponse.body);
        final List<dynamic> events = data is List ? data : (data['content'] ?? [data]);
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
    Map<String, String> headers
  ) async {
    final locationCache = <String, Map<String, String>>{};

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.locationGLN != null && step.locationName == null) {
        if (!locationCache.containsKey(step.locationGLN)) {
          try {
            final response = await _client.get(
              Uri.parse('$_baseUrl/master-data/glns/code/${step.locationGLN}'),
              headers: headers,
            );

            if (response.statusCode == 200) {
              final glnData = jsonDecode(response.body);
              locationCache[step.locationGLN!] = {
                'name': glnData['locationName'] ?? glnData['companyName'] ?? step.locationGLN!,
                'address': '${glnData['addressLine1'] ?? ''}, ${glnData['city'] ?? ''}'.trim(),
              };
            }
          } catch (e) {
            // Ignore GLN lookup errors
          }
        }

        if (locationCache.containsKey(step.locationGLN)) {
          // Create new step with enriched data (steps are immutable)
          steps[i] = JourneyStep(
            eventId: step.eventId,
            eventType: step.eventType,
            businessStep: step.businessStep,
            businessStepLabel: step.businessStepLabel,
            disposition: step.disposition,
            dispositionLabel: step.dispositionLabel,
            eventTime: step.eventTime,
            recordTime: step.recordTime,
            locationGLN: step.locationGLN,
            locationName: locationCache[step.locationGLN]!['name'],
            locationAddress: locationCache[step.locationGLN]!['address'],
            action: step.action,
            parentId: step.parentId,
            childEpcs: step.childEpcs,
            ilmd: step.ilmd,
            status: step.status,
          );
        }
      }
    }
  }

  String _inferIdentifierType(String identifier) {
    if (identifier.contains('sgtin')) return 'SGTIN';
    if (identifier.contains('sscc')) return 'SSCC';
    if (identifier.contains('gtin')) return 'GTIN';
    return 'EPC';
  }

  String _formatGtinForEpc(String gtin) {
    // Remove leading zeros and format for EPC
    // This is a simplified version - full GS1 formatting is more complex
    return gtin.replaceFirst(RegExp('^0+'), '');
  }
}

/// Search result for product lookup
class ProductSearchResult {
  final String identifier;
  final String displayName;
  final String type;
  final String? gtin;
  final String? serialNumber;
  final String? description;

  ProductSearchResult({
    required this.identifier,
    required this.displayName,
    required this.type,
    this.gtin,
    this.serialNumber,
    this.description,
  });
}
