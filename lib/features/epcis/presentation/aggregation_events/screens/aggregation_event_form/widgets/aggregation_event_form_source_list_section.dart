import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class AggregationEventFormSourceListSection extends StatelessWidget {
  const AggregationEventFormSourceListSection({
    super.key,
    required this.sourceListControllers,
    required this.onAddSourceEntry,
    required this.onRemoveSourceEntry,
  });

  final List<MapEntry<TextEditingController, TextEditingController>>
      sourceListControllers;
  final VoidCallback onAddSourceEntry;
  final ValueChanged<int> onRemoveSourceEntry;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Source List',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sourceListControllers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No sources added. Tap "Add Source" to specify where products came from.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ...sourceListControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Source #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => onRemoveSourceEntry(index),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Source Type *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      value: controllers.key.text.isNotEmpty
                          ? controllers.key.text
                          : null,
                      items: ['owning_party', 'possessing_party', 'location']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controllers.key.text = v;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controllers.value,
                      decoration: const InputDecoration(
                        labelText: 'Source Value *',
                        hintText: 'urn:epc:id:sgln:… or GLN',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (controllers.key.text.isNotEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Source value is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onAddSourceEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Source'),
          ),
        ],
      ),
    );
  }
}
