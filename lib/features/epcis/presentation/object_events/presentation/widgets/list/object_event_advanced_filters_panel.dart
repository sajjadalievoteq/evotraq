import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_shared_ui_constants.dart';

class ObjectEventAdvancedFiltersPanel extends StatelessWidget {
  const ObjectEventAdvancedFiltersPanel({
    super.key,
    required this.epcController,
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

  final TextEditingController epcController;
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

  static const _actions = [null, 'ADD', 'OBSERVE', 'DELETE'];
  static const _bizSteps = [
    null,
    'urn:epcglobal:cbv:bizstep:commissioning',
    'urn:epcglobal:cbv:bizstep:shipping',
    'urn:epcglobal:cbv:bizstep:receiving',
    'urn:epcglobal:cbv:bizstep:packing',
    'urn:epcglobal:cbv:bizstep:unpacking',
    'urn:epcglobal:cbv:bizstep:inspecting',
    'urn:epcglobal:cbv:bizstep:storing',
    'urn:epcglobal:cbv:bizstep:decommissioning',
    'urn:epcglobal:cbv:bizstep:destroying',
  ];
  static const _dispositions = [
    null,
    'urn:epcglobal:cbv:disp:active',
    'urn:epcglobal:cbv:disp:in_progress',
    'urn:epcglobal:cbv:disp:in_transit',
    'urn:epcglobal:cbv:disp:expired',
    'urn:epcglobal:cbv:disp:damaged',
    'urn:epcglobal:cbv:disp:destroyed',
    'urn:epcglobal:cbv:disp:recalled',
    'urn:epcglobal:cbv:disp:retail_sold',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String?>(
          decoration: const InputDecoration(
            labelText: 'Action',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          value: selectedAction,
          items: _actions
              .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(a ?? 'All'),
                  ))
              .toList(),
          onChanged: onActionChanged,
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String?>(
          decoration: const InputDecoration(
            labelText: 'Business Step',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          value: selectedBizStep,
          items: _bizSteps
              .map((b) => DropdownMenuItem(
                    value: b,
                    child: Text(
                      b == null
                          ? 'All'
                          : ObjectEventSharedUiConstants.friendlyBizStep(b),
                    ),
                  ))
              .toList(),
          onChanged: onBizStepChanged,
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String?>(
          decoration: const InputDecoration(
            labelText: 'Disposition',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          value: selectedDisposition,
          items: _dispositions
              .map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      d == null
                          ? 'All'
                          : ObjectEventSharedUiConstants.friendlyDisposition(d),
                    ),
                  ))
              .toList(),
          onChanged: onDispositionChanged,
        ),
        const SizedBox(height: 12),

        TextField(
          controller: epcController,
          decoration: const InputDecoration(
            labelText: 'EPC',
            hintText: 'Filter by EPC code',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: locationGlnController,
          decoration: const InputDecoration(
            labelText: 'Location GLN',
            hintText: 'Enter GLN code',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        _DateRangeRow(
          label: 'From',
          value: eventTimeFrom,
          onChanged: onEventTimeFromChanged,
        ),
        const SizedBox(height: 8),
        _DateRangeRow(
          label: 'To',
          value: eventTimeTo,
          onChanged: onEventTimeToChanged,
        ),
        const SizedBox(height: 16),

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

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.label,
    this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onChanged(picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                suffixIcon: Icon(Icons.calendar_today, size: 16),
              ),
              child: Text(
                value != null
                    ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
                    : 'Select date',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        if (value != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () => onChanged(null),
          ),
      ],
    );
  }
}
