import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/admin/cache_health.dart';
import 'package:traqtrace_app/data/models/admin/cache_statistics.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_detailed_stats_card.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_health_row.dart';

class CacheHealthTab extends StatelessWidget {
  const CacheHealthTab({
    super.key,
    this.health,
    this.distributedHealth,
    this.statistics,
  });

  final CacheHealth? health;
  final Map<String, dynamic>? distributedHealth;
  final CacheStatistics? statistics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (health != null)
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
                    CacheHealthRow('Status', health!.status, health!.isUp),
                    CacheHealthRow(
                      'Healthy',
                      health!.healthy.toString(),
                      health!.healthy,
                    ),
                    CacheHealthRow(
                      'Last Check',
                      DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(health!.timestampDateTime),
                      true,
                    ),
                    if (health!.error != null)
                      CacheHealthRow('Error', health!.error!, false),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (distributedHealth != null)
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
                    ...distributedHealth!.entries.map(
                      (entry) => CacheHealthRow(
                        formatCacheStatKey(entry.key),
                        formatCacheStatValue(entry.value),
                        entry.key != 'status' ||
                            entry.value.toString().toLowerCase() == 'healthy',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (statistics != null)
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
                    CacheHealthRow(
                      'Monitoring Enabled',
                      statistics!.monitoringEnabled.toString(),
                      statistics!.monitoringEnabled,
                    ),
                    CacheHealthRow(
                      'Distributed Enabled',
                      statistics!.distributedEnabled.toString(),
                      statistics!.distributedEnabled,
                    ),
                    CacheHealthRow(
                      'Query Cache Size',
                      statistics!.queryResultsCacheSize.toString(),
                      true,
                    ),
                    CacheHealthRow(
                      'Hot Data Patterns',
                      statistics!.hotDataPatterns.toString(),
                      true,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
