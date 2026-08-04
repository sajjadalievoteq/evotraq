import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_health_card.dart';

class PerfOptSystemHealthCards extends StatelessWidget {
  const PerfOptSystemHealthCards(
    this.resourceUsage,
    this.connectionPoolStatus,
    this.threadPoolStatus, {
    super.key,
  });

  final Map<String, dynamic>? resourceUsage;
  final Map<String, dynamic>? connectionPoolStatus;
  final Map<String, dynamic>? threadPoolStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PerfOptHealthCard(
            'Memory Usage',
            resourceUsage?['memory']?['usagePercentage'] ?? 'N/A',
            NavIcons.eventSerialization,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PerfOptHealthCard(
            'CPU Usage',
            '${((resourceUsage?['cpu']?['systemCpuLoad'] ?? 0.0) * 100).toStringAsFixed(1)}%',
            AppAssets.iconComputer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PerfOptHealthCard(
            'Connections',
            '${connectionPoolStatus?['activeConnections'] ?? 0}/${connectionPoolStatus?['totalConnections'] ?? 0}',
            AppAssets.iconHub,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PerfOptHealthCard(
            'Threads',
            '${threadPoolStatus?['systemMetrics']?['activeThreadCount'] ?? 0}',
            AppAssets.iconSettings,
          ),
        ),
      ],
    );
  }
}
