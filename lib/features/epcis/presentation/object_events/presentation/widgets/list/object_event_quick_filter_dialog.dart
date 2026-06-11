import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/list/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_shared_ui_constants.dart';

class ObjectEventQuickFilterResult {
  const ObjectEventQuickFilterResult({
    this.action,
    this.disposition,
    this.cleared = false,
  });

  final String? action;
  final String? disposition;
  final bool cleared;
}

class ObjectEventQuickFilterDialog extends StatefulWidget {
  const ObjectEventQuickFilterDialog({
    super.key,
    this.selectedAction,
    this.selectedDisposition,
  });

  final String? selectedAction;
  final String? selectedDisposition;

  static Future<ObjectEventQuickFilterResult?> open(
    BuildContext context, {
    String? selectedAction,
    String? selectedDisposition,
  }) {
    return showDialog<ObjectEventQuickFilterResult>(
      context: context,
      builder: (_) => ObjectEventQuickFilterDialog(
        selectedAction: selectedAction,
        selectedDisposition: selectedDisposition,
      ),
    );
  }

  @override
  State<ObjectEventQuickFilterDialog> createState() =>
      _ObjectEventQuickFilterDialogState();
}

class _ObjectEventQuickFilterDialogState
    extends State<ObjectEventQuickFilterDialog> {
  String? _action;
  String? _disposition;

  static const _actions = ['ADD', 'OBSERVE', 'DELETE'];
  static const _dispositions = [
    'urn:epcglobal:cbv:disp:active',
    'urn:epcglobal:cbv:disp:in_progress',
    'urn:epcglobal:cbv:disp:in_transit',
    'urn:epcglobal:cbv:disp:expired',
    'urn:epcglobal:cbv:disp:damaged',
    'urn:epcglobal:cbv:disp:destroyed',
    'urn:epcglobal:cbv:disp:recalled',
  ];

  @override
  void initState() {
    super.initState();
    _action = widget.selectedAction;
    _disposition = widget.selectedDisposition;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ObjectEventListUiConstants.dialogQuickFiltersTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Action', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _actions.map((a) {
                return FilterChip(
                  label: Text(a),
                  selected: _action == a,
                  onSelected: (v) => setState(() => _action = v ? a : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Disposition', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _dispositions.map((d) {
                final label =
                    ObjectEventSharedUiConstants.friendlyDisposition(d);
                return FilterChip(
                  label: Text(label),
                  selected: _disposition == d,
                  onSelected: (v) =>
                      setState(() => _disposition = v ? d : null),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context)
              .pop(const ObjectEventQuickFilterResult(cleared: true)),
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ObjectEventQuickFilterResult(
              action: _action,
              disposition: _disposition,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
