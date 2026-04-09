import 'package:flutter/foundation.dart';
import '../services/advanced_query_service.dart';

class TraversalQueryProvider with ChangeNotifier {
  final AdvancedQueryService _queryService;

  TraversalQueryProvider(this._queryService);

  // State management
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _traversalResult;
  Map<String, dynamic>? _itemHistory;
  Map<String, dynamic>? _aggregationHierarchy;

  // Query parameters
  String? _targetEpc;
  String? _direction;
  int? _maxDepth;
  DateTime? _startTime;
  DateTime? _endTime;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get traversalResult => _traversalResult;
  Map<String, dynamic>? get itemHistory => _itemHistory;
  Map<String, dynamic>? get aggregationHierarchy => _aggregationHierarchy;
  String? get targetEpc => _targetEpc;
  String? get direction => _direction;
  int? get maxDepth => _maxDepth;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  // Update methods
  void updateTargetEpc(String? epc) {
    _targetEpc = epc;
    notifyListeners();
  }

  void updateDirection(String? direction) {
    _direction = direction;
    notifyListeners();
  }

  void updateMaxDepth(int? depth) {
    _maxDepth = depth;
    notifyListeners();
  }

  void updateTimeRange(DateTime? start, DateTime? end) {
    _startTime = start;
    _endTime = end;
    notifyListeners();
  }

  // Query methods
  Future<void> executeQuery(String queryType, Map<String, dynamic> parameters) async {
    _setLoading(true);
    _clearError();
    
    try {
      switch (queryType) {
        case 'supplyChainPath':
          await _executeSupplyChainPathQuery(parameters);
          break;
        case 'itemHistory':
          await _executeItemHistoryQuery(parameters);
          break;
        case 'aggregationHierarchy':
          await _executeAggregationHierarchyQuery(parameters);
          break;
        default:
          throw Exception('Unknown query type: $queryType');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _executeSupplyChainPathQuery(Map<String, dynamic> parameters) async {
    try {
      final result = await _queryService.getSupplyChainPath(
        epc: parameters['epc'] ?? '',
        direction: parameters['direction'] ?? 'both',
        maxDepth: parameters['maxDepth'] ?? 10,
        startTime: parameters['startTime'],
        endTime: parameters['endTime'],
      );
      
      _traversalResult = result;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _executeItemHistoryQuery(Map<String, dynamic> parameters) async {
    try {
      final result = await _queryService.getDetailedItemHistory(
        epc: parameters['epc'] ?? '',
        includeTransformations: parameters['includeTransformations'] ?? true,
        includeAggregations: parameters['includeAggregations'] ?? true,
        startTime: parameters['startTime'],
        endTime: parameters['endTime'],
      );
      
      _itemHistory = result;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _executeAggregationHierarchyQuery(Map<String, dynamic> parameters) async {
    try {
      final result = await _queryService.getAggregationHierarchy(
        parentEpc: parameters['parentEpc'] ?? '',
        timestamp: parameters['timestamp'],
        includeHistory: parameters['includeHistory'] ?? false,
      );
      
      _aggregationHierarchy = result;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshData() async {
    if (_targetEpc != null) {
      final parameters = {
        'epc': _targetEpc,
        'direction': _direction ?? 'both',
        'maxDepth': _maxDepth ?? 10,
        'startTime': _startTime,
        'endTime': _endTime,
      };
      
      await executeQuery('supplyChainPath', parameters);
    }
  }

  void clearResults() {
    _traversalResult = null;
    _itemHistory = null;
    _aggregationHierarchy = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
