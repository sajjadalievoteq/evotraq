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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _BulkJobsFilterDropdown(
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
                  : _BulkJobsList(
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
                    color: StatusVisualMappers.bulkJobStatusColor(context, job.status),
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
              BulkJobDetailRow('Progress', '${job.progressPercentage.toStringAsFixed(1)}%'),
              BulkJobDetailRow('Records Processed', '${job.processedEvents}/${job.totalEvents}'),
              BulkJobDetailRow('Started', DisplayDateUtils.dmHm(job.startTime)),
              if (job.endTime != null)
                BulkJobDetailRow('Completed', DisplayDateUtils.dmHm(job.endTime!)),
              if (job.errors.isNotEmpty)
                BulkJobDetailRow('Errors', job.errors.join(', ')),
              if (job.metadata.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...job.metadata.entries.map(
                  (entry) => BulkJobDetailRow(entry.key, entry.value.toString()),
                ).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

class _BulkJobsFilterDropdown extends StatelessWidget {
  const _BulkJobsFilterDropdown({
    required this.selectedFilter,
    required this.onChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      items: const [
        DropdownMenuItem(value: 'ALL', child: Text('All Jobs')),
        DropdownMenuItem(value: 'RUNNING', child: Text('Running')),
        DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
        DropdownMenuItem(value: 'FAILED', child: Text('Failed')),
        DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
      ],
    );
  }
}

class _BulkJobsList extends StatelessWidget {
  const _BulkJobsList({
    required this.jobs,
    required this.onCancel,
    required this.onRetry,
    required this.onShowDetails,
  });

  final List<BulkJobStatus> jobs;
  final Function(String) onCancel;
  final Function(String) onRetry;
  final ValueChanged<BulkJobStatus> onShowDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _BulkJobCard(
          job: job,
          onCancel: onCancel,
          onRetry: onRetry,
          onShowDetails: onShowDetails,
        );
      },
    );
  }
}

class _BulkJobCard extends StatelessWidget {
  const _BulkJobCard({
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
                  color: StatusVisualMappers.bulkJobStatusColor(context, job.status),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
                TraqIcon(AppAssets.iconClock, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Started: ${DisplayDateUtils.dmHm(job.startTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (job.endTime != null) ...[
                  TraqIcon(AppAssets.iconClock, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${DisplayDateUtils.dmHm(job.endTime!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
                  border: Border.all(color: AppColorMapper.errorColor(context).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    TraqIcon(AppAssets.iconAlert, color: AppColorMapper.errorColor(context), size: 16),
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
