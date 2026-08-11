part of 'performance_optimization_dashboard_screen.dart';

extension ConnectionDialogActions on _PerformanceOptimizationDashboardState {
  void _showConnectionLeaksDialog(Map<String, dynamic> data) {
    final List<dynamic> leaks = data['leaks'] ?? [];
    final Map<String, dynamic> summary = data['summary'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            TraqIcon(
              AppAssets.iconHub,
              color: AppColorMapper.warningColor(context),
            ),
            const SizedBox(width: 8),
            const Text('Connection Leak Detection'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: leaks.isEmpty
                      ? AppColorMapper.successColor(
                          context,
                        ).withValues(alpha: 0.1)
                      : AppColorMapper.errorColor(
                          context,
                        ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: leaks.isEmpty
                        ? AppColorMapper.successColor(
                            context,
                          ).withValues(alpha: 0.3)
                        : AppColorMapper.errorColor(
                            context,
                          ).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    TraqIcon(
                      leaks.isEmpty
                          ? AppAssets.iconCheckCircle
                          : AppAssets.iconAlert,
                      color: leaks.isEmpty
                          ? AppColorMapper.successColor(context)
                          : AppColorMapper.errorColor(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leaks.isEmpty
                                ? 'No Leaks Detected'
                                : '${leaks.length} Connection Leaks Found',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            leaks.isEmpty
                                ? 'All connections are properly managed'
                                : 'Immediate attention required to prevent resource exhaustion',
                            style: TextStyle(
                              color: leaks.isEmpty
                                  ? AppColorMapper.successColor(context)
                                  : AppColorMapper.errorColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (summary.isNotEmpty) ...[
                const Text(
                  'Connection Summary:',
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
                        'Total Connections',
                        summary['totalConnections'] ?? 'N/A',
                      ),
                      PerfOptStatRow(
                        'Active Connections',
                        summary['activeConnections'] ?? 'N/A',
                      ),
                      PerfOptStatRow(
                        'Idle Connections',
                        summary['idleConnections'] ?? 'N/A',
                      ),
                      PerfOptStatRow(
                        'Leak Detection Time',
                        summary['scanTime'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'Connection Leaks:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: leaks.isEmpty
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
                              'Excellent! No connection leaks detected.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColorMapper.successColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your application is managing connections properly.',
                              style: TextStyle(
                                color: AppColorMapper.successColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: leaks.length,
                        itemBuilder: (context, index) {
                          final leak = leaks[index];
                          final String connectionId =
                              leak['connectionId'] ?? 'Unknown';
                          final String threadName =
                              leak['threadName'] ?? 'Unknown Thread';
                          final String leakDuration =
                              leak['leakDuration']?.toString() ?? 'Unknown';
                          final String stackTrace =
                              leak['stackTrace'] ?? 'No stack trace available';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColorMapper.errorColor(
                                  context,
                                ).withValues(alpha: 0.15),
                                child: TraqIcon(
                                  AppAssets.iconAlert,
                                  color: AppColorMapper.errorColor(context),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Connection Leak #${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Connection ID: $connectionId'),
                                  Text('Thread: $threadName'),
                                  Text(
                                    'Duration: $leakDuration',
                                    style: TextStyle(
                                      color: AppColorMapper.errorColor(context),
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
                                        'Stack Trace:',
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
                                          stackTrace,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColorMapper.warningColor(
                                            context,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: AppColorMapper.warningColor(
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
                                                      AppColorMapper.warningColor(
                                                        context,
                                                      ),
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Recommended Action:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Close this connection immediately and review the code that created it. '
                                              'Ensure all database connections are properly closed in finally blocks or use try-with-resources.',
                                            ),
                                          ],
                                        ),
                                      ),
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
          if (leaks.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.showWarning('Automatic leak cleanup initiated...');
              },
              icon: TraqIcon(AppAssets.iconSparkle),
              label: const Text('Auto Fix'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
