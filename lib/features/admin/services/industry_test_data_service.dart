import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/admin/data/tobacco_product_data.dart';
import 'package:traqtrace_app/features/admin/data/pharmaceutical_product_data.dart';
import 'package:uuid/uuid.dart';

/// Service for generating industry-specific test data
class IndustryTestDataService {
  final TokenManager tokenManager;
  final AppConfig appConfig;
  final http.Client _httpClient = http.Client();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  IndustryTestDataService({
    required this.tokenManager,
    required this.appConfig,
  });

  String get _baseUrl => appConfig.apiBaseUrl;

  Future<Map<String, String>> get _headers async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generate tobacco GTINs with extensions
  Future<void> generateTobaccoGTINs({
    required Function(int current, int total, String productName) onProgress,
  }) async {
    final products = TobaccoProductData.getUAETobaccoProducts();
    final total = products.length;

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      onProgress(i + 1, total, product['productName'] as String);

      // Create GTIN using master-data endpoint
      final gtinResponse = await _httpClient.post(
        Uri.parse('$_baseUrl/master-data/gtins'),
        headers: await _headers,
        body: jsonEncode({
          'gtin': product['gtinCode'],
          'productName': product['productName'],
          'manufacturer': product['manufacturer'],
          'packagingLevel': 'Primary',
          'packSize': product['unitsPerPack'],
          'productStatus': 'ACTIVE',
        }),
      );

      if (gtinResponse.statusCode == 200 || gtinResponse.statusCode == 201) {
        // Create tobacco extension
        await _httpClient.post(
          Uri.parse('$_baseUrl/tobacco/products/gtin/${product['gtinCode']}'),
          headers: await _headers,
          body: jsonEncode({
            'tobaccoCategory': product['tobaccoCategory'],
            'brandFamily': product['brandFamily'],
            'brandVariant': product['brandVariant'],
            'nicotineContentMg': product['nicotineContentMg'],
            'tarContentMg': product['tarContentMg'],
            'carbonMonoxideMg': product['carbonMonoxideMg'],
            'unitsPerPack': product['unitsPerPack'],
            'packType': product['packType'],
            'isMenthol': product['isMenthol'],
            'isSlim': product['isSlim'],
            'isKingSize': product['isKingSize'],
            'filterType': product['filterType'],
            'cigaretteLengthMm': product['cigaretteLengthMm'],
            'countryOfOrigin': product['countryOfOrigin'],
            'intendedMarket': 'ARE',
            'maxRetailPrice': product['maxRetailPrice'],
            'maxRetailPriceCurrency': 'AED',
            'curingMethod': product['curingMethod'],
          }),
        );
      }

      // Small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Generate tobacco GLNs with extensions
  Future<void> generateTobaccoGLNs({
    required Function(int current, int total, String locationName) onProgress,
  }) async {
    final locations = TobaccoProductData.getUAETobaccoLocations();
    final total = locations.length;

    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      onProgress(i + 1, total, location['locationName'] as String);

      // Create GLN using master-data endpoint
      final glnResponse = await _httpClient.post(
        Uri.parse('$_baseUrl/master-data/glns'),
        headers: await _headers,
        body: jsonEncode({
          'glnCode': location['glnCode'],
          'locationName': location['locationName'],
          'locationType': location['locationType'],
          'addressLine1': location['address'],
          'city': location['city'],
          'postalCode': location['postalCode'] ?? '00000',
          'country': 'United Arab Emirates',
          'locationStatus': 'active',
        }),
      );

      if (glnResponse.statusCode == 200 || glnResponse.statusCode == 201) {
        // Create tobacco extension for the GLN
        await _httpClient.post(
          Uri.parse('$_baseUrl/tobacco/gln/code/${location['glnCode']}'),
          headers: await _headers,
          body: jsonEncode({
            'locationName': location['locationName'],
            // Location type flags
            'isManufacturingFacility': location['locationType'] == 'MANUFACTURER',
            'isRetailLocation': location['locationType'] == 'RETAILER' || 
                                location['locationType'] == 'CONVENIENCE_STORE',
            
            // ===== UAE Federal Tax Authority (FTA) Registration =====
            // UAE requires all tobacco businesses to register with FTA for excise tax
            'taxStampAuthorityId': location['ftaRegistrationNumber'],
            'taxStampAuthorityName': 'UAE Federal Tax Authority (FTA)',
            'taxStampAuthorizationDate': '2024-01-01',
            'taxStampAuthorizationExpiry': '2025-12-31',
            'authorizedTaxStampTypes': 'DIGITAL_TAX_STAMP',
            
            // ===== UAE Digital Tax Stamp System =====
            // FTA requires digital tax stamps on all tobacco products since 2019
            'isUiIssuer': location['locationType'] == 'MANUFACTURER',
            'uiIssuerRegistrationId': location['digitalTaxStampId'],
            'uiSystemProvider': 'UAE FTA Digital Tax Stamp System',
            'antiTamperingDeviceProvider': 'FTA Approved Provider',
            
            // WHO FCTC - UAE is a signatory
            'whoFctcPartyCountry': 'ARE',
            
            // UAE-specific tobacco license
            'stateTobaccoLicenseNumber': location['tobaccoLicenseNumber'],
            'stateTobaccoLicenseType': _getLicenseType(location['locationType'] as String),
            
            // Customs & Import/Export (for manufacturers and distributors)
            'customsRegistrationNumber': location['locationType'] == 'MANUFACTURER' || 
                                          location['locationType'] == 'DISTRIBUTION_CENTER'
                ? location['customsRegistrationNumber']
                : null,
            'authorizedEconomicOperator': location['locationType'] == 'MANUFACTURER' || 
                                           location['locationType'] == 'DISTRIBUTION_CENTER',
            
            // Wholesale license for distributors/wholesalers
            'tobaccoWholesaleLicenseNumber': location['locationType'] == 'WHOLESALER' || 
                                              location['locationType'] == 'DISTRIBUTION_CENTER'
                ? location['wholesaleLicenseNumber']
                : null,
            // Retail permit
            'tobaccoSalesPermitNumber': location['locationType'] == 'RETAILER' || 
                                         location['locationType'] == 'CONVENIENCE_STORE'
                ? location['salesPermitNumber']
                : null,
            // Security features
            'hasSecurityFeatures': true,
            'videoSurveillance': true,
            'accessControlSystem': location['locationType'] == 'MANUFACTURER' || 
                                   location['locationType'] == 'DISTRIBUTION_CENTER',
            'inventoryTrackingSystem': 'TraqTrace',
            // Storage capabilities
            'hasClimateControl': location['locationType'] == 'MANUFACTURER' || 
                                  location['locationType'] == 'DISTRIBUTION_CENTER' ||
                                  location['locationType'] == 'WHOLESALER',
            'storageCapacityPallets': location['storageCapacity'],
            // Age verification for retail
            'ageVerificationSystem': location['locationType'] == 'RETAILER' || 
                                      location['locationType'] == 'CONVENIENCE_STORE'
                ? 'Emirates ID Scanner'
                : null,
            // Authorized brands (all major brands for this demo)
            'authorizedBrands': [
              'Marlboro', 'Dunhill', 'Kent', 'Winston', 'Davidoff',
              'Parliament', 'Camel', 'L&M', 'Rothmans', 'Pall Mall',
              'Lucky Strike', 'Benson & Hedges', 'Vogue', 'Esse', 'Mevius'
            ],
          }),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Generate tobacco SGTINs (serialized items) from existing GTINs
  /// Creates 10 serialized units per GTIN with batch information
  Future<void> generateTobaccoSGTINs({
    required Function(int current, int total, String productInfo) onProgress,
  }) async {
    // First, fetch existing GTINs
    final gtinsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/gtins?page=0&size=50'),
      headers: await _headers,
    );

    if (gtinsResponse.statusCode != 200) {
      throw Exception('Failed to fetch GTINs. Please generate GTINs first.');
    }

    final gtinsData = jsonDecode(gtinsResponse.body);
    final List<dynamic> gtins = gtinsData['content'] ?? [];
    
    if (gtins.isEmpty) {
      throw Exception('No GTINs found. Please generate GTINs first.');
    }

    // Get manufacturer locations for current location assignment
    final glnsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/glns?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> glns = [];
    if (glnsResponse.statusCode == 200) {
      final glnsData = jsonDecode(glnsResponse.body);
      glns = glnsData['content'] ?? [];
    }
    
    // Filter to get manufacturer GLNs
    final manufacturerGlns = glns.where((g) => 
      g['locationType'] == 'MANUFACTURER' || 
      g['locationName']?.toString().contains('Manufacturer') == true ||
      g['locationName']?.toString().contains('Philip Morris') == true ||
      g['locationName']?.toString().contains('BAT') == true ||
      g['locationName']?.toString().contains('JTI') == true
    ).toList();
    
    final total = gtins.length * 10; // 10 SGTINs per GTIN
    int current = 0;
    
    // Production date is 30 days ago, expiry is 2 years from now
    final productionDate = DateTime.now().subtract(const Duration(days: 30));
    final expiryDate = DateTime.now().add(const Duration(days: 730));
    
    for (int gtinIndex = 0; gtinIndex < gtins.length; gtinIndex++) {
      final gtin = gtins[gtinIndex];
      final gtinCode = gtin['gtin'] ?? gtin['gtinCode'];
      final productName = gtin['productName'] ?? 'Product';
      
      // Generate batch number for this GTIN
      final batchNumber = TobaccoProductData.generateBatchNumber(
        gtinIndex % 5 + 1, // Manufacturer 1-5
        DateTime.now().year,
        DateTime.now().month,
        gtinIndex + 1,
      );
      
      // Pick a manufacturer location
      final manufacturerGln = manufacturerGlns.isNotEmpty 
          ? manufacturerGlns[gtinIndex % manufacturerGlns.length]['glnCode']
          : null;
      
      for (int i = 0; i < 10; i++) {
        current++;
        final serialNumber = _generateSerialNumber();
        onProgress(current, total, '$productName (S/N: $serialNumber)');
        
        // Create SGTIN
        final sgtinResponse = await _httpClient.post(
          Uri.parse('$_baseUrl/identifiers/sgtins'),
          headers: await _headers,
          body: jsonEncode({
            'gtin': gtinCode,
            'serialNumber': serialNumber,
            'batchLotNumber': batchNumber,
            'productionDate': productionDate.toIso8601String().split('T')[0],
            'expiryDate': expiryDate.toIso8601String().split('T')[0],
            'status': 'ACTIVE',
            'regulatoryMarket': 'ARE',
            if (manufacturerGln != null) 'currentLocationGLN': manufacturerGln,
          }),
        );
        
        if (sgtinResponse.statusCode != 200 && sgtinResponse.statusCode != 201) {
          // Log error but continue
          print('Failed to create SGTIN for $gtinCode: ${sgtinResponse.body}');
        }
        
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  /// Generate tobacco SSCCs (shipping containers) with tobacco extensions
  /// Creates pallets, cases, and cartons with hierarchical packing
  Future<void> generateTobaccoSSCCs({
    required Function(int current, int total, String containerInfo) onProgress,
  }) async {
    // Fetch manufacturer locations for issuing GLN
    final glnsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/glns?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> glns = [];
    if (glnsResponse.statusCode == 200) {
      final glnsData = jsonDecode(glnsResponse.body);
      glns = glnsData['content'] ?? [];
    }
    
    final manufacturers = glns.where((g) => 
      g['locationType'] == 'MANUFACTURER'
    ).toList();
    
    final distributors = glns.where((g) => 
      g['locationType'] == 'DISTRIBUTION_CENTER' || g['locationType'] == 'WHOLESALER'
    ).toList();
    
    final retailers = glns.where((g) => 
      g['locationType'] == 'RETAILER' || g['locationType'] == 'CONVENIENCE_STORE'
    ).toList();
    
    final prefixes = TobaccoProductData.getManufacturerPrefixes();
    
    // Generate: 10 pallets, 20 cases, 20 cartons = 50 total
    const totalPallets = 10;
    const totalCases = 20;
    const totalCartons = 20;
    const total = totalPallets + totalCases + totalCartons;
    int current = 0;
    
    final createdSsccs = <String, Map<String, dynamic>>{};
    
    // Generate Pallets
    for (int i = 0; i < totalPallets; i++) {
      current++;
      final prefix = prefixes[i % prefixes.length];
      final serialRef = (100000 + i).toString().padLeft(9, '0');
      final ssccCode = TobaccoProductData.generateSSCC('0', prefix['prefix']!, serialRef);
      
      onProgress(current, total, 'Pallet $ssccCode');
      
      final sourceGln = manufacturers.isNotEmpty 
          ? manufacturers[i % manufacturers.length] 
          : null;
      final destGln = distributors.isNotEmpty 
          ? distributors[i % distributors.length] 
          : null;
      
      await _createSSCCWithExtension(
        ssccCode: ssccCode,
        containerType: 'PALLET',
        issuingGln: sourceGln?['glnCode'],
        sourceGln: sourceGln?['glnCode'],
        destGln: destGln?['glnCode'],
        batchNumber: TobaccoProductData.generateBatchNumber(i % 5 + 1, 2024, 12, i + 1),
        stampCount: 1000, // 1000 packs per pallet
      );
      
      createdSsccs[ssccCode] = {'type': 'PALLET', 'index': i};
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Generate Cases
    for (int i = 0; i < totalCases; i++) {
      current++;
      final prefix = prefixes[i % prefixes.length];
      final serialRef = (200000 + i).toString().padLeft(9, '0');
      final ssccCode = TobaccoProductData.generateSSCC('1', prefix['prefix']!, serialRef);
      
      onProgress(current, total, 'Case $ssccCode');
      
      final sourceGln = distributors.isNotEmpty 
          ? distributors[i % distributors.length] 
          : (manufacturers.isNotEmpty ? manufacturers[i % manufacturers.length] : null);
      final destGln = retailers.isNotEmpty 
          ? retailers[i % retailers.length] 
          : null;
      
      await _createSSCCWithExtension(
        ssccCode: ssccCode,
        containerType: 'CASE',
        issuingGln: sourceGln?['glnCode'],
        sourceGln: sourceGln?['glnCode'],
        destGln: destGln?['glnCode'],
        batchNumber: TobaccoProductData.generateBatchNumber(i % 5 + 1, 2024, 12, 100 + i),
        stampCount: 50, // 50 packs per case
      );
      
      createdSsccs[ssccCode] = {'type': 'CASE', 'index': i};
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Generate Cartons
    for (int i = 0; i < totalCartons; i++) {
      current++;
      final prefix = prefixes[i % prefixes.length];
      final serialRef = (300000 + i).toString().padLeft(9, '0');
      final ssccCode = TobaccoProductData.generateSSCC('2', prefix['prefix']!, serialRef);
      
      onProgress(current, total, 'Carton $ssccCode');
      
      final sourceGln = retailers.isNotEmpty 
          ? retailers[i % retailers.length] 
          : (distributors.isNotEmpty ? distributors[i % distributors.length] : null);
      
      await _createSSCCWithExtension(
        ssccCode: ssccCode,
        containerType: 'CARTON',
        issuingGln: sourceGln?['glnCode'],
        sourceGln: sourceGln?['glnCode'],
        destGln: null, // Cartons at retail don't have dest
        batchNumber: TobaccoProductData.generateBatchNumber(i % 5 + 1, 2024, 12, 200 + i),
        stampCount: 10, // 10 packs per carton
      );
      
      createdSsccs[ssccCode] = {'type': 'CARTON', 'index': i};
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Helper to create SSCC with tobacco extension
  Future<void> _createSSCCWithExtension({
    required String ssccCode,
    required String containerType,
    String? issuingGln,
    String? sourceGln,
    String? destGln,
    required String batchNumber,
    required int stampCount,
  }) async {
    // Create base SSCC
    final ssccResponse = await _httpClient.post(
      Uri.parse('$_baseUrl/identifiers/sscc'),
      headers: await _headers,
      body: jsonEncode({
        'sscc': ssccCode,
        'containerType': containerType,
        'containerStatus': 'PACKED',
        'packingDate': DateTime.now().toIso8601String(),
        if (issuingGln != null) 'issuingGLN': issuingGln,
      }),
    );
    
    if (ssccResponse.statusCode == 200 || ssccResponse.statusCode == 201) {
      // Create tobacco extension
      await _httpClient.post(
        Uri.parse('$_baseUrl/tobacco/sscc/code/$ssccCode'),
        headers: await _headers,
        body: jsonEncode({
          'ssccCode': ssccCode,
          // Tax stamp aggregation
          'taxStampAggregationLevel': containerType,
          'aggregatedStampCount': stampCount,
          'taxStampAuthorityId': 'UAE-FTA-2024',
          // Transport info
          'countryOfOrigin': 'ARE',
          'countryOfDestination': 'ARE',
          // Batch tracking
          'containsMultipleBatches': false,
          'primaryBatchNumber': batchNumber,
          // UAE compliance
          'euFirstRetailOutlet': containerType == 'CARTON',
        }),
      );
    }
  }

  /// Generate EPCIS events for the full tobacco supply chain lifecycle
  /// Creates: Commissioning → Packing → Shipping → Receiving events
  Future<void> generateTobaccoEvents({
    required Function(int current, int total, String eventInfo) onProgress,
  }) async {
    // Fetch SGTINs
    final sgtinsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/identifiers/sgtins?page=0&size=100'),
      headers: await _headers,
    );
    
    if (sgtinsResponse.statusCode != 200) {
      throw Exception('Failed to fetch SGTINs. Please generate SGTINs first.');
    }
    
    final sgtinsData = jsonDecode(sgtinsResponse.body);
    final List<dynamic> sgtins = sgtinsData['content'] ?? [];
    
    if (sgtins.isEmpty) {
      throw Exception('No SGTINs found. Please generate SGTINs first.');
    }
    
    // Fetch SSCCs
    final ssccsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/identifiers/sscc?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> ssccs = [];
    if (ssccsResponse.statusCode == 200) {
      final ssccsData = jsonDecode(ssccsResponse.body);
      ssccs = ssccsData['content'] ?? [];
    }
    
    // Fetch GLNs
    final glnsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/glns?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> glns = [];
    if (glnsResponse.statusCode == 200) {
      final glnsData = jsonDecode(glnsResponse.body);
      glns = glnsData['content'] ?? [];
    }
    
    final manufacturers = glns.where((g) => g['locationType'] == 'MANUFACTURER').toList();
    final distributors = glns.where((g) => 
      g['locationType'] == 'DISTRIBUTION_CENTER' || g['locationType'] == 'WHOLESALER'
    ).toList();
    final retailers = glns.where((g) => 
      g['locationType'] == 'RETAILER' || g['locationType'] == 'CONVENIENCE_STORE'
    ).toList();
    
    // Calculate total events:
    // - SGTIN Commissioning: 1 per SGTIN (min 100)
    // - SSCC Commissioning: 1 per SSCC (must commission before aggregation)
    // - Packing: 1 per SSCC  
    // - Shipping: 2 per scenario (manufacturer→distributor, distributor→retailer)
    // - Receiving: 2 per scenario
    final numSgtins = sgtins.length > 100 ? 100 : sgtins.length;
    final numSsccs = ssccs.length > 30 ? 30 : ssccs.length;
    final numShipments = 20; // 10 mfg→dist + 10 dist→retail
    
    final total = numSgtins + (numSsccs * 2) + (numShipments * 2); // sgtin commission + sscc commission + pack + ship + receive
    int current = 0;
    
    // 1. Commissioning Events (ObjectEvent with ADD)
    for (int i = 0; i < numSgtins; i++) {
      current++;
      final sgtin = sgtins[i];
      final gtinCode = sgtin['gtin'] ?? sgtin['gtinCode'];
      final serialNumber = sgtin['serialNumber'];
      final batchLot = sgtin['batchLotNumber'] ?? 'BATCH-${DateTime.now().year}';
      final expiryDate = sgtin['expiryDate'] ?? DateTime.now().add(const Duration(days: 365)).toIso8601String();
      final epcUri = 'urn:epc:id:sgtin:${gtinCode.substring(1, 8)}.${gtinCode.substring(8, 13)}.$serialNumber';
      
      onProgress(current, total, 'Commissioning SGTIN $serialNumber');
      
      final mfgGln = manufacturers.isNotEmpty 
          ? manufacturers[i % manufacturers.length]['glnCode'] 
          : '6291000000013';
      
      // ILMD (Instance/Lot Master Data) required for commissioning
      final ilmd = <String, dynamic>{
        'lotNumber': batchLot,
        'itemExpirationDate': expiryDate,
        'countryOfOrigin': 'AE',
        'productionDate': DateTime.now().subtract(Duration(days: 30 - (i ~/ 10))).toIso8601String().split('T')[0],
      };
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'ADD',
        epcList: [epcUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        readPoint: mfgGln,
        bizLocation: mfgGln,
        eventTime: DateTime.now().subtract(Duration(days: 30 - (i ~/ 10))),
        ilmd: ilmd,
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 2. SSCC Commissioning Events (ObjectEvent with ADD) - must commission SSCCs before aggregation
    for (int i = 0; i < numSsccs && i < ssccs.length; i++) {
      current++;
      final sscc = ssccs[i];
      final ssccCode = sscc['sscc'] ?? sscc['ssccCode'];
      // Use the ssccUri from the API if available, otherwise construct it
      final ssccUri = sscc['ssccUri'] ?? 'urn:epc:id:sscc:${ssccCode.substring(1, 8)}.${ssccCode.substring(8, 17)}';
      
      onProgress(current, total, 'Commissioning SSCC $ssccCode');
      
      final packLocation = manufacturers.isNotEmpty 
          ? manufacturers[i % manufacturers.length]['glnCode']
          : '6291000000013';
      
      // Commission the SSCC first - required before it can be used as parent in AggregationEvent
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'ADD',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        readPoint: packLocation,
        bizLocation: packLocation,
        eventTime: DateTime.now().subtract(Duration(days: 25 + (i ~/ 5))),
        // ILMD for SSCC commissioning
        ilmd: {
          'containerType': sscc['containerType'] ?? 'CASE',
          'countryOfOrigin': 'AE',
          'productionDate': DateTime.now().subtract(Duration(days: 25 + (i ~/ 5))).toIso8601String().split('T')[0],
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 3. Packing/Aggregation Events (AggregationEvent with ADD)
    for (int i = 0; i < numSsccs && i < ssccs.length; i++) {
      current++;
      final sscc = ssccs[i];
      final ssccCode = sscc['sscc'] ?? sscc['ssccCode'];
      // Use the ssccUri from the API if available, otherwise construct it
      final ssccUri = sscc['ssccUri'] ?? 'urn:epc:id:sscc:${ssccCode.substring(1, 8)}.${ssccCode.substring(8, 17)}';
      
      onProgress(current, total, 'Packing into SSCC $ssccCode');
      
      // Get some SGTINs to pack into this SSCC
      final childEpcs = <String>[];
      final startIdx = (i * 3) % sgtins.length;
      for (int j = 0; j < 3 && (startIdx + j) < sgtins.length; j++) {
        final childSgtin = sgtins[startIdx + j];
        // Use sgtinUri from API if available
        final sgtinUri = childSgtin['sgtinUri'];
        if (sgtinUri != null) {
          childEpcs.add(sgtinUri);
        } else {
          final gtinCode = childSgtin['gtin'] ?? childSgtin['gtinCode'];
          final serialNumber = childSgtin['serialNumber'];
          childEpcs.add('urn:epc:id:sgtin:${gtinCode.substring(1, 8)}.${gtinCode.substring(8, 13)}.$serialNumber');
        }
      }
      
      final packLocation = distributors.isNotEmpty 
          ? distributors[i % distributors.length]['glnCode']
          : (manufacturers.isNotEmpty ? manufacturers[i % manufacturers.length]['glnCode'] : '6291000000013');
      
      // Generate packing operation identifiers
      final packingOpId = 'pack_${DateTime.now().millisecondsSinceEpoch}_${i.toString().padLeft(3, '0')}';
      final packingRef = 'PACK-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'AggregationEvent',
        action: 'ADD',
        parentId: ssccUri,
        childEpcs: childEpcs,
        bizStep: 'urn:epcglobal:cbv:bizstep:packing',
        disposition: 'urn:epcglobal:cbv:disp:in_progress',
        readPoint: packLocation,
        bizLocation: packLocation,
        eventTime: DateTime.now().subtract(Duration(days: 20 + (i ~/ 5))),
        bizData: {
          'packing_operation_id': packingOpId,
          'packing_reference': packingRef,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 4. Shipping Events (ObjectEvent with OBSERVE)
    for (int i = 0; i < numShipments ~/ 2; i++) {
      current++;
      final ssccIdx = i % (ssccs.isNotEmpty ? ssccs.length : 1);
      final sscc = ssccs.isNotEmpty ? ssccs[ssccIdx] : null;
      if (sscc == null) continue;
      
      // Use ssccUri from API if available
      final ssccUri = sscc['ssccUri'] ?? 'urn:epc:id:sscc:${(sscc['sscc'] ?? sscc['ssccCode']).substring(1, 8)}.${(sscc['sscc'] ?? sscc['ssccCode']).substring(8, 17)}';
      
      final sourceGln = manufacturers.isNotEmpty 
          ? manufacturers[i % manufacturers.length]['glnCode'] 
          : '6291000000013';
      final destGln = distributors.isNotEmpty 
          ? distributors[i % distributors.length]['glnCode'] 
          : '6291000000068';
      
      onProgress(current, total, 'Shipping from manufacturer → distributor');
      
      final shippingOpId1 = 'ship_mfg_dist_${DateTime.now().millisecondsSinceEpoch}_$i';
      final shippingRef1 = 'SHIP-MFG-DIST-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:shipping',
        disposition: 'urn:epcglobal:cbv:disp:in_transit',
        readPoint: sourceGln,
        bizLocation: sourceGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
          {'sourceType': 'urn:epcglobal:cbv:sdt:owning_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 15 + i)),
        bizData: {
          'shipping_operation_id': shippingOpId1,
          'shipping_reference': shippingRef1,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
      
      // Receiving at distributor
      current++;
      onProgress(current, total, 'Receiving at distributor');
      
      final receivingOpId1 = 'recv_mfg_dist_${DateTime.now().millisecondsSinceEpoch}_$i';
      final receivingRef1 = 'RECV-MFG-DIST-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:receiving',
        disposition: 'urn:epcglobal:cbv:disp:in_progress',
        readPoint: destGln,
        bizLocation: destGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
          {'destinationType': 'urn:epcglobal:cbv:sdt:owning_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 14 + i)),
        bizData: {
          'receiving_operation_id': receivingOpId1,
          'receiving_reference': receivingRef1,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 5. Distributor → Retailer shipments
    for (int i = 0; i < numShipments ~/ 2; i++) {
      current++;
      final ssccIdx = (i + numShipments ~/ 2) % (ssccs.isNotEmpty ? ssccs.length : 1);
      final sscc = ssccs.isNotEmpty ? ssccs[ssccIdx] : null;
      final ssccCode = sscc != null ? (sscc['sscc'] ?? sscc['ssccCode']) : '000629100020000000$i';
      // Use ssccUri from API if available (matches what was commissioned)
      final ssccUri = sscc != null && sscc['ssccUri'] != null 
          ? sscc['ssccUri'] 
          : 'urn:epc:id:sscc:${ssccCode.substring(1, 8)}.${ssccCode.substring(8, 17)}';
      
      final sourceGln = distributors.isNotEmpty 
          ? distributors[i % distributors.length]['glnCode'] 
          : '6291000000068';
      final destGln = retailers.isNotEmpty 
          ? retailers[i % retailers.length]['glnCode'] 
          : '6291000000167';
      
      onProgress(current, total, 'Shipping from distributor → retailer');
      
      final shippingOpId2 = 'ship_dist_ret_${DateTime.now().millisecondsSinceEpoch}_$i';
      final shippingRef2 = 'SHIP-DIST-RET-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:shipping',
        disposition: 'urn:epcglobal:cbv:disp:in_transit',
        readPoint: sourceGln,
        bizLocation: sourceGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
          {'sourceType': 'urn:epcglobal:cbv:sdt:owning_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 10 + i)),
        bizData: {
          'shipping_operation_id': shippingOpId2,
          'shipping_reference': shippingRef2,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
      
      // Receiving at retailer
      current++;
      onProgress(current, total, 'Receiving at retailer');
      
      final receivingOpId2 = 'recv_dist_ret_${DateTime.now().millisecondsSinceEpoch}_$i';
      final receivingRef2 = 'RECV-DIST-RET-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:receiving',
        disposition: 'urn:epcglobal:cbv:disp:sellable_accessible',
        readPoint: destGln,
        bizLocation: destGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
          {'destinationType': 'urn:epcglobal:cbv:sdt:owning_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 9 + i)),
        bizData: {
          'receiving_operation_id': receivingOpId2,
          'receiving_reference': receivingRef2,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  /// Helper to capture an EPCIS event
  Future<void> _captureEvent({
    required String eventType,
    required String action,
    List<String>? epcList,
    String? parentId,
    List<String>? childEpcs,
    required String bizStep,
    required String disposition,
    required String readPoint,
    required String bizLocation,
    List<Map<String, String>>? sourceDestList,
    List<Map<String, String>>? destinationList,
    required DateTime eventTime,
    Map<String, dynamic>? ilmd,
    Map<String, String>? bizData,
  }) async {
    final eventId = 'event_${eventTime.millisecondsSinceEpoch}_${DateTime.now().microsecond.toString().padLeft(3, '0')}';
    
    // Calculate timezone offset
    final offset = eventTime.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    final timezoneOffset = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    
    final event = <String, dynamic>{
      'eventId': eventId,
      'eventType': eventType,
      'eventTime': eventTime.toUtc().toIso8601String(),
      'recordTime': DateTime.now().toUtc().toIso8601String(),
      'eventTimeZoneOffset': timezoneOffset,
      'epcisVersion': '2.0',
      'action': action,
      'businessStep': bizStep,
      'disposition': disposition,
      'readPoint': readPoint,
      'businessLocation': bizLocation,
      // Schema compliance - these fields must be empty arrays/objects, not null
      'bizData': bizData ?? <String, String>{},
      'certificationInfo': <Map<String, dynamic>>[],
      'sourceList': sourceDestList ?? <Map<String, String>>[],
      'destinationList': destinationList ?? <Map<String, String>>[],
    };
    
    // ObjectEvent uses epcList, AggregationEvent uses parentID/childEPCs
    if (eventType == 'ObjectEvent') {
      if (epcList != null && epcList.isNotEmpty) {
        event['epcList'] = epcList;
        event['quantityList'] = []; // Schema compliance
      } else {
        event['epcList'] = [];
        event['quantityList'] = [];
      }
    } else if (eventType == 'AggregationEvent') {
      // AggregationEvent uses parentID and childEPCs
      if (parentId != null) {
        event['parentID'] = parentId;
      }
      if (childEpcs != null && childEpcs.isNotEmpty) {
        event['childEPCs'] = childEpcs;
        event['childQuantityList'] = []; // Schema compliance
      } else {
        event['childEPCs'] = [];
        event['childQuantityList'] = [];
      }
    }
    
    // Add ILMD for commissioning events
    if (ilmd != null) {
      event['ilmd'] = ilmd;
    }
    
    // Use the correct endpoint based on event type (same as working screens)
    final endpoint = eventType == 'ObjectEvent' 
        ? '$_baseUrl/events/object'
        : '$_baseUrl/events/aggregation';
    
    final response = await _httpClient.post(
      Uri.parse(endpoint),
      headers: await _headers,
      body: jsonEncode(event),
    );
    
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create $eventType: ${response.statusCode} - ${response.body}');
    }
  }

  /// Generate a random 12-character alphanumeric serial number
  String _generateSerialNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(12, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  // ==================== PHARMACEUTICAL METHODS ====================
  
  /// Generate pharmaceutical GTINs with extensions
  Future<void> generatePharmaGTINs({
    required Function(int current, int total, String productName) onProgress,
  }) async {
    final products = PharmaceuticalProductData.getUAEPharmaceuticalProducts();
    final total = products.length;

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      onProgress(i + 1, total, product['productName'] as String);

      // Create GTIN using master-data endpoint
      final gtinResponse = await _httpClient.post(
        Uri.parse('$_baseUrl/master-data/gtins'),
        headers: await _headers,
        body: jsonEncode({
          'gtin': product['gtinCode'],
          'productName': product['productName'],
          'manufacturer': product['manufacturer'],
          'packagingLevel': 'Primary',
          'packSize': product['packageQuantity'],
          'productStatus': 'ACTIVE',
        }),
      );

      if (gtinResponse.statusCode == 200 || gtinResponse.statusCode == 201) {
        // Create pharmaceutical extension
        await _httpClient.post(
          Uri.parse('$_baseUrl/pharmaceutical/gtin/code/${product['gtinCode']}'),
          headers: await _headers,
          body: jsonEncode({
            // Product identification
            'therapeuticClass': product['therapeuticClass'],
            'strength': product['strength'].toString(),
            'strengthUnit': product['strengthUnit'],
            'dosageForm': product['dosageForm'],
            
            // Regulatory
            'atcCode': product['atcCode'],
            
            // Pricing & Access
            'requiresPrescription': product['requiresPrescription'],
            
            // Storage & Handling
            'storageConditions': product['temperatureControlled'] ? '2-8°C' : 'Room Temperature',
            'requiresRefrigeration': product['temperatureControlled'],
            
            // Controlled Substance
            'isControlledSubstance': product['narcotic'] ?? false,
          }),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Generate pharmaceutical GLNs with extensions
  Future<void> generatePharmaGLNs({
    required Function(int current, int total, String locationName) onProgress,
  }) async {
    final locations = PharmaceuticalProductData.getUAEPharmaceuticalLocations();
    final total = locations.length;

    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      onProgress(i + 1, total, location['locationName'] as String);

      // Create GLN using master-data endpoint
      final glnResponse = await _httpClient.post(
        Uri.parse('$_baseUrl/master-data/glns'),
        headers: await _headers,
        body: jsonEncode({
          'glnCode': location['glnCode'],
          'locationName': location['locationName'],
          'locationType': _mapLocationTypeToBackend(location['locationType'] as String),
          'addressLine1': location['address'],
          'city': location['city'],
          'postalCode': location['postalCode'] ?? '00000',
          'country': 'United Arab Emirates',
          'locationStatus': 'active',
        }),
      );

      if (glnResponse.statusCode == 200 || glnResponse.statusCode == 201) {
        // Create pharmaceutical extension for the GLN
        await _httpClient.post(
          Uri.parse('$_baseUrl/pharmaceutical/gln/code/${location['glnCode']}'),
          headers: await _headers,
          body: jsonEncode({
            // Cold Chain & Storage Capabilities
            'hasColdChainCapability': location['hasRefrigeratedStorage'] ?? false,
            'hasFreezerCapability': location['hasFreezerStorage'] ?? false,
            'hasControlledRoomTemp': true,
            'gdpCertified': location['gdpCertificateNumber'] != null,
            
            // Clinical Trial Site
            'isClinicalTrialSite': location['locationType'] == 'HOSPITAL_PHARMACY',
            
            // Serialization & DSCSA Compliance
            'hasSerializationCapability': location['serializedProductHandling'] ?? false,
            'hasAggregationCapability': location['serializedProductHandling'] ?? false,
            
            // Healthcare Facility Type
            'healthcareFacilityType': _getHealthcareFacilityType(location['locationType'] as String),
            
            // Certifications
            'isIsoCertified': location['gdpCertificateNumber'] != null || location['gmpCertificateNumber'] != null,
            
            // Contact Information
            'pharmacistInCharge': location['pharmacistLicenseNumber'] != null 
                ? 'Licensed Pharmacist ${location['glnCode']?.substring(location['glnCode']!.length - 4) ?? 'XXXX'}' 
                : null,
            'picLicenseNumber': location['pharmacistLicenseNumber'],
            
            // Operational Details
            'receivingHours': _getOperatingHours(location['locationType'] as String),
            'hasLoadingDock': location['locationType'] == 'MANUFACTURER' || location['locationType'] == 'DISTRIBUTION_CENTER',
            'hasForkliftCapability': location['locationType'] == 'MANUFACTURER' || location['locationType'] == 'DISTRIBUTION_CENTER',
          }),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Generate pharmaceutical SGTINs (serialized items) from existing GTINs
  Future<void> generatePharmaSGTINs({
    required Function(int current, int total, String productInfo) onProgress,
  }) async {
    // Fetch existing GTINs
    final gtinsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/gtins?page=0&size=50'),
      headers: await _headers,
    );

    if (gtinsResponse.statusCode != 200) {
      throw Exception('Failed to fetch GTINs. Please generate GTINs first.');
    }

    final gtinsData = jsonDecode(gtinsResponse.body);
    final List<dynamic> gtins = gtinsData['content'] ?? [];
    
    if (gtins.isEmpty) {
      throw Exception('No GTINs found. Please generate GTINs first.');
    }

    // Get manufacturer locations for current location assignment
    final glnsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/glns?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> glns = [];
    if (glnsResponse.statusCode == 200) {
      final glnsData = jsonDecode(glnsResponse.body);
      glns = glnsData['content'] ?? [];
    }
    
    // Filter to get manufacturer GLNs
    final manufacturerGlns = glns.where((g) => 
      g['locationType'] == 'MANUFACTURER' || 
      g['locationName']?.toString().contains('Pharma') == true ||
      g['locationName']?.toString().contains('Julphar') == true ||
      g['locationName']?.toString().contains('Neopharma') == true
    ).toList();
    
    if (manufacturerGlns.isEmpty) {
      throw Exception('No manufacturer GLNs found. Please generate GLNs first.');
    }
    
    final total = gtins.length * 10; // 10 SGTINs per GTIN
    int current = 0;
    
    // Manufacturing date is 60 days ago, expiry is 2 years from now (pharmaceutical typical)
    final productionDate = DateTime.now().subtract(const Duration(days: 60));
    final expiryDate = DateTime.now().add(const Duration(days: 730));
    
    for (int gtinIndex = 0; gtinIndex < gtins.length; gtinIndex++) {
      final gtin = gtins[gtinIndex];
      final gtinCode = gtin['gtin'] ?? gtin['gtinCode'];
      final productName = gtin['productName'] ?? 'Product';
      
      // Generate batch number for this GTIN
      final batchNumber = PharmaceuticalProductData.generateBatchNumber(
        gtinIndex % 5 + 1,
        DateTime.now().year,
        DateTime.now().month,
        gtinIndex + 1,
      );
      
      // Pick a manufacturer location (always required for commissioning event)
      final manufacturerGln = manufacturerGlns[gtinIndex % manufacturerGlns.length]['glnCode'];
      
      for (int i = 0; i < 10; i++) {
        current++;
        final serialNumber = _generateSerialNumber();
        onProgress(current, total, '$productName (S/N: $serialNumber)');
        
        // Create SGTIN
        final sgtinResponse = await _httpClient.post(
          Uri.parse('$_baseUrl/identifiers/sgtins'),
          headers: await _headers,
          body: jsonEncode({
            'gtin': gtinCode,
            'serialNumber': serialNumber,
            'batchLotNumber': batchNumber,
            'productionDate': productionDate.toIso8601String().split('T')[0],
            'expiryDate': expiryDate.toIso8601String().split('T')[0],
            'status': 'COMMISSIONED',
            'regulatoryMarket': 'ARE',
            'currentLocationGLN': manufacturerGln,
          }),
        );
        
        if (sgtinResponse.statusCode != 200 && sgtinResponse.statusCode != 201) {
          print('Failed to create SGTIN for $gtinCode: ${sgtinResponse.body}');
        }
        
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  /// Generate pharmaceutical SSCCs (shipping containers) with pharmaceutical extensions
  Future<void> generatePharmaSSCCs({
    required Function(int current, int total, String containerInfo) onProgress,
  }) async {
    // Fetch manufacturer and pharmacy locations
    final glnsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/glns?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> glns = [];
    if (glnsResponse.statusCode == 200) {
      final glnsData = jsonDecode(glnsResponse.body);
      glns = glnsData['content'] ?? [];
    }
    
    final manufacturers = glns.where((g) => 
      g['locationType'] == 'MANUFACTURER'
    ).toList();
    
    final distributors = glns.where((g) => 
      g['locationType'] == 'DISTRIBUTION_CENTER'
    ).toList();
    
    final pharmacies = glns.where((g) => 
      g['locationType'] == 'RETAIL_PHARMACY' || g['locationType'] == 'HOSPITAL_PHARMACY'
    ).toList();
    
    final prefixes = PharmaceuticalProductData.getManufacturerPrefixes();
    
    // Generate: 10 pallets, 20 cases, 20 cartons = 50 total
    const totalPallets = 10;
    const totalCases = 20;
    const totalCartons = 20;
    const total = totalPallets + totalCases + totalCartons;
    int current = 0;
    
    // Generate Pallets
    for (int i = 0; i < totalPallets; i++) {
      current++;
      final prefix = prefixes[i % prefixes.length];
      final serialRef = (100000 + i).toString().padLeft(9, '0');
      final ssccCode = PharmaceuticalProductData.generateSSCC('0', prefix['prefix']!, serialRef);
      
      onProgress(current, total, 'Pallet $ssccCode');
      
      final sourceGln = manufacturers.isNotEmpty 
          ? manufacturers[i % manufacturers.length] 
          : null;
      final destGln = distributors.isNotEmpty 
          ? distributors[i % distributors.length] 
          : null;
      
      await _createPharmaSSCCWithExtension(
        ssccCode: ssccCode,
        containerType: 'PALLET',
        issuingGln: sourceGln?['glnCode'],
        sourceGln: sourceGln?['glnCode'],
        destGln: destGln?['glnCode'],
        batchNumber: PharmaceuticalProductData.generateBatchNumber(i % 5 + 1, 2024, 12, i + 1),
        unitCount: 1000,
        temperatureControlled: i % 3 == 0, // Every 3rd pallet is temp-controlled
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Generate Cases
    for (int i = 0; i < totalCases; i++) {
      current++;
      final prefix = prefixes[i % prefixes.length];
      final serialRef = (200000 + i).toString().padLeft(9, '0');
      final ssccCode = PharmaceuticalProductData.generateSSCC('1', prefix['prefix']!, serialRef);
      
      onProgress(current, total, 'Case $ssccCode');
      
      final sourceGln = distributors.isNotEmpty 
          ? distributors[i % distributors.length] 
          : (manufacturers.isNotEmpty ? manufacturers[i % manufacturers.length] : null);
      final destGln = pharmacies.isNotEmpty 
          ? pharmacies[i % pharmacies.length] 
          : null;
      
      await _createPharmaSSCCWithExtension(
        ssccCode: ssccCode,
        containerType: 'CASE',
        issuingGln: sourceGln?['glnCode'],
        sourceGln: sourceGln?['glnCode'],
        destGln: destGln?['glnCode'],
        batchNumber: PharmaceuticalProductData.generateBatchNumber(i % 5 + 1, 2024, 12, 100 + i),
        unitCount: 50,
        temperatureControlled: i % 4 == 0,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Generate Cartons
    for (int i = 0; i < totalCartons; i++) {
      current++;
      final prefix = prefixes[i % prefixes.length];
      final serialRef = (300000 + i).toString().padLeft(9, '0');
      final ssccCode = PharmaceuticalProductData.generateSSCC('2', prefix['prefix']!, serialRef);
      
      onProgress(current, total, 'Carton $ssccCode');
      
      final sourceGln = pharmacies.isNotEmpty 
          ? pharmacies[i % pharmacies.length] 
          : (distributors.isNotEmpty ? distributors[i % distributors.length] : null);
      
      await _createPharmaSSCCWithExtension(
        ssccCode: ssccCode,
        containerType: 'CARTON',
        issuingGln: sourceGln?['glnCode'],
        sourceGln: sourceGln?['glnCode'],
        destGln: null,
        batchNumber: PharmaceuticalProductData.generateBatchNumber(i % 5 + 1, 2024, 12, 200 + i),
        unitCount: 10,
        temperatureControlled: false,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Helper to create SSCC with pharmaceutical extension
  Future<void> _createPharmaSSCCWithExtension({
    required String ssccCode,
    required String containerType,
    String? issuingGln,
    String? sourceGln,
    String? destGln,
    required String batchNumber,
    required int unitCount,
    required bool temperatureControlled,
  }) async {
    // Create base SSCC
    final ssccResponse = await _httpClient.post(
      Uri.parse('$_baseUrl/identifiers/sscc'),
      headers: await _headers,
      body: jsonEncode({
        'sscc': ssccCode,
        'containerType': containerType,
        'containerStatus': 'PACKED',
        'packingDate': DateTime.now().toIso8601String(),
        if (issuingGln != null) 'issuingGLN': issuingGln,
      }),
    );
    
    if (ssccResponse.statusCode == 200 || ssccResponse.statusCode == 201) {
      // Create pharmaceutical extension
      await _httpClient.post(
        Uri.parse('$_baseUrl/pharmaceutical/sscc/code/$ssccCode'),
        headers: await _headers,
        body: jsonEncode({
          // Cold Chain Requirements
          'coldChainRequired': temperatureControlled,
          'minTemperatureCelsius': temperatureControlled ? 2.0 : null,
          'maxTemperatureCelsius': temperatureControlled ? 8.0 : 25.0,
          'temperatureMonitoringRequired': temperatureControlled,
          
          // GDP Compliance
          'gdpCompliant': true,
          
          // Environmental Controls
          'humidityControlled': temperatureControlled,
          'minHumidityPercent': temperatureControlled ? 30 : null,
          'maxHumidityPercent': temperatureControlled ? 60 : null,
          'lightSensitive': false,
          'orientationSensitive': false,
          'shockSensitive': false,
          
          // Chain of Custody
          'chainOfCustodyRequired': temperatureControlled,
          'requiresSignatureOnReceipt': true,
          'requiresPharmacistVerification': containerType == 'PALLET' || containerType == 'CASE',
          
          // Special Handling
          'fragile': false,
          'doNotStack': false,
          'thisSideUp': containerType == 'PALLET',
        }),
      );
    }
  }

  /// Generate EPCIS events for the full pharmaceutical supply chain lifecycle
  Future<void> generatePharmaEvents({
    required Function(int current, int total, String eventInfo) onProgress,
  }) async {
    // Fetch SGTINs
    final sgtinsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/identifiers/sgtins?page=0&size=100'),
      headers: await _headers,
    );
    
    if (sgtinsResponse.statusCode != 200) {
      throw Exception('Failed to fetch SGTINs. Please generate SGTINs first.');
    }
    
    final sgtinsData = jsonDecode(sgtinsResponse.body);
    final List<dynamic> sgtins = sgtinsData['content'] ?? [];
    
    if (sgtins.isEmpty) {
      throw Exception('No SGTINs found. Please generate SGTINs first.');
    }
    
    // Fetch SSCCs
    final ssccsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/identifiers/sscc?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> ssccs = [];
    if (ssccsResponse.statusCode == 200) {
      final ssccsData = jsonDecode(ssccsResponse.body);
      ssccs = ssccsData['content'] ?? [];
    }
    
    // Fetch GLNs
    final glnsResponse = await _httpClient.get(
      Uri.parse('$_baseUrl/master-data/glns?page=0&size=50'),
      headers: await _headers,
    );
    
    List<dynamic> glns = [];
    if (glnsResponse.statusCode == 200) {
      final glnsData = jsonDecode(glnsResponse.body);
      glns = glnsData['content'] ?? [];
    }
    
    final manufacturers = glns.where((g) => g['locationType'] == 'MANUFACTURING_SITE').toList();
    final distributors = glns.where((g) => g['locationType'] == 'DISTRIBUTION_CENTER').toList();
    final pharmacies = glns.where((g) => g['locationType'] == 'PHARMACY').toList();
    
    // Validate that GLNs exist before generating events
    if (manufacturers.isEmpty) {
      throw Exception('No manufacturer GLNs found. Please generate pharmaceutical GLNs first.');
    }
    if (distributors.isEmpty) {
      throw Exception('No distributor GLNs found. Please generate pharmaceutical GLNs first.');
    }
    if (pharmacies.isEmpty) {
      throw Exception('No pharmacy GLNs found. Please generate pharmaceutical GLNs first.');
    }
    
    final numSgtins = sgtins.length > 100 ? 100 : sgtins.length;
    final numSsccs = ssccs.length > 30 ? 30 : ssccs.length;
    final numShipments = 20;
    
    final total = numSgtins + (numSsccs * 2) + (numShipments * 2);
    int current = 0;
    
    // 1. Commissioning Events (ObjectEvent with ADD)
    for (int i = 0; i < numSgtins; i++) {
      current++;
      final sgtin = sgtins[i];
      final gtinCode = sgtin['gtin'] ?? sgtin['gtinCode'];
      final serialNumber = sgtin['serialNumber'];
      final batchLot = sgtin['batchLotNumber'] ?? 'LOT-24-12-${DateTime.now().year}';
      final expiryDate = sgtin['expiryDate'] ?? DateTime.now().add(const Duration(days: 730)).toIso8601String();
      final epcUri = 'urn:epc:id:sgtin:${gtinCode.substring(1, 8)}.${gtinCode.substring(8, 13)}.$serialNumber';
      
      onProgress(current, total, 'Commissioning SGTIN $serialNumber');
      
      final mfgGln = manufacturers[i % manufacturers.length]['glnCode'];
      
      final ilmd = <String, dynamic>{
        'lotNumber': batchLot,
        'itemExpirationDate': expiryDate,
        'countryOfOrigin': 'AE',
        'productionDate': DateTime.now().subtract(Duration(days: 60 - (i ~/ 10))).toIso8601String().split('T')[0],
      };
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'ADD',
        epcList: [epcUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        readPoint: mfgGln,
        bizLocation: mfgGln,
        eventTime: DateTime.now().subtract(Duration(days: 60 - (i ~/ 10))),
        ilmd: ilmd,
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 2. SSCC Commissioning Events
    for (int i = 0; i < numSsccs && i < ssccs.length; i++) {
      current++;
      final sscc = ssccs[i];
      final ssccCode = sscc['sscc'] ?? sscc['ssccCode'];
      final ssccUri = sscc['ssccUri'] ?? 'urn:epc:id:sscc:${ssccCode.substring(1, 8)}.${ssccCode.substring(8, 17)}';
      
      onProgress(current, total, 'Commissioning SSCC $ssccCode');
      
      final packLocation = manufacturers[i % manufacturers.length]['glnCode'];
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'ADD',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        readPoint: packLocation,
        bizLocation: packLocation,
        eventTime: DateTime.now().subtract(Duration(days: 55 + (i ~/ 5))),
        ilmd: {
          'containerType': sscc['containerType'] ?? 'CASE',
          'countryOfOrigin': 'AE',
          'productionDate': DateTime.now().subtract(Duration(days: 55 + (i ~/ 5))).toIso8601String().split('T')[0],
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 3. Packing/Aggregation Events
    for (int i = 0; i < numSsccs && i < ssccs.length; i++) {
      current++;
      final sscc = ssccs[i];
      final ssccCode = sscc['sscc'] ?? sscc['ssccCode'];
      final ssccUri = sscc['ssccUri'] ?? 'urn:epc:id:sscc:${ssccCode.substring(1, 8)}.${ssccCode.substring(8, 17)}';
      
      onProgress(current, total, 'Packing into SSCC $ssccCode');
      
      final childEpcs = <String>[];
      final startIdx = (i * 3) % sgtins.length;
      for (int j = 0; j < 3 && (startIdx + j) < sgtins.length; j++) {
        final childSgtin = sgtins[startIdx + j];
        final sgtinUri = childSgtin['sgtinUri'];
        if (sgtinUri != null) {
          childEpcs.add(sgtinUri);
        } else {
          final gtinCode = childSgtin['gtin'] ?? childSgtin['gtinCode'];
          final serialNumber = childSgtin['serialNumber'];
          childEpcs.add('urn:epc:id:sgtin:${gtinCode.substring(1, 8)}.${gtinCode.substring(8, 13)}.$serialNumber');
        }
      }
      
      final packLocation = distributors[i % distributors.length]['glnCode'];
      
      await _captureEvent(
        eventType: 'AggregationEvent',
        action: 'ADD',
        parentId: ssccUri,
        childEpcs: childEpcs,
        bizStep: 'urn:epcglobal:cbv:bizstep:packing',
        disposition: 'urn:epcglobal:cbv:disp:in_progress',
        readPoint: packLocation,
        bizLocation: packLocation,
        eventTime: DateTime.now().subtract(Duration(days: 50 + (i ~/ 5))),
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 4. Shipping Events (Manufacturer → Distributor)
    for (int i = 0; i < numShipments ~/ 2; i++) {
      current++;
      final ssccIdx = i % (ssccs.isNotEmpty ? ssccs.length : 1);
      final sscc = ssccs.isNotEmpty ? ssccs[ssccIdx] : null;
      if (sscc == null) continue;
      
      final ssccUri = sscc['ssccUri'] ?? 'urn:epc:id:sscc:${(sscc['sscc'] ?? sscc['ssccCode']).substring(1, 8)}.${(sscc['sscc'] ?? sscc['ssccCode']).substring(8, 17)}';
      
      final sourceGln = manufacturers[i % manufacturers.length]['glnCode'];
      final destGln = distributors[i % distributors.length]['glnCode'];
      
      onProgress(current, total, 'Shipping from manufacturer → distributor');
      
      final shippingOpId1 = 'ship_pharma_mfg_dist_${DateTime.now().millisecondsSinceEpoch}_$i';
      final shippingRef1 = 'PHARMA-SHIP-MFG-DIST-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:shipping',
        disposition: 'urn:epcglobal:cbv:disp:in_transit',
        readPoint: sourceGln,
        bizLocation: sourceGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
          {'sourceType': 'urn:epcglobal:cbv:sdt:owning_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 45 + i)),
        bizData: {
          'shipping_operation_id': shippingOpId1,
          'shipping_reference': shippingRef1,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
      
      // Receiving at distributor
      current++;
      onProgress(current, total, 'Receiving at distributor');
      
      final receivingOpId1 = 'recv_pharma_mfg_dist_${DateTime.now().millisecondsSinceEpoch}_$i';
      final receivingRef1 = 'PHARMA-RECV-MFG-DIST-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:receiving',
        disposition: 'urn:epcglobal:cbv:disp:in_progress',
        readPoint: destGln,
        bizLocation: destGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
          {'destinationType': 'urn:epcglobal:cbv:sdt:owning_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 44 + i)),
        bizData: {
          'receiving_operation_id': receivingOpId1,
          'receiving_reference': receivingRef1,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    // 5. Distributor → Pharmacy shipments
    for (int i = 0; i < numShipments ~/ 2; i++) {
      current++;
      final ssccIdx = (i + numShipments ~/ 2) % (ssccs.isNotEmpty ? ssccs.length : 1);
      final sscc = ssccs.isNotEmpty ? ssccs[ssccIdx] : null;
      final ssccCode = sscc != null ? (sscc['sscc'] ?? sscc['ssccCode']) : '000629200020000000$i';
      final ssccUri = sscc != null && sscc['ssccUri'] != null 
          ? sscc['ssccUri'] 
          : 'urn:epc:id:sscc:${ssccCode.substring(1, 8)}.${ssccCode.substring(8, 17)}';
      
      final sourceGln = distributors[i % distributors.length]['glnCode'];
      final destGln = pharmacies[i % pharmacies.length]['glnCode'];
      
      onProgress(current, total, 'Shipping from distributor → pharmacy');
      
      final shippingOpId2 = 'ship_pharma_dist_pharm_${DateTime.now().millisecondsSinceEpoch}_$i';
      final shippingRef2 = 'PHARMA-SHIP-DIST-PHARM-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:shipping',
        disposition: 'urn:epcglobal:cbv:disp:in_transit',
        readPoint: sourceGln,
        bizLocation: sourceGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
          {'sourceType': 'urn:epcglobal:cbv:sdt:owning_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 40 + i)),
        bizData: {
          'shipping_operation_id': shippingOpId2,
          'shipping_reference': shippingRef2,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
      
      // Receiving at pharmacy
      current++;
      onProgress(current, total, 'Receiving at pharmacy');
      
      final receivingOpId2 = 'recv_pharma_dist_pharm_${DateTime.now().millisecondsSinceEpoch}_$i';
      final receivingRef2 = 'PHARMA-RECV-DIST-PHARM-${(i + 1).toString().padLeft(3, '0')}';
      
      await _captureEvent(
        eventType: 'ObjectEvent',
        action: 'OBSERVE',
        epcList: [ssccUri],
        bizStep: 'urn:epcglobal:cbv:bizstep:receiving',
        disposition: 'urn:epcglobal:cbv:disp:sellable_accessible',
        readPoint: destGln,
        bizLocation: destGln,
        sourceDestList: [
          {'sourceType': 'urn:epcglobal:cbv:sdt:possessing_party', 'sourceID': sourceGln},
        ],
        destinationList: [
          {'destinationType': 'urn:epcglobal:cbv:sdt:possessing_party', 'destinationID': destGln},
          {'destinationType': 'urn:epcglobal:cbv:sdt:owning_party', 'destinationID': destGln},
        ],
        eventTime: DateTime.now().subtract(Duration(days: 39 + i)),
        bizData: {
          'receiving_operation_id': receivingOpId2,
          'receiving_reference': receivingRef2,
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  /// Get pharmacy license type based on location type
  String _getPharmacyLicenseType(String locationType) {
    switch (locationType) {
      case 'MANUFACTURER':
        return 'PHARMACEUTICAL_MANUFACTURING';
      case 'DISTRIBUTION_CENTER':
        return 'PHARMACEUTICAL_DISTRIBUTION';
      case 'HOSPITAL_PHARMACY':
        return 'HOSPITAL_PHARMACY';
      case 'RETAIL_PHARMACY':
        return 'COMMUNITY_PHARMACY';
      default:
        return 'OTHER';
    }
  }

  /// Get operating hours based on location type
  String _getOperatingHours(String locationType) {
    switch (locationType) {
      case 'HOSPITAL_PHARMACY':
        return '24/7';
      case 'RETAIL_PHARMACY':
        return '08:00-23:00';
      case 'MANUFACTURER':
      case 'DISTRIBUTION_CENTER':
        return '08:00-18:00';
      default:
        return '09:00-21:00';
    }
  }

  /// Get license type based on location type (for tobacco - keep existing)
  String _getLicenseType(String locationType) {
    switch (locationType) {
      case 'MANUFACTURER':
        return 'MANUFACTURING';
      case 'DISTRIBUTION_CENTER':
        return 'DISTRIBUTION';
      case 'WHOLESALER':
        return 'WHOLESALE';
      case 'RETAILER':
        return 'RETAIL';
      case 'CONVENIENCE_STORE':
        return 'RETAIL';
      default:
        return 'OTHER';
    }
  }

  /// Get healthcare facility type for pharmaceutical locations
  String _getHealthcareFacilityType(String locationType) {
    switch (locationType) {
      case 'MANUFACTURER':
        return 'PHARMACEUTICAL_MANUFACTURER';
      case 'DISTRIBUTION_CENTER':
        return 'PHARMACEUTICAL_WHOLESALER';
      case 'HOSPITAL_PHARMACY':
        return 'HOSPITAL_PHARMACY';
      case 'RETAIL_PHARMACY':
        return 'RETAIL_PHARMACY';
      default:
        return 'OTHER';
    }
  }

  /// Map pharmaceutical location types to backend enum values
  String _mapLocationTypeToBackend(String locationType) {
    switch (locationType) {
      case 'MANUFACTURER':
        return 'MANUFACTURING_SITE';
      case 'DISTRIBUTION_CENTER':
        return 'DISTRIBUTION_CENTER';
      case 'HOSPITAL_PHARMACY':
      case 'RETAIL_PHARMACY':
        return 'PHARMACY';
      default:
        return 'OTHER';
    }
  }
}
