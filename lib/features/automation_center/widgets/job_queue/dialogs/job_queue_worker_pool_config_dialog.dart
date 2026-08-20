import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

typedef JobQueueWorkerPoolSave =
    Future<Map<String, dynamic>> Function({
      required int corePoolSize,
      required int maxPoolSize,
      required int queueCapacity,
    });

class JobQueueWorkerPoolConfigDialog extends StatefulWidget {
  const JobQueueWorkerPoolConfigDialog({
    super.key,
    required this.initialCorePoolSize,
    required this.initialMaxPoolSize,
    required this.initialQueueCapacity,
    required this.onPrefill,
    required this.onSave,
  });

  final String initialCorePoolSize;
  final String initialMaxPoolSize;
  final String initialQueueCapacity;
  final Future<Map<String, dynamic>> Function() onPrefill;
  final JobQueueWorkerPoolSave onSave;

  @override
  State<JobQueueWorkerPoolConfigDialog> createState() =>
      _JobQueueWorkerPoolConfigDialogState();
}

class _JobQueueWorkerPoolConfigDialogState
    extends State<JobQueueWorkerPoolConfigDialog> {
  late final TextEditingController _coreCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _queueCtrl;
  var _saving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _coreCtrl = TextEditingController(text: widget.initialCorePoolSize);
    _maxCtrl = TextEditingController(text: widget.initialMaxPoolSize);
    _queueCtrl = TextEditingController(text: widget.initialQueueCapacity);
    widget
        .onPrefill()
        .then((config) {
          if (!mounted) return;
          final qc = config['queueCapacity'];
          if (qc != null) _queueCtrl.text = '$qc';
          final core = config['corePoolSize'];
          if (core != null) _coreCtrl.text = '$core';
          final max = config['maxPoolSize'];
          if (max != null) _maxCtrl.text = '$max';
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _coreCtrl.dispose();
    _maxCtrl.dispose();
    _queueCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final core = int.tryParse(_coreCtrl.text.trim());
    final max = int.tryParse(_maxCtrl.text.trim());
    final queue = int.tryParse(_queueCtrl.text.trim());
    if (core == null ||
        core < 1 ||
        max == null ||
        max < 1 ||
        queue == null ||
        queue < 1) {
      setState(() => _formError = 'Enter positive integers for all fields');
      return;
    }
    if (max < core) {
      setState(() => _formError = 'Max pool size must be ≥ core pool size');
      return;
    }
    setState(() {
      _saving = true;
      _formError = null;
    });
    try {
      final result = await widget.onSave(
        corePoolSize: core,
        maxPoolSize: max,
        queueCapacity: queue,
      );
      if (!mounted) return;
      if (result['status'] == 'error') {
        setState(() {
          _saving = false;
          _formError = '${result['message'] ?? 'Configuration failed'}';
        });
        return;
      }
      Navigator.of(context).pop(result);
    } catch (e) {
      setState(() {
        _saving = false;
        _formError = 'Failed to configure worker pool: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(AppAssets.iconTune),
          const SizedBox(width: TraqSpacing.sm),
          const Text('Configure Worker Pool'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _coreCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Core pool size',
                border: OutlineInputBorder(),
                helperText: 'Workers kept ready for normal demand',
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            TextField(
              controller: _maxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max pool size',
                border: OutlineInputBorder(),
                helperText: 'Upper limit during peak demand',
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            TextField(
              controller: _queueCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Queue capacity',
                border: OutlineInputBorder(),
                helperText: 'Maximum number of waiting jobs',
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: TraqSpacing.md),
              Text(
                _formError!,
                style: TextStyle(color: AppColorMapper.errorColor(context)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply Configuration'),
        ),
      ],
    );
  }
}
