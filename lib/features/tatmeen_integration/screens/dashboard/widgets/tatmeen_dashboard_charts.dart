import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_chart.dart';

class TatmeenDashboardCharts extends StatelessWidget {
  const TatmeenDashboardCharts({
    super.key,
    required this.chartData,
    required this.breakdown,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final List<TatmeenChartPoint> chartData;
  final TatmeenStatusBreakdown? breakdown;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            children: [
              SizedBox(
                height: 320,
                child: TraqCard(
                  child: TatmeenSyncChart(
                    data: chartData,
                    isLoading: isLoading,
                    error: error,
                    onRetry: onRetry,
                  ),
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              SizedBox(
                height: 320,
                child: TraqCard(
                  child: TatmeenStatusBreakdownChart(
                    breakdown: breakdown,
                    isLoading: isLoading,
                    error: error,
                    onRetry: onRetry,
                  ),
                ),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 320,
                child: TraqCard(
                  child: TatmeenSyncChart(
                    data: chartData,
                    isLoading: isLoading,
                    error: error,
                    onRetry: onRetry,
                  ),
                ),
              ),
            ),
            const SizedBox(width: TraqSpacing.md),
            Expanded(
              child: SizedBox(
                height: 320,
                child: TraqCard(
                  child: TatmeenStatusBreakdownChart(
                    breakdown: breakdown,
                    isLoading: isLoading,
                    error: error,
                    onRetry: onRetry,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
