import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/performance_optimization_dashboard_screen.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_stat_row.dart';

extension OptimizationDialogActions on PerformanceOptimizationDashboardState {
  void showSlowQueriesDialog(Map<String, dynamic> data) {
    final List<dynamic> slowQueries = data['slowQueries'] ?? [];
    final String summary = data['summary'] ?? 'No summary available';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(
              AppAssets.iconBarChart,
              color: AppColorMapper.errorColor(context),
            ),
            const SizedBox(width: 8),
            const Text('Slow Query Detection Results'),
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
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(summary),
                    const SizedBox(height: 8),
                    Text(
                      'Found ${slowQueries.length} slow queries',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: slowQueries.isNotEmpty
                            ? AppColorMapper.errorColor(context)
                            : AppColorMapper.successColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Detected Slow Queries:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: slowQueries.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColorMapper.successColor(
                            context,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TraqIcon(
                              AppAssets.iconCheck,
                              size: 48,
                              color: AppColorMapper.successColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Excellent! No slow queries detected.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColorMapper.successColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your database is performing well.',
                              style: TextStyle(
                                color: AppColorMapper.successColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: slowQueries.length,
                        itemBuilder: (context, index) {
                          final query = slowQueries[index];
                          final String sql = query['sql'] ?? 'Unknown query';
                          final double executionTime =
                              (query['executionTime'] ?? 0.0).toDouble();
                          final String tableName =
                              query['tableName'] ?? 'Unknown';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColorMapper.errorColor(
                                  context,
                                ).withValues(alpha: 0.15),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppColorMapper.errorColor(context),
                                  ),
                                ),
                              ),
                              title: Text(
                                'Query #${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Table: $tableName'),
                                  Text(
                                    'Execution Time: ${executionTime.toStringAsFixed(2)}ms',
                                    style: TextStyle(
                                      color: executionTime > 1000
                                          ? AppColorMapper.errorColor(context)
                                          : AppColorMapper.warningColor(
                                              context,
                                            ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SQL Query:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          sql,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (query['recommendation'] != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColorMapper.infoColor(
                                              context,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: AppColorMapper.infoColor(
                                                context,
                                              ).withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TraqIcon(
                                                    AppAssets.iconLightbulb,
                                                    color:
                                                        AppColorMapper.infoColor(
                                                          context,
                                                        ),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    'Recommendation:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(query['recommendation']),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
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

  void showMemoryOptimizationDialog(Map<String, dynamic> data) {
    final String status = data['status'] ?? 'Unknown';
    final List<dynamic> optimizations = data['optimizations'] ?? [];
    final Map<String, dynamic> memoryStats = data['memoryStats'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(
              AppAssets.iconRefresh,
              color: AppColorMapper.successColor(context),
            ),
            const SizedBox(width: 8),
            const Text('Memory Optimization Results'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: status == 'optimized'
                        ? AppColorMapper.successColor(
                            context,
                          ).withValues(alpha: 0.1)
                        : AppColorMapper.warningColor(
                            context,
                          ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status == 'optimized'
                          ? AppColorMapper.successColor(
                              context,
                            ).withValues(alpha: 0.3)
                          : AppColorMapper.warningColor(
                              context,
                            ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      TraqIcon(
                        status == 'optimized'
                            ? AppAssets.iconCheckCircle
                            : AppAssets.iconSettings,
                        color: status == 'optimized'
                            ? AppColorMapper.successColor(context)
                            : AppColorMapper.warningColor(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status == 'optimized'
                                  ? 'Optimization Complete'
                                  : 'Optimization in Progress',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status == 'optimized'
                                  ? 'Memory usage has been successfully optimized'
                                  : 'Running memory optimization processes...',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (memoryStats.isNotEmpty) ...[
                  const Text(
                    'Memory Statistics:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColorMapper.infoColor(
                        context,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        PerfOptStatRow(
                          'Used Memory',
                          memoryStats['usedMemory'] ?? 'N/A',
                        ),
                        PerfOptStatRow(
                          'Free Memory',
                          memoryStats['freeMemory'] ?? 'N/A',
                        ),
                        PerfOptStatRow(
                          'Total Memory',
                          memoryStats['totalMemory'] ?? 'N/A',
                        ),
                        PerfOptStatRow(
                          'Memory Usage',
                          memoryStats['memoryUsagePercent'] ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text(
                  'Optimizations Applied:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                if (optimizations.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'No specific optimizations were applied.',
                    ),
                  )
                else
                  ...optimizations.map<Widget>((opt) {
                    return Card(
                      child: ListTile(
                        leading: TraqIcon(
                          AppAssets.iconCheck,
                          color: AppColorMapper.successColor(context),
                        ),
                        title: Text(opt['action'] ?? 'Unknown action'),
                        subtitle: opt['description'] != null
                            ? Text(opt['description'])
                            : null,
                        trailing: opt['improvement'] != null
                            ? Chip(
                                label: Text(opt['improvement']),
                                backgroundColor: AppColorMapper.successColor(
                                  context,
                                ).withValues(alpha: 0.15),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
              ],
            ),
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
