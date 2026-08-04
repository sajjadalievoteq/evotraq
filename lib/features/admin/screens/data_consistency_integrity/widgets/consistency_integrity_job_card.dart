import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_job_status_icon.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_result_metric.dart';

class ConsistencyIntegrityJobCard extends StatelessWidget {
  const ConsistencyIntegrityJobCard({
    super.key,
    required this.job,
    required this.onViewViolations,
  });

  final Map<String, dynamic> job;
  final void Function(String jobId, Map<String, dynamic> results)
      onViewViolations;

  @override
  Widget build(BuildContext context) {
    final jobId = job['job_id'] ?? 'UNKNOWN';
    final status = job['status'] ?? 'UNKNOWN';
    final progress = (job['progress'] ?? 0.0).toDouble();
    final results = job['results'] as Map<String, dynamic>?;
    final isCompleted = status.toUpperCase() == 'COMPLETED';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircularProgressIndicator(
          value: progress / 100.0,
          backgroundColor: Colors.grey[300],
        ),
        title: Text(jobId),
        subtitle: Text('Status: $status (${progress.toStringAsFixed(0)}%)'),
        trailing: ConsistencyJobStatusIcon(status),
        children: [
          if (isCompleted && results != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Integrity Check Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ConsistencyResultMetric(
                          'Events Checked',
                          '${results['events_checked'] ?? 0}',
                          AppAssets.iconCalendar,
                          AppColorMapper.infoColor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ConsistencyResultMetric(
                          'Violations Found',
                          '${results['integrity_violations'] ?? 0}',
                          AppAssets.iconAlert,
                          AppColorMapper.warningColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConsistencyResultMetric(
                    'Overall Integrity Score',
                    '${results['overall_integrity_score'] ?? 0}%',
                    AppAssets.iconGrade,
                    AppColorMapper.successColor(context),
                  ),
                  const SizedBox(height: 12),
                  if (results['integrity_violations'] != null &&
                      results['integrity_violations'] > 0)
                    ElevatedButton.icon(
                      onPressed: () => onViewViolations(jobId, results),
                      icon: TraqIcon(AppAssets.iconList),
                      label: const Text('View Violation Details'),
                    ),
                ],
              ),
            ),
          ] else if (status.toUpperCase() == 'RUNNING') ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Current Phase: ${job['phase'] ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100.0,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ] else if (status.toUpperCase() == 'FAILED') ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${job['error'] ?? 'Unknown error occurred'}',
                style: TextStyle(color: AppColorMapper.errorColor(context)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
