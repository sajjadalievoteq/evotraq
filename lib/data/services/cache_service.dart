import 'package:traqtrace_app/features/cache/models/cache_statistics.dart';
import 'package:traqtrace_app/features/cache/models/cache_health.dart';

import '../../core/network/dio_service.dart';

class CacheService {
  final DioService _dioService;

  CacheService({required DioService dioService}) : _dioService = dioService;

  Future<CacheStatistics?> getAllCacheStatistics() async {
    try {
      final response = await _dioService.get('/cache/statistics');
      return CacheStatistics.fromJson(response.data);
    } catch (e) {
      print('Error getting cache statistics: $e');
      return null;
    }
  }

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

  Future<CacheHealth?> getCacheHealth() async {
    try {
      final response = await _dioService.get('/cache/health');
      return CacheHealth.fromJson(response.data);
    } catch (e) {
      print('Error getting cache health: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDistributedCacheHealth() async {
    try {
      final response = await _dioService.get('/cache/distributed/health');
      return response.data;
    } catch (e) {
      print('Error getting distributed cache health: $e');
      return null;
    }
  }

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

  Future<bool> clearAllMasterDataCache() async {
    try {
      await _dioService.delete('/cache/master-data');
      print('Master data cache cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing master data cache: $e');
      return false;
    }
  }

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
