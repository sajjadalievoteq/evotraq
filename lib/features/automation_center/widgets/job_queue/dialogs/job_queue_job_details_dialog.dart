import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class JobQueueJobDetailsDialog extends StatelessWidget {
  const JobQueueJobDetailsDialog({super.key, required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Job Details: ${job['jobId']}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Job Type: ${job['jobType']}'),
            Text('Status: ${job['status']}'),
            Text('Priority: ${job['priority']}'),
            if (job['submittedTime'] != null)
              Text('Submitted: ${job['submittedTime']}'),
            if (job['startTime'] != null) Text('Started: ${job['startTime']}'),
            if (job['endTime'] != null) Text('Completed: ${job['endTime']}'),
            if (job['executionTime'] != null)
              Text('Duration: ${job['executionTime']}'),
            if (job['progress'] != null) Text('Progress: ${job['progress']}%'),
            if (job['errorMessage'] != null) ...[
              const SizedBox(height: 8),
              const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                job['errorMessage'],
                style: TextStyle(color: AppColorMapper.errorColor(context)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
