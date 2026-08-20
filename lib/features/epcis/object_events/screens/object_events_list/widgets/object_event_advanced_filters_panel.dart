import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_events_list/widgets/object_event_date_range_row.dart';

class ObjectEventAdvancedFiltersPanel extends StatelessWidget {
  const ObjectEventAdvancedFiltersPanel({
    super.key,
    required this.epcController,
    required this.locationGlnController,
    required this.availableBizSteps,
    required this.availableDispositions,
    this.isVocabularyLoading = false,
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

  final List<CbvVocabularyItem> availableBizSteps;
  final List<CbvVocabularyItem> availableDispositions;
  final bool isVocabularyLoading;

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
              .map((a) => DropdownMenuItem(value: a, child: Text(a ?? 'All')))
              .toList(),
          onChanged: onActionChanged,
        ),
        const SizedBox(height: 12),

        if (isVocabularyLoading)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              labelText: 'Business Step',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            value: selectedBizStep,
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...availableBizSteps.map(
                (item) =>
                    DropdownMenuItem(value: item.urn, child: Text(item.label)),
              ),
            ],
            onChanged: onBizStepChanged,
          ),
        const SizedBox(height: 12),

        if (isVocabularyLoading)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              labelText: 'Disposition',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            value: selectedDisposition,
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...availableDispositions.map(
                (item) =>
                    DropdownMenuItem(value: item.urn, child: Text(item.label)),
              ),
            ],
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

        ObjectEventDateRangeRow(
          label: 'From',
          value: eventTimeFrom,
          onChanged: onEventTimeFromChanged,
        ),
        const SizedBox(height: 8),
        ObjectEventDateRangeRow(
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
