import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JobQueueControlPanelDialog extends StatelessWidget {
  const JobQueueControlPanelDialog({
    super.key,
    required this.onPause,
    required this.onResume,
    required this.onConfigureWorkers,
    required this.onPurge,
    required this.processingPaused,
  });

  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onConfigureWorkers;
  final VoidCallback onPurge;
  final bool processingPaused;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Queue Controls'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: TraqIcon(
              processingPaused ? AppAssets.iconArrowR : AppAssets.iconMinus,
            ),
            title: Text(
              processingPaused ? 'Resume Processing' : 'Pause Processing',
            ),
            subtitle: Text(
              processingPaused
                  ? 'Allow waiting jobs to start again.'
                  : 'Running jobs continue; waiting jobs will not start.',
            ),
            onTap: () {
              Navigator.of(context).pop();
              processingPaused ? onResume() : onPause();
            },
          ),
          ListTile(
            leading: TraqIcon(AppAssets.iconTune),
            title: const Text('Configure Worker Pool'),
            subtitle: const Text('Set worker and queue capacity limits.'),
            onTap: () {
              Navigator.of(context).pop();
              onConfigureWorkers();
            },
          ),
          ListTile(
            leading: TraqIcon(AppAssets.iconTrash),
            title: const Text('Delete Old Job History'),
            subtitle: const Text('Remove completed records by retention age.'),
            onTap: () {
              Navigator.of(context).pop();
              onPurge();
            },
          ),
        ],
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
