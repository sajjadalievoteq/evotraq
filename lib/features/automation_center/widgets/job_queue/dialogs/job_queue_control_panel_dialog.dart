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
  });

  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onConfigureWorkers;
  final VoidCallback onPurge;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Job Queue Control Panel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: TraqIcon(AppAssets.iconMinus),
            title: const Text('Pause Processing'),
            onTap: () {
              Navigator.of(context).pop();
              onPause();
            },
          ),
          ListTile(
            leading: TraqIcon(AppAssets.iconArrowR),
            title: const Text('Resume Processing'),
            onTap: () {
              Navigator.of(context).pop();
              onResume();
            },
          ),
          ListTile(
            leading: TraqIcon(AppAssets.iconTune),
            title: const Text('Configure Worker Pool'),
            onTap: () {
              Navigator.of(context).pop();
              onConfigureWorkers();
            },
          ),
          ListTile(
            leading: TraqIcon(AppAssets.iconTrash),
            title: const Text('Purge Old Jobs'),
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
