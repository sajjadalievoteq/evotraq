import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/admin/cache_service.dart';
import 'package:traqtrace_app/data/models/admin/cache_statistics.dart';
import 'package:traqtrace_app/data/models/admin/cache_health.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/loading_overlay.dart';
import 'package:traqtrace_app/core/widgets/error_message.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_overview_tab.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_statistics_tab.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_health_tab.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_help_tab.dart';

class CacheManagementScreen extends StatefulWidget {
  const CacheManagementScreen({super.key});

  @override
  State<CacheManagementScreen> createState() => _CacheManagementScreenState();
}

class _CacheManagementScreenState extends State<CacheManagementScreen>
    with SingleTickerProviderStateMixin {
  final CacheService _cacheService = getIt<CacheService>();
  late TabController _tabController;

  CacheStatistics? _statistics;
  CacheHealth? _health;
  Map<String, dynamic>? _distributedHealth;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadCacheData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCacheData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _cacheService.getAllCacheStatistics(),
        _cacheService.getCacheHealth(),
        _cacheService.getDistributedCacheHealth(),
      ]);

      setState(() {
        _statistics = results[0] as CacheStatistics?;
        _health = results[1] as CacheHealth?;
        _distributedHealth = results[2] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load cache data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _performCacheAction(Future<bool> Function() action, String actionName) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await action();
      if (success) {
        context.showSuccess('$actionName completed successfully');
        await _loadCacheData();
      } else {
        context.showError('$actionName failed');
      }
    } catch (e) {
      context.showError('Error during $actionName: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Cache Management'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _loadCacheData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: TraqIcon(AppAssets.iconDashboard)),
            Tab(text: 'Statistics', icon: TraqIcon(AppAssets.iconBarChart)),
            Tab(text: 'Management', icon: TraqIcon(AppAssets.iconSettings)),
            Tab(text: 'Health', icon: TraqIcon(AppAssets.iconSecurity)),
            Tab(text: 'Help', icon: TraqIcon(AppAssets.iconInfo)),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _error != null
            ? ErrorMessage(
                message: _error!,
                onRetry: _loadCacheData,
              )
            : TabBarView(
                controller: _tabController,
                children: [
                if (_statistics == null || _health == null)
                  const Center(child: Text('No data available'))
                else
                  CacheOverviewTab(statistics: _statistics!, health: _health!),
                if (_statistics == null)
                  const Center(child: Text('No statistics available'))
                else
                  CacheStatisticsTab(statistics: _statistics!),
                CacheManagementTab(
                  onWarmUp: () => _performCacheAction(
                    _cacheService.warmUpCache,
                    'Cache Warm-up',
                  ),
                  onSynchronize: () => _performCacheAction(
                    _cacheService.synchronizeCache,
                    'Cache Synchronization',
                  ),
                  onIdentifyHotData: () => _performCacheAction(
                    _cacheService.identifyAndCacheHotData,
                    'Hot Data Identification',
                  ),
                  onClearQueryResults: () => _performCacheAction(
                    _cacheService.clearQueryResultCache,
                    'Clear Query Results Cache',
                  ),
                  onRefreshMasterData: () => _performCacheAction(
                    _cacheService.refreshMasterDataCache,
                    'Refresh Master Data Cache',
                  ),
                  onClearMasterData: () => _showConfirmationDialog(
                    'Clear Master Data Cache',
                    () => _performCacheAction(
                      _cacheService.clearAllMasterDataCache,
                      'Clear Master Data Cache',
                    ),
                  ),
                  onClearHotData: () => _performCacheAction(
                    _cacheService.clearHotDataCache,
                    'Clear Hot Data Cache',
                  ),
                  onClearAll: () => _showConfirmationDialog(
                    'Clear All Caches',
                    () => _performCacheAction(
                      _cacheService.clearAllCaches,
                      'Clear All Caches',
                    ),
                  ),
                  onClearMasterDataType: (dataType) => _performCacheAction(
                    () => _cacheService.clearMasterDataCache(dataType),
                    'Clear $dataType Cache',
                  ),
                  onClearEventDataType: (eventType) => _performCacheAction(
                    () => _cacheService.clearHotDataCache(),
                    'Clear $eventType Cache',
                  ),
                ),
                CacheHealthTab(
                  health: _health,
                  distributedHealth: _distributedHealth,
                  statistics: _statistics,
                ),
                const CacheHelpTab(),
                ],
              ),
      ),
    );
  }



  Future<void> _showConfirmationDialog(String action, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}