import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/cards/job_queue_history_job_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/filters/job_queue_job_type_filter.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_job_type_chart.dart';

class JobQueueHistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> jobHistory;
  final bool fill;
  final String selectedJobType;
  final List<String> jobTypes;
  final ValueChanged<String> onJobTypeChanged;
  final ValueChanged<Map<String, dynamic>> onShowDetails;
  final ValueChanged<String> onRetry;
  final Map<String, int> jobTypeDistribution;

  const JobQueueHistoryTab({
    super.key,
    required this.jobHistory,
    required this.fill,
    required this.selectedJobType,
    required this.jobTypes,
    required this.onJobTypeChanged,
    required this.onShowDetails,
    required this.onRetry,
    required this.jobTypeDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final header = Row(
      children: [
        Text(
          'Job History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        const Spacer(),
        JobQueueJobTypeFilter(
          selectedJobType: selectedJobType,
          jobTypes: jobTypes,
          onChanged: onJobTypeChanged,
        ),
      ],
    );

    final list = jobHistory.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.xl),
            child: Center(
              child: Text(
                'No job history',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: c.textMuted),
              ),
            ),
          )
        : Column(
            children: [
              JobQueueJobTypeChart(distribution: jobTypeDistribution),
              const SizedBox(height: TraqSpacing.lg),
              for (final job in jobHistory)
                JobQueueHistoryJobCard(
                  job: job,
                  onShowDetails: onShowDetails,
                  onRetry: onRetry,
                ),
            ],
          );

    if (!fill) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: TraqSpacing.lg),
          list,
        ],
      );
    }

    return Padding(
      padding: TraqSpacing.surfacePad,
      child: Column(
        children: [
          header,
          const SizedBox(height: TraqSpacing.lg),
          JobQueueJobTypeChart(distribution: jobTypeDistribution),
          const SizedBox(height: TraqSpacing.lg),
          Expanded(
            child: jobHistory.isEmpty
                ? Center(
                    child: Text(
                      'No job history',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: c.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: jobHistory.length,
                    itemBuilder: (context, index) {
                      return JobQueueHistoryJobCard(
                        job: jobHistory[index],
                        onShowDetails: onShowDetails,
                        onRetry: onRetry,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
