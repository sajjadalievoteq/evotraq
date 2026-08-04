import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_integrity_job_card.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class ConsistencyIntegrityTab extends StatelessWidget {
  const ConsistencyIntegrityTab({
    super.key,
    required this.jobsState,
    required this.onRefreshJobs,
    required this.onStartIntegrityJob,
    required this.onViewViolations,
  });

  final LoadState<List<dynamic>> jobsState;
  final VoidCallback onRefreshJobs;
  final VoidCallback onStartIntegrityJob;
  final void Function(String jobId, Map<String, dynamic> results)
      onViewViolations;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(
                        AppAssets.iconLock,
                        color: AppColorMapper.chartColor(context, 5),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Integrity Monitoring',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: onStartIntegrityJob,
                        icon: TraqIcon(AppAssets.iconArrowR),
                        label: const Text('Run Integrity Check'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LoadStateView<List<dynamic>>(
                    state: jobsState,
                    onRetry: onRefreshJobs,
                    emptyWidget: const Text(
                      'No integrity monitoring jobs have been run yet.',
                    ),
                    builder: (context, jobs) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Integrity Jobs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...jobs.map((job) {
                          final map = Map<String, dynamic>.from(job as Map);
                          return ConsistencyIntegrityJobCard(
                            job: map,
                            onViewViolations: onViewViolations,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
