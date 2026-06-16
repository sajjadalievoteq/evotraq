import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';


class AggregationEventQuickFilterResult {
  const AggregationEventQuickFilterResult({
    this.action,
    this.disposition,
    this.cleared = false,
  });

  final String? action;
  final String? disposition;
  final bool cleared;
}


class AggregationEventQuickFilterDialog extends StatefulWidget {
  const AggregationEventQuickFilterDialog({
    super.key,
    this.selectedAction,
    this.selectedDisposition,
  });

  final String? selectedAction;
  final String? selectedDisposition;

  static Future<AggregationEventQuickFilterResult?> open(
    BuildContext context, {
    String? selectedAction,
    String? selectedDisposition,
  }) {
    return showDialog<AggregationEventQuickFilterResult>(
      context: context,
      builder: (_) => AggregationEventQuickFilterDialog(
        selectedAction: selectedAction,
        selectedDisposition: selectedDisposition,
      ),
    );
  }

  @override
  State<AggregationEventQuickFilterDialog> createState() =>
      _AggregationEventQuickFilterDialogState();
}

class _AggregationEventQuickFilterDialogState
    extends State<AggregationEventQuickFilterDialog> {
  String? _action;
  String? _disposition;

  static const _actions = ['ADD', 'OBSERVE', 'DELETE'];
  static const _dispositions = [
    'in_progress',
    'active',
    'inactive',
    'expired',
    'recalled',
    'damaged',
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
      title: const Text(AggregationEventUiConstants.dialogQuickFiltersTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Action',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _actions.map((a) {
                  final selected = _action == a;
                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _action = selected ? null : a),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Disposition',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dispositions.map((d) {
                  final selected = _disposition == d;
                  final label =
                      AggregationEventUiConstants.friendlyDisposition(d);
                  return FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _disposition = selected ? null : d),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const AggregationEventQuickFilterResult(cleared: true),
          ),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            AggregationEventQuickFilterResult(
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
