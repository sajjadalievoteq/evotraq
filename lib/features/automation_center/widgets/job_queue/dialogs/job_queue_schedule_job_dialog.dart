import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JobQueueScheduleSubmitRequest {
  const JobQueueScheduleSubmitRequest({
    required this.jobName,
    required this.jobType,
    required this.description,
    required this.priorityLabel,
    required this.parameters,
  });

  final String jobName;
  final String jobType;
  final String description;
  final String priorityLabel;
  final List<Map<String, String>> parameters;
}

class JobQueueScheduleJobDialog extends StatefulWidget {
  const JobQueueScheduleJobDialog({super.key});

  @override
  State<JobQueueScheduleJobDialog> createState() =>
      _JobQueueScheduleJobDialogState();
}

class _JobQueueScheduleJobDialogState extends State<JobQueueScheduleJobDialog> {
  // TODO(scheduling): real deferred/cron execution requires a backend
  // scheduled-submit endpoint + quartz/scheduler; out of scope here.
  var _selectedJobType = 'NOTIFICATION_BATCH';
  var _selectedPriority = 'MEDIUM';
  var _jobName = '';
  var _description = '';
  final _parameters = <Map<String, String>>[];

  void _submit() {
    if (_jobName.trim().isEmpty) {
      context.showError('Job name is required');
      return;
    }
    Navigator.of(context).pop(
      JobQueueScheduleSubmitRequest(
        jobName: _jobName.trim(),
        jobType: _selectedJobType,
        description: _description.trim(),
        priorityLabel: _selectedPriority,
        parameters: List<Map<String, String>>.from(_parameters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(
            AppAssets.iconClock,
            color: AppColorMapper.successColor(context),
          ),
          const SizedBox(width: TraqSpacing.sm),
          const Text('Submit Job'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submits a job to the queue immediately '
                '(POST /jobs/submit).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textMuted,
                    ),
              ),
              const SizedBox(height: TraqSpacing.lg),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Job Name *',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _jobName = value,
              ),
              const SizedBox(height: TraqSpacing.md),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Job Type *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedJobType,
                items: const [
                  DropdownMenuItem(
                    value: 'NOTIFICATION_BATCH',
                    child: Text('NOTIFICATION_BATCH'),
                  ),
                ],
                onChanged: (value) => setState(
                  () => _selectedJobType = value!,
                ),
              ),
              const SizedBox(height: TraqSpacing.sm),
              Text(
                'Runs processScheduledBatchNotifications — delivers '
                'due BATCH/SCHEDULED notification batches.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textMuted,
                    ),
              ),
              const SizedBox(height: TraqSpacing.md),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: TraqSpacing.md),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPriority,
                items: const [
                  DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                  DropdownMenuItem(
                    value: 'MEDIUM',
                    child: Text('MEDIUM'),
                  ),
                  DropdownMenuItem(value: 'LOW', child: Text('LOW')),
                ],
                onChanged: (value) => setState(
                  () => _selectedPriority = value!,
                ),
              ),
              const SizedBox(height: TraqSpacing.xl),
              Text(
                'Additional parameters (optional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: TraqSpacing.sm),
              ..._parameters.asMap().entries.map((entry) {
                final index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Key',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              _parameters[index]['key'] = value,
                        ),
                      ),
                      const SizedBox(width: TraqSpacing.sm),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              _parameters[index]['value'] = value,
                        ),
                      ),
                      IconButton(
                        icon: TraqIcon(
                          AppAssets.iconRemoveCircle,
                          color: AppColorMapper.errorColor(context),
                        ),
                        onPressed: () => setState(
                          () => _parameters.removeAt(index),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              OutlinedButton.icon(
                onPressed: () => setState(
                  () => _parameters.add({'key': '', 'value': ''}),
                ),
                icon: TraqIcon(AppAssets.iconPlus),
                label: const Text('Add Parameter'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Submit Job'),
        ),
      ],
    );
  }
}
