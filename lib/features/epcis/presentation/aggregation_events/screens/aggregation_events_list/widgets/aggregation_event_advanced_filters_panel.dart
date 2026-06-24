import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';

class AggregationEventAdvancedFiltersPanel extends StatelessWidget {
  const AggregationEventAdvancedFiltersPanel({
    super.key,
    required this.parentEpcController,
    required this.childEpcController,
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

  final TextEditingController parentEpcController;
  final TextEditingController childEpcController;
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

  static const _actions = ['ADD', 'OBSERVE', 'DELETE'];

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  String _capitalizeLabel(String label) {
    if (label.isEmpty) return label;
    return label[0].toUpperCase() + label.substring(1);
  }

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
        if (isVocabularyLoading)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String>(
            value: selectedBizStep,
            decoration: const InputDecoration(
              labelText: 'Business step',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any')),
              ...availableBizSteps.map((item) => DropdownMenuItem(
                    value: item.code,
                    child: Text(_capitalizeLabel(item.label)),
                  )),
            ],
            onChanged: onBizStepChanged,
          ),

        _sectionLabel('Disposition'),
        if (isVocabularyLoading)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String>(
            value: selectedDisposition,
            decoration: const InputDecoration(
              labelText: 'Disposition',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any')),
              ...availableDispositions.map((item) => DropdownMenuItem(
                    value: item.code,
                    child: Text(_capitalizeLabel(item.label)),
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
