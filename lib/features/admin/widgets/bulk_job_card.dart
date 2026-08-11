import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_summary.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_empty_state.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_job_detail_row.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_job_status_chip.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class BulkJobCard extends StatelessWidget {
  const BulkJobCard({
    required this.job,
    required this.onCancel,
    required this.onRetry,
    required this.onShowDetails,
  });

  final BulkJobStatus job;
  final Function(String) onCancel;
  final Function(String) onRetry;
  final ValueChanged<BulkJobStatus> onShowDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  StatusVisualMappers.bulkJobStatusIcon(job.status),
                  color: StatusVisualMappers.bulkJobStatusColor(
                    context,
                    job.status,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Job ID: ${job.jobId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                BulkJobStatusChip(job.status),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: job.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                StatusVisualMappers.bulkJobStatusColor(context, job.status),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${job.progressPercentage.toStringAsFixed(1)}% completed',
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${job.processedEvents}/${job.totalEvents} records',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconClock,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Started: ${DisplayDateUtils.dmHm(job.startTime)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (job.endTime != null) ...[
                  TraqIcon(
                    AppAssets.iconClock,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${DisplayDateUtils.dmHm(job.endTime!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (job.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorMapper.errorColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColorMapper.errorColor(context).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    TraqIcon(
                      AppAssets.iconAlert,
                      color: AppColorMapper.errorColor(context),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.errors.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColorMapper.errorColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (job.status == 'RUNNING')
                  TextButton.icon(
                    onPressed: () => onCancel(job.jobId),
                    icon: TraqIcon(AppAssets.iconX, size: 16),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColorMapper.errorColor(context),
                    ),
                  ),
                if (job.status == 'FAILED')
                  TextButton.icon(
                    onPressed: () => onRetry(job.jobId),
                    icon: TraqIcon(AppAssets.iconRefresh, size: 16),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColorMapper.infoColor(context),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => onShowDetails(job),
                  icon: TraqIcon(AppAssets.iconInfo, size: 16),
                  label: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
