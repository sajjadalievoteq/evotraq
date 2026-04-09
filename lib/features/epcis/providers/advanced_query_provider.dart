// import 'package:flutter/foundation.dart';
// import '../models/epcis_query_parameters.dart';
// import '../models/advanced_query_result.dart';
// import '../services/advanced_query_service.dart';

// class AdvancedQueryProvider with ChangeNotifier {
//   final AdvancedQueryService _queryService;

//   AdvancedQueryProvider(this._queryService) {
//     // Load available facets on initialization
//     _loadAvailableFacets();
//   }

//   // State management
//   bool _isLoading = false;
//   String? _error;
//   EPCISQueryParameters _queryParameters = EPCISQueryParameters();
//   AdvancedQueryResult? _queryResult;
//   Map<String, dynamic>? _facetedResults;
//   Map<String, dynamic>? _fullTextResults;
//   List<dynamic>? _geospatialResults;

//   // Faceted search state
//   Map<String, List<String>>? _availableFacets;
//   Map<String, List<String>> _selectedFacets = {};

//   // Query form state
//   String? _searchText;
//   String? _selectedEventType;
//   double? _centerLatitude;
//   double? _centerLongitude;
//   double? _radius;

//   // Stored query state
//   String? _storedQueryName;
//   String? _storedQueryDescription;

//   // Getters
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   EPCISQueryParameters get queryParameters => _queryParameters;
//   AdvancedQueryResult? get queryResult => _queryResult;
//   Map<String, dynamic>? get facetedResults => _facetedResults;
//   Map<String, dynamic>? get fullTextResults => _fullTextResults;
//   List<dynamic>? get geospatialResults => _geospatialResults;
//   Map<String, List<String>>? get availableFacets => _availableFacets;
//   Map<String, List<String>> get selectedFacets => _selectedFacets;
//   String? get searchText => _searchText;
//   String? get selectedEventType => _selectedEventType;
//   double? get centerLatitude => _centerLatitude;
//   double? get centerLongitude => _centerLongitude;
//   double? get radius => _radius;

//   // Update methods
//   void updateQueryParameters(EPCISQueryParameters parameters) {
//     _queryParameters = parameters;
//     notifyListeners();
//   }

//   void updateSelectedFacets(Map<String, List<String>> facets) {
//     _selectedFacets = facets;
//     notifyListeners();
    
//     // Automatically execute faceted query when facets are selected
//     if (facets.isNotEmpty) {
//       _executeFacetedQueryWithSelectedFacets();
//     } else {
//       // Clear results when no facets are selected
//       _facetedResults = null;
//       notifyListeners();
//     }
//   }

//   Future<void> _executeFacetedQueryWithSelectedFacets() async {
//     _setLoading(true);
//     _clearError();

//     try {
//       // Create query parameters from selected facets
//       final queryParams = EPCISQueryParameters();
      
//       // Set facet filters based on selected facets
//       if (_selectedFacets.containsKey('eventType')) {
//         queryParams.eventTypes = _selectedFacets['eventType'];
//       }
//       if (_selectedFacets.containsKey('businessStep')) {
//         queryParams.businessSteps = _selectedFacets['businessStep'];
//       }
//       if (_selectedFacets.containsKey('disposition')) {
//         queryParams.dispositions = _selectedFacets['disposition'];
//       }
//       if (_selectedFacets.containsKey('readPoint')) {
//         queryParams.readPoints = _selectedFacets['readPoint'];
//       }
      
//       // Get the list of facet fields that are available
//       final facetFields = _availableFacets?.keys.toList() ?? [];
      
//       // Execute the faceted query
//       _facetedResults = await _queryService.executeFacetedQuery(queryParams, facetFields);
//     } catch (e) {
//       _setError('Failed to execute faceted query: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void updateSearchText(String text) {
//     _searchText = text;
//     notifyListeners();
//   }

//   void updateSelectedEventType(String? eventType) {
//     _selectedEventType = eventType;
//     notifyListeners();
//   }

