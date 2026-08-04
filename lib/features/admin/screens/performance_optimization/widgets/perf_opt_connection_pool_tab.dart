import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_stat_row.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class PerfOptConnectionPoolTab extends StatelessWidget {
  const PerfOptConnectionPoolTab({
    super.key,
    required this.reportState,
    required this.onRetry,
    required this.onOptimizePool,
    required this.onDetectLeaks,
  });

  final LoadState<Map<String, dynamic>> reportState;
  final VoidCallback onRetry;
  final VoidCallback onOptimizePool;
  final VoidCallback onDetectLeaks;

  @override
  Widget build(BuildContext context) {
    return LoadStateView<Map<String, dynamic>>(
      state: reportState,
      onRetry: onRetry,
      builder: (context, report) {
        final connectionPoolStatus =
            report['connectionPoolPerformance'] as Map<String, dynamic>?;
        final currentStats = connectionPoolStatus?['currentStatistics'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connection Pool Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (currentStats != null) ...[
                        PerfOptStatRow(
                          'Active Connections',
                          '${currentStats['activeConnections'] ?? 0}',
                        ),
                        PerfOptStatRow(
                          'Idle Connections',
                          '${currentStats['idleConnections'] ?? 0}',
                        ),
                        PerfOptStatRow(
                          'Total Connections',
                          '${currentStats['totalConnections'] ?? 0}',
                        ),
                        PerfOptStatRow(
                          'Max Pool Size',
                          '${currentStats['maxPoolSize'] ?? 0}',
                        ),
                        PerfOptStatRow(
                          'Connection Timeout',
                          '${currentStats['connectionTimeout'] ?? 0}ms',
                        ),
                        PerfOptStatRow(
                          'Avg Connection Time',
                          '${currentStats['avgConnectionTime'] ?? 0}ms',
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: onOptimizePool,
                            child: const Text('Optimize Pool'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: onDetectLeaks,
                            child: const Text('Detect Leaks'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
