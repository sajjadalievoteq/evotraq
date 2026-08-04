import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_quick_actions_card.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_recommendations_card.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_score_card.dart';
import 'package:traqtrace_app/features/admin/screens/performance_optimization/widgets/perf_opt_system_health_cards.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class PerfOptOverviewTab extends StatelessWidget {
  const PerfOptOverviewTab({
    super.key,
    required this.reportState,
    required this.onRetry,
    required this.onRunBenchmark,
    required this.onDetectSlowQueries,
    required this.onOptimizeMemory,
    required this.onDetectLeaks,
  });

  final LoadState<Map<String, dynamic>> reportState;
  final VoidCallback onRetry;
  final VoidCallback onRunBenchmark;
  final VoidCallback onDetectSlowQueries;
  final VoidCallback onOptimizeMemory;
  final VoidCallback onDetectLeaks;

  @override
  Widget build(BuildContext context) {
    return LoadStateView<Map<String, dynamic>>(
      state: reportState,
      onRetry: onRetry,
      builder: (context, report) {
        final overallScore = report['overallPerformanceScore'] ?? 0.0;
        final recommendations = report['topRecommendations'] as List? ?? [];
        final resourceUsage = report['resourceUsage'] as Map<String, dynamic>?;
        final connectionPoolStatus =
            report['connectionPoolPerformance'] as Map<String, dynamic>?;
        final threadPoolStatus =
            report['threadPoolPerformance'] as Map<String, dynamic>?;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PerfOptScoreCard(
                overallScore is double
                    ? overallScore
                    : (overallScore as num).toDouble(),
              ),
              const SizedBox(height: 16),
              PerfOptSystemHealthCards(
                resourceUsage,
                connectionPoolStatus,
                threadPoolStatus,
              ),
              const SizedBox(height: 16),
              PerfOptRecommendationsCard(recommendations),
              const SizedBox(height: 16),
              PerfOptQuickActionsCard(
                onRunBenchmark: onRunBenchmark,
                onDetectSlowQueries: onDetectSlowQueries,
                onOptimizeMemory: onOptimizeMemory,
                onDetectLeaks: onDetectLeaks,
              ),
            ],
          ),
        );
      },
    );
  }
}