//   void updateCenterLatitude(double? latitude) {
//     _centerLatitude = latitude;
//     notifyListeners();
//   }

//   void updateCenterLongitude(double? longitude) {
//     _centerLongitude = longitude;
//     notifyListeners();
//   }

//   void updateRadius(double? radius) {
//     _radius = radius;
//     notifyListeners();
//   }

//   void updateStoredQueryName(String name) {
//     _storedQueryName = name;
//     notifyListeners();
//   }

//   void updateStoredQueryDescription(String description) {
//     _storedQueryDescription = description;
//     notifyListeners();
//   }

//   // Query execution methods
//   Future<void> executeAdvancedQuery() async {
//     _setLoading(true);
//     _clearError();

//     try {
//       _queryResult = await _queryService.executeAdvancedQuery(_queryParameters);
//     } catch (e) {
//       _setError('Failed to execute advanced query: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> executeFacetedQuery(EPCISQueryParameters parameters, List<String> facetFields) async {
//     _setLoading(true);
//     _clearError();

//     try {
//       _facetedResults = await _queryService.executeFacetedQuery(parameters, facetFields);
//     } catch (e) {
//       _setError('Failed to execute faceted query: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> executeFullTextSearch() async {
//     if (_searchText == null || _searchText!.trim().isEmpty) {
//       _setError('Please enter search text');
//       return;
//     }

//     _setLoading(true);
//     _clearError();

//     try {
//       List<String>? eventTypes = _selectedEventType != null ? [_selectedEventType!] : null;
//       _fullTextResults = await _queryService.executeFullTextSearch(_searchText!, eventTypes);
//     } catch (e) {
//       _setError('Failed to execute full-text search: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> executeGeospatialQuery() async {
//     if (_centerLatitude == null || _centerLongitude == null || _radius == null) {
//       _setError('Please enter center coordinates and radius');
//       return;
//     }

//     _setLoading(true);
//     _clearError();

//     try {
//       _geospatialResults = await _queryService.executeGeospatialQuery(
//         _centerLatitude!,
//         _centerLongitude!,
//         _radius!,
//         _queryParameters,
//       );
//     } catch (e) {
//       _setError('Failed to execute geospatial query: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> saveStoredQuery() async {
//     if (_storedQueryName == null || _storedQueryName!.trim().isEmpty) {
//       _setError('Please enter a query name');
//       return;
//     }

//     _setLoading(true);
//     _clearError();

//     try {
//       await _queryService.createStoredQuery(
//         _storedQueryName!,
//         _queryParameters,
//         _storedQueryDescription,
//       );
//       _storedQueryName = null;
//       _storedQueryDescription = null;
//     } catch (e) {
//       _setError('Failed to save query: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> exportResults(String format) async {
//     if (_queryResult == null) {
//       _setError('No results to export');
//       return;
//     }

//     _setLoading(true);
//     _clearError();

//     try {
//       await _queryService.exportResults(_queryParameters, format);
//     } catch (e) {
//       _setError('Failed to export results: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Load available facets on initialization
//   Future<void> _loadAvailableFacets() async {
//     try {
//       _availableFacets = await _queryService.getAvailableFacets();
//       notifyListeners();
//     } catch (e) {
//       // Silently fail for facets loading, don't show error to user
//       print('Failed to load available facets: $e');
//     }
//   }

//   // Public method to refresh facets
//   Future<void> refreshAvailableFacets() async {
//     await _loadAvailableFacets();
//   }

//   // Utility methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setError(String error) {
//     _error = error;
//     notifyListeners();
//   }

//   void _clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   void clearResults() {
//     _queryResult = null;
//     _facetedResults = null;
//     _fullTextResults = null;
//     _geospatialResults = null;
//     notifyListeners();
//   }

//   void reset() {
//     _queryParameters = EPCISQueryParameters();
//     _searchText = null;
//     _selectedEventType = null;
//     _centerLatitude = null;
//     _centerLongitude = null;
//     _radius = null;
//     clearResults();
//     _clearError();
//     notifyListeners();
//   }
// }
