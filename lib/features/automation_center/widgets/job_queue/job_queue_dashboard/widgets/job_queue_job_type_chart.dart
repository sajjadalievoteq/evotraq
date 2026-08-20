import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_dashboard_section.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_empty_panel.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class JobQueueJobTypeChart extends StatelessWidget {
  const JobQueueJobTypeChart({super.key, required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.where((e) => e.value > 0).toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return JobQueueDashboardSection(
      title: 'Job types',
      child: total <= 0
          ? const JobQueueEmptyPanel(
              title: 'No active or queued jobs',
              subtitle: 'Type mix appears when the queue has work.',
              iconAsset: AppAssets.iconWork,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 320;
                final chart = SizedBox(
                  height: 160,
                  width: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 42,
                          sections: [
                            for (var i = 0; i < entries.length; i++)
                              PieChartSectionData(
                                value: entries[i].value.toDouble(),
                                color: StatusVisualMappers.jobTypeColor(
                                  context,
                                  entries[i].key,
                                ),
                                radius: 28,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: context.colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                final legend = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: StatusVisualMappers.jobTypeColor(
                                  context,
                                  e.key,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: TraqSpacing.sm),
                            Expanded(
                              child: Text(
                                e.key,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                );

                if (compact) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: TraqSpacing.lg),
                      legend,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chart,
                    const SizedBox(width: TraqSpacing.lg),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
    );
  }
}
