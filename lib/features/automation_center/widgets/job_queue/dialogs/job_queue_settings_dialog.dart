import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JobQueueSettingsResult {
  const JobQueueSettingsResult({
    required this.autoRefresh,
    required this.intervalSeconds,
  });

  final bool autoRefresh;
  final int intervalSeconds;
}

class JobQueueSettingsDialog extends StatefulWidget {
  const JobQueueSettingsDialog({
    super.key,
    required this.initialAutoRefresh,
    required this.initialIntervalSeconds,
  });

  final bool initialAutoRefresh;
  final int initialIntervalSeconds;

  @override
  State<JobQueueSettingsDialog> createState() => _JobQueueSettingsDialogState();
}

class _JobQueueSettingsDialogState extends State<JobQueueSettingsDialog> {
  late bool _autoRefresh;
  late final TextEditingController _intervalCtrl;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _autoRefresh = widget.initialAutoRefresh;
    _intervalCtrl = TextEditingController(
      text: '${widget.initialIntervalSeconds}',
    );
  }

  @override
  void dispose() {
    _intervalCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final interval = int.tryParse(_intervalCtrl.text.trim());
    if (interval == null || interval < 2 || interval > 120) {
      setState(
        () => _formError =
            'Interval must be an integer between 2 and 120',
      );
      return;
    }
    Navigator.of(context).pop(
      JobQueueSettingsResult(
        autoRefresh: _autoRefresh,
        intervalSeconds: interval,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(AppAssets.iconSettings),
          const SizedBox(width: TraqSpacing.sm),
          const Text('Queue Settings'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto refresh'),
              subtitle: const Text(
                'Periodically reload the active tab',
              ),
              value: _autoRefresh,
              onChanged: (v) => setState(() => _autoRefresh = v),
            ),
            const SizedBox(height: TraqSpacing.md),
            TextField(
              controller: _intervalCtrl,
              enabled: _autoRefresh,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Refresh interval (seconds)',
                border: OutlineInputBorder(),
                helperText: 'Between 2 and 120 seconds',
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: TraqSpacing.md),
              Text(
                _formError!,
                style: TextStyle(
                  color: AppColorMapper.errorColor(context),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
