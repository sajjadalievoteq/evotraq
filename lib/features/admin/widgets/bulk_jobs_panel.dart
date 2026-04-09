import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

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
                const Icon(Icons.work, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Bulk Processing Jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildFilterDropdown(),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Jobs',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildJobsSummary(filteredJobs),
            const SizedBox(height: 16),
            SizedBox(
              height: 400, // Fixed height instead of Expanded
              child: filteredJobs.isEmpty
                  ? _buildEmptyState()
                  : _buildJobsList(filteredJobs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
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

  Widget _buildJobsSummary(List<BulkJobStatus> jobs) {
    final running = jobs.where((j) => j.status == 'RUNNING').length;
    final completed = jobs.where((j) => j.status == 'COMPLETED').length;
    final failed = jobs.where((j) => j.status == 'FAILED').length;
    final pending = jobs.where((j) => j.status == 'PENDING').length;

    return Row(
      children: [
        _buildSummaryCard('Running', running, Colors.blue),
        const SizedBox(width: 8),
        _buildSummaryCard('Completed', completed, Colors.green),
        const SizedBox(width: 8),
        _buildSummaryCard('Failed', failed, Colors.red),
        const SizedBox(width: 8),
        _buildSummaryCard('Pending', pending, Colors.orange),
      ],
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No bulk jobs found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bulk processing jobs will appear here when started',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(List<BulkJobStatus> jobs) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(BulkJobStatus job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(job.status),
                  color: _getStatusColor(job.status),
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
                _buildStatusChip(job.status),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: job.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(job.status),
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
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Started: ${_formatDateTime(job.startTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (job.endTime != null) ...[
                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${_formatDateTime(job.endTime!)}',
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.errors.first,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
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
                    onPressed: () => widget.onJobCancel(job.jobId),
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                if (job.status == 'FAILED')
                  TextButton.icon(
                    onPressed: () => widget.onJobRetry(job.jobId),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _showJobDetails(job),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return Icons.play_circle_filled;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'FAILED':
        return Icons.error;
      case 'PENDING':
        return Icons.schedule;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  List<BulkJobStatus> _getFilteredJobs() {
    if (_selectedFilter == 'ALL') {
      return widget.jobs;
    }
    return widget.jobs.where((job) => job.status == _selectedFilter).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
                  Icon(
                    _getStatusIcon(job.status),
                    color: _getStatusColor(job.status),
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
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Job ID', job.jobId),
              _buildDetailRow('Type', job.jobType),
              _buildDetailRow('Status', job.status),
              _buildDetailRow('Progress', '${job.progressPercentage.toStringAsFixed(1)}%'),
              _buildDetailRow('Records Processed', '${job.processedEvents}/${job.totalEvents}'),
              _buildDetailRow('Started', _formatDateTime(job.startTime)),
              if (job.endTime != null)
                _buildDetailRow('Completed', _formatDateTime(job.endTime!)),
              if (job.errors.isNotEmpty)
                _buildDetailRow('Errors', job.errors.join(', ')),
              if (job.metadata.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...job.metadata.entries.map(
                  (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                ).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
