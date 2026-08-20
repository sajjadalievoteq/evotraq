import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class SgtinDecommissionDialog extends StatefulWidget {
  const SgtinDecommissionDialog({super.key, required this.onConfirm});

  final ValueChanged<String> onConfirm;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => SgtinDecommissionDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<SgtinDecommissionDialog> createState() =>
      _SgtinDecommissionDialogState();
}

class _SgtinDecommissionDialogState extends State<SgtinDecommissionDialog> {
  String _reason = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decommission SGTIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please provide a reason for decommissioning:'),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => _reason = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorMapper.errorColor(context),
          ),
          onPressed: () {
            if (_reason.isEmpty) return;
            Navigator.pop(context);
            widget.onConfirm(_reason);
          },
          child: const Text('Decommission'),
        ),
      ],
    );
  }
}
