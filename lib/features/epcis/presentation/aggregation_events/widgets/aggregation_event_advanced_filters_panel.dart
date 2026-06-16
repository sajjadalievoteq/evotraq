import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class AggregationEventAdvancedFiltersPanel extends StatelessWidget {
  const AggregationEventAdvancedFiltersPanel({
    super.key,
    required this.parentEpcController,
    required this.childEpcController,
    required this.locationGlnController,
    this.selectedAction,
    this.selectedBizStep,
    this.selectedDisposition,
    required this.onActionChanged,
    required this.onBizStepChanged,
    required this.onDispositionChanged,
    this.eventTimeFrom,
    this.eventTimeTo,
    required this.onEventTimeFromChanged,
    required this.onEventTimeToChanged,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController parentEpcController;
  final TextEditingController childEpcController;
  final TextEditingController locationGlnController;

  final String? selectedAction;
  final String? selectedBizStep;
  final String? selectedDisposition;
  final ValueChanged<String?> onActionChanged;
  final ValueChanged<String?> onBizStepChanged;
  final ValueChanged<String?> onDispositionChanged;

  final DateTime? eventTimeFrom;
  final DateTime? eventTimeTo;
  final ValueChanged<DateTime?> onEventTimeFromChanged;
  final ValueChanged<DateTime?> onEventTimeToChanged;

  final VoidCallback onApply;
  final VoidCallback onClear;

  static const _actions = ['ADD', 'OBSERVE', 'DELETE'];
  static const _bizSteps = [
    'packing',
    'unpacking',
    'receiving',
    'shipping',
    'storing',
    'picking',
    'stocking',
    'accepting',
  ];
  static const _dispositions = [
    'in_progress',
    'active',
    'inactive',
    'expired',
    'recalled',
    'damaged',
    'destroyed',
    'dispensed',
  ];

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initial,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Action'),
        DropdownButtonFormField<String>(
          value: selectedAction,
          decoration: const InputDecoration(
            labelText: 'Action',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any')),
            ..._actions.map((a) => DropdownMenuItem(value: a, child: Text(a))),
          ],
          onChanged: onActionChanged,
        ),

        _sectionLabel('Business Step'),
        DropdownButtonFormField<String>(
          value: selectedBizStep,
          decoration: const InputDecoration(
            labelText: 'Business step',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any')),
            ..._bizSteps.map((b) => DropdownMenuItem(
                  value: b,
                  child: Text(b[0].toUpperCase() + b.substring(1)),
                )),
          ],
          onChanged: onBizStepChanged,
        ),

        _sectionLabel('Disposition'),
        DropdownButtonFormField<String>(
          value: selectedDisposition,
          decoration: const InputDecoration(
            labelText: 'Disposition',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any')),
            ..._dispositions.map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.replaceAll('_', ' ')[0].toUpperCase() +
                      d.replaceAll('_', ' ').substring(1)),
                )),
          ],
          onChanged: onDispositionChanged,
        ),

        _sectionLabel('Parent EPC'),
        TextField(
          controller: parentEpcController,
          decoration: const InputDecoration(
            labelText: 'Parent EPC / SSCC',
            hintText: 'urn:epc:id:sscc:…',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),

        _sectionLabel('Child EPC'),
        TextField(
          controller: childEpcController,
          decoration: const InputDecoration(
            labelText: 'Child EPC / SGTIN',
            hintText: 'urn:epc:id:sgtin:…',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),

        _sectionLabel('Location GLN'),
        TextField(
          controller: locationGlnController,
          decoration: const InputDecoration(
            labelText: 'Business location GLN',
            hintText: '1234567890123',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),

        _sectionLabel('Event Time Range'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _pickDate(context, eventTimeFrom, onEventTimeFromChanged),
                child: Text(
                  eventTimeFrom == null
                      ? 'From'
                      : dateFormat.format(eventTimeFrom!),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _pickDate(context, eventTimeTo, onEventTimeToChanged),
                child: Text(
                  eventTimeTo == null ? 'To' : dateFormat.format(eventTimeTo!),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: Constants.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear all')),
            const SizedBox(width: 8),
            FilledButton(onPressed: onApply, child: const Text('Apply')),
          ],
        ),
      ],
    );
  }
}
