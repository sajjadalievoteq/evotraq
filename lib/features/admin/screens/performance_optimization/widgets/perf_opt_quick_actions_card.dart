import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PerfOptQuickActionsCard extends StatelessWidget {
  const PerfOptQuickActionsCard({
    super.key,
    required this.onRunBenchmark,
    required this.onDetectSlowQueries,
    required this.onOptimizeMemory,
    required this.onDetectLeaks,
  });

  final VoidCallback onRunBenchmark;
  final VoidCallback onDetectSlowQueries;
  final VoidCallback onOptimizeMemory;
  final VoidCallback onDetectLeaks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: onRunBenchmark,
                  icon: const TraqIcon(NavIcons.performanceOptimization, size: 16),
                  label: const Text('Run Benchmark'),
                ),
                ElevatedButton.icon(
                  onPressed: onDetectSlowQueries,
                  icon: const TraqIcon(AppAssets.iconBarChart, size: 16),
                  label: const Text('Detect Slow Queries'),
                ),
                ElevatedButton.icon(
                  onPressed: onOptimizeMemory,
                  icon: TraqIcon(AppAssets.iconRefresh, size: 16),
                  label: const Text('Optimize Memory'),
                ),
                ElevatedButton.icon(
                  onPressed: onDetectLeaks,
                  icon: const TraqIcon(AppAssets.iconHub, size: 16),
                  label: const Text('Check Leaks'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
