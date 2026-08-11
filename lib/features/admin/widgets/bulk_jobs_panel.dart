import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_summary.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_empty_state.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_job_detail_row.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_filter_dropdown.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_list.dart';

class BulkJobsPanel extends StatefulWidget {
  final List<BulkJobStatus> jobs;
  final Function(String) onJobCancel;
  final Function(String) onJobRetry;
  final Function() onRefresh;

  const BulkJobsPanel({
    super.key,
    required this.jobs,
    required this.onJobCancel,
    required this.onJobRetry,
    required this.onRefresh,
  });

  @override
  State<BulkJobsPanel> createState() => _BulkJobsPanelState();
}

class _BulkJobsPanelState extends State<BulkJobsPanel> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _getFilteredJobs();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(AppAssets.iconList, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Bulk Processing Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                BulkJobsFilterDropdown(
                  selectedFilter: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onRefresh,
                  icon: TraqIcon(AppAssets.iconRefresh),
                  tooltip: 'Refresh Jobs',
                ),
              ],
            ),
            const SizedBox(height: 16),
            BulkJobsSummary(filteredJobs),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: filteredJobs.isEmpty
                  ? const BulkJobsEmptyState()
                  : BulkJobsList(
                      jobs: filteredJobs,
                      onCancel: widget.onJobCancel,
                      onRetry: widget.onJobRetry,
                      onShowDetails: _showJobDetails,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<BulkJobStatus> _getFilteredJobs() {
    if (_selectedFilter == 'ALL') {
      return widget.jobs;
    }
    return widget.jobs.where((job) => job.status == _selectedFilter).toList();
  }

  void _showJobDetails(BulkJobStatus job) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  Text(
                    'Job Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: TraqIcon(AppAssets.iconX),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              BulkJobDetailRow('Job ID', job.jobId),
              BulkJobDetailRow('Type', job.jobType),
              BulkJobDetailRow('Status', job.status),
              BulkJobDetailRow(
                'Progress',
                '${job.progressPercentage.toStringAsFixed(1)}%',
              ),
              BulkJobDetailRow(
                'Records Processed',
                '${job.processedEvents}/${job.totalEvents}',
              ),
              BulkJobDetailRow('Started', DisplayDateUtils.dmHm(job.startTime)),
              if (job.endTime != null)
                BulkJobDetailRow(
                  'Completed',
                  DisplayDateUtils.dmHm(job.endTime!),
                ),
              if (job.errors.isNotEmpty)
                BulkJobDetailRow('Errors', job.errors.join(', ')),
              if (job.metadata.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...job.metadata.entries
                    .map(
                      (entry) =>
                          BulkJobDetailRow(entry.key, entry.value.toString()),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
