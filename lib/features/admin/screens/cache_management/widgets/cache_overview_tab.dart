import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/admin/cache_health.dart';
import 'package:traqtrace_app/data/models/admin/cache_statistics.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_size_row.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_stat_card.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_type_row.dart';

class CacheOverviewTab extends StatelessWidget {
  const CacheOverviewTab({
    super.key,
    required this.statistics,
    required this.health,
  });

  final CacheStatistics statistics;
  final CacheHealth health;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      TraqIcon(
                        health.isUp
                            ? AppAssets.iconCheckCircle
                            : AppAssets.iconXCircle,
                        color: health.isUp
                            ? AppColorMapper.successColor(context)
                            : AppColorMapper.errorColor(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        health.status,
                        style: TextStyle(
                          color: health.isUp
                              ? AppColorMapper.successColor(context)
                              : AppColorMapper.errorColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Last Check: ${DateFormat('HH:mm:ss').format(health.timestampDateTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  if (statistics.totalHits > 0 || statistics.totalMisses > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CacheStatCard(
                          'Hit Ratio',
                          '${(statistics.overallHitRatio * 100).toStringAsFixed(1)}%',
                          AppAssets.iconTarget,
                          AppColorMapper.infoColor(context),
                        ),
                        CacheStatCard(
                          'Total Hits',
                          statistics.totalHits.toString(),
                          AppAssets.iconThumbUp,
                          AppColorMapper.successColor(context),
                        ),
                        CacheStatCard(
                          'Total Misses',
                          statistics.totalMisses.toString(),
                          AppAssets.iconThumbDown,
                          AppColorMapper.warningColor(context),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CacheStatCard(
                          'Cache Entries',
                          statistics.totalCacheEntries.toString(),
                          NavIcons.databasePartitioning,
                          AppColorMapper.chartColor(context, 5),
                        ),
                        CacheStatCard(
                          'Master Data',
                          statistics.masterDataEntries.toString(),
                          AppAssets.iconBraces,
                          AppColorMapper.infoColor(context),
                        ),
                        CacheStatCard(
                          'Hot Data',
                          statistics.hotDataEntries.toString(),
                          AppAssets.iconFlame,
                          AppColorMapper.warningColor(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            AppColorMapper.infoColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          TraqIcon(
                            AppAssets.iconInfo,
                            color: AppColorMapper.infoColor(context),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cache is active with ${statistics.totalCacheEntries} entries. Hit/Miss tracking available for manual cache operations only.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColorMapper.infoColor(context),
                                  ),
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
                  if (statistics.totalHits > 0 || statistics.totalMisses > 0) ...[
                    CacheTypeRow(
                      'Query Results',
                      statistics.queryResultsHitRatio,
                      statistics.queryResultsHits,
                      statistics.queryResultsMisses,
                    ),
                    const SizedBox(height: 8),
                    CacheTypeRow(
                      'Master Data',
                      statistics.masterDataHitRatio,
                      statistics.masterDataHits,
                      statistics.masterDataMisses,
                    ),
                    const SizedBox(height: 8),
                    CacheTypeRow(
                      'Hot Data',
                      statistics.hotDataHitRatio,
                      statistics.hotDataHits,
                      statistics.hotDataMisses,
                    ),
                  ] else ...[
                    CacheSizeRow(
                      'Query Results',
                      statistics.queryResultsEntries,
                      AppAssets.iconSearch,
                      AppColorMapper.chartColor(context, 0),
                    ),
                    const SizedBox(height: 8),
                    CacheSizeRow(
                      'Master Data',
                      statistics.masterDataEntries,
                      AppAssets.iconBraces,
                      AppColorMapper.chartColor(context, 1),
                    ),
                    const SizedBox(height: 8),
                    CacheSizeRow(
                      'Hot Data',
                      statistics.hotDataEntries,
                      AppAssets.iconFlame,
                      AppColorMapper.chartColor(context, 2),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
