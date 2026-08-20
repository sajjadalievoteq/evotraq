import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

class TatmeenStatusBreakdownPie extends StatelessWidget {
  const TatmeenStatusBreakdownPie({super.key, required this.breakdown});

  final TatmeenStatusBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 2,
              sections:
                  [
                        (breakdown.successful, context.colors.success),
                        (breakdown.failed, context.colors.error),
                        (breakdown.pending, context.colors.warning),
                      ]
                      .map(
                        (section) => PieChartSectionData(
                          value: section.$1.toDouble(),
                          color: section.$2,
                          radius: 26,
                          showTitle: false,
                        ),
                      )
                      .toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${breakdown.total}',
                style: context.text.h2.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'This month',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
