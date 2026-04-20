import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../../../data/services/cache_service.dart';
import '../../cache/models/cache_statistics.dart';
import '../../cache/models/cache_health.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_message.dart';
import '../../../core/widgets/app_drawer.dart';

/// Cache Management Screen for Phase 3.2 Caching Layer
/// Provides comprehensive cache monitoring and management interface
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$actionName completed successfully')),
        );
        await _loadCacheData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$actionName failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during $actionName: $e')),
      );
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadCacheData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
            Tab(text: 'Management', icon: Icon(Icons.settings)),
            Tab(text: 'Health', icon: Icon(Icons.health_and_safety)),
            Tab(text: 'Help', icon: Icon(Icons.help_outline)),
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
                  _buildOverviewTab(),
                  _buildStatisticsTab(),
                  _buildManagementTab(),
                  _buildHealthTab(),
                  _buildHelpTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_statistics == null || _health == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cache Health Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cache System Status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _health!.isUp ? Icons.check_circle : Icons.error,
                        color: _health!.isUp ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _health!.status,
                        style: TextStyle(
                          color: _health!.isUp ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Last Check: ${DateFormat('HH:mm:ss').format(_health!.timestampDateTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Overall Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Performance',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  // Show hit/miss stats if available, otherwise show cache sizes
                  if (_statistics!.totalHits > 0 || _statistics!.totalMisses > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Hit Ratio',
                          '${(_statistics!.overallHitRatio * 100).toStringAsFixed(1)}%',
                          Icons.track_changes,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Total Hits',
                          _statistics!.totalHits.toString(),
                          Icons.thumb_up,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Total Misses',
                          _statistics!.totalMisses.toString(),
                          Icons.thumb_down,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ] else ...[
                    // Show cache entry counts when hit/miss data is not available
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Cache Entries',
                          _statistics!.totalCacheEntries.toString(),
                          Icons.storage,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          'Master Data',
                          _statistics!.masterDataEntries.toString(),
                          Icons.data_object,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Hot Data',
                          _statistics!.hotDataEntries.toString(),
                          Icons.whatshot,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cache is active with ${_statistics!.totalCacheEntries} entries. Hit/Miss tracking available for manual cache operations only.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cache Types Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cache Types Performance',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  // Show hit/miss performance if available, otherwise show cache sizes
                  if (_statistics!.totalHits > 0 || _statistics!.totalMisses > 0) ...[
                    _buildCacheTypeRow('Query Results', _statistics!.queryResultsHitRatio, _statistics!.queryResultsHits, _statistics!.queryResultsMisses),
                    const SizedBox(height: 8),
                    _buildCacheTypeRow('Master Data', _statistics!.masterDataHitRatio, _statistics!.masterDataHits, _statistics!.masterDataMisses),
                    const SizedBox(height: 8),
                    _buildCacheTypeRow('Hot Data', _statistics!.hotDataHitRatio, _statistics!.hotDataHits, _statistics!.hotDataMisses),
                  ] else ...[
                    _buildCacheSizeRow('Query Results', _statistics!.queryResultsEntries, Icons.search, Colors.blue),
                    const SizedBox(height: 8),
                    _buildCacheSizeRow('Master Data', _statistics!.masterDataEntries, Icons.data_object, Colors.green),
                    const SizedBox(height: 8),
                    _buildCacheSizeRow('Hot Data', _statistics!.hotDataEntries, Icons.whatshot, Colors.orange),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCacheTypeRow(String type, double hitRatio, int hits, int misses) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(type, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: hitRatio,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              hitRatio > 0.8 ? Colors.green : hitRatio > 0.5 ? Colors.orange : Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(hitRatio * 100).toStringAsFixed(1)}%'),
        const SizedBox(width: 16),
        Text('$hits/$misses'),
      ],
    );
  }

  Widget _buildCacheSizeRow(String type, int entries, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(type, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$entries entries',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          entries > 0 ? 'Active' : 'Empty',
          style: TextStyle(
            color: entries > 0 ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: Text('No statistics available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailedStatsCard('Query Results Cache', _statistics!.queryResults),
          const SizedBox(height: 16),
          _buildDetailedStatsCard('Master Data Cache', _statistics!.masterData),
          const SizedBox(height: 16),
          _buildDetailedStatsCard('Hot Data Cache', _statistics!.hotData),
          const SizedBox(height: 16),
          _buildDetailedStatsCard('Overall Statistics', _statistics!.overall),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsCard(String title, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...stats.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatStatKey(entry.key),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _formatStatValue(entry.value),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatStatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  String _formatStatValue(dynamic value) {
    if (value is double) {
      if (value >= 0 && value <= 1) {
        return '${(value * 100).toStringAsFixed(1)}%';
      }
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  Widget _buildManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _performCacheAction(
                          _cacheService.warmUpCache,
                          'Cache Warm-up',
                        ),
                        icon: const Icon(Icons.whatshot),
                        label: const Text('Warm Up Cache'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _performCacheAction(
                          _cacheService.synchronizeCache,
                          'Cache Synchronization',
                        ),
                        icon: const Icon(Icons.sync),
                        label: const Text('Synchronize'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _performCacheAction(
                          _cacheService.identifyAndCacheHotData,
                          'Hot Data Identification',
                        ),
                        icon: const Icon(Icons.whatshot),
                        label: const Text('Identify Hot Data'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cache Management Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cache Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildManagementAction(
                    'Clear Query Results Cache',
                    'Remove all cached query results',
                    Icons.query_stats,
                    () => _cacheService.clearQueryResultCache(),
                  ),
                  _buildManagementAction(
                    'Refresh Master Data Cache',
                    'Reload all master data into cache',
                    Icons.refresh,
                    () => _cacheService.refreshMasterDataCache(),
                  ),
                  _buildManagementAction(
                    'Clear Hot Data Cache',
                    'Remove all cached hot data',
                    Icons.local_fire_department,
                    () => _cacheService.clearHotDataCache(),
                  ),
                  const Divider(),
                  _buildManagementAction(
                    'Clear All Caches',
                    'Remove all cached data (Use with caution)',
                    Icons.delete_sweep,
                    () => _cacheService.clearAllCaches(),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Master Data Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Master Data Cache Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...['gtin', 'gln', 'sscc', 'sgtin', 'trading-partner', 'validation-rule'].map(
                    (dataType) => _buildMasterDataAction(dataType),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Event Data Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Data Cache Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...['object-event', 'aggregation-event', 'transaction-event', 'transformation-event'].map(
                    (eventType) => _buildEventDataAction(eventType),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementAction(
    String title,
    String description,
    IconData icon,
    Future<bool> Function() action, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(description),
      trailing: ElevatedButton(
        onPressed: () => isDestructive
            ? _showConfirmationDialog(title, () => _performCacheAction(action, title))
            : _performCacheAction(action, title),
        style: isDestructive
            ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
            : null,
        child: Text(isDestructive ? 'Clear' : 'Execute'),
      ),
    );
  }

  Widget _buildMasterDataAction(String dataType) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: Text('${dataType.toUpperCase()} Cache'),
      subtitle: Text('Manage $dataType master data cache'),
      trailing: ElevatedButton(
        onPressed: () => _performCacheAction(
          () => _cacheService.clearMasterDataCache(dataType),
          'Clear $dataType Cache',
        ),
        child: const Text('Clear'),
      ),
    );
  }

  Widget _buildEventDataAction(String eventType) {
    return ListTile(
      leading: const Icon(Icons.event),
      title: Text('${eventType.replaceAll('-', ' ').toUpperCase()} Cache'),
      subtitle: Text('Manage $eventType hot data cache'),
      trailing: ElevatedButton(
        onPressed: () => _performCacheAction(
          () => _cacheService.clearHotDataCache(),
          'Clear $eventType Cache',
        ),
        child: const Text('Clear'),
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cache Health Status
          if (_health != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache System Health',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildHealthRow('Status', _health!.status, _health!.isUp),
                    _buildHealthRow('Healthy', _health!.healthy.toString(), _health!.healthy),
                    _buildHealthRow('Last Check', DateFormat('yyyy-MM-dd HH:mm:ss').format(_health!.timestampDateTime), true),
                    if (_health!.error != null)
                      _buildHealthRow('Error', _health!.error!, false),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Distributed Cache Health
          if (_distributedHealth != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distributed Cache Health',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ..._distributedHealth!.entries.map((entry) => _buildHealthRow(
                          _formatStatKey(entry.key),
                          _formatStatValue(entry.value),
                          entry.key != 'status' || entry.value.toString().toLowerCase() == 'healthy',
                        )),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // System Information
          if (_statistics != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildHealthRow('Monitoring Enabled', _statistics!.monitoringEnabled.toString(), _statistics!.monitoringEnabled),
                    _buildHealthRow('Distributed Enabled', _statistics!.distributedEnabled.toString(), _statistics!.distributedEnabled),
                    _buildHealthRow('Query Cache Size', _statistics!.queryResultsCacheSize.toString(), true),
                    _buildHealthRow('Hot Data Patterns', _statistics!.hotDataPatterns.toString(), true),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String value, bool isHealthy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.error,
                size: 16,
                color: isHealthy ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isHealthy ? Colors.green : Colors.red,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'TraqTrace Cache Management System',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phase 3.2 Caching Layer - Comprehensive Performance Optimization',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // System Overview
          _buildHelpSection(
            'System Overview',
            Icons.architecture,
            Colors.blue,
            [
              'The TraqTrace caching system implements a multi-tier caching strategy designed to optimize performance for pharmaceutical track and trace operations.',
              'Our implementation uses Redis as the distributed cache backend with Spring Cache annotations for seamless integration.',
              'The system provides automatic cache management, real-time monitoring, and intelligent eviction policies.',
            ],
          ),

          const SizedBox(height: 16),

          // Cache Types
          _buildHelpSection(
            'Cache Types Implemented',
            Icons.layers,
            Colors.green,
            [
              '🔵 Query Results Cache (15-minute TTL): Stores complex EPCIS query results for fast retrieval',
              '🟡 Master Data Cache (1-hour TTL): Caches GS1 identifiers (GTIN, GLN, SSCC, SGTIN) and validation rules',
              '🔴 Hot Data Cache (30-minute TTL): Stores recent EPCIS events (Object, Aggregation, Transaction, Transformation)',
              '🟣 Distributed Cache: Enables cache synchronization across multiple application instances',
            ],
          ),

          const SizedBox(height: 16),

          // Implementation Details
          _buildHelpSection(
            'Technical Implementation',
            Icons.code,
            Colors.orange,
            [
              '• Spring Cache Integration: @Cacheable, @CacheEvict, and @CachePut annotations',
              '• Redis Backend: Lettuce connection factory with connection pooling',
              '• Serialization: JSON serialization for complex objects',
              '• Key Strategy: Unique cache keys per service and identifier type',
              '• TTL Management: Time-based expiration with configurable durations',
              '• Eviction Policy: LRU (Least Recently Used) for optimal memory usage',
            ],
          ),

          const SizedBox(height: 16),

          // Services Covered
          _buildHelpSection(
            'Cached Services Coverage',
            Icons.settings,
            Colors.purple,
            [
              '✅ GS1 Identifier Services: GTIN, GLN, SSCC, SGTIN services',
              '✅ EPCIS Event Services: Object, Aggregation, Transaction, Transformation events',
              '✅ Advanced Query Service: Complex multi-criteria searches',
              '✅ Validation Rules: Business rule validation caching',
              '✅ Trading Partners: Supply chain partner information',
            ],
          ),

          const SizedBox(height: 16),

          // Development Environment
          _buildHelpSection(
            'Development Environment (Current)',
            Icons.computer,
            Colors.teal,
            [
              '🐳 Docker Redis Container (REQUIRED)',
              '   • Image: redis:7-alpine',
              '   • Port: 6379 (localhost)',
              '   • Password: None (development only)',
              '',
              '🚀 Quick Setup Commands:',
              '   1. Install Docker Desktop',
              '   2. Run: docker run -d --name redis-cache -p 6379:6379 redis:7-alpine',
              '   3. Verify: docker ps',
              '   4. Stop: docker stop redis-cache',
              '   5. Start: docker start redis-cache',
              '',
              '⚙️ Application Configuration:',
              '   • spring.redis.host=localhost',
              '   • spring.redis.port=6379',
              '   • Connection pooling enabled',
              '',
              '❗ Note: Redis must be running for cache operations to work',
            ],
          ),

          const SizedBox(height: 16),

          // Production Environment
          _buildHelpSection(
            'Production Environment (Azure)',
            Icons.cloud,
            Colors.deepPurple,
            [
              '☁️ Azure Redis Cache (Managed Service)',
              '   • Tier: Standard (Primary + Replica)',
              '   • SLA: 99.9% uptime guarantee',
              '   • Port: 6380 (SSL enabled)',
              '   • Features: Automatic backup, scaling, monitoring',
              '',
              '🔐 Security Features:',
              '   • SSL/TLS encryption in transit',
              '   • VNet integration for private access',
              '   • Access key rotation',
              '   • Azure Active Directory integration',
              '',
              '📊 Monitoring Integration:',
              '   • Azure Monitor integration',
              '   • Application Insights correlation',
              '   • Custom metrics and alerts',
            ],
          ),

          const SizedBox(height: 16),

          // Performance Benefits
          _buildHelpSection(
            'Performance Benefits',
            Icons.speed,
            Colors.red,
            [
              '🚀 Response Time Reduction: Up to 90% faster for cached queries',
              '💾 Database Load Reduction: Significant decrease in PostgreSQL queries',
              '📈 Scalability Improvement: Better handling of concurrent requests',
              '🔄 Distributed Performance: Cache sharing across application instances',
              '⚡ Hot Data Access: Near-instant retrieval of recent events',
            ],
          ),

          const SizedBox(height: 16),

          // Management Operations
          _buildHelpSection(
            'Available Management Operations',
            Icons.admin_panel_settings,
            Colors.indigo,
            [
              '🔄 Cache Warm-up: Pre-populate cache with frequently accessed data',
              '🧹 Selective Clearing: Clear specific cache types (Master Data, Hot Data, Query Results)',
              '📊 Real-time Statistics: Monitor hit ratios, cache sizes, and performance metrics',
              '🏥 Health Monitoring: Track cache system health and connectivity',
              '⚠️ Emergency Clear: Complete cache reset (use with caution)',
              '🔍 Cache Inspection: Detailed view of cache contents and metadata',
            ],
          ),

          const SizedBox(height: 16),

          // Best Practices
          _buildHelpSection(
            'Best Practices & Guidelines',
            Icons.thumb_up,
            Colors.green[700]!,
            [
              '• Monitor cache hit ratios regularly (target: >80%)',
              '• Use cache warm-up after deployments',
              '• Clear caches selectively rather than full clears',
              '• Monitor memory usage and adjust TTL as needed',
              '• Use the Health tab to verify Redis connectivity',
              '• In production, rely on Azure Redis Cache monitoring',
              '• Test cache behavior in staging before production',
            ],
          ),

          const SizedBox(height: 16),

          // Troubleshooting
          _buildHelpSection(
            'Troubleshooting Common Issues',
            Icons.bug_report,
            Colors.red[700]!,
            [
              '🔥 "Unable to connect to Redis" Error:',
              '   1. Check if Docker Redis is running: docker ps',
              '   2. Start Redis if stopped: docker start redis-cache',
              '   3. Verify port 6379 is not blocked',
              '   4. Check application.properties Redis configuration',
              '',
              '⚡ Poor Cache Performance:',
              '   • Check hit ratios in Statistics tab',
              '   • Consider increasing TTL values',
              '   • Use cache warm-up for frequently accessed data',
              '',
              '💾 Memory Issues:',
              '   • Monitor cache sizes in Overview tab',
              '   • Adjust max-size limits in configuration',
              '   • Clear unused caches periodically',
              '',
              '🔄 Production Deployment:',
              '   • Ensure Azure Redis Cache is provisioned',
              '   • Update connection strings in environment variables',
              '   • Test connectivity before deployment',
            ],
          ),

          const SizedBox(height: 24),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                const SizedBox(height: 8),
                Text(
                  'Cache Management System v3.2',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Implemented as part of Phase 3.2 - Performance Optimization Layer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, IconData icon, Color color, List<String> items) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              if (item.isEmpty) {
                return const SizedBox(height: 8);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              );
            }),
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
