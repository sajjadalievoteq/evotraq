import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_stat_row.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class PerfOptResourceManagementTab extends StatelessWidget {
  const PerfOptResourceManagementTab({
    super.key,
    required this.reportState,
    required this.onRetry,
    required this.onOptimizeMemory,
    required this.onOptimizeCpu,
    required this.onOptimizeIo,
  });

  final LoadState<Map<String, dynamic>> reportState;
  final VoidCallback onRetry;
  final VoidCallback onOptimizeMemory;
  final VoidCallback onOptimizeCpu;
  final VoidCallback onOptimizeIo;

  @override
  Widget build(BuildContext context) {
    return LoadStateView<Map<String, dynamic>>(
      state: reportState,
      onRetry: onRetry,
      builder: (context, report) {
        final resourceUsage = report['resourceUsage'] as Map<String, dynamic>?;
        final memoryUsage = resourceUsage?['memory'];
        final cpuUsage = resourceUsage?['cpu'];

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
                        'System Resources',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (memoryUsage != null) ...[
                        const Text(
                          'Memory Usage:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        PerfOptStatRow(
                          'Used Memory',
                          '${(memoryUsage['usedMemory'] ?? 0) ~/ 1024 ~/ 1024} MB',
                        ),
                        PerfOptStatRow(
                          'Free Memory',
                          '${(memoryUsage['freeMemory'] ?? 0) ~/ 1024 ~/ 1024} MB',
                        ),
                        PerfOptStatRow(
                          'Max Memory',
                          '${(memoryUsage['maxMemory'] ?? 0) ~/ 1024 ~/ 1024} MB',
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (cpuUsage != null) ...[
                        const Text(
                          'CPU Information:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        PerfOptStatRow(
                          'Available Processors',
                          '${cpuUsage['availableProcessors'] ?? 0}',
                        ),
                        PerfOptStatRow(
                          'System CPU Load',
                          '${((cpuUsage['systemCpuLoad'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: onOptimizeMemory,
                            child: const Text('Optimize Memory'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: onOptimizeCpu,
                            child: const Text('Balance CPU'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: onOptimizeIo,
                            child: const Text('Optimize I/O'),
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
