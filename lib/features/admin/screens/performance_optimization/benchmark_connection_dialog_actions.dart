import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/performance_optimization_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_stat_row.dart';

extension BenchmarkConnectionDialogActions
    on PerformanceOptimizationDashboardState {
  void showBenchmarkResultsDialog(Map<String, dynamic> data) {
    final String testType = data['testType'] ?? 'Unknown';
    final String status = data['status'] ?? 'Unknown';
    final List<dynamic> results = data['results'] ?? [];
    final Map<String, dynamic> summary = data['summary'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(
              AppAssets.iconClock,
              color: AppColorMapper.infoColor(context),
            ),
            const SizedBox(width: 8),
            Text('Performance Benchmark Results'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorMapper.infoColor(
                    context,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColorMapper.infoColor(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benchmark: ${testType.toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TraqIcon(
                          status == 'completed'
                              ? AppAssets.iconCheckCircle
                              : AppAssets.iconPending,
                          color: status == 'completed'
                              ? AppColorMapper.successColor(context)
                              : AppColorMapper.warningColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${status.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == 'completed'
                                ? AppColorMapper.successColor(context)
                                : AppColorMapper.warningColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (summary.isNotEmpty) ...[
                const Text(
                  'Performance Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorMapper.successColor(
                      context,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      PerfOptStatRow(
                        'Average Response Time',
                        summary['avgResponseTime'] ?? 'N/A',
                      ),
                      PerfOptStatRow(
                        'Throughput',
                        summary['throughput'] ?? 'N/A',
                      ),
                      PerfOptStatRow(
                        'Success Rate',
                        summary['successRate'] ?? 'N/A',
                      ),
                      PerfOptStatRow(
                        'Total Requests',
                        summary['totalRequests'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'Detailed Results:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: results.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TraqIcon(
                              AppAssets.iconInfo,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No detailed results available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          final String testName =
                              result['testName'] ?? 'Test ${index + 1}';
                          final String responseTime =
                              result['responseTime']?.toString() ?? 'N/A';
                          final String status = result['status'] ?? 'Unknown';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: status == 'success'
                                    ? AppColorMapper.successColor(
                                        context,
                                      ).withValues(alpha: 0.15)
                                    : AppColorMapper.errorColor(
                                        context,
                                      ).withValues(alpha: 0.15),
                                child: TraqIcon(
                                  status == 'success'
                                      ? AppAssets.iconCheck
                                      : AppAssets.iconX,
                                  color: status == 'success'
                                      ? AppColorMapper.successColor(context)
                                      : AppColorMapper.errorColor(context),
                                ),
                              ),
                              title: Text(
                                testName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Response Time: ${responseTime}ms'),
                                  Text(
                                    'Status: ${status.toUpperCase()}',
                                    style: TextStyle(
                                      color: status == 'success'
                                          ? AppColorMapper.successColor(context)
                                          : AppColorMapper.errorColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: result['score'] != null
                                  ? Chip(
                                      label: Text('Score: ${result['score']}'),
                                      backgroundColor: AppColorMapper.infoColor(
                                        context,
                                      ).withValues(alpha: 0.15),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
