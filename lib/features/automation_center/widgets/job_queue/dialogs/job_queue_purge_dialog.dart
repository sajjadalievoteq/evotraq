import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JobQueuePurgeDialog extends StatefulWidget {
  const JobQueuePurgeDialog({super.key, required this.onPurge});

  final Future<Map<String, dynamic>> Function(int retentionDays) onPurge;

  @override
  State<JobQueuePurgeDialog> createState() => _JobQueuePurgeDialogState();
}

class _JobQueuePurgeDialogState extends State<JobQueuePurgeDialog> {
  final _daysCtrl = TextEditingController(text: '30');
  var _purging = false;
  String? _formError;

  @override
  void dispose() {
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final days = int.tryParse(_daysCtrl.text.trim());
    if (days == null || days < 1) {
      setState(
        () => _formError = 'Enter a positive number of retention days',
      );
      return;
    }
    setState(() {
      _purging = true;
      _formError = null;
    });
    try {
      final result = await widget.onPurge(days);
      if (!mounted) return;
      Navigator.of(context).pop({'days': days, 'result': result});
    } catch (e) {
      setState(() {
        _purging = false;
        _formError = 'Failed to purge jobs: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(
            AppAssets.iconTrash,
            color: AppColorMapper.errorColor(context),
          ),
          const SizedBox(width: TraqSpacing.sm),
          const Text('Purge Old Jobs'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permanently remove completed job history older than the '
              'retention period. This cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TraqSpacing.lg),
            TextField(
              controller: _daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Retain jobs from the last N days',
                border: OutlineInputBorder(),
                helperText: 'Jobs ending before this window are purged',
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
          onPressed: _purging ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColorMapper.errorColor(context),
          ),
          onPressed: _purging ? null : _confirm,
          child: _purging
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Purge'),
        ),
      ],
    );
  }
}
