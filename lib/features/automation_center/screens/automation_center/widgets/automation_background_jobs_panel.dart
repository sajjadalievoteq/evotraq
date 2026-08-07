import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';

class AutomationBackgroundJobsPanel extends StatefulWidget {
  const AutomationBackgroundJobsPanel({super.key});

  @override
  State<AutomationBackgroundJobsPanel> createState() =>
      _AutomationBackgroundJobsPanelState();
}

class _AutomationBackgroundJobsPanelState
    extends State<AutomationBackgroundJobsPanel> {
  final _panelKey = GlobalKey<JobQueuePanelState>();

  static const _instructions = WorkbenchInstructions(
    summary:
        'Monitor background jobs, cancel or retry failed work, and schedule '
        'supported queue tasks.',
    useCase:
        'Use for operational visibility into the job queue. Supported submit '
        'type: notification batch processing.',
    audience: 'Admins',
    steps: [
      'Review dashboard counts, then drill into Active, Queued, or History.',
      'Cancel running/queued jobs or retry failed ones from the row actions.',
      'Schedule a NOTIFICATION_BATCH job to process due alert batches on demand.',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AutomationWorkbenchPanel(
      title: 'Background Jobs',
      instructions: _instructions,
      actions: [
        OutlinedButton.icon(
          onPressed: () => _panelKey.currentState?.showControlPanel(),
          icon: TraqIcon(AppAssets.iconTune, size: 14),
          label: const Text('Control Panel'),
        ),
        OutlinedButton.icon(
          onPressed: () => _panelKey.currentState?.refreshCurrentTab(),
          icon: TraqIcon(AppAssets.iconRefresh, size: 14),
          label: const Text('Refresh'),
        ),
        FilledButton.icon(
          onPressed: () => _panelKey.currentState?.showScheduleJobDialog(),
          icon: TraqIcon(AppAssets.iconClock, size: 14),
          label: const Text('Schedule Job'),
        ),
      ],
      child: JobQueuePanel(
        key: _panelKey,
        embedded: true,
      ),
    );
  }
}
