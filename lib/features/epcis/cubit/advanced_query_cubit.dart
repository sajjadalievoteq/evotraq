import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/advanced_query_result.dart';
import '../models/epcis_query_parameters.dart';
import '../services/advanced_query_service.dart';

class AdvancedQueryState extends Equatable {
  final bool loading;
  final String? error;
  final EPCISQueryParameters queryParameters;
  final AdvancedQueryResult? queryResult;
  final Map<String, dynamic>? facetedResults;
  final Map<String, dynamic>? fullTextResults;
  final List<dynamic>? geospatialResults;
  final Map<String, List<String>>? availableFacets;
  final Map<String, List<String>> selectedFacets;
  final String? searchText;
  final String? selectedEventType;
  final double? centerLatitude;
  final double? centerLongitude;
  final double? radius;
  final String? storedQueryName;
  final String? storedQueryDescription;

  AdvancedQueryState({
    this.loading = false,
    this.error,
    EPCISQueryParameters? queryParameters,
    this.queryResult,
    this.facetedResults,
    this.fullTextResults,
    this.geospatialResults,
    this.availableFacets,
    Map<String, List<String>>? selectedFacets,
    this.searchText,
    this.selectedEventType,
    this.centerLatitude,
    this.centerLongitude,
    this.radius,
    this.storedQueryName,
    this.storedQueryDescription,
  }) : queryParameters = queryParameters ?? EPCISQueryParameters(),
       selectedFacets = selectedFacets ?? const {};

  AdvancedQueryState copyWith({
    bool? loading,
    String? error,
    EPCISQueryParameters? queryParameters,
    AdvancedQueryResult? queryResult,
    Map<String, dynamic>? facetedResults,
    Map<String, dynamic>? fullTextResults,
    List<dynamic>? geospatialResults,
    Map<String, List<String>>? availableFacets,
    Map<String, List<String>>? selectedFacets,
    String? searchText,
    String? selectedEventType,
    double? centerLatitude,
    double? centerLongitude,
    double? radius,
    String? storedQueryName,
    String? storedQueryDescription,
  }) {
    return AdvancedQueryState(
      loading: loading ?? this.loading,
      error: error,
      queryParameters: queryParameters ?? this.queryParameters,
      queryResult: queryResult ?? this.queryResult,
      facetedResults: facetedResults ?? this.facetedResults,
      fullTextResults: fullTextResults ?? this.fullTextResults,
      geospatialResults: geospatialResults ?? this.geospatialResults,
      availableFacets: availableFacets ?? this.availableFacets,
      selectedFacets: selectedFacets ?? this.selectedFacets,
      searchText: searchText ?? this.searchText,
      selectedEventType: selectedEventType ?? this.selectedEventType,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      radius: radius ?? this.radius,
      storedQueryName: storedQueryName ?? this.storedQueryName,
      storedQueryDescription:
          storedQueryDescription ?? this.storedQueryDescription,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    queryParameters,
    queryResult,
    facetedResults,
    fullTextResults,
    geospatialResults,
    availableFacets,
    selectedFacets,
    searchText,
    selectedEventType,
    centerLatitude,
    centerLongitude,
    radius,
    storedQueryName,
    storedQueryDescription,
  ];
}

class AdvancedQueryCubit extends Cubit<AdvancedQueryState> {
  final AdvancedQueryService _queryService;

  AdvancedQueryCubit(this._queryService) : super(AdvancedQueryState());

  void _setLoading(bool loading) {
    emit(state.copyWith(loading: loading));
  }

