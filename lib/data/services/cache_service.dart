import 'package:traqtrace_app/features/cache/models/cache_statistics.dart';
import 'package:traqtrace_app/features/cache/models/cache_health.dart';

import '../../core/network/dio_service.dart';


/// Cache Service for managing caching operations in the TraqTrace system
/// Provides interface to backend Phase 3.2 Caching Layer
class CacheService {
  final DioService _dioService;

  CacheService() : _dioService = DioService();

  /// Get all cache statistics
  Future<CacheStatistics?> getAllCacheStatistics() async {
    try {
      final response = await _dioService.get('/cache/statistics');
      return CacheStatistics.fromJson(response.data);
    } catch (e) {
      print('Error getting cache statistics: $e');
      return null;
    }
  }

  /// Get query result cache statistics
  Future<Map<String, dynamic>?> getQueryCacheStatistics() async {
    try {
      final response = await _dioService.get(
        '/cache/statistics/query-results',
      );
      return response.data;
    } catch (e) {
      print('Error getting query cache statistics: $e');
      return null;
    }
  }

  /// Check cache health
  Future<CacheHealth?> getCacheHealth() async {
    try {
      final response = await _dioService.get('/cache/health');
      return CacheHealth.fromJson(response.data);
    } catch (e) {
      print('Error getting cache health: $e');
      return null;
    }
  }

  /// Get distributed cache health
  Future<Map<String, dynamic>?> getDistributedCacheHealth() async {
    try {
      final response = await _dioService.get('/cache/distributed/health');
      return response.data;
    } catch (e) {
      print('Error getting distributed cache health: $e');
      return null;
    }
  }

  /// Warm up cache
  Future<bool> warmUpCache() async {
    try {
      await _dioService.post('/cache/warm-up', data: {});
      print('Cache warm-up initiated successfully');
      return true;
    } catch (e) {
      print('Error warming up cache: $e');
      return false;
    }
  }

  /// Clear query result cache
  Future<bool> clearQueryResultCache() async {
    try {
      await _dioService.delete('/cache/query-results');
      print('Query result cache cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing query result cache: $e');
      return false;
    }
  }

  /// Evict specific query result
  Future<bool> evictQueryResult(String queryKey) async {
    try {
      await _dioService.delete('/cache/query-results/$queryKey');
      print('Query result evicted successfully: $queryKey');
      return true;
    } catch (e) {
      print('Error evicting query result: $e');
      return false;
    }
  }

  /// Clear master data cache for specific type
  Future<bool> clearMasterDataCache(String dataType) async {
    try {
      await _dioService.delete('/cache/master-data/$dataType');
      print('Master data cache cleared successfully: $dataType');
      return true;
    } catch (e) {
      print('Error clearing master data cache: $e');
      return false;
    }
  }

  /// Evict specific master data entry
  Future<bool> evictMasterData(String dataType, String key) async {
    try {
      await _dioService.delete('/cache/master-data/$dataType/$key');
      print('Master data entry evicted successfully: $dataType:$key');
      return true;
    } catch (e) {
      print('Error evicting master data entry: $e');
      return false;
    }
  }

  /// Refresh master data cache
  Future<bool> refreshMasterDataCache() async {
    try {
      await _dioService.post('/cache/master-data/refresh', data: {});
      print('Master data cache refreshed successfully');
      return true;
    } catch (e) {
      print('Error refreshing master data cache: $e');
      return false;
    }
  }

  /// Clear hot data cache
  Future<bool> clearHotDataCache() async {
    try {
      await _dioService.delete('/cache/hot-data');
      print('Hot data cache cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing hot data cache: $e');
      return false;
    }
  }

  /// Identify and cache hot data
  Future<bool> identifyAndCacheHotData() async {
    try {
      await _dioService.post('/cache/hot-data/identify', data: {});
      print('Hot data identification and caching completed');
      return true;
    } catch (e) {
      print('Error identifying hot data: $e');
      return false;
    }
  }

  /// Synchronize distributed cache
  Future<bool> synchronizeCache() async {
    try {
      await _dioService.post('/cache/synchronize', data: {});
      print('Cache synchronization completed');
      return true;
    } catch (e) {
      print('Error synchronizing cache: $e');
      return false;
    }
  }

  /// Clear all caches
  Future<bool> clearAllCaches() async {
    try {
      await _dioService.delete('/cache/all');
      print('All caches cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing all caches: $e');
      return false;
    }
  }
}
