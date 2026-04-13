import '../../../data/services/advanced_query_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TraversalQueryState extends Equatable {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? traversalResult;
  final Map<String, dynamic>? itemHistory;
  final Map<String, dynamic>? aggregationHierarchy;

  final String? lastQueryType;
  final Map<String, dynamic>? lastQueryParameters;

  final String? targetEpc;
  final String? direction;
  final int? maxDepth;
  final DateTime? startTime;
  final DateTime? endTime;

  const TraversalQueryState({
    required this.isLoading,
    required this.error,
    required this.traversalResult,
    required this.itemHistory,
    required this.aggregationHierarchy,
    required this.lastQueryType,
    required this.lastQueryParameters,
    required this.targetEpc,
    required this.direction,
    required this.maxDepth,
    required this.startTime,
    required this.endTime,
  });

  factory TraversalQueryState.initial() => const TraversalQueryState(
    isLoading: false,
    error: null,
    traversalResult: null,
    itemHistory: null,
    aggregationHierarchy: null,
    lastQueryType: null,
    lastQueryParameters: null,
    targetEpc: null,
    direction: null,
    maxDepth: null,
    startTime: null,
    endTime: null,
  );

  TraversalQueryState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? traversalResult,
    Map<String, dynamic>? itemHistory,
    Map<String, dynamic>? aggregationHierarchy,
    String? lastQueryType,
    Map<String, dynamic>? lastQueryParameters,
    String? targetEpc,
    String? direction,
    int? maxDepth,
    DateTime? startTime,
    DateTime? endTime,
    bool clearError = false,
    bool clearResults = false,
    bool clearLastQuery = false,
  }) {
    return TraversalQueryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      traversalResult: clearResults
          ? null
          : (traversalResult ?? this.traversalResult),
      itemHistory: clearResults ? null : (itemHistory ?? this.itemHistory),
      aggregationHierarchy: clearResults
          ? null
          : (aggregationHierarchy ?? this.aggregationHierarchy),
      lastQueryType: clearLastQuery
          ? null
          : (lastQueryType ?? this.lastQueryType),
      lastQueryParameters: clearLastQuery
          ? null
          : (lastQueryParameters ?? this.lastQueryParameters),
      targetEpc: targetEpc ?? this.targetEpc,
      direction: direction ?? this.direction,
      maxDepth: maxDepth ?? this.maxDepth,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    traversalResult,
    itemHistory,
    aggregationHierarchy,
    lastQueryType,
    lastQueryParameters,
    targetEpc,
    direction,
    maxDepth,
    startTime,
    endTime,
  ];
}

class TraversalQueryCubit extends Cubit<TraversalQueryState> {
  final AdvancedQueryService _queryService;

  TraversalQueryCubit(this._queryService)
    : super(TraversalQueryState.initial());

  void updateTargetEpc(String? epc) {
    emit(state.copyWith(targetEpc: epc));
  }

  void updateDirection(String? direction) {
    emit(state.copyWith(direction: direction));
  }

  void updateMaxDepth(int? depth) {
    emit(state.copyWith(maxDepth: depth));
  }

  void updateTimeRange(DateTime? start, DateTime? end) {
    emit(state.copyWith(startTime: start, endTime: end));
  }

  Future<void> executeQuery(
    String queryType,
    Map<String, dynamic> parameters,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        lastQueryType: queryType,
        lastQueryParameters: Map<String, dynamic>.from(parameters),
      ),
    );

    try {
      switch (queryType) {
        case 'supplyChainPath':
          emit(
            state.copyWith(
              targetEpc: parameters['epc'],
              direction: parameters['direction'],
              maxDepth: parameters['maxDepth'],
              startTime: parameters['startTime'],
              endTime: parameters['endTime'],
            ),
          );
          await _executeSupplyChainPathQuery(parameters);
          break;
        case 'itemHistory':
          emit(
            state.copyWith(
              targetEpc: parameters['epc'],
              startTime: parameters['startTime'],
              endTime: parameters['endTime'],
            ),
          );
          await _executeItemHistoryQuery(parameters);
          break;
        case 'aggregationHierarchy':
          emit(
            state.copyWith(
              targetEpc: parameters['parentEpc'],
              startTime: null,
              endTime: null,
            ),
          );
          await _executeAggregationHierarchyQuery(parameters);
          break;
        default:
          throw Exception('Unknown query type: $queryType');
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _executeSupplyChainPathQuery(
    Map<String, dynamic> parameters,
  ) async {
    final result = await _queryService.getSupplyChainPath(
      epc: parameters['epc'] ?? '',
      direction: parameters['direction'] ?? 'both',
      maxDepth: parameters['maxDepth'] ?? 10,
      startTime: parameters['startTime'],
      endTime: parameters['endTime'],
    );

    emit(state.copyWith(traversalResult: result));
  }

  Future<void> _executeItemHistoryQuery(Map<String, dynamic> parameters) async {
    final result = await _queryService.getDetailedItemHistory(
      epc: parameters['epc'] ?? '',
      includeTransformations: parameters['includeTransformations'] ?? true,
      includeAggregations: parameters['includeAggregations'] ?? true,
      startTime: parameters['startTime'],
      endTime: parameters['endTime'],
    );

    emit(state.copyWith(itemHistory: result));
  }

  Future<void> _executeAggregationHierarchyQuery(
    Map<String, dynamic> parameters,
  ) async {
    final result = await _queryService.getAggregationHierarchy(
      parentEpc: parameters['parentEpc'] ?? '',
      timestamp: parameters['timestamp'],
      includeHistory: parameters['includeHistory'] ?? false,
    );

    emit(state.copyWith(aggregationHierarchy: result));
  }

  Future<void> refreshData() async {
    if (state.lastQueryType == null || state.lastQueryParameters == null)
      return;
    await executeQuery(state.lastQueryType!, state.lastQueryParameters!);
  }

  void clearResults() {
    emit(state.copyWith(clearResults: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