  void _setError(String? message) {
    emit(state.copyWith(error: message));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void updateQueryParameters(EPCISQueryParameters parameters) {
    emit(state.copyWith(queryParameters: parameters));
  }

  Future<void> updateSelectedFacets(Map<String, List<String>> facets) async {
    emit(state.copyWith(selectedFacets: facets));
    if (facets.isNotEmpty) {
      await _executeFacetedQueryWithSelectedFacets();
    } else {
      emit(state.copyWith(facetedResults: null));
    }
  }

  void updateSearchText(String text) {
    emit(state.copyWith(searchText: text));
  }

  void updateSelectedEventType(String? eventType) {
    emit(state.copyWith(selectedEventType: eventType));
  }

  void updateCenterLatitude(double? latitude) {
    emit(state.copyWith(centerLatitude: latitude));
  }

  void updateCenterLongitude(double? longitude) {
    emit(state.copyWith(centerLongitude: longitude));
  }

  void updateRadius(double? radius) {
    emit(state.copyWith(radius: radius));
  }

  void updateStoredQueryName(String name) {
    emit(state.copyWith(storedQueryName: name));
  }

  void updateStoredQueryDescription(String description) {
    emit(state.copyWith(storedQueryDescription: description));
  }

  Future<void> executeAdvancedQuery() async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _queryService.executeAdvancedQuery(
        state.queryParameters,
      );
      emit(state.copyWith(queryResult: result));
    } catch (e) {
      _setError('Failed to execute advanced query: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> executeFacetedQuery(
    EPCISQueryParameters parameters,
    List<String> facetFields,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final results = await _queryService.executeFacetedQuery(
        parameters,
        facetFields,
      );
      emit(state.copyWith(facetedResults: results));
    } catch (e) {
      _setError('Failed to execute faceted query: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> executeFullTextSearch() async {
    final searchText = state.searchText;
    if (searchText == null || searchText.trim().isEmpty) {
      _setError('Please enter search text');
      return;
    }

    _setLoading(true);
    _setError(null);
    try {
      final eventTypes = state.selectedEventType != null
          ? [state.selectedEventType!]
          : null;
      final results = await _queryService.executeFullTextSearch(
        searchText,
        eventTypes,
      );
      emit(state.copyWith(fullTextResults: results));
    } catch (e) {
      _setError('Failed to execute full-text search: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> executeGeospatialQuery() async {
    final centerLatitude = state.centerLatitude;
    final centerLongitude = state.centerLongitude;
    final radius = state.radius;

    if (centerLatitude == null || centerLongitude == null || radius == null) {
      _setError('Please enter center coordinates and radius');
      return;
    }

    _setLoading(true);
    _setError(null);
    try {
      final results = await _queryService.executeGeospatialQuery(
        centerLatitude,
        centerLongitude,
        radius,
        state.queryParameters,
      );
      emit(state.copyWith(geospatialResults: results));
    } catch (e) {
      _setError('Failed to execute geospatial query: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveStoredQuery() async {
    final storedQueryName = state.storedQueryName;
    if (storedQueryName == null || storedQueryName.trim().isEmpty) {
      _setError('Please enter a query name');
      return;
    }

    _setLoading(true);
    _setError(null);
    try {
      await _queryService.createStoredQuery(
        storedQueryName,
        state.queryParameters,
        state.storedQueryDescription,
      );
      emit(state.copyWith(storedQueryName: null, storedQueryDescription: null));
    } catch (e) {
      _setError('Failed to save query: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> exportResults(String format) async {
    if (state.queryResult == null) {
      _setError('No results to export');
      return;
    }

    _setLoading(true);
    _setError(null);
    try {
      await _queryService.exportResults(state.queryParameters, format);
    } catch (e) {
      _setError('Failed to export results: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAvailableFacets() async {
    try {
      final facets = await _queryService.getAvailableFacets();
      emit(state.copyWith(availableFacets: facets));
    } catch (_) {}
  }

  Future<void> refreshAvailableFacets() async {
    await loadAvailableFacets();
  }

  void clearResults() {
    emit(
      state.copyWith(
        queryResult: null,
        facetedResults: null,
        fullTextResults: null,
        geospatialResults: null,
      ),
    );
  }

  void reset() {
    emit(
      state.copyWith(
        queryParameters: EPCISQueryParameters(),
        searchText: null,
        selectedEventType: null,
        centerLatitude: null,
        centerLongitude: null,
        radius: null,
        queryResult: null,
        facetedResults: null,
        fullTextResults: null,
        geospatialResults: null,
        error: null,
        selectedFacets: const {},
      ),
    );
  }

  Future<void> _executeFacetedQueryWithSelectedFacets() async {
    _setLoading(true);
    _setError(null);
    try {
      final queryParams = EPCISQueryParameters();
      final selectedFacets = state.selectedFacets;

      if (selectedFacets.containsKey('eventType')) {
        queryParams.eventTypes = selectedFacets['eventType'];
      }
      if (selectedFacets.containsKey('businessStep')) {
        queryParams.businessSteps = selectedFacets['businessStep'];
      }
      if (selectedFacets.containsKey('disposition')) {
        queryParams.dispositions = selectedFacets['disposition'];
      }
      if (selectedFacets.containsKey('readPoint')) {
        queryParams.readPoints = selectedFacets['readPoint'];
      }

      final facetFields = state.availableFacets?.keys.toList() ?? [];
      final results = await _queryService.executeFacetedQuery(
        queryParams,
        facetFields,
      );
      emit(state.copyWith(facetedResults: results));
    } catch (e) {
      _setError('Failed to execute faceted query: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
