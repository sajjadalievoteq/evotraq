import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/admin/performance_test_service.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/widgets/performance_test_metric_row.dart';
import 'package:traqtrace_app/features/admin/screens/performance_test/widgets/performance_test_status_badge.dart';

class PerformanceTestResults extends StatelessWidget {
  const PerformanceTestResults({super.key, required this.results});

  final Map<String, PerformanceTestResult>? results;

  @override
  Widget build(BuildContext context) {
    if (results == null || results!.isEmpty) {
      return Center(
        child: Column(
          children: [
            const TraqIcon(AppAssets.iconPlay, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text(
              'No tests have been run yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Use the controls above to run performance tests'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Test Results', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...results!.entries.map((entry) {
          final testKey = entry.key;
          final result = entry.value;

          final isBackendTest = !testKey.startsWith('frontend');
          final testGroup = isBackendTest ? 'Backend' : 'Frontend';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isBackendTest
                              ? AppColorMapper.infoColor(context)
                                  .withOpacity(0.1)
                              : AppColorMapper.warningColor(context)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isBackendTest
                                ? AppColorMapper.infoColor(context)
                                : AppColorMapper.warningColor(context),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          testGroup,
                          style: TextStyle(
                            color: isBackendTest
                                ? AppColorMapper.infoColor(context)
                                : AppColorMapper.warningColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.testName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      PerformanceTestStatusBadge(passed: result.passed),
                    ],
                  ),
                  const Divider(height: 32),
                  PerformanceTestMetricRow(
                    label: 'Operations per second',
                    value: result.operationsPerSecond.toStringAsFixed(2),
                    iconAsset: NavIcons.performanceOptimization,
                  ),
                  PerformanceTestMetricRow(
                    label: 'Execution time',
                    value: '${result.executionTimeMs} ms',
                    iconAsset: NavIcons.performanceTests,
                  ),
                  PerformanceTestMetricRow(
                    label: 'Threshold',
                    value: '${result.thresholdOperationsPerSecond} ops/s',
                    iconAsset: AppAssets.iconTrendingUp,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        TraqIcon(AppAssets.iconInfo, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(child: Text(result.message)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
