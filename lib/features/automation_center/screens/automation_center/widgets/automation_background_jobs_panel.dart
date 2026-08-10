import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';

class AutomationBackgroundJobsPanel extends StatefulWidget {
  const AutomationBackgroundJobsPanel({super.key});

  @override
  State<AutomationBackgroundJobsPanel> createState() =>
      _AutomationBackgroundJobsPanelState();
}

class _AutomationBackgroundJobsPanelState
    extends State<AutomationBackgroundJobsPanel> {
  final _panelKey = GlobalKey<JobQueuePanelState>();

  @override
  Widget build(BuildContext context) {
    return AutomationWorkbenchPanel(
      title: 'Job Operations',
      actions: [
        OutlinedButton.icon(
          onPressed: () => _panelKey.currentState?.showControlPanel(),
          icon: TraqIcon(AppAssets.iconTune, size: 14),
          label: const Text('Queue Controls'),
        ),
        OutlinedButton.icon(
          onPressed: () => _panelKey.currentState?.refreshCurrentTab(),
          icon: TraqIcon(AppAssets.iconRefresh, size: 14),
          label: const Text('Refresh'),
        ),
        FilledButton.icon(
          onPressed: () => _panelKey.currentState?.showScheduleJobDialog(),
          icon: TraqIcon(AppAssets.iconClock, size: 14),
          label: const Text('Run Job'),
        ),
      ],
      child: JobQueuePanel(key: _panelKey, embedded: true),
    );
  }
}
