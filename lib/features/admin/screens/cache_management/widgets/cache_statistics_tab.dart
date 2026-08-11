import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/cache_statistics.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_detailed_stats_card.dart';

class CacheStatisticsTab extends StatelessWidget {
  const CacheStatisticsTab({super.key, required this.statistics});

  final CacheStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CacheDetailedStatsCard(
            'Query Results Cache',
            statistics.queryResults,
          ),
          const SizedBox(height: 16),
          CacheDetailedStatsCard('Master Data Cache', statistics.masterData),
          const SizedBox(height: 16),
          CacheDetailedStatsCard('Hot Data Cache', statistics.hotData),
          const SizedBox(height: 16),
          CacheDetailedStatsCard('Overall Statistics', statistics.overall),
        ],
      ),
    );
  }
}
